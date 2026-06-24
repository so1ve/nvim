return {
  "mini.tabline",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  keys = {
    { "[b", "<cmd>bprevious<cr>", desc = "Previous buffer" },
    { "]b", "<cmd>bnext<cr>", desc = "Next buffer" },
  },
  config = function()
    local tabline = require("mini.tabline")

    tabline.setup({
      format = function(buf_id, label)
        local suffix = vim.bo[buf_id].modified and "[+] " or ""

        return " " .. tabline.default_format(buf_id, label) .. suffix .. " "
      end,
      tabpage_section = "right",
    })
  end,
}
