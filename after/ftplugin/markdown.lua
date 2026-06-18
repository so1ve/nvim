vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:append("o")

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

local function continue_or_exit(rest, quote_prefix, marker_prefix)
  if rest:match("^%s*$") then
    return "<C-U>" .. quote_prefix
  end

  return "<C-G>u<CR>" .. quote_prefix .. marker_prefix
end

local function marker_keys()
  local line = vim.api.nvim_get_current_line()
  local quote_prefix, quote_depth, content = "", 0, line

  if line:match("^%s*>") then
    quote_prefix, quote_depth, content = quote_parts(line)
  end

  local content_indent = content:match("^%s*") or ""
  local body = content:sub(#content_indent + 1)

  -- Continue GitHub-style task list items, always starting the next checkbox unchecked.
  local bullet, _, checkbox_rest = body:match("^([%-%+%*])%s+%[([ xX])%]%s*(.*)$")
  if bullet then
    return continue_or_exit(checkbox_rest, quote_prefix, content_indent .. bullet .. " [ ] ")
  end

  -- Continue unordered list items using the same bullet marker.
  local unordered, unordered_rest = body:match("^([%-%+%*])%s+(.*)$")
  if unordered then
    return continue_or_exit(unordered_rest, quote_prefix, content_indent .. unordered .. " ")
  end

  -- Continue ordered list items by incrementing the numeric marker.
  local number, delimiter, ordered_rest = body:match("^(%d+)([%.%)])%s+(.*)$")
  if number then
    return continue_or_exit(ordered_rest, quote_prefix, content_indent .. (tonumber(number) + 1) .. delimiter .. " ")
  end

  -- No Markdown marker outside a quote: let regular <CR> happen.
  if quote_depth == 0 then
    return nil
  end

  -- Continue nested blockquotes, or leave the quote when it is empty.
  return content:match("^%s*$") and "<C-U>" or "<C-G>u<CR>" .. quote_prefix
end

require("mini.keymap").map_multistep("i", "<CR>", {
  {
    condition = function()
      return marker_keys() ~= nil
    end,
    action = marker_keys,
  },
}, { buffer = true })
