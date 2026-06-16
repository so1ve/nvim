return {
  "mini.diff",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  config = function()
    local diff = require("mini.diff")

    diff.setup({
      view = {
        style = "sign",
        signs = { add = "▌", change = "▌", delete = "▌" },
      },
      mappings = {
        apply = "gh",
        reset = "gH",
        textobject = "gh",
        goto_first = "[C",
        goto_prev = "[c",
        goto_next = "]c",
        goto_last = "]C",
      },
    })

    vim.keymap.set("n", "<leader>go", function()
      diff.toggle_overlay(0)
    end, { desc = "Toggle diff overlay" })

    vim.keymap.set("n", "<leader>gh", function()
      local hunks = diff.export("qf", { scope = "current" })

      if #hunks == 0 then
        vim.notify("No hunks in current file", vim.log.levels.INFO)

        return
      end

      vim.fn.setqflist(hunks, "r")
      vim.cmd.copen()
    end, { desc = "Current file hunks" })
  end,
}
