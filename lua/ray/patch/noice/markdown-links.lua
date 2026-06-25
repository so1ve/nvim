-- Noice markdown renderer for LSP docs.
--
-- Split markdown at block level: prose stays native markdown so inline syntax
-- like **strong**, ~~strike~~, and `code` still works; fenced code blocks are
-- rendered with their actual language, so Rust brackets never go through
-- markdown_inline highlighting. Links are shortened before entering the buffer
-- so hidden URLs do not affect wrapping, while gx/K still open the targets.

local M = {}

local hacks = require("ray.patch.hacks")

local LINK_HL = "@markup.link"

local function trim(text)
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalize_label(label)
  return trim(label):gsub("`([^`]*)`", "%1"):gsub("`", ""):gsub("%s+", " "):lower()
end

local function normalize_url(url)
  return url and (trim(url):match("^<(.+)>$") or trim(url)) or nil
end

local function reference_definition(line)
  local label, url = line:match("^%s*%[(.-)%]:%s*<([^>]+)>")

  if label then
    return label, url
  end

  return line:match("^%s*%[(.-)%]:%s*(%S+)")
end

local function is_reference_definition(line)
  local label = reference_definition(line)

  return label ~= nil and not label:match("^%^")
end

local function references_from(text)
  local references = {}

  for line in (text .. "\n"):gmatch("([^\r\n]*)\r?\n") do
    local label, url = reference_definition(line)

    if label and not label:match("^%^") then
      url = normalize_url(url)

      if url and url ~= "" then
        references[normalize_label(label)] = url
      end
    end
  end

  return references
end

local function fence_marker(line)
  local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")

  if marker and #marker >= 3 then
    return marker:sub(1, 1), #marker
  end
end

local function is_blank(line)
  return line:match("^%s*$") ~= nil
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

local function is_indented_code(line)
  return (line:sub(1, 4) == "    " or line:sub(1, 1) == "\t") and not is_blank(line)
end

local function reflow(text)
  local lines = {}
  local paragraph = {}
  local fence_char
  local fence_len

  local function flush()
    if #paragraph > 0 then
      lines[#lines + 1] = table.concat(paragraph, " ")
      paragraph = {}
    end
  end

  for line in (text:gsub("\r", "") .. "\n"):gmatch("([^\n]*)\n") do
    if fence_char then
      lines[#lines + 1] = line

      local char, len = fence_marker(line)

      if char == fence_char and len >= fence_len then
        fence_char = nil
        fence_len = nil
      end
    else
      local char, len = fence_marker(line)

      if char then
        flush()
        lines[#lines + 1] = line
        fence_char = char
        fence_len = len
      elseif is_blank(line) or is_structural_line(line) or is_indented_code(line) then
        flush()
        lines[#lines + 1] = line
      else
        paragraph[#paragraph + 1] = trim(line)
      end
    end
  end

  flush()

  return table.concat(lines, "\n"):gsub("\n$", "")
end

local function node_text(source, node)
  local _, start_col, _, end_col = node:range()

  return source:sub(start_col + 1, end_col)
end

local function child(node, node_type)
  for child_node in node:iter_children() do
    if child_node:type() == node_type then
      return child_node
    end
  end
end

local function label_text(source, node)
  local node_type = node:type()
  local label = child(node, node_type == "image" and "image_description" or "link_text")

  return label and node_text(source, label) or nil
end

local function reference_url(references, label)
  return references[normalize_label(label)]
end

local function collect_links(source, node, references, links)
  local node_type = node:type()

  if node_type == "inline_link" or node_type == "image" then
    local label = label_text(source, node)
    local destination = child(node, "link_destination")

    if label and destination then
      local _, from, _, to = node:range()

      links[#links + 1] = {
        from = from + 1,
        to = to,
        label = label,
        url = normalize_url(node_text(source, destination)),
      }
    end

    return
  end

  if node_type == "shortcut_link" or node_type == "collapsed_reference_link" or node_type == "full_reference_link" then
    local label = label_text(source, node)
    local reference = child(node, "link_label")
    local reference_label = reference and node_text(source, reference):match("^%[(.*)%]$") or label
    local url = label and (reference_url(references, reference_label) or reference_url(references, label))

    if url then
      local _, from, _, to = node:range()

      links[#links + 1] = { from = from + 1, to = to, label = label, url = url }
    end

    return
  end

  for child_node in node:iter_children() do
    collect_links(source, child_node, references, links)
  end
end

local function parse_links(line, references)
  local parser = vim.treesitter.get_string_parser(line, "markdown_inline")
  local ok, trees = pcall(parser.parse, parser)

  if not (ok and trees and trees[1]) then
    return {}
  end

  local links = {}

  collect_links(line, trees[1]:root(), references, links)
  table.sort(links, function(left, right)
    return left.from < right.from
  end)

  return links
end

local function render_links(line, references)
  local links = parse_links(line, references)

  if #links == 0 then
    return line, nil
  end

  local parts = {}
  local rendered_links = {}
  local source_pos = 1
  local output_col = 0

  local function append(text)
    if text ~= "" then
      parts[#parts + 1] = text
      output_col = output_col + #text
    end
  end

  for _, link in ipairs(links) do
    if link.from >= source_pos then
      append(line:sub(source_pos, link.from - 1))

      local from = output_col + 1

      append(link.label)
      rendered_links[#rendered_links + 1] = { from = from, to = output_col, url = link.url }
      source_pos = link.to + 1
    end
  end

  append(line:sub(source_pos))

  return table.concat(parts), rendered_links
end

local function set_line_width(line, text)
  if line then
    line._ray_markdown_width_source = text
    line._ray_markdown_visual_width = vim.api.nvim_strwidth(text)
  end
end

local function add_link_highlights(message, links)
  local noice_text = require("noice.text")

  for _, link in ipairs(links or {}) do
    message:append(noice_text("", {
      hl_group = LINK_HL,
      col = link.from - 1,
      length = link.to - link.from + 1,
      priority = 120,
    }))
  end
end

local function append_code_block(message, block)
  local noice_text = require("noice.text")

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
end

local function append_markdown_syntax(message, line_count)
  if line_count > 0 then
    message:append(require("noice.text").syntax("markdown", line_count))
  end
end

local function append_prose(markdown, message, line, references)
  message:newline()

  if markdown.is_rule(line) then
    markdown.horizontal_line(message)
    return
  end

  local rendered, links = render_links(line, references)

  message:append(rendered)
  set_line_width(message:last_line(), rendered)

  if links then
    message:last_line()._ray_markdown_links = links
  end

  for _, highlight in ipairs(markdown.get_highlights(rendered)) do
    message:append(highlight)
  end

  add_link_highlights(message, links)
end

local function format_markdown(markdown, message, text, opts)
  local normalized = reflow(text)
  local references = references_from(normalized)
  local markdown_lines = 0

  for _, block in ipairs(markdown.parse(normalized, opts or {})) do
    if block.code then
      append_markdown_syntax(message, markdown_lines)
      markdown_lines = 0
      append_code_block(message, block)
    elseif not is_reference_definition(block.line) then
      append_prose(markdown, message, block.line, references)
      markdown_lines = markdown_lines + 1
    end
  end

  append_markdown_syntax(message, markdown_lines)
end

local function attach_links(bufnr, lines, linenr_start)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local links_by_line = linenr_start ~= 1
      and type(vim.b[bufnr]._ray_markdown_links) == "table"
      and vim.b[bufnr]._ray_markdown_links
    or {}

  for index, line in ipairs(lines or {}) do
    links_by_line[tostring((linenr_start or 1) + index - 1)] = line._ray_markdown_links
  end

  vim.b[bufnr]._ray_markdown_links = links_by_line
end

local function patch_keys(markdown)
  hacks.replace(markdown, "noice.markdown.keys", "keys", function(buf)
    if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].markdown_keys then
      return
    end

    local function map(lhs)
      vim.keymap.set("n", lhs, function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local links = type(vim.b[buf]._ray_markdown_links) == "table" and vim.b[buf]._ray_markdown_links[tostring(row)]
          or nil

        for _, link in ipairs(type(links) == "table" and links or {}) do
          if col + 1 >= link.from and col + 1 <= link.to then
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

            if from and col + 1 >= from and col + 1 <= to then
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
      markdown.keys(bufnr)
    end
  end)
end

return M
