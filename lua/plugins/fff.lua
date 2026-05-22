return {
  {
    "dmtrKovalenko/fff.nvim",
    cmd = {
      "FFFFind",
      "FFFScan",
      "FFFRefreshGit",
      "FFFClearCache",
      "FFFHealth",
      "FFFDebug",
      "FFFOpenLog",
    },
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    opts = {},
  },
  {
    "so1ve/snacks-fff.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "dmtrKovalenko/fff.nvim",
    },
    keys = {
      {
        "<leader>ff",
        function()
          require("snacks-fff").find_files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("snacks-fff").live_grep()
        end,
        desc = "Live grep",
      },
    },
  },
}
