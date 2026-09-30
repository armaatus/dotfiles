-- Extend nvim-lspconfig's tailwindcss config so class completion works inside
-- Rust `view!` macros (Topcoat). List fields replace instead of merge, so the
-- default filetypes are read and extended rather than redefined.
local base = vim.api.nvim_get_runtime_file("lsp/tailwindcss.lua", false)[1]
local filetypes = base and vim.deepcopy(dofile(base).filetypes) or {}
table.insert(filetypes, "rust")

return {
	filetypes = filetypes,
	settings = {
		tailwindCSS = {
			includeLanguages = {
				rust = "html",
			},
			experimental = {
				-- class!("btn", "px-4" if cond) -> each string literal
				classRegex = {
					{ [[class!\(([^)]*)\)]], [["([^"]*)"]] },
				},
			},
		},
	},
}
