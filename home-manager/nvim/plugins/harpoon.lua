local harpoon = require("harpoon")
harpoon:setup({})

--[[ -- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

vim.keymap.set("n", "<C-e>", function()
	toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })
]]

vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end, { desc = "Add to harpoon" })

vim.keymap.set("n", "<C-1>", function()
	harpoon:list():select(1)
end, { desc = "Harpoon 1" })
vim.keymap.set("n", "<C-2>", function()
	harpoon:list():select(2)
end, { desc = "Harpoon 2" })
vim.keymap.set("n", "<C-3>", function()
	harpoon:list():select(3)
end, { desc = "Harpoon 3" })
vim.keymap.set("n", "<C-4>", function()
	harpoon:list():select(4)
end, { desc = "Harpoon 4" })
vim.keymap.set("n", "<C-5>", function()
	harpoon:list():select(5)
end, { desc = "Harpoon 5" })
vim.keymap.set("n", "<C-6>", function()
	harpoon:list():select(6)
end, { desc = "Harpoon 6" })
vim.keymap.set("n", "<C-7>", function()
	harpoon:list():select(7)
end, { desc = "Harpoon 7" })
vim.keymap.set("n", "<C-8>", function()
	harpoon:list():select(8)
end, { desc = "Harpoon 8" })
vim.keymap.set("n", "<C-9>", function()
	harpoon:list():select(9)
end, { desc = "Harpoon 9" })
vim.keymap.set("n", "<C-0>", function()
	harpoon:list():select(0)
end, { desc = "Harpoon 0" })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end, { desc = "Harpoon go previous" })
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end, { desc = "Harpoon go next" })
