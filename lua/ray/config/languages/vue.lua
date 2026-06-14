local formatters = require("ray.config.formatters")

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
      lsp = { "vtsls", "vue_ls", "eslint", "stylelint_lsp", "unocss" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
      hover = { "vue_ls", "vtsls" },
    },
  },
  servers = {
    vue_ls = {},
  },
  extend = function(catalog, helpers)
    helpers.extend(catalog.servers.vtsls, "filetypes", { "vue" })
    helpers.extend(catalog.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path(),
        languages = { "vue" },
        configNamespace = "typescript",
        enableForWorkspaceTypeScriptVersions = true,
      },
    })

    helpers.extend(catalog.servers.eslint, "filetypes", { "vue" })
    helpers.extend(catalog.servers.stylelint_lsp, "filetypes", { "vue" })
  end,
}
