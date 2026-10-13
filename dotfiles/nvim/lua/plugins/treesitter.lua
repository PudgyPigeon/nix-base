-- 1.6 TREESITTER CONFIG
require("nvim-treesitter.config").setup({
  ensure_installed = { "go", "lua", "markdown", "vim", "rust", "haskell", "erlang" },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable Treesitter highlighting for supported buffers",
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})