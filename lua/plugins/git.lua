return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      require("gitsigns").setup(opts)

      vim.api.nvim_create_autocmd("InsertLeave", {
        desc = "Restore gitsigns current line blame after leaving insert mode",
        callback = function(event)
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(event.buf) then
              require("gitsigns.current_line_blame").update(event.buf)
            end
          end)
        end,
      })
    end,
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })

            return
          end

          gitsigns.nav_hunk("next")
        end, "Next git hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })

            return
          end

          gitsigns.nav_hunk("prev")
        end, "Previous git hunk")

        map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage hunk")
        map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset hunk")
        map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage buffer")
        map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", function()
          gitsigns.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>ghd", gitsigns.diffthis, "Diff this")
        map("n", "<leader>ghD", function()
          gitsigns.diffthis("~")
        end, "Diff against HEAD~")
        map("n", "<leader>ght", gitsigns.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>ghw", gitsigns.toggle_word_diff, "Toggle word diff")

        map("v", "<leader>ghs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk")

        map("v", "<leader>ghr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk")

        map({ "o", "x" }, "ih", gitsigns.select_hunk, "Git hunk")
      end,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
        virt_text_priority = 100,
      },
    },
  },
}
