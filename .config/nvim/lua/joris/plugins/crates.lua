return {
	"saecki/crates.nvim",
	tag = "stable",
	event = { "BufRead Cargo.toml" },
	opts = {
		-- in-process LSP: completion, hover and code actions for Cargo.toml
		-- (the nvim-cmp source is deprecated upstream)
		lsp = {
			enabled = true,
			actions = true,
			completion = true,
			hover = true,
		},
		completion = {
			crates = { enabled = true },
		},
	},
}
