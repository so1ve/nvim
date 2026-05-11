local edgy = require("config.edgy")
local bufferline = require("config.bufferline")

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
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
    },
    opts = {
      enable_git_status = false,
      hide_root_node = true,
      retain_hidden_root_indent = true,
      use_libuv_file_watcher = true,
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
      },
      -- window = {
      --   mappings = {
      --     q = "close_window",
      --   },
      -- },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        window = {
          mappings = {
            ["<cr>"] = "open",
            ["<space>"] = "noop",
            ["/"] = "noop",
            ["f"] = "noop",
          },
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_ignored = false,
          hide_hidden = false,
          show_hidden_count = false,
          never_show = {
            ".git",
            ".svn",
            ".hg",
            "CVS",
            ".DS_Store",
            "Thumbs.db",
            "thumbs.db",
          },
          never_show_by_pattern = {
            "%.tsbuildinfo$",
          },
        },
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

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })

      require("neo-tree").setup(opts)
    end,
  },
  edgy.view_spec(
    "left",
    edgy.view("Explorer", "neo-tree", {
      filter = function(buf)
        local source = vim.b[buf].neo_tree_source

        return source == nil or source == "filesystem"
      end,
      open = "Neotree show",
      wo = { winbar = false },
    })
  ),
  bufferline.offset_spec(bufferline.offset("neo-tree", "Explorer")),
}
