local bufferline = require("integrations.bufferline")
local edgy = require("integrations.edgy")

local explorer_view = edgy.view("Explorer", "neo-tree", {
  filter = function(buf)
    local source = vim.b[buf].neo_tree_source

    return source == nil or source == "filesystem" or source == "git_status"
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
    init = function()
      vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter", "WinEnter" }, {
        desc = "Keep Neo-tree windows free of sign columns",
        callback = function(args)
          if vim.bo[args.buf].filetype ~= "neo-tree" then
            return
          end

          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local", win = win })
            end
          end
        end,
      })
    end,
    keys = {
      { "<leader>e", edgy.with_focus(explorer_view, "Neotree toggle"), desc = "Toggle explorer" },
      { "<leader>E", edgy.with_focus(explorer_view, "Neotree reveal"), desc = "Reveal current file" },
      { "<leader>gt", edgy.with_focus(explorer_view, "Neotree git_status"), desc = "Toggle git tree" },
    },
    opts = {
      hide_root_node = true,
      source_selector = {
        winbar = true,
        content_layout = "center",
        tabs_layout = "equal",
        sources = {
          { source = "filesystem", display_name = "Files" },
          { source = "git_status", display_name = "Git" },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
      },
      window = {
        mappings = {
          ["<C-b>"] = { smooth_scroll_or_preview(-1, 10), desc = "Smooth page up or scroll preview" },
          ["<C-f>"] = { smooth_scroll_or_preview(1, -10), desc = "Smooth page down or scroll preview" },
          ["O"] = { "show_help", nowait = false, config = { title = "Open", prefix_key = "O" } },
          ["Os"] = "open_split",
          ["Ot"] = "open_tabnew",
          ["Ov"] = "open_vsplit",
          ["Ow"] = "open_with_window_picker",
          ["S"] = "noop",
          ["s"] = "noop",
          ["t"] = "noop",
          ["w"] = "noop",
        },
      },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true,
        },
        window = {
          mappings = {
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
      git_status = {
        window = {
          mappings = {
            ["s"] = "git_toggle_file_stage",
            ["a"] = "git_add_file",
            ["u"] = "git_unstage_file",
            ["r"] = "git_revert_file",
            ["ga"] = "noop",
            ["gu"] = "noop",
            ["gU"] = "noop",
            ["gt"] = "noop",
            ["gr"] = "noop",
            ["gc"] = "noop",
            ["gp"] = "noop",
            ["gg"] = "noop",
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
  edgy.view_spec("left", explorer_view),
  bufferline.offset_spec(bufferline.offset("neo-tree", "Neo Tree")),
}
