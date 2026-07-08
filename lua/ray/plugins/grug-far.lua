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
      startInInsertMode = false,
    },
    keys = {
      {
        "<leader>sr",
        function()
          require("panels").open("grug-far", function()
            require("grug-far").open({
              transient = true,
              prefills = { paths = vim.fn.expand("%") },
            })
          end)
        end,
        mode = { "n", "x" },
        desc = "Search and replace current file",
      },
      {
        "<leader>sR",
        function()
          require("panels").open("grug-far", function()
            require("grug-far").open({ transient = true })
          end)
        end,
        mode = { "n", "x" },
        desc = "Search and replace",
      },
    },
  },
}
