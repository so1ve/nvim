local edgy = require("integrations.edgy")

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
        edgy.with_main(function()
          require("neogit").open()
        end),
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
      require("patch.neogit.replace-close").patch()
      require("neogit").setup(opts)
    end,
  },
}
