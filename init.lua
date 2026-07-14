vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("ray.config.options")
require("ray.config.ui2")
require("ray.config.diagnostics").setup()
require("ray.config.filetypes")
require("ray.config.autocmds")
require("ray.config.ignore").setup()
require("ray.config.zpack")
require("ray.config.keymaps")
require("ray.config.commands")

vim.cmd.colorscheme("undefined")
