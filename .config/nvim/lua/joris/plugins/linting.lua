return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local resolve_python = require("joris.util.python").resolve

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    local pylint = lint.linters.pylint
    local default_args = vim.deepcopy(pylint.args or {})
    pylint.args = function()
      local args = vim.deepcopy(default_args)
      local fname = vim.api.nvim_buf_get_name(0)
      local start = fname ~= "" and fname or vim.fn.getcwd()
      local py = resolve_python(start)
      if py then
        local venv = py:gsub("/bin/python[%d.]*$", "")
        local hook = string.format(
          "import sys, glob; sys.path[:0] = glob.glob('%s/lib/python*/site-packages')",
          venv
        )
        table.insert(args, "--init-hook=" .. hook)
      end
      return args
    end

    vim.api.nvim_create_user_command("PylintPython", function()
      local fname = vim.api.nvim_buf_get_name(0)
      local start = fname ~= "" and fname or vim.fn.getcwd()
      vim.notify("pylint venv python = " .. tostring(resolve_python(start)), vim.log.levels.INFO)
    end, {})

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
