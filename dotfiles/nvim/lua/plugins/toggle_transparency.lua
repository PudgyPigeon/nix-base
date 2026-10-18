local transparent = false

local function toggle_transparency()
  transparent = not transparent

  if transparent then
    local groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "LineNr",
      "CursorLineNr",
      "FoldColumn",
    }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
    end
    print("Transparency: ON")
  else
    local current_scheme = vim.g.colors_name or "default"
    vim.cmd.colorscheme(current_scheme)
    print("Transparency: OFF")
  end
end

-- Full name with Tab-completion (:ToggleTransparency)
vim.api.nvim_create_user_command("ToggleTransparency", toggle_transparency, {
  desc = "Toggle background transparency",
})

-- Fast 2-character shorthand
vim.api.nvim_create_user_command("TT", toggle_transparency, {
  desc = "Toggle background transparency shorthand",
})
