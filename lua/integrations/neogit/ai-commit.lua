local curl = require("plenary.curl")
local hacks = require("utils.hacks")

local M = {}

local TIMEOUT_MS = 15000
local MAX_DIFF_CHARS = 20000

local pending = false
local running = {}
local token
local expires_at = 0
local api_base = "https://api.githubcopilot.com"

local function json(response)
  local ok, data = pcall(vim.json.decode, response.body or "")
  return ok and data or {}
end

local function http_error(label, response)
  local body = json(response)
  local message = body.message or (body.error and body.error.message)

  return message or ("%s failed (HTTP %s)"):format(label, response.status)
end

local function oauth_token()
  for _, app in pairs(require("copilot.auth").get_creds() or {}) do
    if type(app) == "table" and app.oauth_token then
      return app.oauth_token
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
      Authorization = "Bearer " .. oauth,
      ["User-Agent"] = "Neovim",
    },
    callback = vim.schedule_wrap(function(response)
      if response.status ~= 200 then
        callback(http_error("Copilot token request", response))
        return
      end

      local body = json(response)
      if not body.token then
        callback("Copilot token response missing token")
        return
      end

      token = body.token
      expires_at = body.expires_at or (os.time() + 1800)
      api_base = body.endpoints and body.endpoints.api or api_base
      callback(nil, token)
    end),
    on_error = vim.schedule_wrap(function(err)
      callback(err.message or "Copilot token request failed")
    end),
  })
end

local function clean_message(text)
  local lines = {}

  for _, line in ipairs(vim.split(text:gsub("^Commit message:%s*", ""), "\n", { plain = true })) do
    if not line:match("^```") then
      lines[#lines + 1] = line
    end
  end

  return vim.trim(table.concat(lines, "\n"))
end

local function chat(prompt, callback)
  copilot_token(function(err, bearer)
    if err then
      callback(err)
      return
    end

    local version = vim.version()
    curl.post(api_base:gsub("/+$", "") .. "/chat/completions", {
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
          { role = "user", content = prompt },
        },
      }),
      callback = vim.schedule_wrap(function(response)
        if response.status < 200 or response.status >= 300 then
          callback(http_error("Copilot chat request", response))
          return
        end

        local body = json(response)
        local choice = body.choices and body.choices[1]
        local message = choice and choice.message and clean_message(choice.message.content or "")

        if not message or message == "" then
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

local function staged_diff(callback)
  vim.system(
    { "git", "diff", "--cached", "--no-ext-diff", "--diff-algorithm=minimal" },
    {
      text = true,
      env = { GIT_MASTER = "1" },
    },
    vim.schedule_wrap(function(result)
      if result.code == 0 then
        callback(nil, result.stdout or "")
      else
        callback("Failed to read staged diff: " .. vim.trim(result.stderr or ""))
      end
    end)
  )
end

local function commit_prompt(diff)
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

local function first_comment_line(bufnr)
  local char = require("neogit.lib.git").config.get("core.commentChar"):read()
  local pattern = "^%s*" .. vim.pesc(char and char ~= "" and char ~= "auto" and char or "#")

  for index, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match(pattern) then
      return index - 1
    end
  end

  return vim.api.nvim_buf_line_count(bufnr)
end

local function write_message(bufnr, message)
  local lines = vim.split(message, "\n", { plain = true })
  local footer = first_comment_line(bufnr)

  if footer < vim.api.nvim_buf_line_count(bufnr) then
    lines[#lines + 1] = ""
  end

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, footer, false, lines)
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

  staged_diff(function(err, diff)
    if err or vim.trim(diff) == "" then
      running[bufnr] = nil
      vim.notify(err or "No staged changes to summarize", err and vim.log.levels.ERROR or vim.log.levels.WARN)
      return
    end

    chat(commit_prompt(diff), function(chat_err, message)
      running[bufnr] = nil

      if chat_err then
        vim.notify(chat_err, vim.log.levels.ERROR)
      elseif vim.api.nvim_buf_is_valid(bufnr) then
        write_message(bufnr, message)
        vim.notify("Commit message generated")
      end
    end)
  end)
end

function M.commit()
  if not require("neogit.lib.git").status.anything_staged() then
    vim.notify("No staged changes to commit", vim.log.levels.WARN)
    return
  end

  pending = true

  require("neogit.lib.async").void(function()
    require("neogit.popups.commit.actions").commit({
      get_arguments = function()
        return {}
      end,
    })
  end)()
end

function M.setup()
  hacks.wrap(require("neogit.buffers.editor"), "neogit_ai-commit_editor", "open", function(open)
    return function(self, kind)
      local result = open(self, kind)
      local bufnr = self.filename:match("COMMIT_EDITMSG$") and self.buffer and self.buffer.handle

      if bufnr then
        vim.keymap.set("n", "<leader>ac", function()
          M.generate(bufnr)
        end, { buffer = bufnr, desc = "AI commit message" })

        if pending then
          pending = false
          vim.schedule(function()
            M.generate(bufnr)
          end)
        end
      end

      return result
    end
  end)
end

return M
