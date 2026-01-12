return {
	"seblyng/roslyn.nvim",
	ft = "cs", -- Only load for C# files
	opts = {
		-- File watching: "auto" uses roslyn for .NET 9+ SDK, falls back otherwise
		filewatching = "auto",

		-- Don't search child directories for .sln files
		broad_search = false,

		-- Show notifications when server starts
		silent = false,
	},
}
