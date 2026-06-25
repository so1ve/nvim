-- Link-aware Noice markdown rendering for LSP docs.
--
-- Responsibilities:
-- 1. Reflow hard-wrapped prose before Noice parses markdown blocks.
-- 2. Render code blocks with their real language syntax.
-- 3. Render prose without markdown_inline conceal, so Rust snippets like [i32]
--    and vec![1, 2, 3] stay visible.
-- 4. Keep useful inline markdown: code spans, inline links, and reference links.

local M = {}

local hacks = require("ray.patch.hacks")

local CODE_HL = "@markup.raw"
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

local function parse_reference_definition(line)
  local label, url = line:match("^%s*%[(.-)%]:%s*<([^>]+)>")

  if label then
    return label, url
  end

  return line:match("^%s*%[(.-)%]:%s*(%S+)")
end

local function is_reference_definition(line)
  local label = parse_reference_definition(line)

  return label ~= nil and not label:match("^%^")
end

local function collect_references(text)
  local references = {}

  for line in (text .. "\n"):gmatch("([^\r\n]*)\r?\n") do
    local label, url = parse_reference_definition(line)

    if label and not label:match("^%^") then
      url = normalize_url(url)

      if url and url ~= "" then
        references[normalize_label(label)] = url
        references[normalize_label(plain_label(label))] = url
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
  local fence_char
  local fence_len

  local function flush_paragraph()
    if #paragraph > 0 then
      out[#out + 1] = table.concat(paragraph, " ")
      paragraph = {}
    end
  end

  for line in (text:gsub("\r", "") .. "\n"):gmatch("([^\n]*)\n") do
    if fence_char then
      out[#out + 1] = line

      local char, len = fence_marker(line)

      if char == fence_char and len >= fence_len then
        fence_char = nil
        fence_len = nil
      end
    else
      local char, len = fence_marker(line)

      if char then
        flush_paragraph()
        out[#out + 1] = line
        fence_char = char
        fence_len = len
      elseif is_blank(line) then
        flush_paragraph()
        out[#out + 1] = line
      elseif is_indented_code(line) or is_structural_line(line) then
        flush_paragraph()
        out[#out + 1] = line
      else
        paragraph[#paragraph + 1] = trim(line)
      end
    end
  end

  flush_paragraph()

  return table.concat(out, "\n"):gsub("\n$", "")
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

local function code_span_text(source, node)
  local delimiters = {}

  for child_node in node:iter_children() do
    if child_node:type() == "code_span_delimiter" then
      delimiters[#delimiters + 1] = child_node
    end
  end

  if #delimiters < 2 then
    return node_text(source, node):gsub("^`+", ""):gsub("`+$", "")
  end

  local open = delimiters[1]
  local close = delimiters[#delimiters]
  local _, _, _, open_end = open:range()
  local _, close_start = close:range()
  local text = source:sub(open_end + 1, close_start)

  if text:match("^%s") and text:match("%s$") and text:match("%S") then
    return text:sub(2, -2)
  end

  return text
end

local function inline_text(source, node)
  local _, start_col, _, end_col = node:range()
  local parts = {}
  local pos = start_col + 1

  local function append(text)
    if text ~= "" then
      parts[#parts + 1] = text
    end
  end

  for child_node in node:iter_children() do
    local _, child_start, _, child_end = child_node:range()

    if child_start + 1 >= pos then
      append(source:sub(pos, child_start))
      append(child_node:type() == "code_span" and code_span_text(source, child_node) or inline_text(source, child_node))
      pos = child_end + 1
    end
  end

  append(source:sub(pos, end_col))

  return table.concat(parts)
end

local function reference_url(references, label)
  return references[normalize_label(label)] or references[normalize_label(plain_label(label))]
end

local function add_link_item(items, from, to, text, url)
  if url then
    items[#items + 1] = {
      kind = "link",
      from = from,
      to = to,
      text = text,
      url = url,
    }
  end
end

local function collect_inline_items(source, node, references, items)
  local node_type = node:type()

  if node_type == "code_span" then
    local _, from, _, to = node:range()

    items[#items + 1] = {
      kind = "code",
      from = from,
      to = to,
      text = code_span_text(source, node),
    }

    return
  end

  if node_type == "inline_link" or node_type == "image" then
    local label_node = child(node, node_type == "image" and "image_description" or "link_text")
    local destination_node = child(node, "link_destination")

    if label_node and destination_node then
      local _, from, _, to = node:range()

      add_link_item(
        items,
        from,
        to,
        inline_text(source, label_node),
        normalize_url(node_text(source, destination_node))
      )
    end

    return
  end

  if node_type == "shortcut_link" or node_type == "collapsed_reference_link" or node_type == "full_reference_link" then
    local label_node = child(node, "link_text")

    if label_node then
      local reference_node = child(node, "link_label")
      local label = inline_text(source, label_node)
      local reference = reference_node and (node_text(source, reference_node):match("^%[(.*)%]$") or label) or label
      local _, from, _, to = node:range()

      add_link_item(items, from, to, label, reference_url(references, reference) or reference_url(references, label))
    end

    return
  end

  for child_node in node:iter_children() do
    collect_inline_items(source, child_node, references, items)
  end
end

local function parse_inline_items(line, references)
  local parser = vim.treesitter.get_string_parser(line, "markdown_inline")
  local ok, trees = pcall(parser.parse, parser)

  if not (ok and trees and trees[1]) then
    return {}
  end

  local items = {}

  collect_inline_items(line, trees[1]:root(), references, items)
  table.sort(items, function(left, right)
    return left.from < right.from
  end)

  return items
end

local function render_inline(line, references)
  local parts = {}
  local links = {}
  local highlights = {}
  local source_pos = 1
  local output_len = 0

  local function append(text)
    if text ~= "" then
      parts[#parts + 1] = text
      output_len = output_len + #text
    end
  end

  for _, item in ipairs(parse_inline_items(line, references)) do
    if item.from + 1 >= source_pos then
      append(line:sub(source_pos, item.from))

      local from = output_len + 1

      append(item.text)

      if item.kind == "link" then
        links[#links + 1] = { from = from, to = output_len, url = item.url }
      else
        highlights[#highlights + 1] = { from = from, to = output_len, hl_group = CODE_HL }
      end

      source_pos = item.to + 1
    end
  end

  append(line:sub(source_pos))

  return table.concat(parts), links, highlights
end

local function set_line_width(line, text)
  if line then
    line._ray_markdown_width_source = text
    line._ray_markdown_visual_width = vim.api.nvim_strwidth(text)
  end
end

local function append_highlight(message, highlight, priority)
  local noice_text = require("noice.text")

  message:append(noice_text("", {
    hl_group = highlight.hl_group,
    col = highlight.from - 1,
    length = highlight.to - highlight.from + 1,
    priority = priority,
  }))
end

local function append_prose(markdown, message, block, references)
  if markdown.is_rule(block.line) then
    markdown.horizontal_line(message)
    return
  end

  local line, links, code_spans = render_inline(block.line, references)

  message:append(line)

  local last_line = message:last_line()

  set_line_width(last_line, line)

  if last_line and #links > 0 then
    last_line._ray_markdown_links = links
  end

  for _, highlight in ipairs(markdown.get_highlights(line)) do
    message:append(highlight)
  end

  for _, highlight in ipairs(code_spans) do
    append_highlight(message, highlight, 110)
  end

  for _, link in ipairs(links) do
    append_highlight(message, {
      hl_group = LINK_HL,
      from = link.from,
      to = link.to,
    }, 120)
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

local function format_markdown(markdown, message, text, opts)
  local normalized = reflow(text)
  local references = collect_references(normalized)

  for _, block in ipairs(markdown.parse(normalized, opts or {})) do
    if block.code then
      append_code_block(message, block)
    elseif not is_reference_definition(block.line) then
      message:newline()
      append_prose(markdown, message, block, references)
    end
  end
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
        local links = type(vim.b[buf]._ray_markdown_links) == "table" and vim.b[buf]._ray_markdown_links[tostring(row)]
          or nil

        for _, link in ipairs(type(links) == "table" and links or {}) do
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
      markdown.keys(bufnr)
    end
  end)
end

return M
