local map = vim.keymap.set
local visual_search = require("ray.utils.visual-search")
local window_resize = require("ray.utils.window-resize")

local resize_step = 2

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
map("x", "/", function()
  return visual_search.search_keys("forward")
end, { desc = "Search selected text forward", expr = true, replace_keycodes = true })
map("x", "?", function()
  return visual_search.search_keys("backward")
end, { desc = "Search selected text backward", expr = true, replace_keycodes = true })

-- Editing
map("n", "x", '"_x', { desc = "Delete without yanking" })
-- Disable `q` since it is easy to hit by accident and enter recording mode, which can be confusing
map("n", "q", "<Nop>", { noremap = true, silent = true })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })

-- Clipboard
map({ "c", "i" }, "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })
map({ "n", "x" }, "<leader>yp", '"0p', { desc = "Paste yanked text" })
map({ "n", "x" }, "<leader>yP", '"0P', { desc = "Paste yanked text before" })

-- Line motions
map({ "n", "x", "o" }, "H", "^", { desc = "Move to first non-blank character" })
map({ "n", "x", "o" }, "L", "$", { desc = "Move to end of line" })

-- Prevent bare <Leader> from falling back to Normal-mode <space>, which moves
-- the cursor when no leader sequence is completed.
map({ "n", "x" }, "<leader>", "<Nop>", { desc = "Leader", silent = true })

-- Files
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>W", "<cmd>wall<CR>", { desc = "Write all files" })

-- UI
map("n", "<leader>lw", "<cmd>setlocal wrap!<CR>", { desc = "Toggle line wrap" })
map("n", "<leader>uC", function()
  require("ray.config.themes").select()
end, { desc = "Colorscheme" })

-- Quit / close
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })
map("n", "<leader>qb", function()
  Snacks.bufdelete()
end, { desc = "Quit buffer" })
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
map("n", "gK", "i<CR><Esc>", { desc = "Split line at cursor" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-Right>", function()
  window_resize.resize("width", resize_step)
end, { desc = "Increase window width" })
map("n", "<C-Left>", function()
  window_resize.resize("width", -resize_step)
end, { desc = "Decrease window width" })
map("n", "<C-Up>", function()
  window_resize.resize("height", resize_step)
end, { desc = "Increase window height" })
map("n", "<C-Down>", function()
  window_resize.resize("height", -resize_step)
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

-- map("n", "go", [["0yi):!start <C-r>0<CR>]], { desc = "Open target with system app" })

-- Diagnostics
map("n", "<leader>cd", function()
  require("ray.config.diagnostics").open_float()
end, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })
