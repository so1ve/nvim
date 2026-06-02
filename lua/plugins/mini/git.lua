local M = {}

local in_progress_commands = {
  apply = "rebase",
  ["cherry-pick"] = "cherry-pick",
  merge = "merge",
  rebase = "rebase",
  revert = "revert",
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "mini.git" })
end

local function git_root()
  if _G.MiniGit ~= nil then
    local ok, data = pcall(MiniGit.get_buf_data, 0)

    if ok and type(data) == "table" and type(data.root) == "string" and data.root ~= "" then
      return data.root
    end
  end

  return vim.fs.root(0, ".git")
end

local function current_repo_file()
  local root = git_root()

  if root == nil then
    notify("Current buffer is not inside a Git repository", vim.log.levels.WARN)

    return nil
  end

  local path = vim.api.nvim_buf_get_name(0)

  if path == "" then
    notify("Current buffer has no file path", vim.log.levels.WARN)

    return nil
  end

  local relative = vim.fs.relpath(root, path)

  if relative == nil then
    notify("Current file is outside the Git repository", vim.log.levels.WARN)

    return nil
  end

  return {
    root = root,
    relative = relative,
  }
end

local function run_git(args, opts)
  opts = opts or {}

  local root = opts.root or git_root()

  if root == nil then
    notify("Current buffer is not inside a Git repository", vim.log.levels.WARN)

    return false
  end

  local command = { "git", "-C", root }

  vim.list_extend(command, args)

  local result = vim.system(command, { text = true }):wait()

  if result.code ~= 0 then
    local message = vim.trim(result.stderr or "")

    if message == "" then
      message = vim.trim(result.stdout or "")
    end

    notify(message ~= "" and message or "Git command failed", vim.log.levels.ERROR)

    return false
  end

  if opts.message ~= nil then
    notify(opts.message)
  end

  vim.cmd.checktime()
  vim.cmd.redrawstatus()

  return true
end

local function write_current_buffer()
  if not vim.bo.modified then
    return true
  end

  local ok, err = pcall(vim.cmd.write)

  if not ok then
    notify("Failed to write buffer: " .. tostring(err), vim.log.levels.ERROR)

    return false
  end

  return true
end

local function checkout_conflict_version(version, opts)
  opts = opts or {}

  if vim.bo.modified then
    notify("Write or discard buffer changes before replacing conflict content", vim.log.levels.WARN)

    return
  end

  local file = current_repo_file()

  if file == nil then
    return
  end

  local flag = version == "merge" and "--merge" or "--" .. version
  local ok = run_git({ "checkout", flag, "--", file.relative }, { root = file.root })

  if not ok or not opts.stage then
    return
  end

  run_git({ "add", "--", file.relative }, {
    root = file.root,
    message = "Took " .. version .. " and staged " .. file.relative,
  })
end

local function stage_current_file()
  if not write_current_buffer() then
    return
  end

  local file = current_repo_file()

  if file == nil then
    return
  end

  run_git({ "add", "--", file.relative }, {
    root = file.root,
    message = "Staged " .. file.relative,
  })
end

local function in_progress_command()
  if _G.MiniGit == nil then
    return nil
  end

  local ok, data = pcall(MiniGit.get_buf_data, 0)

  if not ok or type(data) ~= "table" or type(data.in_progress) ~= "string" then
    return nil
  end

  for item in data.in_progress:gmatch("[^,]+") do
    local command = in_progress_commands[item]

    if command ~= nil then
      return command
    end
  end

  return nil
end

local function run_in_progress(action)
  local command = in_progress_command()

  if command == nil then
    notify("No merge, rebase, cherry-pick, or revert is in progress", vim.log.levels.WARN)

    return
  end

  vim.cmd("Git " .. command .. " --" .. action)
end

function M.setup()
  require("mini.git").setup()

  vim.keymap.set("n", "<leader>gco", function()
    checkout_conflict_version("ours", { stage = true })
  end, { desc = "Take ours" })

  vim.keymap.set("n", "<leader>gct", function()
    checkout_conflict_version("theirs", { stage = true })
  end, { desc = "Take theirs" })

  vim.keymap.set("n", "<leader>gcx", function()
    checkout_conflict_version("merge")
  end, { desc = "Recreate conflict" })

  vim.keymap.set("n", "<leader>gcs", stage_current_file, { desc = "Stage resolved file" })

  vim.keymap.set("n", "<leader>gcc", function()
    run_in_progress("continue")
  end, { desc = "Continue Git operation" })

  vim.keymap.set("n", "<leader>gca", function()
    run_in_progress("abort")
  end, { desc = "Abort Git operation" })

  vim.keymap.set("n", "<leader>gB", function()
    vim.cmd("vertical Git blame -- %")
  end, { desc = "Git blame" })
end

return M
