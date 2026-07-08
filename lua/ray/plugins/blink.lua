local function accept_ai()
  local suggestion = require("copilot.suggestion")

  if not suggestion.is_visible() then
    return false
  end

  suggestion.accept()

  return true
end

local function accept_nes()
  local nes = require("copilot.nes.api")

  if not nes.nes_apply_pending_nes() then
    return false
  end

  nes.nes_walk_cursor_end_edit()

  return true
end

return {
  "saghen/blink.cmp",
  version = vim.version.range("1.*"),
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "nvim-mini/mini.nvim",
    "xzbdmw/colorful-menu.nvim",
    "so1ve/tiny-md.nvim",
  },
  config = function(_, opts)
    require("colorful-menu").setup({
      ls = {
        fallback = false,
      },
    })
    require("blink.cmp").setup(opts)
  end,
  opts = {
    appearance = {
      kind_icons = require("ray.config.icons").symbols,
    },
    snippets = {
      preset = "mini_snippets",
    },
    keymap = {
      preset = "none",
      ["<Tab>"] = {
        "select_and_accept",
        accept_ai,
        accept_nes,
        "fallback",
      },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-d>"] = { "scroll_documentation_down", "scroll_signature_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "scroll_signature_up", "fallback" },
      ["<C-n>"] = { "select_next", "show" },
      ["<C-p>"] = { "select_prev", "show" },
      ["<C-j>"] = { "select_next", "show" },
      ["<C-k>"] = { "select_prev", "show" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
    },
    cmdline = {
      keymap = {
        ["<Tab>"] = { "show", "accept" },
        ["<C-j>"] = { "select_next", "show" },
        ["<C-k>"] = { "select_prev", "show" },
      },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
    completion = {
      menu = {
        draw = {
          gap = 2,
          columns = { { "kind_icon" }, { "label" }, { "detail" }, { "kind" } },
          components = {
            label = {
              text = function(ctx)
                local highlights_info = require("colorful-menu").blink_highlights(ctx)

                if highlights_info then
                  return highlights_info.label
                end

                return ctx.label
              end,
              highlight = function(ctx)
                local highlights_info = require("colorful-menu").blink_highlights(ctx)

                if highlights_info then
                  local highlights = highlights_info.highlights or {}

                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                  end

                  return highlights
                end

                local highlights = {
                  { 0, #ctx.label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
                }

                for _, idx in ipairs(ctx.label_matched_indices) do
                  table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                end

                return highlights
              end,
            },
            detail = {
              width = { max = 30 },
              text = function(ctx)
                if require("colorful-menu").blink_highlights(ctx) then
                  return ""
                end

                local detail = ctx.item and ctx.item.detail

                if type(detail) ~= "string" then
                  return ""
                end

                return detail:match("^[^\r\n]+") or ""
              end,
              highlight = "BlinkCmpLabelDetail",
            },
            kind = {
              text = function(ctx)
                return ctx.kind or ""
              end,
              highlight = "Comment",
            },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        draw = function(opts)
          require("tiny-md.blink").draw(opts)
        end,
        window = {
          desired_min_width = 24,
          desired_min_height = 5,
          direction_priority = {
            menu_north = { "e", "n", "s" },
            menu_south = { "e", "s", "n" },
          },
        },
      },
    },
    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        lsp = {
          transform_items = function(ctx, items)
            if
              vim.bo[ctx.bufnr].filetype ~= "toml"
              or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ctx.bufnr), ":t") ~= "Cargo.toml"
            then
              return items
            end

            return vim
              .iter(items)
              :filter(function(item)
                return item.client_name ~= "crates.nvim"
                  or (item.kind_name ~= "Version" and item.kind_name ~= "Feature")
              end)
              :totable()
          end,
        },
        snippets = {
          opts = {
            use_items_cache = true,
            use_label_description = true,
          },
        },
      },
    },
    signature = {
      enabled = true,
    },
  },
}
