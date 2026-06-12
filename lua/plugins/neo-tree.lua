local bufferline = require("integrations.bufferline")
local ignore = require("config.ignore")
local edgy = require("integrations.edgy")

local neotree_view = edgy.view("Neo Tree", "neo-tree", {
  filter = function(buf)
    local source = vim.b[buf].neo_tree_source

    return source == nil or source == "filesystem"
  end,
  open = "Neotree show",
  wo = { winbar = false },
})

local function smooth_scroll_or_preview(tree_direction, preview_direction)
  return function(state)
    if require("neo-tree.sources.common.preview").is_active() then
      state.config = { direction = preview_direction }

      return state.commands.scroll_preview(state)
    end

    require("patch.neoscroll.cursor-first").scroll_page(tree_direction)
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-mini/mini.nvim",
    },
    keys = {
      { "<leader>e", edgy.with_focus(neotree_view, "Neotree toggle"), desc = "Toggle explorer" },
      { "<leader>E", edgy.with_focus(neotree_view, "Neotree reveal"), desc = "Reveal current file" },
    },
    opts = {
      hide_root_node = true,
      retain_hidden_root_indent = true,
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
      },
      window = {
        mappings = {
          ["<C-b>"] = { smooth_scroll_or_preview(-1, 10), desc = "Smooth page up or scroll preview" },
          ["<C-f>"] = { smooth_scroll_or_preview(1, -10), desc = "Smooth page down or scroll preview" },
          ["<C-r>"] = "refresh",
          ["O"] = { "show_help", nowait = false, config = { title = "Open", prefix_key = "O" } },
          ["Os"] = "open_split",
          ["Ot"] = "open_tabnew",
          ["Ov"] = "open_vsplit",
          ["Ow"] = "open_with_window_picker",
          ["R"] = "noop",
          ["S"] = "noop",
          ["s"] = "noop",
          ["t"] = "noop",
          ["w"] = "noop",
          ["Y"] = "clear_clipboard",
        },
      },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true,
        },
        window = {
          mappings = {
            ["<Tab>"] = "toggle_node",
            ["<space>"] = "noop",
            ["/"] = "noop",
            ["f"] = "noop",
          },
        },
        filtered_items = ignore.filtered_items(),
      },
      nesting_rules = {
        ["package.json"] = {
          pattern = "^package%.json$",
          files = {
            "package-lock.json",
            "yarn.lock",
            "pnpm-lock.yaml",
            "pnpm-workspace.yaml",
            "bun.lockb",
            "bun.lock",
          },
        },
        ["tsconfig.json"] = {
          pattern = "^tsconfig%.json$",
          files = {
            "tsconfig.*.json",
            "jsconfig.json",
            "auto-imports.d.ts",
            "components.d.ts",
            "env.d.ts",
            "typed-router.d.ts",
          },
        },
        ["Cargo.toml"] = {
          pattern = "^Cargo%.toml$",
          files = {
            "Cargo.lock",
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local function normalize_path(path)
        local normalized = vim.fs.normalize(path)

        if vim.fn.has("win32") == 1 then
          normalized = normalized:lower()
        end

        return normalized
      end

      local function on_delete(path)
        local deleted_path = normalize_path(path)

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and normalize_path(vim.api.nvim_buf_get_name(buf)) == deleted_path then
            Snacks.bufdelete({ buf = buf, force = true })

            break
          end
        end
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
        { event = events.FILE_DELETED, handler = on_delete },
      })

      require("neo-tree").setup(opts)
    end,
  },
  edgy.view_spec("left", neotree_view),
  bufferline.offset_spec(bufferline.offset("neo-tree", "Neo Tree")),
}
