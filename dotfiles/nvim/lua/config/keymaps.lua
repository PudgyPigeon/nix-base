local map = vim.keymap.set
local layout = require("config.layout")

-- Seamless window navigation
map({ "n", "t" }, "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map({ "n", "t" }, "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Move to lower window" })
map({ "n", "t" }, "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Move to upper window" })
map({ "n", "t" }, "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- Escape terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- In-window file explorer (opens file in THIS current window)
map("n", "<leader>e", function()
  vim.cmd("Explore")
  vim.b.netrw_browse_split = 0
end, { desc = "Open in-window file explorer" })

-- Toggle the same bottom terminal buffer created at startup
local function toggle_terminal()
  local term_buf = layout.term_buf

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if term_buf and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == term_buf then
      vim.api.nvim_win_close(win, false)
      return
    end
  end

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.cmd("botright sbuffer " .. term_buf)
  else
    vim.cmd("botright new")
    layout.term_buf = vim.api.nvim_get_current_buf()
    vim.fn.termopen(vim.o.shell)
    vim.bo[layout.term_buf].buflisted = false
  end

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(win, 15)
  vim.wo[win].winfixheight = true
  vim.cmd("startinsert")
end

map("n", "<leader>t", toggle_terminal, { desc = "Toggle bottom terminal" })