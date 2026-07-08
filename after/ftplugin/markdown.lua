vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:append("o")

require("ray.utils.keymaps").map_display_line_motion()

local list_parser = require("markdown-plus.list.parser")
local list_handler_utils = require("markdown-plus.list.handler_utils")

local function quote_parts(line)
  local indent = line:match("^%s*") or ""
  local cursor = #indent + 1
  local depth = 0

  while line:sub(cursor, cursor) == ">" do
    depth = depth + 1
    cursor = cursor + 1
    cursor = line:find("%S", cursor) or (#line + 1)
  end

  return indent .. string.rep("> ", depth), depth, line:sub(cursor)
end

local function quoted_list_keys(content, quote_prefix)
  local list_info = list_parser.parse_list_line(content)
  if not list_info then
    return nil
  end

  if list_parser.is_empty_list_item(content, list_info) then
    return "<C-U>" .. quote_prefix
  end

  return "<C-G>u<CR>"
    .. quote_prefix
    .. list_handler_utils.build_list_prefix(
      list_info.indent,
      list_parser.get_next_marker(list_info),
      list_info.checkbox
    )
end

local function quote_keys()
  local line = vim.api.nvim_get_current_line()
  if not line:match("^%s*>") then
    return nil
  end

  local quote_prefix, _, content = quote_parts(line)
  local list_keys = quoted_list_keys(content, quote_prefix)
  if list_keys then
    return list_keys
  end

  -- Continue nested blockquotes, or leave the quote when it is empty.
  return content:match("^%s*$") and "<C-U>" or "<C-G>u<CR>" .. quote_prefix
end

local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

vim.keymap.set("i", "<CR>", function()
  local keys = quote_keys()
  if keys then
    feed(keys)
    return
  end

  require("markdown-plus.list").handle_enter()
end, { buffer = true, desc = "Markdown smart enter" })
