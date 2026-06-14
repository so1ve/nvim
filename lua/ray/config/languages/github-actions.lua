return {
  filetypes = {
    pattern = {
      [".*[\\/]%.github[\\/]workflows[\\/][^\\/]+%.ya?ml%..*"] = { "yaml", { priority = 1 } },
      [".*[\\/]%.github[\\/]workflows[\\/][^\\/]+%.ya?ml"] = "yaml.github-actions",
    },
  },
  languages = {
    ["yaml.github-actions"] = {
      treesitter = "yaml",
      lsp = { "yamlls" },
      tools = { "actionlint" },
      linters = { "actionlint" },
    },
  },
  extend = function(catalog, helpers)
    helpers.extend(catalog.servers.yamlls, "filetypes", { "yaml.github-actions" })
  end,
}
