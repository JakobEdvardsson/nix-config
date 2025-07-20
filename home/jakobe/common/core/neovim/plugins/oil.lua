require("oil").setup({
  win_options = {
    signcolumn = "yes:2",
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("oil-git-status").setup()
require("oil-lsp-diagnostics").setup()
