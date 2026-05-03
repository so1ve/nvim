local map = vim.keymap.set

local function has_modified_buffers()
  return vim.iter(vim.api.nvim_list_bufs()):any(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified
  end)
end

local function quit_all()
  Snacks.bufdelete.all()

  if has_modified_buffers() then
    return
  end

  vim.cmd.qall()
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })
map("n", "<leader>Q", quit_all, { desc = "Quit all" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })
