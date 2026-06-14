local function attach_eslint(client, bufnr)
  pcall(vim.api.nvim_buf_del_user_command, bufnr, "EslintFixAll")
  vim.api.nvim_buf_create_user_command(bufnr, "EslintFixAll", function()
    client:request("workspace/executeCommand", {
      command = "eslint.applyAllFixes",
      arguments = {
        {
          uri = vim.uri_from_bufnr(bufnr),
          version = vim.lsp.util.buf_versions[bufnr],
        },
      },
    }, nil, bufnr)
  end, {})
end

return {
  servers = {
    eslint = {
      on_attach = attach_eslint,
      before_init = function(_, config)
        if not config.root_dir then
          return
        end

        -- vscode-eslint expects a file URI here. On Windows, the upstream
        -- default raw path can make projectService resolve test files wrong.
        config.settings.workspaceFolder = {
          name = vim.fn.fnamemodify(config.root_dir, ":t"),
          uri = vim.uri_from_fname(config.root_dir),
        }
      end,
      filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "html",
        "markdown",
        "mdc",
        "json",
        "jsonc",
        "toml",
        "yaml",
        "yaml.github-actions",
        "svelte",
        "astro",
      },
      settings = {
        format = false,
        workingDirectory = {
          mode = "location",
        },
      },
    },
  },
}
