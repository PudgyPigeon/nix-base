-- telescope.lua
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

-- <leader>c: Colorscheme picker with preview
vim.keymap.set("n", "<leader>c", function()
  builtin.colorscheme(themes.get_dropdown({
    enable_preview = true,
    previewer = false,
    prompt_title = "Theme",
    winblend = 10,
    layout_config = {
      width = 0.3,
      height = 0.4,
    },
  }))
end, { desc = "Browse colorschemes" })

-- <leader>e: Find files
vim.keymap.set("n", "<leader>e", function()
  builtin.find_files()
end, { desc = "Find files" })