return {
	"chomosuke/typst-preview.nvim",
	lazy = false,
	ft = "typst",
	version = "1.*",
	config = function()
		local typst_preview = require("typst-preview")

		typst_preview.setup()
		-- Run update function silently by suppressing all output
		vim.api.nvim_exec(
			[[
            silent! lua require("typst-preview").update()
        ]],
			false
		)

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>tp", "<cmd>TypstPreview<CR>", { desc = "Show typst preview" })
		keymap.set("n", "<leader>ts", "<cmd>TypstPreviewStop<CR>", { desc = "Stop typst preview" })
	end,
}
