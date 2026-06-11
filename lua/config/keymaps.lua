local map = vim.keymap.set

-- delete them since when lsp is not ready for references, `gr` triggers the builtin key hint menu instead of a warning indicating that no references are found
local conflict_keymaps = {
  n = { "gO", "gra", "gri", "grn", "grr", "grt", "grx", "<C-W>d", "<C-W><C-D>" },
  i = { "<C-S>" },
  v = { "<C-S>" },
  x = { "gra" },
  s = { "<C-S>" },
}

for mode, keys in pairs(conflict_keymaps) do
  for _, lhs in ipairs(keys) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Disable `q` since it is easy to hit by accident and enter recording mode, which can be confusing
map("n", "q", "<Nop>", { noremap = true, silent = true })

-- Prevent bare <Leader> from falling back to Normal-mode <space>, which moves
-- the cursor when no leader sequence is completed.
map({ "n", "x" }, "<leader>", "<Nop>", { desc = "Leader", silent = true })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>W", "<cmd>wall<CR>", { desc = "Write all files" })
map("n", "<leader>qq", function()
  Snacks.bufdelete()
end, { desc = "Quit buffer" })
map("n", "<leader>qa", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>qw", "<C-W>c", { desc = "Delete window", remap = true })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("i", "<A-h>", "<Left>", { desc = "Move lef cursor" })
map("i", "<A-j>", "<Down>", { desc = "Move down cursor" })
map("i", "<A-k>", "<Up>", { desc = "Move up cursor" })
map("i", "<A-l>", "<Right>", { desc = "Move right cursor" })

map("c", "<A-h>", "<Left>", { desc = "Move left in command line" })
map("c", "<A-l>", "<Right>", { desc = "Move right in command line" })

map("n", "<leader>cd", function()
  require("config.diagnostics").open_float({ scope = "line" })
end, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })

map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
