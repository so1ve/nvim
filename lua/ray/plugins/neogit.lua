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
      signs = {
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
      mappings = {
        status = {
          ["C"] = function()
            require("ray.features.git.ai-commit").commit_with_generated_message()
          end,
        },
      },
      treesitter_diff_highlight = true,
      commit_editor = {
        staged_diff_split_kind = "vsplit",
        spell_check = false,
      },
    },
    config = function(_, opts)
      require("ray.features.git.ai-commit").setup()
      require("ray.patch.neogit.hunk-paths").patch()
      require("neogit").setup(opts)
    end,
  },
}
