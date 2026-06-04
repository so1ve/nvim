local edgy = require("integrations.edgy")

local neogit_view = edgy.view("Neogit", "NeogitStatus")

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
        edgy.with_focus(neogit_view, function()
          require("neogit").open()
        end),
        desc = "Git status",
      },
    },
    opts = {
      kind = "vsplit",
      commit_editor = {
        kind = "replace",
      },
      treesitter_diff_highlight = true,
    },
    config = function(_, opts)
      require("integrations.neogit.ai-commit").setup()
      require("patch.neogit.commit-view").patch()
      require("patch.neogit.hunk-paths").patch()
      require("neogit").setup(opts)
    end,
  },
  edgy.view_spec("right", neogit_view),
  edgy.neo_tree_exclusion_spec("NeogitStatus"),
}
