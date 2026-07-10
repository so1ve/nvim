return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "esmuellert/codediff.nvim",
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
        codediff = true,
        diffview = false,
        snacks = false,
        mini_pick = false,
      },
      diff_viewer = "codediff",
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
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
      diff = {
        compute_moves = true,
      },
      explorer = {
        initial_focus = "explorer",
        visible_groups = {
          staged = true,
          unstaged = true,
          conflicts = true,
        },
      },
      keymaps = {
        view = {
          next_file = "<Tab>",
          prev_file = "<S-Tab>",
        },
        explorer = {
          refresh = "<c-r>",
          stage_all = "S",
          unstage_all = "U",
          restore = "x",
        },
        conflict = {
          next_conflict = "<leader>gcn",
          prev_conflict = "<leader>gcp",
          accept_incoming = "<leader>gci",
          accept_current = "<leader>gcc",
          accept_both = "<leader>gcb",
          discard = "<leader>gcB",
          accept_all_incoming = "<leader>gcI",
          accept_all_current = "<leader>gcC",
          accept_all_both = "<leader>gcA",
          discard_all = "<leader>gcX",
          diffget_incoming = "2do",
          diffget_current = "3do",
        },
      },
    },
  },
}
