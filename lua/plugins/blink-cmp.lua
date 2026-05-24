local function label_text(ctx)
  local highlights_info = require("colorful-menu").blink_highlights(ctx)

  if highlights_info then
    return highlights_info.label
  end

  return ctx.label
end

local function detail_text(ctx)
  if require("colorful-menu").blink_highlights(ctx) then
    return ""
  end

  local detail = ctx.item and ctx.item.detail

  if type(detail) ~= "string" then
    return ""
  end

  return detail:match("^[^\r\n]+") or ""
end

local function label_highlight(ctx)
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
end

local function cargo_lsp_items(ctx, items)
  if
    vim.bo[ctx.bufnr].filetype ~= "toml"
    or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ctx.bufnr), ":t") ~= "Cargo.toml"
  then
    return items
  end

  return vim
    .iter(items)
    :filter(function(item)
      return item.client_name ~= "crates.nvim" or (item.kind_name ~= "Version" and item.kind_name ~= "Feature")
    end)
    :totable()
end

return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "xzbdmw/colorful-menu.nvim",
    "so1ve/blink-noice-docs.nvim",
  },
  config = function(_, opts)
    require("colorful-menu").setup({
      ls = {
        fallback = false,
      },
    })
    require("blink.cmp").setup(opts)
    require("blink-noice-docs").setup()
  end,
  opts = {
    appearance = {
      kind_icons = require("config.icons").symbols,
    },
    keymap = {
      preset = "none",
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
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
      ["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-d>"] = { "scroll_documentation_down", "scroll_signature_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "scroll_signature_up", "fallback" },
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
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
        draw = {
          gap = 2,
          columns = { { "kind_icon" }, { "label" }, { "detail" }, { "kind" } },
          components = {
            label = {
              text = label_text,
              highlight = label_highlight,
            },
            detail = {
              width = { max = 30 },
              text = detail_text,
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
          transform_items = cargo_lsp_items,
        },
        snippets = {
          opts = {
            friendly_snippets = false,
          },
        },
      },
    },
    signature = {
      enabled = true,
    },
  },
}
