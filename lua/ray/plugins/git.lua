return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "dlyongemallo/diffview-plus.nvim",
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
            require("ray.features.git.ai-commit").commit_with_generated_message()
          end,
        },
      },
      commit_editor = {
        staged_diff_split_kind = "vsplit",
        spell_check = false,
      },
    },
    config = function(_, opts)
      require("ray.features.git.ai-commit").setup()
      require("ray.patch.neogit").patch()
      require("neogit").setup(opts)
    end,
  },
  {
    "niekdomi/conflict.nvim",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
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
      local Hydra = require("ray.integrations.hydra")
      local conflict = require("conflict")

      conflict.setup(opts)

      Hydra({
        name = "Git Conflicts",
        mode = "n",
        body = "<leader>gc",
        heads = {
          {
            "n",
            function()
              conflict.navigate("next")
            end,
            { desc = "Next", group = "Move" },
          },
          {
            "p",
            function()
              conflict.navigate("prev")
            end,
            { desc = "Previous", group = "Move" },
          },
          { "r", "<cmd>Conflict refresh<cr>", { desc = "Refresh", group = "Move" } },
          {
            "c",
            function()
              conflict.choose("current")
            end,
            { desc = "Current", group = "Accept" },
          },
          {
            "i",
            function()
              conflict.choose("incoming")
            end,
            { desc = "Incoming", group = "Accept" },
          },
          {
            "B",
            function()
              conflict.choose("both")
            end,
            { desc = "Both", group = "Accept" },
          },
          {
            "b",
            function()
              conflict.choose("base")
            end,
            { desc = "Base", group = "Accept" },
          },
          { "l", conflict.list, { exit = true, desc = "Files", group = "Lists" } },
          { "Q", conflict.qflist, { exit_before = true, desc = "Quickfix", group = "Lists" } },
        },
      })
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
