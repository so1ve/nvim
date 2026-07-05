local sessions = require("mini.sessions")

local M = {}

local session_dir = vim.fn.stdpath("state") .. "/sessions"
local minimum_buffers = 1

local function encode_path(path)
  return path:gsub("[\\/:]+", "%%")
end

local function decode_path(path)
  local decoded = path:gsub("%%", "/")

  if jit.os:find("Windows") then
    decoded = decoded:gsub("^(%w)/", "%1:/")
  end

  return decoded
end

local function current_session_name()
  return encode_path(vim.fn.getcwd()) .. ".vim"
end

local function session_path(name)
  return vim.fs.normalize(session_dir .. "/" .. name)
end

local function read_session(name)
  if vim.fn.filereadable(session_path(name)) == 1 then
    sessions.read(name)
  end
end

local function is_file_buffer(bufnr)
  return vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function has_enough_file_buffers()
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

local function save_session(verbose, require_file_buffer)
  if require_file_buffer and not has_enough_file_buffers() then
    return
  end

  sessions.write(current_session_name(), {
    force = true,
    verbose = verbose,
  })
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
  local paths = vim.fn.glob(session_dir .. "/*.vim", true, true)

  table.sort(paths, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  return vim.tbl_map(session_item, paths)
end

local function select_session()
  vim.ui.select(list_sessions(), {
    prompt = "Select a session: ",
    format_item = function(item)
      return vim.fn.fnamemodify(item.dir, ":p:~")
    end,
  }, function(item)
    if not item then
      return
    end

    save_session(false, true)
    vim.fn.chdir(item.dir)
    read_session(item.name)
  end)
end

local function load_last_session()
  local latest = list_sessions()[1]

  if latest then
    read_session(latest.name)
  end
end

function M.load()
  read_session(current_session_name())
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

  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      if vim.v.this_session ~= "" then
        vim.v.this_session = session_path(current_session_name())
      end
    end,
  })

  vim.api.nvim_create_autocmd("ExitPre", {
    callback = function()
      save_session(false, true)
    end,
  })

  vim.keymap.set("n", "<leader>pr", M.load, { desc = "Restore project session" })
  vim.keymap.set("n", "<leader>pw", function()
    save_session(true, false)
  end, { desc = "Save session" })
  vim.keymap.set("n", "<leader>ps", select_session, { desc = "Select session" })
  vim.keymap.set("n", "<leader>pl", load_last_session, { desc = "Restore last session" })
end

return M
