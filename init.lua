vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

vim.cmd.colorscheme("undefined")

require("ray.config.options")
require("ray.config.ui2")
require("ray.config.diagnostics").setup()
require("ray.config.filetypes")
require("ray.config.autocmds")
require("ray.config.lazy")
require("ray.config.keymaps")
require("ray.config.commands")
