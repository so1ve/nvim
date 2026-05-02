return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  opts = {
    appearance = {
      kind_icons = require("config.icons").symbols,
    },
    keymap = {
      preset = "super-tab",
      ["<Tab>"] = {
        function(cmp)
          local has_sidekick, sidekick = pcall(require, "sidekick")

          if has_sidekick and sidekick.nes_jump_or_apply() then
            return true
          end

          local has_copilot, suggestion = pcall(require, "copilot.suggestion")

          if has_copilot and suggestion.is_visible() then
            suggestion.accept()
            return true
          end

          if cmp.snippet_active() then
            return cmp.accept()
          end

          return cmp.select_and_accept()
        end,
        "snippet_forward",
        "fallback",
      },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
      },
    },
  },
}
