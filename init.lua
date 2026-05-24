vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

require("config.options")
require("config.diagnostics").setup()
require("config.filetypes")
require("config.autocmds")
require("config.keymaps")
require("config.commands")

vim.cmd.colorscheme("undefined")

require("config.lazy")
