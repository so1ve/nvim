local function vue_language_server_path()
  return vim.fs.joinpath(
    vim.fn.stdpath("data"),
    "mason",
    "packages",
    "vue-language-server",
    "node_modules",
    "@vue",
    "language-server"
  )
end

return {
  languages = {
    vue = {
      treesitter = "vue",
      lsp = { "vtsls", "vue_ls", "eslint", "stylelint_lsp" },
      tools = { "prettierd" },
      formatters = { "prettierd" },
      hover = { "vue_ls", "vtsls" },
    },
  },
  servers = {
    vue_ls = {},
  },
  extend = function(servers, lsp)
    lsp.extend(servers.vtsls, "filetypes", { "vue" })
    lsp.extend(servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path(),
        languages = { "vue" },
        configNamespace = "typescript",
      },
    })

    lsp.extend(servers.eslint, "filetypes", { "vue" })
    lsp.extend(servers.stylelint_lsp, "filetypes", { "vue" })
  end,
}
