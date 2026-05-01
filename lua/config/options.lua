local opt = vim.opt

opt.termguicolors = true
opt.mouse = "a"
opt.mousemoveevent = true
opt.clipboard = "unnamedplus"

opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.linebreak = true
opt.breakindent = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true

opt.list = true
opt.listchars = {
  lead = "·",
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.splitright = true
opt.splitbelow = true

opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }

opt.fileformat = "unix"
opt.shortmess:append("I")
