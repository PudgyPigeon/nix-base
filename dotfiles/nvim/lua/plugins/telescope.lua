-- 1.7 TELESCOPE CONFIG
local themes = require("telescope.themes")

vim.keymap.set("n", "<leader>c", function()
  require("telescope.builtin").colorscheme(themes.get_dropdown({
    enable_preview = true,
    previewer = false,   -- Disable Telescope's inner preview box (code in background is your preview)
    prompt_title = "Theme",
    winblend = 10,       -- Slight transparency (optional)
    layout_config = {
      width = 0.3,       -- Only 30% of screen width
      height = 0.4,      -- Only 40% of screen height
    },
  }))
end, { desc = "Browse colorschemes with live preview" })