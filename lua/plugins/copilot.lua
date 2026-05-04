local uv = vim.uv or vim.loop

local copilot_restart_delay_ms = 5000
local copilot_restart_window_ms = 5 * 60 * 1000
local copilot_restart_limit = 3
local copilot_restart_timestamps = {}

local function prune_copilot_restart_timestamps(now)
  local recent_timestamps = {}
  for _, timestamp in ipairs(copilot_restart_timestamps) do
    if now - timestamp <= copilot_restart_window_ms then
      recent_timestamps[#recent_timestamps + 1] = timestamp
    end
  end

  copilot_restart_timestamps = recent_timestamps
end

local function restart_copilot_after_exit(code)
  if code == 0 then
    return
  end

  local now = uv.now()
  prune_copilot_restart_timestamps(now)

  if #copilot_restart_timestamps >= copilot_restart_limit then
    vim.notify(
      "Copilot LSP exited repeatedly; leaving it offline. Run :Copilot enable after the network recovers.",
      vim.log.levels.WARN
    )

    return
  end

  copilot_restart_timestamps[#copilot_restart_timestamps + 1] = now
  vim.defer_fn(function()
    local ok, err = pcall(vim.cmd, "Copilot enable")
    if not ok then
      vim.notify("Failed to restart Copilot LSP: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, copilot_restart_delay_ms)
end

local function register_copilot_blink_autocmds()
  local group = vim.api.nvim_create_augroup("RayCopilotBlink", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "BlinkCmpMenuOpen",
    desc = "Hide Copilot inline suggestions while blink menu is open",
    callback = function()
      require("copilot.suggestion").dismiss()
      vim.b.copilot_suggestion_hidden = true
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "BlinkCmpMenuClose",
    desc = "Restore Copilot inline suggestions after blink menu closes",
    callback = function()
      vim.b.copilot_suggestion_hidden = false
    end,
  })
end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function(_, opts)
    require("copilot").setup(opts)
    register_copilot_blink_autocmds()
  end,
  opts = {
    panel = {
      enabled = false,
    },
    suggestion = {
      auto_trigger = true,
    },
    server_opts_overrides = {
      on_exit = function(code)
        restart_copilot_after_exit(code)
      end,
    },
  },
}
