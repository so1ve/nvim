local opt = vim.opt

opt.termguicolors = true
opt.mouse = "a"
opt.mousemoveevent = true
opt.clipboard = "unnamedplus"

opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.laststatus = 3
opt.cmdheight = 0
opt.showmode = false
opt.confirm = true
opt.hidden = false

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
opt.autoread = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }

opt.fileformat = "unix"
opt.shortmess:append("I")
opt.messagesopt = "wait:1000,history:500,progress:c"
