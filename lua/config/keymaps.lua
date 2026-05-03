local map = vim.keymap.set

local function listed_buffers()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

local function is_layout_placeholder(buf)
  if vim.bo[buf].buftype ~= "" or vim.bo[buf].modified or vim.api.nvim_buf_get_name(buf) ~= "" then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, 2, false)
  return #lines == 1 and lines[1] == ""
end

local function should_quit_from_placeholder()
  local buf = vim.api.nvim_get_current_buf()
  local listed = listed_buffers()

  return #listed == 1 and listed[1] == buf and is_layout_placeholder(buf)
end

local function quit_from_placeholder(force)
  if force then
    vim.cmd.qall({ bang = true })
  else
    vim.cmd("confirm qall")
  end
end

local function should_close_window_natively()
  return vim.bo.buftype ~= "" or not vim.bo.buflisted or vim.bo.filetype == "neo-tree"
end

local function close_window(force)
  local ok = pcall(vim.cmd, force and "close!" or "close")

  if not ok then
    vim.cmd(force and "quit!" or "quit")
  end
end

local function close_buffer(opts)
  opts = opts or {}

  if should_close_window_natively() then
    close_window(opts.force)

    return
  end

  if should_quit_from_placeholder() then
    quit_from_placeholder(opts.force)

    return
  end

  Snacks.bufdelete(opts.force and { force = true } or nil)
end

-- route normal file close commands through Snacks.bufdelete without stealing native special-window close behavior
local close_commands = {
  close = function()
    close_buffer()
  end,
  ["close!"] = function()
    close_buffer({ force = true })
  end,
  exit = function()
    vim.cmd.update()
    close_buffer()
  end,
  q = function()
    close_buffer()
  end,
  ["q!"] = function()
    close_buffer({ force = true })
  end,
  quit = function()
    close_buffer()
  end,
  ["quit!"] = function()
    close_buffer({ force = true })
  end,
  wq = function()
    vim.cmd.write()
    close_buffer()
  end,
  ["wq!"] = function()
    vim.cmd("write!")
    close_buffer({ force = true })
  end,
  x = function()
    vim.cmd.update()
    close_buffer()
  end,
  xit = function()
    vim.cmd.update()
    close_buffer()
  end,
}

map("c", "<CR>", function()
  if vim.fn.getcmdtype() ~= ":" then
    return "<CR>"
  end

  local command = close_commands[vim.trim(vim.fn.getcmdline())]

  if command and not should_close_window_natively() then
    vim.schedule(command)
    return "<C-c>"
  end

  return "<CR>"
end, { expr = true, desc = "Route close-window commands through Snacks.bufdelete" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", function()
  close_buffer()
end, { desc = "Close buffer" })
map("n", "<leader>Q", "<cmd>confirm qall<CR>", { desc = "Quit all" })
map("n", "<C-w>c", function()
  close_buffer()
end, { desc = "Close buffer" })
map("n", "<C-w>q", function()
  close_buffer()
end, { desc = "Close buffer" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics location list" })
