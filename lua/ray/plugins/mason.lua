local lsp_packages = {
  cssls = "css-lsp",
  docker_compose_language_service = "docker-compose-language-service",
  dockerls = "dockerfile-language-server",
  eslint = "eslint-lsp",
  html = "html-lsp",
  jsonls = "json-lsp",
  lua_ls = "lua-language-server",
  powershell_es = "powershell-editor-services",
  stylelint_lsp = "stylelint-language-server",
  unocss = "unocss-language-server",
  vue_ls = "vue-language-server",
  yamlls = "yaml-language-server",
}

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUpdate" },
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- Its startup installer is wired through the plugin's VimEnter hook, so it
    -- needs to be loaded before VimEnter rather than on VeryLazy.
    lazy = false,
    opts_extend = { "ensure_installed" },
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = function()
      local languages = require("ray.config.languages")
      local packages = vim.list_extend(
        vim.tbl_map(function(server)
          return lsp_packages[server] or server
        end, languages.collect("lsp")),
        languages.collect("tools")
      )

      return {
        ensure_installed = vim.fn.uniq(vim.fn.sort(packages)),
        integrations = {
          ["mason-null-ls"] = false,
          ["mason-nvim-dap"] = false,
        },
      }
    end,
  },
}
