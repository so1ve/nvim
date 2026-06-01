-- Shared Snacks-style backdrop helper for local patch modules.
-- Purpose: centralize the editor-sized dimming float used behind custom
-- floating UIs while keeping plugin-specific lifecycle hooks in each patch.

local M = {}

local DEFAULT_BLEND = 60
local DEFAULT_GROUP = "SnacksBackdrop_000000"
local DEFAULT_ZINDEX = 50

local Backdrop = {}
Backdrop.__index = Backdrop

local function valid_win(win)
  return type(win) == "number" and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
  return type(buf) == "number" and vim.api.nvim_buf_is_valid(buf)
end

local function ensure_highlight(group, bg)
  vim.api.nvim_set_hl(0, group, { bg = bg })
end

local function create_buffer(filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  return buf
end

function Backdrop:config()
  return {
    relative = "editor",
    row = 0,
    col = 0,
    width = math.max(1, vim.o.columns),
    height = math.max(1, vim.o.lines - vim.o.cmdheight),
    style = "minimal",
    border = "none",
    focusable = false,
    noautocmd = true,
    zindex = self.zindex,
  }
end

function Backdrop:set_window_options()
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:" .. self.group .. ",EndOfBuffer:" .. self.group,
    { win = self.win }
  )
  vim.api.nvim_set_option_value("winblend", self.blend, { win = self.win })
  vim.api.nvim_set_option_value("colorcolumn", "", { win = self.win })
  vim.api.nvim_set_option_value("number", false, { win = self.win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = self.win })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = self.win })
  vim.api.nvim_set_option_value("foldcolumn", "0", { win = self.win })
  vim.api.nvim_set_option_value("fillchars", "eob: ", { win = self.win })
  vim.api.nvim_set_option_value("wrap", false, { win = self.win })
end

function Backdrop:open()
  self:close()
  ensure_highlight(self.group, self.bg)

  self.buf = create_buffer(self.filetype)
  self.win = vim.api.nvim_open_win(self.buf, false, self:config())
  self:set_window_options()
end

function Backdrop:close()
  if valid_win(self.win) then
    pcall(vim.api.nvim_win_close, self.win, true)
  end
  self.win = nil

  if valid_buf(self.buf) then
    pcall(vim.api.nvim_buf_delete, self.buf, { force = true })
  end
  self.buf = nil
end

function Backdrop:sync()
  if valid_win(self.win) then
    vim.api.nvim_win_set_config(self.win, self:config())
    return
  end

  if valid_buf(self.buf) then
    self.win = vim.api.nvim_open_win(self.buf, false, self:config())
    self:set_window_options()
    return
  end

  self:close()
end

---@param opts { filetype: string, zindex?: number, blend?: number, group?: string, bg?: string }
---@return table
function M.new(opts)
  return setmetatable({
    bg = opts.bg or "#000000",
    blend = opts.blend or DEFAULT_BLEND,
    buf = nil,
    filetype = opts.filetype,
    group = opts.group or DEFAULT_GROUP,
    win = nil,
    zindex = opts.zindex or DEFAULT_ZINDEX,
  }, Backdrop)
end

return M
