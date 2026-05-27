vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:append("o")

local function blockquote(line)
  local indent = line:match("^%s*") or ""
  local index = #indent + 1
  local quote_count = 0

  while line:sub(index, index) == ">" do
    quote_count = quote_count + 1
    index = index + 1

    while line:sub(index, index):match("%s") do
      index = index + 1
    end
  end

  if quote_count == 0 then
    return nil
  end

  return {
    empty = line:sub(index):match("^%s*$") ~= nil,
    prefix = indent .. string.rep("> ", quote_count),
  }
end

vim.keymap.set("i", "<CR>", function()
  local quote = blockquote(vim.api.nvim_get_current_line())

  if not quote then
    return "\r"
  end

  if quote.empty then
    return "\21\r"
  end

  return "\r" .. quote.prefix
end, {
  buffer = true,
  desc = "Continue or exit Markdown blockquote",
  expr = true,
})
