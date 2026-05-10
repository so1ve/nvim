-- Link-aware Noice markdown rendering.
-- Purpose: render markdown links as their visible labels while storing URL ranges
-- so hover buffers can open them with K/gx. Supports both inline links and
-- rust-analyzer/rustdoc reference-style links such as:
--   See [`set_control_flow()`]
--   [`set_control_flow()`]: https://docs.rs/...

local M = {}
local hacks = require("utils.hacks")

local LINK_HL = "@markup.link"

local function normalize_url(url)
  return url and (url:match("^<(.+)>$") or url) or nil
end

local function normalize_reference_label(label)
  return label:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " "):lower()
end

local function plain_reference_label(label)
  return label:gsub("`([^`]*)`", "%1"):gsub("`", "")
end

local function set_reference(references, label, url)
  if not (label and url) then
    return
  end

  url = normalize_url(url)

  references[normalize_reference_label(label)] = url

  local plain_label = plain_reference_label(label)

  if plain_label ~= label then
    references[normalize_reference_label(plain_label)] = url
  end
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

local function node_text(text, node)
  local _, start_col, _, end_col = node:range()

  return text:sub(start_col + 1, end_col)
end

local function strip_reference_brackets(label)
  return label:match("^%[(.*)%]$") or label
end

local function reference_url(references, label)
  return references[normalize_reference_label(label)]
end

local function collect_links(text, node, links, references)
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
  elseif
    node_type == "shortcut_link"
    or node_type == "collapsed_reference_link"
    or node_type == "full_reference_link"
  then
    local label_node
    local reference_node

    for child in node:iter_children() do
      if child:type() == "link_text" then
        label_node = child
      elseif child:type() == "link_label" then
        reference_node = child
      end
    end

    if label_node then
      local _, full_start, _, full_end = node:range()
      local _, label_start, _, label_end = label_node:range()
      local label = text:sub(label_start + 1, label_end)
      local reference = reference_node and strip_reference_brackets(node_text(text, reference_node)) or label
      local url = reference_url(references, reference) or reference_url(references, label)

      if url then
        links[#links + 1] = {
          full_start = full_start,
          full_end = full_end,
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

  collect_links(text, trees[1]:root(), links, references or {})
  table.sort(links, function(a, b)
    return a.full_start < b.full_start
  end)

  return links
end

local function transform_line(text, references)
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

  for _, link in ipairs(parse_links(text, references)) do
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

function M.reference_definitions(text)
  return parse_reference_definitions(text)
end

function M.visual_content(text, references)
  return transform_line(text, references)
end

function M.is_reference_definition(line)
  return is_reference_definition(line)
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
  local references = parse_reference_definitions(text)
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
    elseif is_reference_definition(block.line) then
      -- Reference definitions are rendered as clickable ranges on their visible
      -- labels. Keep footnote definitions (`[^1]:`) visible by excluding them in
      -- `is_reference_definition()`.
    else
      message:newline()

      if markdown.is_rule(block.line) then
        markdown.horizontal_line(message)
      else
        local line, links = transform_line(block.line, references)

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
    format_markdown(markdown, message, text, opts)
  end)

  patch_keys(markdown)

  local block = require("noice.text.block")

  hacks.wrap(block, "noice.markdown.block.render", "render", function(render)
    return function(self, bufnr, ns_id, linenr_start, linenr_end)
      render(self, bufnr, ns_id, linenr_start, linenr_end)
      attach_links(bufnr, self._lines, linenr_start)
    end
  end)
end

return M
