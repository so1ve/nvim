return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "dlyongemallo/diffview-plus.nvim",
      "so1ve/copilot-ai-commit.nvim",
    },
    keys = {
      {
        "<leader>gg",
        function()
          require("neogit").open()
        end,
        desc = "Git status",
      },
    },
    opts = {
      treesitter_diff_highlight = true,
      disable_insert_on_commit = true,
      process_spinner = true,
      graph_style = "kitty",
      signs = {
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
      integrations = {
        codediff = false,
        diffview = true,
        snacks = false,
        mini_pick = false,
      },
      diff_viewer = "diffview",
      mappings = {
        status = {
          ["C"] = function()
            require("copilot-ai-commit").commit_with_generated_message()
          end,
        },
      },
      commit_editor = {
        staged_diff_split_kind = "vsplit",
        spell_check = false,
      },
    },
    config = function(_, opts)
      require("copilot-ai-commit").setup()
      require("neogit").setup(opts)
    end,
  },
  {
    "niekdomi/conflict.nvim",
    event = "BufReadPre",
    opts = {
      default_mappings = {
        current = false,
        incoming = false,
        both = false,
        base = false,
        none = false,
        next = false,
        prev = false,
      },
    },
    config = function(_, opts)
      local conflict = require("conflict")

      conflict.setup(opts)

      local map = function(keys, rhs, desc)
        vim.keymap.set("n", "<leader>gc" .. keys, rhs, { desc = desc })
      end

      map("n", function()
        conflict.navigate("next")
      end, "Next conflict")
      map("p", function()
        conflict.navigate("prev")
      end, "Previous conflict")
      map("r", "<cmd>Conflict refresh<cr>", "Refresh conflicts")
      map("c", function()
        conflict.choose("current")
      end, "Accept current")
      map("i", function()
        conflict.choose("incoming")
      end, "Accept incoming")
      map("B", function()
        conflict.choose("both")
      end, "Accept both")
      map("b", function()
        conflict.choose("base")
      end, "Accept base")
      map("l", conflict.list, "Conflict files")
      map("Q", conflict.qflist, "Conflicts quickfix")
    end,
  },
  {
    "dlyongemallo/diffview-plus.nvim",
    main = "diffview",
    cmd = {
      "DiffviewOpen",
      "DiffviewToggle",
      "DiffviewFileHistory",
      "DiffviewDiffFiles",
      "DiffviewMergeFiles",
      "DiffviewDiffDirs",
      "DiffviewClose",
    },
    opts = function()
      local close = function()
        require("diffview").close(nil, { force = false })
      end
      local close_map = { "n", "q", close, { desc = "Close Diffview" } }

      return {
        keymaps = {
          view = { close_map },
          file_panel = { close_map },
          file_history_panel = { close_map },
        },
      }
    end,
  },
}
