local restart = {
  delay = 5000,
  window = 5 * 60 * 1000,
  limit = 3,
  times = {},
}

local function restart_copilot(code)
  if code == 0 then
    return
  end

  local now = vim.uv.now()

  restart.times = vim.tbl_filter(function(time)
    return now - time <= restart.window
  end, restart.times)

  if #restart.times >= restart.limit then
    vim.notify(
      "Copilot LSP exited repeatedly; leaving it offline. Run :Copilot enable after the network recovers.",
      vim.log.levels.WARN
    )
    return
  end

  restart.times[#restart.times + 1] = now

  vim.defer_fn(function()
    local ok, err = pcall(vim.cmd, "Copilot enable")
    if not ok then
      vim.notify("Failed to restart Copilot LSP: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, restart.delay)
end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",

  opts = {
    panel = { enabled = false },
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = false,
      },
    },
    server_opts_overrides = {
      on_exit = restart_copilot,
    },
  },

  config = function(_, opts)
    require("copilot").setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuOpen",
      desc = "Hide Copilot inline suggestions while blink menu is open",
      callback = function()
        require("copilot.suggestion").dismiss()
        vim.b.copilot_suggestion_hidden = true
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuClose",
      desc = "Restore Copilot inline suggestions after blink menu closes",
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })
  end,
}
