local map = vim.keymap.set

local function close_properly()
  local bufnr = vim.api.nvim_get_current_buf()
  local is_special_buffer = vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].buflisted
  local current_tab_wins = vim.api.nvim_tabpage_list_wins(0)

  -- With multiple windows, close the current view instead of deleting its buffer.
  -- This keeps split editing predictable, even when another window shows the same buffer.
  if #current_tab_wins > 1 then
    vim.cmd.close()

    return
  end

  if is_special_buffer then
    vim.cmd.bdelete()

    return
  end

  Snacks.bufdelete()
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
map("n", "<leader>q", close_properly, { desc = "Close buffer or window" })
map("n", "<leader>Q", quit_all, { desc = "Quit all" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("c", "<C-j>", "<Tab>", { desc = "Next command completion" })
map("c", "<C-k>", "<S-Tab>", { desc = "Previous command completion" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })

map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
