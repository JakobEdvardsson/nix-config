vim.opt.termguicolors = true
local bufferline = require("bufferline")
bufferline.setup({
	options = {
		numbers = "ordinal",
		mode = "tabs",
	},
})
