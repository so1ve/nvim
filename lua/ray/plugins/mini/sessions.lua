local sessions = require("mini.sessions")

local session_dir = vim.fn.stdpath("state") .. "/sessions"

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

local function has_file_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= "" then
      return true
    end
  end
  return false
end

local function save_session(verbose, require_file_buffer)
  if require_file_buffer and not has_file_buffer() then
    return
  end

  sessions.write(current_session_name(), { force = true, verbose = verbose })
end

local function list_sessions()
  local paths = vim.fn.glob(session_dir .. "/*.vim", true, true)

  table.sort(paths, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  return vim.tbl_map(function(path)
    local name = vim.fn.fnamemodify(path, ":t")
    return { dir = decode_path(vim.fn.fnamemodify(name, ":r")), name = name }
  end, paths)
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

local function load_project_session()
  read_session(current_session_name())
end

local M = {}

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

  vim.keymap.set("n", "<leader>pr", load_project_session, { desc = "Restore project session" })
  vim.keymap.set("n", "<leader>pw", function()
    save_session(true, false)
  end, { desc = "Save session" })
  vim.keymap.set("n", "<leader>ps", select_session, { desc = "Select session" })
  vim.keymap.set("n", "<leader>pl", load_last_session, { desc = "Restore last session" })
end

return M
