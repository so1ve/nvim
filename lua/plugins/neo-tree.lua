local edgy = require("config.edgy")

local function open_neo_tree_on_startup()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  if vim.bo.buftype ~= "" or vim.fn.expand("%") == "" then
    return
  end

  vim.schedule(function()
    vim.cmd("Neotree show")
  end)
end

local function register_neo_tree_startup_autocmd()
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("RayNeoTree", { clear = true }),
    desc = "Open neo-tree after opening a file",
    once = true,
    callback = open_neo_tree_on_startup,
  })
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
    init = function()
      register_neo_tree_startup_autocmd()
    end,
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
    },
    opts = {
      enable_git_status = false,
      hide_root_node = true,
      retain_hidden_root_indent = true,
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
      },
      window = {
        mappings = {
          ["<leader>q"] = "close_window",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        window = {
          mappings = {
            ["<space>"] = { "toggle_node", nowait = false },
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
}
