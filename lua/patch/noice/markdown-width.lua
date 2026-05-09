-- Noice markdown visual width patch.
-- Purpose: make hover layout size itself from rendered markdown width instead
-- of raw markdown source width, especially for inline links where `[label](url)`
-- visually occupies only `label`.
-- Behavior: markdown links remain clickable via stored link ranges, while layout
-- height/width calculations use the transformed visual text.
-- Implementation: patches Noice markdown formatting and text block width/render
-- methods, caches each line's visual width, and exposes `fix_layout()` so the
-- hover layout patch can recalculate wrapped popup dimensions before placement.

local M = {}
local hacks = require("utils.hacks")

local LINK_HL = "@markup.link"

local function normalize_url(url)
  return url:match("^<(.+)>$") or url
end

local function node_text(text, node)
  local _, start_col, _, end_col = node:range()

  return text:sub(start_col + 1, end_col)
end

local function collect_links(text, node, links)
  local node_type = node:type()
  local label_type = node_type == "image" and "image_description" or "link_text"

  if node_type == "inline_link" or node_type == "image" then
    local label_node
    local destination_node

    for child in node:iter_children() do
      if child:type() == label_type then
        label_node = child
      elseif child:type() == "link_destination" then
        destination_node = child
      end
    end

    if label_node and destination_node then
      local _, full_start, _, full_end = node:range()
      local _, label_start, _, label_end = label_node:range()

      links[#links + 1] = {
        full_start = full_start,
        full_end = full_end,
        label = text:sub(label_start + 1, label_end),
        url = normalize_url(node_text(text, destination_node)),
      }
    end

    return
  end

  for child in node:iter_children() do
    collect_links(text, child, links)
  end
end

local function parse_links(text)
  if text == "" or not (vim.treesitter and vim.treesitter.get_string_parser) then
    return {}
  end

  local ok, parser = pcall(vim.treesitter.get_string_parser, text, "markdown_inline")

  if not ok then
    return {}
  end

  local parsed, trees = pcall(parser.parse, parser)

  if not (parsed and trees and trees[1]) then
    return {}
  end

  local links = {}

  collect_links(text, trees[1]:root(), links)
  table.sort(links, function(a, b)
    return a.full_start < b.full_start
  end)

  return links
end

local function transform_line(text)
  local ret = {}
  local links = {}
  local source_pos = 0
  local output_len = 0

  local function append(chunk)
    if chunk == "" then
      return
    end

    ret[#ret + 1] = chunk
    output_len = output_len + #chunk
  end

  for _, link in ipairs(parse_links(text)) do
    if link.full_start >= source_pos then
      append(text:sub(source_pos + 1, link.full_start))

      local from = output_len + 1

      append(link.label)

      if link.url ~= "" and link.label ~= "" then
        links[#links + 1] = { from = from, to = output_len, url = link.url }
      end

      source_pos = link.full_end
    end
  end

  append(text:sub(source_pos + 1))

  return table.concat(ret), links
end

function M.visual_content(text)
  return transform_line(text)
end

function M.width(text)
  local content = M.visual_content(text)

  return vim.api.nvim_strwidth(content)
end

function M.line_width(line)
  local content = line:content()

  if line._ray_markdown_visual_width and line._ray_markdown_width_source == content then
    return line._ray_markdown_visual_width
  end

  return line:width()
end

function M.fix_layout(view, layout)
  if not (layout.size and type(layout.size.width) == "number" and layout.size.width > 0) then
    return layout
  end

  if not (view._opts.type == "popup" and view._opts.win_options and view._opts.win_options.wrap) then
    return layout
  end

  local view_width = view:width()

  if layout.size.width >= view_width then
    return layout
  end

  local height = 0

  for _, msg in ipairs(view._messages or {}) do
    for _, line in ipairs(msg._lines or {}) do
      height = height + math.max(1, math.ceil(M.line_width(line) / layout.size.width))
    end
  end

  return require("noice.util").nui.get_layout({ width = view_width, height = height }, view._opts)
end

local function attach_links(bufnr, lines, linenr_start)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  linenr_start = linenr_start or 1

  local existing = vim.b[bufnr]._ray_markdown_links
  local buf_links = {}

  if linenr_start ~= 1 and type(existing) == "table" then
    buf_links = existing
  end

  for index, line in ipairs(lines or {}) do
    local linenr = linenr_start + index - 1
    buf_links[tostring(linenr)] = line._ray_markdown_links
  end

  vim.b[bufnr]._ray_markdown_links = buf_links
end

local function format_markdown(markdown, message, text, opts)
  opts = opts or {}

  local noice_text = require("noice.text")
  local blocks = markdown.parse(text, opts)
  local md_lines = 0

  local function emit_md()
    if md_lines > 0 then
      message:append(noice_text.syntax("markdown", md_lines))
      md_lines = 0
    end
  end

  for _, block in ipairs(blocks) do
    if block.code then
      emit_md()
      message:newline()

      for index, line in ipairs(block.code) do
        message:append(line)

        if index == #block.code then
          message:append(noice_text.syntax(block.lang, #block.code))
        else
          message:newline()
        end
      end
    else
      message:newline()

      if markdown.is_rule(block.line) then
        markdown.horizontal_line(message)
      else
        local line, links = transform_line(block.line)

        message:append(line)

        local last_line = message:last_line()

        if last_line then
          last_line._ray_markdown_width_source = line
          last_line._ray_markdown_visual_width = vim.api.nvim_strwidth(line)
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
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    if vim.b[buf].markdown_keys then
      return
    end

    local function map(lhs)
      vim.keymap.set("n", lhs, function()
        local pos = vim.api.nvim_win_get_cursor(0)
        local row = pos[1]
        local col = pos[2] + 1
        local links = vim.b[buf]._ray_markdown_links
        local line_links = type(links) == "table" and links[tostring(row)] or nil

        if type(line_links) ~= "table" then
          line_links = {}
        end

        for _, link in ipairs(line_links) do
          if
            type(link) == "table"
            and type(link.from) == "number"
            and type(link.to) == "number"
            and col >= link.from
            and col <= link.to
          then
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
    -- Replace Noice's markdown formatting so inline links are rendered as visual
    -- labels with our own link metadata, rather than raw markdown source text.
    format_markdown(markdown, message, text, opts)
  end)

  patch_keys(markdown)

  local block = require("noice.text.block")

  hacks.wrap(block, "noice.markdown.block.render", "render", function(render)
    -- Attach link metadata during render so the patched gx/K handlers can open the
    -- URL even though the visible text no longer contains markdown link syntax.
    return function(self, bufnr, ns_id, linenr_start, linenr_end)
      render(self, bufnr, ns_id, linenr_start, linenr_end)
      attach_links(bufnr, self._lines, linenr_start)
    end
  end)

  hacks.wrap(block, "noice.markdown.block.width", "width", function(width)
    -- Prefer cached visual widths for lines produced by our markdown formatter;
    -- fall back to Noice's upstream width calculation for all other blocks.
    return function(self)
      local has_markdown_width = false
      local ret = 0

      for _, line in ipairs(self._lines or {}) do
        if line._ray_markdown_visual_width then
          has_markdown_width = true
        end

        ret = math.max(ret, M.line_width(line))
      end

      if has_markdown_width then
        return ret
      end

      return width(self)
    end
  end)
end

return M
