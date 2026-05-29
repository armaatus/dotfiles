local M = {}

local function is_exe(p)
	return p and p ~= "" and vim.fn.executable(p) == 1
end

local function from_virtual_env()
	local venv = vim.env.VIRTUAL_ENV
	if not venv or venv == "" then
		return nil
	end
	local p = venv .. "/bin/python"
	return is_exe(p) and p or nil
end

local function from_project_dir(root)
	if not root then
		return nil
	end
	for _, name in ipairs({ ".venv", "venv" }) do
		local p = root .. "/" .. name .. "/bin/python"
		if is_exe(p) then
			return p
		end
	end
	return nil
end

local function from_poetry(root)
	if not root or vim.fn.executable("poetry") ~= 1 then
		return nil
	end
	if vim.fn.filereadable(root .. "/pyproject.toml") ~= 1 then
		return nil
	end
	local out = vim.fn.system({ "poetry", "-C", root, "env", "info", "-e" })
	if vim.v.shell_error ~= 0 then
		return nil
	end
	local p = vim.trim(out)
	return is_exe(p) and p or nil
end

function M.resolve(start)
	local py = from_virtual_env()
	if py then
		return py
	end
	local root = vim.fs.root(start, { ".venv", "venv", "pyproject.toml", "setup.py", ".git" })
	return from_project_dir(root) or from_poetry(root)
end

return M
