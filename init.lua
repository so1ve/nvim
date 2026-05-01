vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

require("config.options")
require("config.autocmds")
require("config.keymaps")

vim.cmd.colorscheme("undefined")

require("config.lazy")
