local opt = vim.opt

-- ui
opt.termguicolors = true
opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.laststatus = 3
opt.cmdheight = 0
opt.showmode = false
opt.title = true
opt.titlestring = "nvim: %t"

-- interaction
opt.mouse = "a"
opt.mousemodel = "extend"
opt.mousemoveevent = true
opt.clipboard = "unnamedplus"
opt.confirm = true

-- scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- wrapping
opt.linebreak = true
opt.breakindent = true

-- indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true

-- whitespace
opt.list = true
opt.listchars = {
  lead = "·",
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- splits
opt.splitright = true
opt.splitbelow = true

-- files
opt.fileformat = "unix"
opt.undofile = true
opt.autoread = true

-- responsiveness
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }

-- messages
opt.shortmess:append("I")
opt.messagesopt = "wait:1000,history:500,progress:c"
