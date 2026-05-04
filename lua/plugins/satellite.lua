return {
  "lewis6991/satellite.nvim",
  cmd = {
    "SatelliteDisable",
    "SatelliteEnable",
    "SatelliteRefresh",
  },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    current_only = true,
    excluded_filetypes = {
      "grug-far",
      "help",
      "lazy",
      "man",
      "mason",
      "neo-tree",
      "noice",
      "notify",
      "qf",
      "snacks_dashboard",
    },
    handlers = {
      gitsigns = {
        overlap = true,
      },
      marks = {
        enable = false,
      },
      quickfix = {
        enable = false,
      },
      search = {
        enable = false,
      },
    },
  },
}
