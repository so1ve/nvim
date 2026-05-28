vim.opt_local.spell = true
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:append("o")

local function blockquote_context(line)
  local indent = line:match("^%s*") or ""
  local cursor = #indent + 1
  local depth = 0

  while line:sub(cursor, cursor) == ">" do
    depth = depth + 1
    cursor = cursor + 1
    cursor = line:find("%S", cursor) or (#line + 1)
  end

  if depth == 0 then
    return nil
  end

  return {
    empty = line:sub(cursor):match("^%s*$") ~= nil,
    prefix = indent .. string.rep("> ", depth),
  }
end

vim.keymap.set("i", "<CR>", function()
  local quote = blockquote_context(vim.api.nvim_get_current_line())

  if not quote then
    return "<CR>"
  end

  if quote.empty then
    return "<C-U>"
  end

  return "<C-G>u<CR>" .. quote.prefix
end, {
  buffer = true,
  desc = "Continue or exit Markdown blockquote",
  expr = true,
  replace_keycodes = true,
})
