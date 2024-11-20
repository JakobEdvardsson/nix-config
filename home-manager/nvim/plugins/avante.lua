-- deps:
require("img-clip").setup({
	-- recommended settings
	default = {
		embed_image_as_base64 = false,
		prompt_for_file_name = false,
		drag_and_drop = {
			insert_mode = true,
		},
		-- required for Windows users
		use_absolute_path = true,
	},
})

require("render-markdown").setup({
	file_types = { "markdown", "Avante" },
})

require("avante_lib").load()
require("avante").setup({

	provider = "ollama",
	use_absolute_path = true,
	vendors = {
		---@type AvanteProvider
		ollama = {
			["local"] = true,
			endpoint = "http://192.168.50.99:11434/v1",
			model = "codellama:7b",
			parse_curl_args = function(opts, code_opts)
				return {
					url = opts.endpoint .. "/chat/completions",
					headers = {
						["Accept"] = "application/json",
						["Content-Type"] = "application/json",
						["x-api-key"] = "ollama",
					},
					body = {
						model = opts.model,
						messages = require("avante.providers").copilot.parse_messages(code_opts), -- you can make your own message, but this is very advanced
						max_tokens = 2048,
						stream = true,
					},
				}
			end,
			parse_response_data = function(data_stream, event_state, opts)
				require("avante.providers").openai.parse_response(data_stream, event_state, opts)
			end,
		},
	},
	behaviour = {
		auto_suggestions = false, -- Experimental stage
		auto_set_highlight_group = true,
		auto_set_keymaps = true,
		auto_apply_diff_after_generation = false,
		support_paste_from_clipboard = true,
	},
	mappings = {
		--- @class AvanteConflictMappings
		diff = {
			ours = "co",
			theirs = "ct",
			all_theirs = "ca",
			both = "cb",
			cursor = "cc",
			next = "]x",
			prev = "[x",
		},
		suggestion = {
			accept = "<M-l>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
		jump = {
			next = "]]",
			prev = "[[",
		},
		submit = {
			normal = "<CR>",
			insert = "<C-CR>",
		},
		sidebar = {
			apply_all = "A",
			apply_cursor = "a",
			switch_windows = "<Tab>",
			reverse_switch_windows = "<S-Tab>",
		},
	},
	hints = { enabled = true },
	windows = {
		---@type "right" | "left" | "top" | "bottom"
		position = "right", -- the position of the sidebar
		wrap = true, -- similar to vim.o.wrap
		width = 30, -- default % based on available width
		sidebar_header = {
			align = "center", -- left, center, right for title
			rounded = true,
		},
	},
	highlights = {
		---@type AvanteConflictHighlights
		diff = {
			current = "DiffText",
			incoming = "DiffAdd",
		},
	},
	--- @class AvanteConflictUserConfig
	diff = {
		autojump = true,
		---@type string | fun(): any
		list_opener = "copen",
	},
})
