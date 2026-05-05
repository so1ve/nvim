local function snippets_last(a, b)
  local snippet_kind = require("blink.cmp.types").CompletionItemKind.Snippet
  local a_is_snippet = a.kind == snippet_kind
  local b_is_snippet = b.kind == snippet_kind

  if a_is_snippet ~= b_is_snippet then
    return not a_is_snippet
  end
end

return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "nvim-mini/mini.nvim",
    "xzbdmw/colorful-menu.nvim",
  },
  opts = {
    appearance = {
      kind_icons = require("config.icons").symbols,
    },
    snippets = {
      preset = "mini_snippets",
    },
    fuzzy = {
      sorts = { snippets_last, "score", "sort_text" },
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
      ["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-e>"] = { "hide", "fallback" },
    },
    cmdline = {
      keymap = {
        ["<Tab>"] = { "show", "accept" },
        ["<C-j>"] = { "select_next", "fallback_to_mappings" },
        ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
    completion = {
      menu = {
        border = "rounded",
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        window = {
          border = "rounded",
        },
      },
    },
  },
}
