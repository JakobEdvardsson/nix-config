local lualine = require("lualine")

local colors = {
	blue = "#65D1FF",
	green = "#3EFFDC",
	violet = "#FF61EF",
	yellow = "#FFDA7B",
	red = "#FF4A4A",
	fg = "#c3ccdc",
	bg = "#112638",
	inactive_bg = "#2c3043",
}

local theme = require("lualine.themes.base16")
theme.normal.b.bg = nil
theme.normal.c.bg = nil
theme.replace.b.bg = nil
theme.insert.b.bg = nil
theme.visual.b.bg = nil
theme.inactive.a.bg = nil
theme.inactive.b.bg = nil
theme.inactive.c.bg = nil

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = theme,
	},
	sections = {
		lualine_a = {
			{
				"buffers",
			},
		},
	},
})
