return {
	"milanglacier/minuet-ai.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("minuet").setup({
			provider = "openai_fim_compatible",
			n_completions = 1,
			context_window = 2048,
			context_ratio = 0.7,
			throttle = 250,
			debounce = 120,
			request_timeout = 8,
			provider_options = {
				openai_fim_compatible = {
					api_key = function()
						return "altijdsamen"
					end,
					name = "oMLX-Mellum",
					end_point = "http://localhost:1515/v1/completions",
					model = "Mellum-4b-base-4bit",
					optional = {
						max_tokens = 48,
						temperature = 0,
						top_p = 0.9,
						stream = false,
					},
					template = {
						prompt = function(context_before_cursor, context_after_cursor, _)
							return "<fim_suffix>"
								.. context_after_cursor
								.. "<fim_prefix>"
								.. context_before_cursor
								.. "<fim_middle>"
						end,
						suffix = false,
					},
				},
			},
			virtualtext = {
				auto_trigger_ft = { "*" },
				keymap = {
					accept = "<Tab>",
					accept_line = "<C-l>",
					prev = nil,
					next = nil,
					dismiss = "<C-]>",
				},
			},
		})

		vim.keymap.set("i", "<C-g>", function()
			require("minuet.virtualtext").action.trigger()
		end, { desc = "Minuet: trigger suggestion" })

		vim.defer_fn(function()
			vim.system({
				"curl", "-s", "-o", "/dev/null", "--max-time", "30",
				"-X", "POST", "http://localhost:1515/v1/completions",
				"-H", "Content-Type: application/json",
				"-H", "Authorization: Bearer altijdsamen",
				"-d", '{"model":"Mellum-4b-base-4bit","prompt":"<fim_suffix><fim_prefix>x<fim_middle>","max_tokens":1,"temperature":0}',
			})
		end, 500)
	end,
}
