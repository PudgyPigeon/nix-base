-- 1.5 THEME SETUP
require("tokyonight").setup({
  style = "storm",
  transparent_background = true,
})

-- Everforest theme specific settings because it's not in NixPKgs as NVIM plugin
vim.opt.termguicolors = true
vim.o.background = "dark"
-- Settings must be set via vim.g before loading the theme:
vim.g.everforest_background = "hard" -- 'soft', 'medium', or 'hard'
vim.g.everforest_enable_italic = 1
vim.g.everforest_transparent_background = 0

vim.cmd.colorscheme("tokyonight-storm")
