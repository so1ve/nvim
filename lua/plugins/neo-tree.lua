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

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-mini/mini.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      group = vim.api.nvim_create_augroup("RayNeoTree", { clear = true }),
      desc = "Open neo-tree after opening a file",
      once = true,
      callback = open_neo_tree_on_startup,
    })
  end,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle explorer" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
  },
  opts = {
    close_if_last_window = true,
    enable_git_status = false,
    hide_root_node = true,
    retain_hidden_root_indent = true,
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      window = {
        mappings = {
          ["<space>"] = { "toggle_node", nowait = true },
        },
      },
      filtered_items = {
        hide_gitignored = true,
        never_show = {
          ".DS_Store",
          "thumbs.db",
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
}
