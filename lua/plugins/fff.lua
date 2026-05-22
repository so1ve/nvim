local function find_files()
  require("fff").find_files()
end

local function live_grep()
  require("fff").live_grep()
end

return {
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
  keys = {
    { "<leader><space>", find_files, desc = "Find files" },
    { "<leader>ff", find_files, desc = "Find files" },
    { "<leader>fg", live_grep, desc = "Live grep" },
  },
  opts = {
    layout = {
      prompt_position = "top",
    },
    prompt_vim_mode = true,
    keymaps = {
      close = { "<Esc>", "q" },
      move_down = { "<Down>", "<C-j>" },
      move_up = { "<Up>", "<C-k>" },
    },
  },
}
