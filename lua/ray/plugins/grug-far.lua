local edgy = require("ray.integrations.edgy")
local ignore = require("ray.config.ignore")

local function rg_flags()
  local flags = {}

  for _, name in ipairs(ignore.names) do
    flags[#flags + 1] = "--glob=!" .. name
  end

  for _, pattern in ipairs(ignore.patterns) do
    flags[#flags + 1] = "--glob=!" .. pattern
  end

  return table.concat(flags, " ")
end

return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {
      engines = {
        ripgrep = {
          extraArgs = rg_flags(),
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
