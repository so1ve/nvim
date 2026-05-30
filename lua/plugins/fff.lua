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
      prompt = " ",
      title = "Files",
      prompt_vim_mode = true,
      wrap_around = true,
      layout = {
        prompt_position = "top",
        flex = {
          size = 120,
          wrap = "bottom",
        },
        path_shorten_strategy = "middle_number",
        anchor = "center",
      },
      keymaps = {
        close = { "<Esc>", "q" },
        select = "<CR>",
        select_split = "<C-s>",
        select_vsplit = "<C-v>",
        select_tab = "<C-t>",
        move_up = { "<Up>", "<C-p>", "<C-k>" },
        move_down = { "<Down>", "<C-n>", "<C-j>" },
        preview_scroll_up = "<C-b>",
        preview_scroll_down = "<C-f>",
        toggle_debug = "<A-d>",
        cycle_grep_modes = { "<S-Tab>", "<A-r>" },
        cycle_previous_query = "<C-Up>",
        cycle_forward_query = "<C-Down>",
        toggle_select = "<Tab>",
        send_to_quickfix = "<C-q>",
        focus_list = "/",
        focus_preview = "<A-p>",
      },
      hl = {
        grep_match = "Search",
      },
    },
    config = function(_, opts)
      require("patch.fff.backdrop").patch()
      require("patch.fff.keymap").patch()
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
