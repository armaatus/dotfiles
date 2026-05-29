local resolve = require("joris.util.python").resolve

vim.api.nvim_create_user_command("PyrightPython", function()
	local cli = vim.lsp.get_clients({ name = "pyright" })[1]
	if not cli then
		vim.notify("no pyright client attached", vim.log.levels.WARN)
		return
	end
	local path = vim.tbl_get(cli.settings or {}, "python", "pythonPath")
	vim.notify("pyright python.pythonPath = " .. tostring(path), vim.log.levels.INFO)
end, {})

return {
	on_init = function(client)
		local start = client.config.root_dir or vim.fn.getcwd()
		local py = resolve(start)
		if not py then
			return
		end
		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			python = { pythonPath = py },
		})
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end,
}
