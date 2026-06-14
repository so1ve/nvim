local curl = require("plenary.curl")

local M = {}

local TIMEOUT_MS = 15000
local MAX_DIFF_CHARS = 20000
local NEXT_COMMIT_TIMEOUT_MS = 10000

local running = {}
local token
local expires_at = 0
local generate_on_next_commit = false

local function is_commit_edit_message(bufnr)
  return vim.api.nvim_buf_get_name(bufnr):match("COMMIT_EDITMSG$") ~= nil
end

local function json(body)
  local ok, data = pcall(vim.json.decode, body or "")
  return ok and data or {}
end

local function api_error(label, response)
  local body = json(response.body)
  local error_message = type(body.error) == "table" and body.error.message
  return body.message or error_message or ("%s failed (HTTP %s)"):format(label, response.status)
end

local function oauth_token()
  local config_path = require("copilot.auth").find_config_path()
  for _, filename in ipairs({ "hosts.json", "apps.json" }) do
    local path = config_path .. "/github-copilot/" .. filename
    if vim.fn.filereadable(path) == 1 then
      for _, app in pairs(json(table.concat(vim.fn.readfile(path), "\n"))) do
        if type(app) == "table" and app.oauth_token then
          return app.oauth_token
        end
      end
    end
  end
end

local function copilot_token(callback)
  if token and os.time() < expires_at - 60 then
    callback(nil, token)
    return
  end

  local oauth = oauth_token()
  if not oauth then
    callback("Copilot is not authenticated")
    return
  end

  curl.get("https://api.github.com/copilot_internal/v2/token", {
    timeout = TIMEOUT_MS,
    headers = {
      Accept = "application/json",
      Authorization = "Token " .. oauth,
      ["User-Agent"] = "Neovim",
    },
    callback = vim.schedule_wrap(function(response)
      if response.status ~= 200 then
        callback(api_error("Copilot token request", response))
        return
      end

      local body = json(response.body)
      if not body.token then
        callback("Copilot token response missing token")
        return
      end

      token = body.token
      expires_at = body.expires_at or (os.time() + 1800)
      callback(nil, token)
    end),
    on_error = vim.schedule_wrap(function(err)
      callback(err.message or "Copilot token request failed")
    end),
  })
end

local function staged_diff(callback)
  vim.system(
    { "git", "diff", "--cached", "--no-ext-diff", "--diff-algorithm=minimal" },
    { text = true, env = { GIT_MASTER = "1" } },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        callback("Failed to read staged diff: " .. vim.trim(result.stderr or ""))
        return
      end

      local diff = result.stdout or ""
      if vim.trim(diff) == "" then
        callback("No staged changes to summarize")
        return
      end

      callback(nil, diff)
    end)
  )
end

local function prompt(diff)
  if #diff > MAX_DIFF_CHARS then
    diff = diff:sub(1, MAX_DIFF_CHARS) .. "\n\n[Diff truncated.]"
  end

  return ([[Generate exactly one commit message for this staged git diff.

Rules:
- Output only the commit message, no markdown or explanation.
- Use Conventional Commits: <type>(<scope>): <description>.
- Use a scope only when it is obvious.
- Keep the subject under 72 characters.

Staged diff:
%s]]):format(diff)
end

local function clean_message(text)
  local lines = {}

  for _, line in ipairs(vim.split((text or ""):gsub("^Commit message:%s*", ""), "\n", { plain = true })) do
    if not line:match("^```") then
      lines[#lines + 1] = line
    end
  end

  return vim.trim(table.concat(lines, "\n"))
end

local function generate_message(diff, callback)
  copilot_token(function(err, bearer)
    if err then
      callback(err)
      return
    end

    local version = vim.version()
    curl.post("https://api.githubcopilot.com/chat/completions", {
      timeout = TIMEOUT_MS,
      headers = {
        Authorization = "Bearer " .. bearer,
        ["Content-Type"] = "application/json",
        ["Copilot-Integration-Id"] = "vscode-chat",
        ["Editor-Version"] = ("Neovim/%d.%d.%d"):format(version.major, version.minor, version.patch),
        ["User-Agent"] = "GitHubCopilotChat/0.26.7",
      },
      body = vim.json.encode({
        model = "gpt-4o",
        stream = false,
        max_tokens = 200,
        temperature = 0.2,
        messages = {
          { role = "system", content = "You write concise Conventional Commit messages." },
          { role = "user", content = prompt(diff) },
        },
      }),
      callback = vim.schedule_wrap(function(response)
        if response.status < 200 or response.status >= 300 then
          callback(api_error("Copilot chat request", response))
          return
        end

        local body = json(response.body)
        local choice = body.choices and body.choices[1]
        local message = clean_message(choice and choice.message and choice.message.content)

        if message == "" then
          callback("Copilot returned no commit message")
          return
        end

        callback(nil, message)
      end),
      on_error = vim.schedule_wrap(function(err)
        callback(err.message or "Copilot chat request failed")
      end),
    })
  end)
end

local function write_message(bufnr, message)
  local comment_char = require("neogit.lib.git").config.get("core.commentChar"):read()
  local comment_pattern = "^%s*"
    .. vim.pesc(comment_char and comment_char ~= "" and comment_char ~= "auto" and comment_char or "#")
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local footer = #lines

  for index, line in ipairs(lines) do
    if line:match(comment_pattern) then
      footer = index - 1
      break
    end
  end

  local message_lines = vim.split(message, "\n", { plain = true })
  if footer < #lines then
    message_lines[#message_lines + 1] = ""
  end

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, footer, false, message_lines)
  vim.bo[bufnr].modified = true

  local win = vim.fn.win_findbuf(bufnr)[1]
  if win then
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
end

function M.generate(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if running[bufnr] then
    vim.notify("Copilot is already generating a commit message", vim.log.levels.WARN)
    return
  end

  running[bufnr] = true
  vim.notify("Generating commit message with Copilot…")

  staged_diff(function(diff_err, diff)
    if diff_err then
      running[bufnr] = nil
      vim.notify(diff_err, diff_err:match("^No staged changes") and vim.log.levels.WARN or vim.log.levels.ERROR)
      return
    end

    generate_message(diff, function(message_err, message)
      running[bufnr] = nil

      if message_err then
        vim.notify(message_err, vim.log.levels.ERROR)
      elseif vim.api.nvim_buf_is_valid(bufnr) then
        write_message(bufnr, message)
        vim.notify("Commit message generated")
      end
    end)
  end)
end

function M.commit_with_generated_message()
  generate_on_next_commit = true
  vim.defer_fn(function()
    generate_on_next_commit = false
  end, NEXT_COMMIT_TIMEOUT_MS)

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
      if not is_commit_edit_message(event.buf) then
        return
      end

      vim.keymap.set("n", "<leader>ac", function()
        M.generate(event.buf)
      end, { buffer = event.buf, desc = "AI commit message" })

      if generate_on_next_commit then
        generate_on_next_commit = false
        vim.schedule(function()
          M.generate(event.buf)
        end)
      end
    end,
  })
end

return M
