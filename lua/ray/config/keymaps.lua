local map = vim.keymap.set
local map_multistep = require("mini.keymap").map_multistep
local window_resize = require("ray.integrations.edgy.resize")

-- Remove builtin mappings that conflict with plugin/LSP behavior. When LSP is not
-- ready for references, `gr` otherwise opens the builtin key hint menu instead of
-- showing the expected "no references" feedback.
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

-- Search
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Editing
map("n", "x", '"_x', { desc = "Delete without yanking" })
map("n", "q", "<Nop>", { noremap = true, silent = true })
map("n", "Q", "q", { noremap = true, silent = true })
map({ "i", "c" }, "jj", "<Esc>", { desc = "Exit insert or command-line mode" })
map({ "i", "c" }, "jk", "<Esc>", { desc = "Exit insert or command-line mode" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
map_multistep("i", "<C-l>", { "minisnippets_next", "jump_after_close" })
map_multistep("i", "<C-h>", { "minisnippets_prev", "jump_before_open" })

-- Clipboard
map({ "c", "i" }, "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })
map("n", "<leader>yp", '"0p', { desc = "Paste yanked text after cursor" })
map("n", "<leader>yP", '"0P', { desc = "Paste yanked text before cursor" })
map("n", "<leader>yi", "i<C-r>0<Esc>", { desc = "Insert yanked text at cursor" })
map("x", "<leader>yp", '"_d"0P', { desc = "Replace selection with yanked text" })
map("x", "<leader>yP", '"_d"0P', { desc = "Replace selection with yanked text" })

-- Line motions
map({ "n", "x", "o" }, "H", "^", { desc = "Move to first non-blank character" })
map({ "n", "x", "o" }, "L", "$", { desc = "Move to end of line" })

-- Prevent bare <Leader> from falling back to Normal-mode <space>, which moves
-- the cursor when no leader sequence is completed.
map({ "n", "x" }, "<leader>", "<Nop>", { desc = "Leader", silent = true })

-- Files
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>W", "<cmd>wall<CR>", { desc = "Write all files" })

-- Buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- UI
map("n", "<leader>lw", "<cmd>setlocal wrap!<CR>", { desc = "Toggle line wrap" })

-- Quit / close
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>qb", function()
  Snacks.bufdelete()
end, { desc = "Quit buffer" })
-- workaround for not deleting all buffers
local function delete_twice(filter)
  Snacks.bufdelete(filter)
  Snacks.bufdelete(filter)
end
map("n", "<leader>q[", function()
  local current = vim.api.nvim_get_current_buf()
  delete_twice(function(buf)
    return buf < current
  end)
end, { desc = "Quit buffers to the left" })
map("n", "<leader>q]", function()
  local current = vim.api.nvim_get_current_buf()

  delete_twice(function(buf)
    return buf > current
  end)
end, { desc = "Quit buffers to the right" })
map("n", "<leader>qo", function()
  Snacks.bufdelete.other()
  Snacks.bufdelete.other()
end, { desc = "Quit other buffers" })
map("n", "<leader>qt", "<cmd>tabclose<CR>", { desc = "Quit tab" })
map("n", "<leader>qT", "<cmd>tabonly<CR>", { desc = "Quit other tabs" })
map("n", "<leader>qw", "<C-W>c", { desc = "Delete window", remap = true })

-- Tabs
map("n", "[t", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "[T", "<cmd>tabfirst<CR>", { desc = "First tab" })
map("n", "]T", "<cmd>tablast<CR>", { desc = "Last tab" })

-- Line editing
map("n", "[<Space>", "O<Esc>", { desc = "Blank line above" })
map("n", "]<Space>", "o<Esc>", { desc = "Blank line below" })
map("n", "<leader>,", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

  vim.api.nvim_buf_set_lines(0, row, row, false, { line })
  vim.api.nvim_win_set_cursor(0, { row + 1, math.min(col, #line) })
end, { desc = "Duplicate line" })
map("n", "gK", "i<CR><Esc>", { desc = "Split line at cursor" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-Right>", function()
  window_resize.resize("width", 2)
end, { desc = "Increase window width" })
map("n", "<C-Left>", function()
  window_resize.resize("width", -2)
end, { desc = "Decrease window width" })
map("n", "<C-Up>", function()
  window_resize.resize("height", 2)
end, { desc = "Increase window height" })
map("n", "<C-Down>", function()
  window_resize.resize("height", -2)
end, { desc = "Decrease window height" })
map("n", "<leader>=", window_resize.equalize, { desc = "Equalize windows" })

-- Insert-mode navigation
map("i", "<A-h>", "<Left>", { desc = "Move left cursor" })
map("i", "<A-j>", "<Down>", { desc = "Move down cursor" })
map("i", "<A-k>", "<Up>", { desc = "Move up cursor" })
map("i", "<A-l>", "<Right>", { desc = "Move right cursor" })

-- Command-line navigation
map("c", "<A-h>", "<Left>", { desc = "Move left in command line" })
map("c", "<A-l>", "<Right>", { desc = "Move right in command line" })

-- Diagnostics
map("n", "<leader>cd", function()
  require("ray.config.diagnostics").open_float()
end, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })
