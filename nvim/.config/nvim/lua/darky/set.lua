local o = vim.opt

o.guicursor = ""

o.nu = true
o.relativenumber = true

o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
o.expandtab = true

o.smartindent = true

o.wrap = false

o.swapfile = false
o.backup = false
o.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true

o.termguicolors = true

o.scrolloff = 8
o.signcolumn = "yes"
o.fillchars = { eob = " " }
o.isfname:append("@-@")
o.updatetime = 50

o.showmode = false;

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
