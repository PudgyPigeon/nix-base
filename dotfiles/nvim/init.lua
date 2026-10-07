-- 1. BASE SETTINGS & CUSTOM SHORTCUT LEADER
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- NETRW (FILE EXPLORER) BEHAVIOR
vim.g.netrw_banner = 0              -- Hide bulky banner
vim.g.netrw_liststyle = 3           -- Tree view style
vim.g.netrw_browse_split = 4        -- Open selected file in editor window
vim.g.netrw_altv = 1                -- Open splits to the right
vim.g.netrw_winsize = 14            -- Smaller default width percentage

-- Strip line numbers inside Netrw so the sidebar stays slim
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.foldcolumn = "0"
  end,
})

-- 1.5 THEME SETUP
require("kanagawa").setup({
  flavour = "wave",
  transparent_background = false,
})
vim.cmd.colorscheme("kanagawa-wave")

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
-- Turn off automatic split equalization so your custom sizes stay locked
vim.opt.equalalways = false

-- 4. STARTUP AUTOMATIC SPLIT LAYOUT
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argc = vim.fn.argc()
    local is_directory = false

    if argc == 1 then
      local arg = vim.fn.argv(0)
      if vim.fn.isdirectory(arg) == 1 then
        is_directory = true
      end
    end

    if argc == 0 or is_directory then
      -- 1. Open netrw on left
      if argc == 0 then
        vim.cmd("Ex")
      end

      -- 2. Open editor buffer to the right
      vim.cmd("rightbelow vsplit")
      local editor_win = vim.api.nvim_get_current_win()
      vim.cmd("enew")

      -- 3. Open terminal at the bottom
      vim.cmd("botright split | term")
      local term_win = vim.api.nvim_get_current_win()

      -- 4. Defer resizing until all windows are drawn on screen
      vim.schedule(function()
        -- Lock terminal height (e.g. 7 lines)
        if vim.api.nvim_win_is_valid(term_win) then
          vim.api.nvim_win_set_height(term_win, 15)
          vim.wo[term_win].winfixheight = true
        end

        -- Find netrw window (top-left) and lock its narrow width (e.g. 16 columns)
        vim.cmd("wincmd t")
        local netrw_win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_is_valid(netrw_win) then
          vim.api.nvim_win_set_width(netrw_win, 35)
          vim.wo[netrw_win].winfixwidth = true
        end

        -- Return focus cleanly to the editor pane
        if vim.api.nvim_win_is_valid(editor_win) then
          vim.api.nvim_set_current_win(editor_win)
        end
      end)
    end
  end,
})