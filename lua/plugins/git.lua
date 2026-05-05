local function set_gitsigns_keymap(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
end

local function refresh_current_line_blame(event)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(event.buf) then
      require("gitsigns.current_line_blame").update(event.buf)
    end
  end)
end

local function register_current_line_blame_refresh_autocmd()
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("RayGitSignsBlame", { clear = true }),
    desc = "Restore gitsigns current line blame after leaving insert mode",
    callback = refresh_current_line_blame,
  })
end

local function gitsigns_on_attach(bufnr)
  local gitsigns = require("gitsigns")

  set_gitsigns_keymap(bufnr, "n", "]c", function()
    if vim.wo.diff then
      vim.cmd.normal({ "]c", bang = true })

      return
    end

    gitsigns.nav_hunk("next")
  end, "Next git hunk")

  set_gitsigns_keymap(bufnr, "n", "[c", function()
    if vim.wo.diff then
      vim.cmd.normal({ "[c", bang = true })

      return
    end

    gitsigns.nav_hunk("prev")
  end, "Previous git hunk")

  set_gitsigns_keymap(bufnr, "n", "<leader>ghs", gitsigns.stage_hunk, "Stage hunk")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghr", gitsigns.reset_hunk, "Reset hunk")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghS", gitsigns.stage_buffer, "Stage buffer")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghR", gitsigns.reset_buffer, "Reset buffer")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghb", function()
    gitsigns.blame_line({ full = true })
  end, "Blame line")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghd", gitsigns.diffthis, "Diff this")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghD", function()
    gitsigns.diffthis("~")
  end, "Diff against HEAD~")
  set_gitsigns_keymap(bufnr, "n", "<leader>ght", gitsigns.toggle_current_line_blame, "Toggle line blame")
  set_gitsigns_keymap(bufnr, "n", "<leader>ghw", gitsigns.toggle_word_diff, "Toggle word diff")

  set_gitsigns_keymap(bufnr, "v", "<leader>ghs", function()
    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Stage hunk")

  set_gitsigns_keymap(bufnr, "v", "<leader>ghr", function()
    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, "Reset hunk")

  set_gitsigns_keymap(bufnr, { "o", "x" }, "ih", gitsigns.select_hunk, "Git hunk")
end

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      require("gitsigns").setup(opts)
      register_current_line_blame_refresh_autocmd()
    end,
    opts = {
      on_attach = gitsigns_on_attach,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
        virt_text_priority = 100,
      },
    },
  },
}
