-- 1. BASE SETTINGS & CUSTOM SHORTCUT LEADER
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- NETRW (FILE EXPLORER) BEHAVIOR
vim.g.netrw_banner = 0             -- Hide bulky banner
vim.g.netrw_liststyle = 3          -- Tree view style
vim.g.netrw_browse_split = 4       -- Open selected file in editor window
vim.g.netrw_altv = 1               -- Open splits to the right
vim.g.netrw_winsize = 14           -- Smaller default width percentage

-- Group directories first, separated from regular files
vim.g.netrw_sort_sequence = "[\\/]$,*"

-- Sort by name (0 = name, 1 = time, 2 = size, 3 = ext)
vim.g.netrw_sort_by = "name"

-- Optional clean display tweaks
vim.g.netrw_banner = 0         -- Disable the noisy top header banner
vim.g.netrw_liststyle = 3      -- 3 = Tree view (1 = thin, 2 = long, 3 = tree)
vim.g.netrw_winsize = 25       -- Set Lexplore window width to 25%

-- Turn off automatic split equalization so your custom sizes stay locked
vim.opt.equalalways = false


