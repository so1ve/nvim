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
      commit_editor = {
        kind = "replace",
      },
      treesitter_diff_highlight = true,
    },
    config = function(_, opts)
      require("integrations.neogit.ai-commit").setup()
      require("patch.neogit.status").patch()
      require("patch.neogit.hunk-paths").patch()
      require("neogit").setup(opts)
    end,
  },
}
