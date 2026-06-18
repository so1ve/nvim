local edgy = require("ray.integrations.edgy")

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
        close = { n = "q" },
        qflist = { n = "<localleader>F" },
        refresh = { n = "<C-r>" },
      },
    },
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
}
