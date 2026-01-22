return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				typst = { "typstyle" },
				python = { "isort", "black" },
				cs = {}, -- Empty = use LSP fallback (Roslyn)
				razor = {}, -- Empty = use LSP fallback (Roslyn)
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000, -- Increased for Roslyn
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000, -- Increased for Roslyn
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
