local telescope = require("telescope")
local actions = require("telescope.actions")
local transform_mod = require("telescope.actions.mt").transform_mod

local trouble = require("trouble")
trouble.setup({})
local trouble_telescope = require("trouble.sources.telescope")

-- or create your custom action
local custom_actions = transform_mod({
	open_trouble_qflist = function(prompt_bufnr)
		trouble.toggle("quickfix")
	end,
})

telescope.setup({
	defaults = {
		path_display = { "smart" },
		mappings = {
			n = {
				-- I'm used to closing buffers with "d" from bufexplorer
				["d"] = require("telescope.actions").delete_buffer,
				-- I'm also used to quitting bufexplorer with q instead of escape
				["q"] = require("telescope.actions").close,
			},
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
				["<C-t>"] = trouble_telescope.open,
			},
		},
	},
})

telescope.load_extension("fzf")

-- set keymaps
local keymap = vim.keymap -- for conciseness

keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
