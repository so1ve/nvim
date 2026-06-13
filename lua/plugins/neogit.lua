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
      disable_insert_on_commit = true,
      mappings = {
        status = {
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
