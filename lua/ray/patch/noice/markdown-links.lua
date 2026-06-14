-- Minimal link-aware Noice markdown rendering.
-- Fixes LSP hover docs that arrive as hard-wrapped Markdown paragraphs by
-- reflowing prose before Noice splits it into one rendered line per source line.

local M = {}

local hacks = require("ray.utils.hacks")

local LINK_HL = "@markup.link"

local function trim(text)
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalize_label(label)
  return trim(label):gsub("%s+", " "):lower()
end

local function normalize_url(url)
  if not url then
    return nil
  end

  return trim(url):match("^<(.+)>$") or trim(url)
end

local function plain_label(label)
  return label:gsub("`([^`]*)`", "%1"):gsub("`", "")
end

local function set_reference(references, label, url)
  url = normalize_url(url)

  if not (label and url and url ~= "") then
    return
  end

  references[normalize_label(label)] = url
  references[normalize_label(plain_label(label))] = url
end

local function parse_reference_definition(line)
  local label, url = line:match("^%s*%[(.-)%]:%s*<([^>]+)>")

  if label then
    return label, url
  end

  return line:match("^%s*%[(.-)%]:%s*(%S+)")
end

local function parse_reference_definitions(text)
  local references = {}

  for line in (text .. "\n"):gmatch("([^\r\n]*)\r?\n") do
    local label, url = parse_reference_definition(line)

    if label and not label:match("^%^") then
      set_reference(references, label, url)
    end
  end

  return references
end

local function is_reference_definition(line)
  local label = parse_reference_definition(line)

  return label ~= nil and not label:match("^%^")
end

local function fence_marker(line)
  local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")

  if marker and #marker >= 3 then
    return marker:sub(1, 1), #marker
  end

  return nil, nil
end

local function is_fence_close(line, fence_char, fence_len)
  local char, len = fence_marker(line)

  return char == fence_char and len >= fence_len
end

local function is_blank(line)
  return line:match("^%s*$") ~= nil
end

local function is_indented_code(line)
  return (line:sub(1, 4) == "    " or line:sub(1, 1) == "\t") and not is_blank(line)
end

local function is_structural_line(line)
  return line:match("^%s*#")
    or line:match("^%s*>")
    or line:match("^%s*[%-%+%*]%s+")
    or line:match("^%s*%d+[%.%)]%s+")
    or line:match("^%s*|.*|")
    or line:match("^%s*%[.-%]:%s*")
    or line:match("^%s*[-*_][%s%-*_]*$")
end

local function reflow(text)
  local out = {}
  local paragraph = {}
  local in_fence = false
  local fence_char
  local fence_len

  local function emit(line)
    out[#out + 1] = line
  end

  local function flush_paragraph()
    if #paragraph == 0 then
      return
    end

    emit(table.concat(paragraph, " "))
    paragraph = {}
  end

  for line in (text:gsub("\r", "") .. "\n"):gmatch("([^\n]*)\n") do
    if in_fence then
      emit(line)

      if is_fence_close(line, fence_char, fence_len) then
        in_fence = false
      end
    else
      local char, len = fence_marker(line)

      if char then
        flush_paragraph()
        emit(line)
        in_fence = true
        fence_char = char
        fence_len = len
      elseif is_blank(line) then
        flush_paragraph()
        emit(line)
      elseif is_indented_code(line) or is_structural_line(line) then
        flush_paragraph()
        emit(line)
      else
        paragraph[#paragraph + 1] = trim(line)
      end
    end
  end

  flush_paragraph()

  return table.concat(out, "\n"):gsub("\n$", "")
end

local function node_text(text, node)
  local _, start_col, _, end_col = node:range()

  return text:sub(start_col + 1, end_col)
end

local function strip_reference_brackets(label)
  return label:match("^%[(.*)%]$") or label
end

local function reference_url(references, label)
  return references[normalize_label(label)] or references[normalize_label(plain_label(label))]
end

local function child(node, node_type)
  for child_node in node:iter_children() do
    if child_node:type() == node_type then
      return child_node
    end
  end

  return nil
end

local function collect_links(text, node, links, references)
  local node_type = node:type()

  if node_type == "inline_link" or node_type == "image" then
    local label_type = node_type == "image" and "image_description" or "link_text"
    local label_node = child(node, label_type)
    local destination_node = child(node, "link_destination")

    if label_node and destination_node then
      local _, full_start, _, full_end = node:range()
      local _, label_start, _, label_end = label_node:range()

      links[#links + 1] = {
        from = full_start,
        to = full_end,
        label = text:sub(label_start + 1, label_end),
        url = normalize_url(node_text(text, destination_node)),
      }
    end

    return
  elseif
    node_type == "shortcut_link"
    or node_type == "collapsed_reference_link"
    or node_type == "full_reference_link"
  then
    local label_node = child(node, "link_text")
    local reference_node = child(node, "link_label")

    if label_node then
      local _, full_start, _, full_end = node:range()
      local _, label_start, _, label_end = label_node:range()
      local label = text:sub(label_start + 1, label_end)
      local reference = reference_node and strip_reference_brackets(node_text(text, reference_node)) or label
      local url = reference_url(references, reference) or reference_url(references, label)

      if url then
        links[#links + 1] = {
          from = full_start,
          to = full_end,
          label = label,
          url = url,
        }
      end
    end

    return
  end

  for child in node:iter_children() do
    collect_links(text, child, links, references)
  end
end

local function parse_links(text, references)
  local parser = vim.treesitter.get_string_parser(text, "markdown_inline")
  local ok, trees = pcall(parser.parse, parser)

  if not (ok and trees and trees[1]) then
    return {}
  end

  local links = {}

  collect_links(text, trees[1]:root(), links, references or {})
  table.sort(links, function(a, b)
    return a.from < b.from
  end)

  return links
end

local function render_line(text, references)
  local parts = {}
  local links = {}
  local source_pos = 1
  local output_len = 0

  local function append(chunk)
    if chunk == "" then
      return
    end

    parts[#parts + 1] = chunk
    output_len = output_len + #chunk
  end

  for _, link in ipairs(parse_links(text, references)) do
    if link.from + 1 >= source_pos then
      append(text:sub(source_pos, link.from))

      local from = output_len + 1

      append(link.label)
      links[#links + 1] = { from = from, to = output_len, url = link.url }
      source_pos = link.to + 1
    end
  end

  append(text:sub(source_pos))

  return table.concat(parts), links
end

local function attach_links(bufnr, lines, linenr_start)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local existing = linenr_start ~= 1
      and type(vim.b[bufnr]._ray_markdown_links) == "table"
      and vim.b[bufnr]._ray_markdown_links
    or {}

  for index, line in ipairs(lines or {}) do
    existing[tostring((linenr_start or 1) + index - 1)] = line._ray_markdown_links
  end

  vim.b[bufnr]._ray_markdown_links = existing
end

local function set_line_width(line, text)
  if not line then
    return
  end

  line._ray_markdown_width_source = text
  line._ray_markdown_visual_width = vim.api.nvim_strwidth(text)
end

local function format_markdown(markdown, message, text, opts)
  local noice_text = require("noice.text")
  local normalized = reflow(text)
  local references = parse_reference_definitions(normalized)
  local blocks = markdown.parse(normalized, opts or {})
  local md_lines = 0

  local function emit_md()
    if md_lines == 0 then
      return
    end

    message:append(noice_text.syntax("markdown", md_lines))
    md_lines = 0
  end

  for _, block in ipairs(blocks) do
    if block.code then
      emit_md()
      message:newline()

      for index, line in ipairs(block.code) do
        message:append(line)
        set_line_width(message:last_line(), line)

        if index == #block.code then
          message:append(noice_text.syntax(block.lang, #block.code))
        else
          message:newline()
        end
      end
    elseif is_reference_definition(block.line) then
      -- Keep reference definitions available for links, but don't render them.
    else
      message:newline()

      if markdown.is_rule(block.line) then
        markdown.horizontal_line(message)
      else
        local line, links = render_line(block.line, references)

        message:append(line)

        local last_line = message:last_line()

        set_line_width(last_line, line)

        if last_line then
          last_line._ray_markdown_links = #links > 0 and links or nil
        end

        for _, highlight in ipairs(markdown.get_highlights(line)) do
          message:append(highlight)
        end

        for _, link in ipairs(links) do
          message:append(noice_text("", {
            hl_group = LINK_HL,
            col = link.from - 1,
            length = link.to - link.from + 1,
            priority = 120,
          }))
        end
      end

      md_lines = md_lines + 1
    end
  end

  emit_md()
end

local function patch_keys(markdown)
  hacks.replace(markdown, "noice.markdown.keys", "keys", function(buf)
    if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].markdown_keys then
      return
    end

    local function map(lhs)
      vim.keymap.set("n", lhs, function()
        local pos = vim.api.nvim_win_get_cursor(0)
        local row = pos[1]
        local col = pos[2] + 1
        local links = vim.b[buf]._ray_markdown_links
        local line_links = type(links) == "table" and links[tostring(row)] or nil

        for _, link in ipairs(type(line_links) == "table" and line_links or {}) do
          if col >= link.from and col <= link.to then
            return require("noice.util").open(link.url)
          end
        end

        local line = vim.api.nvim_get_current_line()
        local config = require("noice.config")

        for pattern, handler in pairs(config.options.markdown.hover) do
          local from = 1
          local to, url

          while from do
            from, to, url = line:find(pattern, from)

            if from and col >= from and col <= to then
              return handler(url)
            end

            if from then
              from = to + 1
            end
          end
        end

        vim.api.nvim_feedkeys(lhs, "n", false)
      end, { buffer = buf, silent = true })
    end

    map("gx")
    map("K")

    vim.b[buf].markdown_keys = true
  end)
end

function M.patch()
  local markdown = require("noice.text.markdown")

  hacks.replace(markdown, "noice.markdown.format", "format", function(message, text, opts)
    format_markdown(markdown, message, text, opts)
  end)

  patch_keys(markdown)

  hacks.wrap(require("noice.text.block"), "noice.markdown.block.render", "render", function(render)
    return function(self, bufnr, ns_id, linenr_start, linenr_end)
      render(self, bufnr, ns_id, linenr_start, linenr_end)
      attach_links(bufnr, self._lines, linenr_start)
    end
  end)
end

return M
