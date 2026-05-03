local function hide_copilot_suggestions()
  require("copilot.suggestion").dismiss()
  vim.b.copilot_suggestion_hidden = true
end

local function restore_copilot_suggestions()
  vim.b.copilot_suggestion_hidden = false
end

local function register_copilot_blink_autocmds()
  local group = vim.api.nvim_create_augroup("RayCopilotBlink", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "BlinkCmpMenuOpen",
    desc = "Hide Copilot inline suggestions while blink menu is open",
    callback = hide_copilot_suggestions,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "BlinkCmpMenuClose",
    desc = "Restore Copilot inline suggestions after blink menu closes",
    callback = restore_copilot_suggestions,
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
  },
}
