return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
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
      kind = "replace",
      disable_insert_on_commit = true,
      commit_editor = {
        kind = "replace",
      },
      mappings = {
        commit_editor = {
          ["q"] = false,
        },
        status = {
          ["q"] = false,
          ["C"] = function()
            require("integrations.neogit.ai-commit").commit_with_generated_message()
          end,
        },
      },
      treesitter_diff_highlight = true,
    },
    config = function(_, opts)
      require("integrations.neogit.ai-commit").setup()
      require("patch.neogit.hunk-paths").patch()
      require("neogit").setup(opts)
    end,
  },
}
