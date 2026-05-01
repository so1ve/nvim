return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  cmd = { "Neotree" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-mini/mini.nvim",
  },
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({
          source = "filesystem",
          toggle = true,
          reveal = true,
          position = "left",
        })
      end,
      desc = "Toggle explorer",
    },
    {
      "<leader>E",
      function()
        require("neo-tree.command").execute({
          source = "filesystem",
          reveal = true,
          position = "left",
        })
      end,
      desc = "Reveal current file",
    },
  },
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    default_source = "filesystem",
    close_if_last_window = false,
    enable_diagnostics = true,
    enable_git_status = true,
    enable_modified_markers = true,
    enable_opened_markers = true,
    open_files_do_not_replace_types = { "terminal", "qf" },
    popup_border_style = "rounded",
    source_selector = {
      winbar = true,
      statusline = false,
      content_layout = "center",
      sources = {
        { source = "filesystem", display_name = "Files" },
        { source = "buffers", display_name = "Buffers" },
        { source = "git_status", display_name = "Git" },
      },
    },
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
      },
      git_status = {
        symbols = {
          added = "✚",
          deleted = "✖",
          modified = "●",
          renamed = "󰁕",
          untracked = "?",
          ignored = "◌",
          unstaged = "○",
          staged = "●",
          conflict = "",
        },
      },
    },
    nesting_rules = {
      package_json = {
        pattern = "package%.json",
        files = {
          "package-lock.json",
          "pnpm-lock.yaml",
          "pnpm-workspace.yaml",
          "yarn.lock",
          "bun.lock",
          "bun.lockb",
        },
      },
      tsconfig_json = {
        pattern = "tsconfig%.json",
        files = {
          "tsconfig.*.json",
          "jsconfig.json",
          "auto-imports.d.ts",
          "components.d.ts",
          "env.d.ts",
          "typed-router.d.ts",
        },
      },
    },
    window = {
      position = "left",
      width = 40,
      mappings = {
        ["<space>"] = { "toggle_node", nowait = false },
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["<esc>"] = "cancel",
        ["P"] = { "toggle_preview", config = { use_float = true } },
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["t"] = "open_tabnew",
        ["w"] = "noop",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["a"] = { "add", config = { show_path = "none" } },
        ["A"] = "add_directory",
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = "copy",
        ["m"] = "move",
        ["q"] = "close_window",
        ["R"] = "refresh",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
      },
    },
    filesystem = {
      bind_to_cwd = true,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      group_empty_dirs = false,
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
        hide_by_name = {
          ".DS_Store",
          "thumbs.db",
        },
        never_show = {
          ".git",
        },
      },
      window = {
        mappings = {
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["/"] = "fuzzy_finder",
          ["D"] = "fuzzy_finder_directory",
          ["f"] = "filter_on_submit",
          ["<C-x>"] = "clear_filter",
        },
      },
    },
    buffers = {
      bind_to_cwd = true,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      group_empty_dirs = false,
      show_unloaded = true,
      window = {
        mappings = {
          ["d"] = "buffer_delete",
          ["bd"] = "buffer_delete",
        },
      },
    },
    git_status = {
      window = {
        mappings = {
          ["A"] = "git_add_all",
          ["ga"] = "git_add_file",
          ["gu"] = "git_unstage_file",
          ["gr"] = "git_revert_file",
          ["gc"] = "git_commit",
          ["gp"] = "git_push",
        },
      },
    },
  },
}
