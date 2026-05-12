local map = vim.keymap.set
local cmdline_util = require("utils.cmdline")
local window_util = require("utils.windows")

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

local function quit_all()
  local ok, picker = pcall(require, "snacks.picker")
  local active_pickers = ok and picker.get({ tab = false }) or {}

  if #active_pickers > 0 then
    for _, active_picker in ipairs(active_pickers) do
      active_picker:close()
    end

    vim.schedule(function()
      vim.cmd("confirm qall")
    end)

    return
  end

  vim.cmd("confirm qall")
end

local function close_buffer_or_window()
  local bufnr = vim.api.nvim_get_current_buf()

  if window_util.is_dashboard(bufnr) then
    quit_all()

    return
  end

  local wins = vim.api.nvim_tabpage_list_wins(0)
  local has_multiple_windows = #wins > 1
  local should_delete_buffer = window_util.is_file(bufnr)
    and (not has_multiple_windows or not window_util.has_many_files(wins))

  if should_delete_buffer then
    Snacks.bufdelete()

    return
  end

  if has_multiple_windows then
    vim.cmd.close()

    return
  end

  vim.cmd.bdelete()
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
-- Prevent bare <Leader> from falling back to Normal-mode <space>, which moves
-- the cursor when no leader sequence is completed.
map({ "n", "x" }, "<leader>", "<Nop>", { desc = "Leader", silent = true })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", close_buffer_or_window, { desc = "Close buffer or window" })
map("n", "<leader>Q", quit_all, { desc = "Quit all" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("i", "<A-h>", "<Left>", { desc = "Move lef cursor" })
map("i", "<A-j>", "<Down>", { desc = "Move down cursor" })
map("i", "<A-k>", "<Up>", { desc = "Move up cursor" })
map("i", "<A-l>", "<Right>", { desc = "Move right cursor" })

map("c", "<A-h>", cmdline_util.guard_prefix("<Left>"), { desc = "Move left in command line", expr = true })
map("c", "<A-l>", "<Right>", { desc = "Move right in command line" })
map("c", "<Left>", cmdline_util.guard_prefix("<Left>"), { desc = "Move left in command line", expr = true })
map("c", "<BS>", cmdline_util.guard_prefix("<BS>"), { desc = "Keep command prefix", expr = true })
map("c", "<C-h>", cmdline_util.guard_prefix("<BS>"), { desc = "Keep command prefix", expr = true })

map("n", "<leader>za", "za", { desc = "Toggle fold" })
map("n", "<leader>zc", "zc", { desc = "Close fold" })
map("n", "<leader>zo", "zo", { desc = "Open fold" })
map("n", "<leader>zM", "zM", { desc = "Close all folds" })
map("n", "<leader>zR", "zR", { desc = "Open all folds" })
map("n", "<leader>zm", "zm", { desc = "Fold more" })
map("n", "<leader>zr", "zr", { desc = "Fold less" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })

map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
