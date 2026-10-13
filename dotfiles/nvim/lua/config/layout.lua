local M = {}
M.term_buf = nil

-- Netrw sidebar tweaks
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.foldcolumn = "0"
  end,
})

-- Automated terminal insert mode
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- Startup layout: Editor + Persistent Left Lexplore + Bottom Terminal
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argc = vim.fn.argc()
    local is_directory = false
    local target_dir = nil

    if argc == 1 then
      local arg = vim.fn.argv(0)
      if vim.fn.isdirectory(arg) == 1 then
        is_directory = true
        target_dir = arg
      end
    end

    if argc == 0 or is_directory then
      -- 1. Main editor window starts in an empty buffer
      vim.cmd("enew")
      local editor_win = vim.api.nvim_get_current_win()

      -- 2. Open permanent Lexplore sidebar on the left
      if target_dir then
        vim.cmd("Lexplore " .. vim.fn.fnameescape(target_dir))
      else
        vim.cmd("Lexplore")
      end

      -- Enforce Lexplore opens into adjacent editor split (split mode 4)
      vim.b.netrw_browse_split = 4

      -- 3. Open terminal docked at the bottom across the screen
      vim.cmd("botright split | term")
      local term_win = vim.api.nvim_get_current_win()
      M.term_buf = vim.api.nvim_get_current_buf()
      vim.bo[M.term_buf].buflisted = false

      -- 4. Set sizing and return focus to editor
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(term_win) then
          vim.api.nvim_win_set_height(term_win, 15)
          vim.wo[term_win].winfixheight = true
        end

        vim.cmd("wincmd t")
        local netrw_win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_is_valid(netrw_win) and netrw_win ~= editor_win then
          vim.api.nvim_win_set_width(netrw_win, 35)
          vim.wo[netrw_win].winfixwidth = true
        end

        if vim.api.nvim_win_is_valid(editor_win) then
          vim.api.nvim_set_current_win(editor_win)
        end
      end)
    end
  end,
})

return M