local g = vim.g
local opt = vim.opt

g.loaded_python_provider = 0
g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

g.loaded_2html_plugin = 1
g.loaded_gzip = 1
g.loaded_man = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_remote_plugins = 1
g.loaded_spellfile_plugin = 1
g.loaded_tarPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_zipPlugin = 1

-- to make keywordprg a no-op because multiple shift+k will eventually call the default behavior of keywordprg which is to open `:help` and breaks window layout
vim.api.nvim_create_user_command("RayKeywordPrg", function() end, { nargs = "*" })

-- ui
opt.termguicolors = true
opt.belloff = "all"
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.laststatus = 3
opt.showtabline = 2
opt.showcmd = true
opt.showcmdloc = "statusline"
opt.showmode = false
opt.title = true
opt.titlestring = "nvim: %t"
opt.winborder = "rounded"

-- interaction
opt.mouse = "a"
opt.mousemodel = "extend"
opt.clipboard = "unnamedplus"
opt.virtualedit = "block"
opt.confirm = true
opt.keywordprg = ":RayKeywordPrg"

require("ray.config.terminal").setup()

-- scrolling
opt.scrolloff = 3
opt.sidescrolloff = 3
opt.jumpoptions = "view"
opt.smoothscroll = true

-- wrapping
opt.linebreak = true
opt.breakindent = true

-- folds
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

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
  precedes = "<",
  extends = ">",
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.gdefault = true

-- splits
opt.equalalways = false
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- files
opt.fileformats = { "unix", "dos", "mac" }
opt.undofile = true
opt.swapfile = false
opt.autoread = true

-- sessions
opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "localoptions" }

-- responsiveness
opt.updatetime = 250
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.completeopt = { "menu", "menuone", "noselect" }

-- messages
opt.shortmess:append("I")
opt.messagesopt = "wait:1000,history:500,progress:c"
