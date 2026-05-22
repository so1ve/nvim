local function find_files()
  require("snacks-fff").find_files()
end

local function live_grep()
  require("snacks-fff").live_grep()
end

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
    config = function(_, opts)
      require("fff").setup(opts)
    end,
  },
  {
    dir = "D:/Workspace/snacks-fff.nvim",
    name = "snacks-fff.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "dmtrKovalenko/fff.nvim",
    },
    keys = {
      { "<leader><space>", find_files, desc = "Find files" },
      { "<leader>ff", find_files, desc = "Find files" },
      { "<leader>fg", live_grep, desc = "Live grep" },
    },
  },
}
