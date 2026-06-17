local opt = vim.opt

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
opt.cmdheight = 0
opt.showcmd = true
opt.showcmdloc = "statusline"
opt.showmode = false
opt.title = true
opt.titlestring = "nvim: %t"
opt.winborder = "rounded"

-- neovide
if vim.g.neovide then
  vim.o.guifont = "R_Maple_Mono_NF_CN:h10:#h-full:#e-antialias"
  vim.g.neovide_title_background_color = "#212221"
  vim.g.neovide_floating_blur_amount_x = 6.0
  vim.g.neovide_floating_blur_amount_y = 6.0
end

-- interaction
opt.mouse = "a"
opt.mousemodel = "extend"
opt.clipboard = "unnamedplus"
opt.confirm = true
opt.keywordprg = ":RayKeywordPrg"

require("ray.config.terminal").setup()

-- scrolling
opt.scrolloff = 3
opt.sidescrolloff = 3

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
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

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
opt.completeopt = { "menu", "menuone", "noselect" }

-- messages
opt.shortmess:append("I")
opt.messagesopt = "wait:1000,history:500,progress:c"
