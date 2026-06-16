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
    opts = {
      prompt_vim_mode = true,
      wrap_around = true,
      layout = {
        prompt_position = "top",
        flex = {
          size = 120,
          wrap = "bottom",
        },
        path_shorten_strategy = "middle_number",
      },
      keymaps = {
        close = { "<Esc>", "q" },
        move_up = { "<Up>", "<C-p>", "<C-k>" },
        move_down = { "<Down>", "<C-n>", "<C-j>" },
        preview_scroll_up = "<C-b>",
        preview_scroll_down = "<C-f>",
        toggle_debug = "<A-d>",
        cycle_grep_modes = { "<S-Tab>", "<A-r>" },
        focus_list = "/",
        focus_preview = "<A-p>",
      },
      hl = {
        grep_match = "Search",
      },
    },
    config = function(_, opts)
      require("ray.patch.fff.backdrop").patch()
      require("ray.patch.fff.ignore").patch()
      require("ray.patch.fff.keymap").patch()
      require("ray.patch.fff.preview_match").patch()
      require("fff").setup(opts)
    end,
    keys = {
      {
        "<leader>ff",
        function()
          require("fff").find_files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("fff").live_grep()
        end,
        desc = "Live grep",
      },
    },
  },
}
