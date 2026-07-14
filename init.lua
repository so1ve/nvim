vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("ray.config.options")
require("vim._core.ui2").enable()
require("ray.config.diagnostics").setup()
require("ray.config.filetypes")
require("ray.config.autocmds")
require("ray.config.ignore").setup()

vim.pack.add({ "https://github.com/zuqini/zpack.nvim" })

require("zpack").setup({
  spec = {
    { import = "ray.plugins" },
  },
  defaults = {
    lazy = true,
    confirm = false,
  },
})

require("ray.config.keymaps")
require("ray.config.commands")

vim.cmd.colorscheme("undefined")
