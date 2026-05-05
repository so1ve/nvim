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
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  opts = {
    -- create a vertical split on the right 25% of the screen
    windowCreationCommand = [[execute 'botright vertical ' . float2nr(&columns * 0.25) . 'vsplit | setlocal winfixwidth']],
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
  config = function(_, opts)
    require("grug-far").setup(opts)
  end,
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
}
