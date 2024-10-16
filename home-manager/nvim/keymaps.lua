vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set({ "n", "x" }, "<A-LEFT>", "<C-w>h", { desc = "Window go left" })
keymap.set({ "n", "x" }, "<A-UP>", "<C-w>j", { desc = "Window go up" })
keymap.set({ "n", "x" }, "<A-DOWN>", "<C-w>k", { desc = "Window go down" })
keymap.set({ "n", "x" }, "<A-RIGHT>", "<C-w>l", { desc = "Window go right" })

-- tabs
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- buffers
keymap.set("n", "<leader>bo", "<cmd>enew<CR>", { desc = "Open new buffer" })
keymap.set("n", "<leader>bl", ":ls<CR>", { desc = "List buffers" })
keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bb", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bp", ":bprev<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bB", ":bprev<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bx", ":bdelete!<CR>", { desc = "Delete buffer" })
keymap.set("n", "<leader>bv", ":vsplit | bnext<CR>", { desc = "Vertical split with next buffer" })
keymap.set("n", "<leader>bh", ":split | bnext<CR>", { desc = "Horizontal split with next buffer" })

keymap.set({ "n", "x" }, "<leader>1", "<cmd>lua require('bufferline').go_to(1, true)<cr>", { desc = "Buf 1" })
keymap.set({ "n", "x" }, "<leader>2", "<cmd>lua require('bufferline').go_to(2, true)<cr>", { desc = "Buf 2" })
keymap.set({ "n", "x" }, "<leader>3", "<cmd>lua require('bufferline').go_to(3, true)<cr>", { desc = "Buf 3" })
keymap.set({ "n", "x" }, "<leader>4", "<cmd>lua require('bufferline').go_to(4, true)<cr>", { desc = "Buf 4" })
keymap.set({ "n", "x" }, "<leader>5", "<cmd>lua require('bufferline').go_to(5, true)<cr>", { desc = "Buf 5" })
keymap.set({ "n", "x" }, "<leader>6", "<cmd>lua require('bufferline').go_to(6, true)<cr>", { desc = "Buf 6" })
keymap.set({ "n", "x" }, "<leader>7", "<cmd>lua require('bufferline').go_to(7, true)<cr>", { desc = "Buf 7" })
keymap.set({ "n", "x" }, "<leader>8", "<cmd>lua require('bufferline').go_to(8, true)<cr>", { desc = "Buf 8" })
keymap.set({ "n", "x" }, "<leader>9", "<cmd>lua require('bufferline').go_to(9, true)<cr>", { desc = "Buf 9" })
keymap.set({ "n", "x" }, "<leader>0", "<cmd>lua require('bufferline').go_to(10, true)<cr>", { desc = "Buf 10" })

-- terminal
keymap.set("n", "<leader><CR>", "<cmd>term<CR>a", { desc = "Open a terminal" })
keymap.set("t", "<C-ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
