local edgy = require("config.edgy")

local function open_search_replace()
  require("grug-far").open({ transient = true })
end

local function open_current_file_search_replace()
  require("grug-far").open({
    transient = true,
    prefills = { paths = vim.fn.expand("%") },
  })
end

return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {
      engines = {
        ripgrep = {
          defaults = {
            flags = "--multiline --multiline-dotall",
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
        open_current_file_search_replace,
        mode = { "n", "x" },
        desc = "Search and replace current file",
      },
      {
        "<leader>sR",
        open_search_replace,
        mode = { "n", "x" },
        desc = "Search and replace",
      },
    },
  },
  edgy.view_spec("right", edgy.view("Search & Replace", "grug-far")),
  edgy.neo_tree_exclusion_spec("grug-far"),
}
