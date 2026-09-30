return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- main-branch API: setup() only accepts `install_dir`; call with no args
		require("nvim-treesitter").setup()

		-- nvim-ts-autotag is configured via its own setup() on the main branch
		require("nvim-ts-autotag").setup({})

		-- parsers to keep installed
		local ensure = {
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"rust",
			"toml",
			"ron",
		}

		-- install any missing parsers (async; no-op once present)
		pcall(function()
			local installed = require("nvim-treesitter.config").get_installed("parsers")
			local missing = vim.tbl_filter(function(lang)
				return not vim.tbl_contains(installed, lang)
			end, ensure)
			if #missing > 0 then
				require("nvim-treesitter").install(missing)
			end
		end)

		-- enable highlighting + treesitter indentation per buffer
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(ev)
				if pcall(vim.treesitter.start, ev.buf) then
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
