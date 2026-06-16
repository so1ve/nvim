local M = {}

local COMMIT_SCRIPT =
  vim.fs.joinpath(debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*)[/\\]"), "copilot-commit-message.mjs")

local generating = false
local generate_on_open = false

local function write_message(bufnr, message)
  local comment = require("neogit.lib.git").config.get("core.commentChar"):read()
  comment = (comment and comment ~= "" and comment ~= "auto") and vim.pesc(comment) or "#"

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local body_end = #lines
  for index, line in ipairs(lines) do
    if line:match("^%s*" .. comment) then
      body_end = index - 1
      break
    end
  end

  local message_lines = vim.split(message, "\n", { plain = true })
  if body_end < #lines then
    message_lines[#message_lines + 1] = ""
  end

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, body_end, false, message_lines)
end

function M.generate(bufnr)
  if generating then
    vim.notify("Copilot is already generating a commit message", vim.log.levels.WARN)
    return
  end

  local copilot = debug.getinfo(require("copilot").setup, "S").source:gsub("^@", "")
  local command = {
    "node",
    COMMIT_SCRIPT,
    require("copilot.auth").find_config_path(),
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(copilot))),
  }

  generating = true
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.notify("Generating commit message with Copilot…")

  vim.system(
    command,
    { text = true },
    vim.schedule_wrap(function(result)
      generating = false
      if result.code ~= 0 then
        vim.notify(vim.trim(result.stderr or "Copilot commit message failed"), vim.log.levels.ERROR)
      elseif vim.api.nvim_buf_is_valid(bufnr) then
        write_message(bufnr, vim.trim(result.stdout or ""))
        vim.notify("Commit message generated")
      end
    end)
  )
end

function M.commit_with_generated_message()
  generate_on_open = true
  require("neogit.lib.async").void(function()
    require("neogit.popups.commit.actions").commit({
      get_arguments = function()
        return {}
      end,
    })
    require("neogit.watcher").instance():dispatch_refresh()
  end)()
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "gitcommit",
    callback = function(event)
      if not vim.api.nvim_buf_get_name(event.buf):match("COMMIT_EDITMSG$") then
        return
      end

      vim.keymap.set("n", "<leader>ac", function()
        M.generate(event.buf)
      end, { buffer = event.buf, desc = "AI commit message" })

      if generate_on_open then
        generate_on_open = false
        vim.schedule(function()
          M.generate(event.buf)
        end)
      end
    end,
  })
end

return M
