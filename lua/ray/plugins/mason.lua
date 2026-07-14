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
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "basedpyright",
        "clangd",
        "css-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "eslint-lsp",
        "gofumpt",
        "goimports",
        "gopls",
        "html-lsp",
        "json-lsp",
        "latexindent",
        "lua-language-server",
        "marksman",
        "powershell-editor-services",
        "prettier",
        "prettierd",
        "ruff",
        "stylelint-language-server",
        "stylua",
        "texlab",
        "tinymist",
        "tombi",
        "unocss-language-server",
        "vtsls",
        "vue-language-server",
        "yaml-language-server",
        "zls",
      },
      integrations = {
        ["mason-null-ls"] = false,
        ["mason-nvim-dap"] = false,
      },
    },
  },
}
