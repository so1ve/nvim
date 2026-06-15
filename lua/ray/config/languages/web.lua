local formatters = require("ray.config.formatters")

local function css_language(treesitter)
  return {
    treesitter = treesitter,
    lsp = { "cssls", "stylelint_lsp", "unocss" },
    tools = formatters.prettier_tools,
    formatters = formatters.prettier_formatters,
  }
end

return {
  languages = {
    html = {
      treesitter = "html",
      lsp = { "html", "stylelint_lsp", "unocss" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
    css = css_language("css"),
    scss = css_language("scss"),
  },
  servers = {
    stylelint_lsp = {
      filetypes = { "css", "scss", "html" },
      settings = {
        stylelint = {
          validate = { "css", "scss", "html", "vue" },
        },
      },
    },
  },
}
