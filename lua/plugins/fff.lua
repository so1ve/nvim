local function list_scroll(picker, direction)
  return function()
    local list_height = picker.state.layout and picker.state.layout.list_height or 10
    local count = math.max(1, math.floor(list_height / 2))
    local move = direction > 0 and picker.move_down or picker.move_up

    for _ = 1, count do
      move()
    end
  end
end

local function map_picker_buffer(mode, lhs, rhs, bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true })
end

local function cycle_picker_window(picker)
  return function()
    local current = vim.api.nvim_get_current_win()

    if current == picker.state.input_win then
      picker.focus_list_win()
    elseif
      current == picker.state.list_win
      and picker.state.preview_win
      and vim.api.nvim_win_is_valid(picker.state.preview_win)
    then
      picker.focus_preview_win()
    else
      picker.focus_input_win()
    end
  end
end

local function patch_snacks_like_keymaps()
  local hacks = require("utils.hacks")

  hacks.on_module("fff.picker_ui", function(picker)
    hacks.wrap(picker, "snacks_like_keymaps", "setup_keymaps", function(original)
      return function(...)
        original(...)

        map_picker_buffer("n", "q", picker.close, picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<C-j>", picker.move_down, picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<C-k>", picker.move_up, picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<C-d>", list_scroll(picker, 1), picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<C-u>", list_scroll(picker, -1), picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<C-b>", picker.scroll_preview_up, picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<C-f>", picker.scroll_preview_down, picker.state.input_buf)
        map_picker_buffer({ "i", "n" }, "<A-w>", cycle_picker_window(picker), picker.state.input_buf)

        map_picker_buffer("n", "/", picker.focus_input_win, picker.state.list_buf)
        map_picker_buffer("n", "<C-j>", picker.move_down, picker.state.list_buf)
        map_picker_buffer("n", "<C-k>", picker.move_up, picker.state.list_buf)
        map_picker_buffer("n", "<C-n>", picker.move_down, picker.state.list_buf)
        map_picker_buffer("n", "<C-p>", picker.move_up, picker.state.list_buf)
        map_picker_buffer("n", "<C-d>", list_scroll(picker, 1), picker.state.list_buf)
        map_picker_buffer("n", "<C-u>", list_scroll(picker, -1), picker.state.list_buf)
        map_picker_buffer("n", "<C-b>", picker.scroll_preview_up, picker.state.list_buf)
        map_picker_buffer("n", "<C-f>", picker.scroll_preview_down, picker.state.list_buf)
        map_picker_buffer("n", "<A-w>", cycle_picker_window(picker), picker.state.list_buf)

        map_picker_buffer("n", "/", picker.focus_input_win, picker.state.preview_buf)
        map_picker_buffer("n", "<C-b>", picker.scroll_preview_up, picker.state.preview_buf)
        map_picker_buffer("n", "<C-f>", picker.scroll_preview_down, picker.state.preview_buf)
        map_picker_buffer("n", "<A-w>", cycle_picker_window(picker), picker.state.preview_buf)
      end
    end)
  end)
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
    },
    config = function(_, opts)
      patch_snacks_like_keymaps()
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
