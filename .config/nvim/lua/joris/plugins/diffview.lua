return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose" },
	opts = {
		default_args = { DiffviewOpen = { "--imply-local" } },
	},
}
