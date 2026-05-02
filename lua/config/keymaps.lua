local map = vim.keymap.set

-- override default close commands to route through Snacks.bufdelete, which prevents neo-tree layout from being full-screened
local close_commands = {
  close = function()
    Snacks.bufdelete()
  end,
  ["close!"] = function()
    Snacks.bufdelete({ force = true })
  end,
  exit = function()
    vim.cmd.update()
    Snacks.bufdelete()
  end,
  q = function()
    Snacks.bufdelete()
  end,
  ["q!"] = function()
    Snacks.bufdelete({ force = true })
  end,
  quit = function()
    Snacks.bufdelete()
  end,
  ["quit!"] = function()
    Snacks.bufdelete({ force = true })
  end,
  wq = function()
    vim.cmd.write()
    Snacks.bufdelete()
  end,
  ["wq!"] = function()
    vim.cmd("write!")
    Snacks.bufdelete({ force = true })
  end,
  x = function()
    vim.cmd.update()
    Snacks.bufdelete()
  end,
  xit = function()
    vim.cmd.update()
    Snacks.bufdelete()
  end,
}

map("c", "<CR>", function()
  if vim.fn.getcmdtype() ~= ":" then
    return "<CR>"
  end

  local command = close_commands[vim.trim(vim.fn.getcmdline())]

  if command and vim.bo.filetype ~= "neo-tree" then
    vim.schedule(command)
    return "<C-c>"
  end

  return "<CR>"
end, { expr = true, desc = "Route close-window commands through Snacks.bufdelete" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })
map("n", "<leader>Q", "<cmd>confirm qall<CR>", { desc = "Quit all" })
map("n", "<C-w>c", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })
map("n", "<C-w>q", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })
