return {
  "mini.keymap",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  config = function()
    local keymap = require("mini.keymap")
    local map_combo = keymap.map_combo
    local map_multistep = keymap.map_multistep
    local combo_opts = { delay = vim.o.timeoutlen }

    for _, lhs in ipairs({ "jk", "jj" }) do
      map_combo("i", lhs, "<BS><BS><Esc>", combo_opts)
      map_combo("c", lhs, "<BS><BS><C-c>", combo_opts)
    end

    map_combo("t", "jk", "<BS><BS><C-\\><C-n>", combo_opts)
    map_combo({ "x", "s" }, "jk", "<BS><BS><Esc>", combo_opts)

    map_multistep("i", "<C-l>", { "minisnippets_next", "jump_after_close" })
    map_multistep("i", "<C-h>", { "minisnippets_prev", "jump_before_open" })
  end,
}
