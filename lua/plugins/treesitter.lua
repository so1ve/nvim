local function install_configured_parsers()
  require("nvim-treesitter").install(require("config.languages").treesitter_parsers())
end

local function register_treesitter_aliases(languages)
  for parser, filetypes in pairs(languages.treesitter_aliases()) do
    vim.treesitter.language.register(parser, filetypes)
  end
end

local function start_treesitter_for_buffer(languages, event)
  local filetype = vim.bo[event.buf].filetype
  local parser = languages.treesitter_language(filetype)

  if parser and vim.treesitter.language.add(parser) == true then
    vim.treesitter.start(event.buf, parser)
  end
end

local function register_treesitter_autocmd(languages)
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("RayTreesitter", { clear = true }),
    desc = "Start Tree-sitter for configured parsers",
    callback = function(event)
      start_treesitter_for_buffer(languages, event)
    end,
  })
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = install_configured_parsers,
  config = function()
    local languages = require("config.languages")
    local treesitter = require("nvim-treesitter")

    treesitter.install(languages.treesitter_parsers())
    register_treesitter_aliases(languages)
    register_treesitter_autocmd(languages)
  end,
}
