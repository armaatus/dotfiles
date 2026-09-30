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
				vue = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
					graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				typst = { "typstyle" },
				python = { "ruff_organize_imports", "ruff_format" },
				-- rustfmt first, then topcoat formats view!/class! macro bodies
				-- (topcoat only runs in projects with a Topcoat.toml marker)
				rust = { "rustfmt", "topcoat" },
				toml = { "tombi" },
			},
			formatters = {
				rustfmt = {
					-- fallback when Cargo.toml has no edition
					options = { default_edition = "2024" },
				},
				topcoat = {
					command = "topcoat",
					args = { "fmt", "--stdin" },
					require_cwd = true,
					cwd = function(self, ctx)
						return require("conform.util").root_file({ "Topcoat.toml" })(self, ctx)
					end,
				},
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
