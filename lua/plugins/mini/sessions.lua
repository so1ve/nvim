local M = {}
local sessions = require("mini.sessions")

local session_dir = vim.fn.stdpath("state") .. "/sessions"
local minimum_buffers = 1

local function encode_path(path)
  return path:gsub("[\\/:]+", "%%")
end

local function decode_path(path)
  local decoded = path:gsub("%%", "/")

  if jit and jit.os:find("Windows") then
    decoded = decoded:gsub("^(%w)/", "%1:/")
  end

  return decoded
end

local function session_name()
  return encode_path(vim.fn.getcwd()) .. ".vim"
end

local function session_path(name)
  return session_dir .. "/" .. name
end

local function is_file_buffer(bufnr)
  return vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function has_enough_buffers()
  local count = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if is_file_buffer(bufnr) then
      count = count + 1
      if count >= minimum_buffers then
        return true
      end
    end
  end

  return false
end

local function session_item(path)
  local name = vim.fn.fnamemodify(path, ":t")
  local stem = vim.fn.fnamemodify(name, ":r")

  return {
    dir = decode_path(stem),
    name = name,
    path = path,
  }
end

local function list_sessions()
  local sessions = vim.fn.glob(session_dir .. "/*.vim", true, true)

  table.sort(sessions, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  return vim.tbl_map(session_item, sessions)
end

local function read_session(name)
  if vim.fn.filereadable(session_path(name)) == 0 then
    return
  end

  sessions.read(name)
end

function M.current()
  return session_name()
end

function M.load()
  read_session(session_name())
end

function M.save(opts)
  opts = opts or {}
  sessions.write(session_name(), {
    force = true,
    verbose = opts.verbose,
  })
end

function M.select()
  vim.ui.select(list_sessions(), {
    prompt = "Select a session: ",
    format_item = function(item)
      return vim.fn.fnamemodify(item.dir, ":p:~")
    end,
  }, function(item)
    if not item then
      return
    end

    vim.fn.chdir(item.dir)
    read_session(item.name)
  end)
end

function M.load_last()
  local latest = list_sessions()[1]

  if latest then
    read_session(latest.name)
  end
end

function M.start()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    desc = "Auto-write current Mini.sessions session",
    callback = function()
      if not has_enough_buffers() then
        return
      end

      M.save({ verbose = false })
    end,
  })
end

function M.setup()
  sessions.setup({
    autoread = false,
    autowrite = false,
    directory = session_dir,
    file = "",
    force = {
      delete = false,
      read = false,
      write = true,
    },
    verbose = {
      delete = true,
      read = false,
      write = true,
    },
  })

  M.start()

  vim.keymap.set("n", "<leader>pr", M.load, { desc = "Restore project session" })
  vim.keymap.set("n", "<leader>pw", M.save, { desc = "Save session" })
  vim.keymap.set("n", "<leader>ps", M.select, { desc = "Select session" })
  vim.keymap.set("n", "<leader>pl", M.load_last, { desc = "Restore last session" })
end

return M
