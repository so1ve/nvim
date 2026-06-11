local edgy = require("integrations.edgy")

return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {
      engines = {
        ripgrep = {
          defaults = {
            flags = "--smart-case",
          },
        },
      },
      keymaps = {
        close = { n = "<leader>q" },
        qflist = { n = "<localleader>F" },
      },
    },
    config = true,
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({
            transient = true,
            prefills = { paths = vim.fn.expand("%") },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and replace current file",
      },
      {
        "<leader>sR",
        function()
          require("grug-far").open({ transient = true })
        end,
        mode = { "n", "x" },
        desc = "Search and replace",
      },
    },
  },
  edgy.view_spec("right", edgy.view("Search & Replace", "grug-far")),
  edgy.neo_tree_exclusion_spec("grug-far"),
}
