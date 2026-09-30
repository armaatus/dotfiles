return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false, -- filetype plugin, lazy-loads itself
	init = function()
		-- rust-analyzer comes from rustup (`rustup component add rust-analyzer rust-src`),
		-- not mason, so it always matches the active toolchain.
		-- Do NOT enable nvim-lspconfig's rust_analyzer alongside this plugin.
		vim.g.rustaceanvim = {
			tools = {
				enable_clippy = true,
			},
			server = {
				on_attach = function(_, bufnr)
					local function map(lhs, cmd, desc)
						vim.keymap.set("n", lhs, function()
							vim.cmd.RustLsp(cmd)
						end, { buffer = bufnr, silent = true, desc = desc })
					end

					-- override the generic LSP maps with rust-analyzer aware versions
					map("K", { "hover", "actions" }, "Rust hover actions")
					vim.keymap.set({ "n", "v" }, "<leader>ca", function()
						vim.cmd.RustLsp("codeAction")
					end, { buffer = bufnr, silent = true, desc = "Rust code actions (grouped)" })

					map("<leader>Rm", "expandMacro", "Expand macro")
					map("<leader>Re", "explainError", "Explain error")
					map("<leader>Rd", "renderDiagnostic", "Render full diagnostic")
					map("<leader>Rp", "parentModule", "Go to parent module")
					map("<leader>Ro", "openDocs", "Open docs.rs for symbol")
					map("<leader>Rc", "openCargo", "Open Cargo.toml")
					map("<leader>Rj", "joinLines", "Join lines")
					map("<leader>Rs", "ssr", "Structural search & replace")
				end,
				default_settings = {
					["rust-analyzer"] = {
						-- separate target dir so background checks never hold the
						-- cargo lock while you build/run yourself
						cargo = {
							allFeatures = true,
							targetDir = true,
						},
						check = {
							command = "clippy",
							allTargets = true,
						},
						imports = {
							granularity = { group = "crate" },
							prefix = "crate",
						},
						completion = {
							fullFunctionSignatures = { enable = true },
						},
						procMacro = { enable = true },
						diagnostics = { styleLints = { enable = true } },
					},
				},
			},
			dap = {
				-- editing only: no debugger configs loaded on attach
				autoload_configurations = false,
			},
		}
	end,
}
