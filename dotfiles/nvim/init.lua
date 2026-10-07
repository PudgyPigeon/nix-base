-- 1. BASE SETTINGS & CUSTOM SHORTCUT LEADER
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- NETRW (FILE EXPLORER) BEHAVIOR
vim.g.netrw_banner = 0              -- Hide the bulky banner at the top
vim.g.netrw_liststyle = 3           -- Tree view style
vim.g.netrw_browse_split = 4        -- Open selected file in the previous (right-hand) window
vim.g.netrw_altv = 1                -- Open splits to the right
vim.g.netrw_winsize = 20            -- Default width percentage (20%)

-- 1.5 THEME SETUP
require("catppuccin").setup({
  flavour = "mocha", -- "latte", "frappe", "macchiato", or "mocha"
  transparent_background = false,
})
vim.cmd.colorscheme("catppuccin")

-- 2. SEAMLESS WINDOW NAVIGATION SHORTCUTS
vim.keymap.set({ "n", "t" }, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({ "n", "t" }, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({ "n", "t" }, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({ "n", "t" }, "<A-l>", "<C-\\><C-n><C-w>l")

-- 3. AUTOMATED TERMINAL INSERT MODE
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- 4. STARTUP AUTOMATIC SPLIT LAYOUT
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argc = vim.fn.argc()
    local is_directory = false

    -- Check if Neovim was launched with a folder argument (e.g., nvim .)
    if argc == 1 then
      local arg = vim.fn.argv(0)
      if vim.fn.isdirectory(arg) == 1 then
        is_directory = true
      end
    end

    -- Run layout only for empty startup (nvim) or directory launch (nvim .)
    if argc == 0 or is_directory then
      -- 1. Open netrw on left if not already opened
      if argc == 0 then
        vim.cmd("Ex")
      end

      -- 2. Slim down file explorer width (e.g., 20 columns) and lock it
      vim.cmd("vertical resize 20")
      vim.opt_local.winfixwidth = true

      -- 3. Open editor buffer to the right
      vim.cmd("rightbelow vsplit")
      vim.cmd("enew")

      -- 4. Open terminal spanning the bottom, lock height to x lines
      vim.cmd("botright split | term")
      vim.cmd("resize 8")
      vim.opt_local.winfixheight = true

      -- 5. Focus main editor buffer (top-right)
      vim.cmd("wincmd t")
      vim.cmd("wincmd l")
    end
  end,
})