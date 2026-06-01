local function diffview_visual_range()
  local mode = vim.api.nvim_get_mode().mode
  local ctrl_v = vim.api.nvim_replace_termcodes("<C-v>", true, true, true)

  if mode == "v" or mode == "V" or mode == ctrl_v then
    local first = vim.fn.line(".")
    local last = vim.fn.line("v")

    if first > last then
      first, last = last, first
    end

    return first, last, true
  end

  local line = vim.fn.line(".")
  return line, line, false
end

local function write_diffview_index_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].modified then
    return
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("update")
  end)
end

local function stage_diffview_line()
  local view = require("diffview.lib").get_current_view()
  local entry = view and view.cur_entry
  local layout = view and view.cur_layout

  if not entry or not layout then
    return
  end

  local index_win
  local source_win

  if entry.kind == "working" then
    index_win = layout.a
    source_win = layout.b
  elseif entry.kind == "staged" then
    index_win = layout.b
    source_win = layout.a
  else
    vim.notify("Diffview line staging only works for working or staged entries", vim.log.levels.WARN)
    return
  end

  local index_bufnr = index_win and index_win.file and index_win.file.bufnr
  local source_bufnr = source_win and source_win.file and source_win.file.bufnr

  if not index_bufnr or not source_bufnr then
    vim.notify("Diffview could not find the index buffer for this entry", vim.log.levels.WARN)
    return
  end

  local current_bufnr = vim.api.nvim_get_current_buf()
  local first, last, is_visual = diffview_visual_range()

  if current_bufnr == index_bufnr then
    vim.cmd(("%d,%ddiffget %d"):format(first, last, source_bufnr))
  elseif current_bufnr == source_bufnr then
    vim.cmd(("%d,%ddiffput %d"):format(first, last, index_bufnr))
  else
    vim.notify("Put the cursor in one of the active Diffview diff buffers", vim.log.levels.WARN)
    return
  end

  if is_visual then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
  end

  write_diffview_index_buffer(index_bufnr)
end

return {
  {
    "dlyongemallo/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    dependencies = {
      "nvim-mini/mini.nvim",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Repo file history" },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
      keymaps = {
        diff2 = {
          { { "n", "x" }, "s", stage_diffview_line, { desc = "Stage / unstage current line or range" } },
        },
      },
    },
  },
}
