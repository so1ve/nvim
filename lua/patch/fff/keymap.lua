local hacks = require("utils.hacks")

local M = {}

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

function M.patch()
  hacks.on_module("fff.picker_ui.picker_ui", function(picker)
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

        map_picker_buffer("n", "/", picker.focus_input_win, picker.state.list_buf)
        map_picker_buffer("n", "<C-j>", picker.move_down, picker.state.list_buf)
        map_picker_buffer("n", "<C-k>", picker.move_up, picker.state.list_buf)
        map_picker_buffer("n", "<C-n>", picker.move_down, picker.state.list_buf)
        map_picker_buffer("n", "<C-p>", picker.move_up, picker.state.list_buf)
        map_picker_buffer("n", "<C-d>", list_scroll(picker, 1), picker.state.list_buf)
        map_picker_buffer("n", "<C-u>", list_scroll(picker, -1), picker.state.list_buf)
        map_picker_buffer("n", "<C-b>", picker.scroll_preview_up, picker.state.list_buf)
        map_picker_buffer("n", "<C-f>", picker.scroll_preview_down, picker.state.list_buf)

        map_picker_buffer("n", "/", picker.focus_input_win, picker.state.preview_buf)
        map_picker_buffer("n", "<C-b>", picker.scroll_preview_up, picker.state.preview_buf)
        map_picker_buffer("n", "<C-f>", picker.scroll_preview_down, picker.state.preview_buf)
      end
    end)
  end)
end

return M
