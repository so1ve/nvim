local map = vim.keymap.set
local window_util = require("util.windows")

local function close_buffer_or_window()
  local bufnr = vim.api.nvim_get_current_buf()
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

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", close_buffer_or_window, { desc = "Close buffer or window" })
map("n", "<leader>Q", quit_all, { desc = "Quit all" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("n", "<leader>za", "za", { desc = "Toggle fold" })
map("n", "<leader>zc", "zc", { desc = "Close fold" })
map("n", "<leader>zo", "zo", { desc = "Open fold" })
map("n", "<leader>zM", "zM", { desc = "Close all folds" })
map("n", "<leader>zR", "zR", { desc = "Open all folds" })
map("n", "<leader>zm", "zm", { desc = "Fold more" })
map("n", "<leader>zr", "zr", { desc = "Fold less" })

map("c", "<C-j>", "<Tab>", { desc = "Next command completion" })
map("c", "<C-k>", "<S-Tab>", { desc = "Previous command completion" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })

map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
