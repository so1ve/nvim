local bufferline = require("integrations.bufferline")
local edgy = require("integrations.edgy")

local neotree_view = edgy.view("Neo Tree", "neo-tree", {
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

local function is_deleted_git_node(node)
  local status = node and node.extra and node.extra.git_status

  return node and node.type == "file" and type(status) == "string" and status:find("D", 1, true) ~= nil
end

local function split_lines(text)
  local normalized = text:gsub("\r\n", "\n")
  local lines = vim.split(normalized, "\n", { plain = true })

  if lines[#lines] == "" then
    table.remove(lines)
  end

  return lines
end

local function open_buffer_from_git(state, path, open_cmd, buf)
  if open_cmd == "tabnew" then
    vim.cmd.tabnew()
    vim.api.nvim_win_set_buf(0, buf)
    vim.bo[buf].buflisted = true

    return
  end

  require("neo-tree.utils").open_file(state, path, open_cmd, buf)
end

local function open_deleted_git_file(state, open_cmd)
  local node = state.tree:get_node()

  if not is_deleted_git_node(node) then
    return false
  end

  local path = node.path or node:get_id()
  local root = assert(vim.fs.root(state.path or path, ".git") or vim.fs.root(path, ".git"), "Git root not found")
  local relative = assert(vim.fs.relpath(root, path), "Deleted file is outside Git root"):gsub("\\", "/")
  local name = ("deleted://HEAD/%s"):format(relative)
  local existing = vim.fn.bufnr(name)

  if existing > 0 then
    open_buffer_from_git(state, name, open_cmd, existing)

    return true
  end

  local result = vim.system({ "git", "-C", root, "show", ("HEAD:%s"):format(relative) }, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR, { title = "Git deleted file" })

    return true
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local filetype = vim.filetype.match({ filename = path })

  vim.api.nvim_buf_set_name(buf, name)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, split_lines(result.stdout))
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("readonly", true, { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

  if filetype then
    vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
  end

  open_buffer_from_git(state, name, open_cmd, buf)

  return true
end

local function git_open(command, open_cmd)
  return function(state, toggle_directory)
    if open_deleted_git_file(state, open_cmd) then
      return
    end

    require("neo-tree.sources.common.commands")[command](state, toggle_directory)
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
      { "<leader>e", edgy.with_focus(neotree_view, "Neotree toggle"), desc = "Toggle explorer" },
      { "<leader>E", edgy.with_focus(neotree_view, "Neotree reveal"), desc = "Reveal current file" },
      { "<leader>gt", edgy.with_focus(neotree_view, "Neotree git_status"), desc = "Toggle git tree" },
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
        commands = {
          open = git_open("open", "e"),
          open_split = git_open("open_split", "split"),
          open_vsplit = git_open("open_vsplit", "vsplit"),
          open_tabnew = git_open("open_tabnew", "tabnew"),
        },
        window = {
          mappings = {
            ["<space>"] = "noop",
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
  edgy.view_spec("left", neotree_view),
  bufferline.offset_spec(bufferline.offset("neo-tree", "Neo Tree")),
}
