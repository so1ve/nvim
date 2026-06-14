vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

require("ray.config.options")
require("ray.config.diagnostics").setup()
require("ray.config.filetypes")
require("ray.config.autocmds")
require("ray.config.keymaps")
require("ray.config.commands")

vim.cmd.colorscheme("undefined")

require("ray.config.lazy")
