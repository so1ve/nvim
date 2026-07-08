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
}
