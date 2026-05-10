local extra_parsers = {
  "bash",
  "lua",
  "markdown",
  "markdown_inline",
  "regex",
  "vim",
}

local function configured_parsers()
  return require("config.languages").collect("treesitter", {
    extra = extra_parsers,
    fallback = vim.treesitter.language.get_lang,
  })
end

local function install_configured_parsers()
  require("nvim-treesitter").install(configured_parsers())
end

local function register_treesitter_aliases(languages)
  local aliases = {}

  for filetype, language in pairs(languages.by_filetype) do
    local parser = language.treesitter

    if parser and parser ~= filetype then
      aliases[parser] = aliases[parser] or {}
      table.insert(aliases[parser], filetype)
    end
  end

  for parser, filetypes in pairs(aliases) do
    vim.treesitter.language.register(parser, filetypes)
  end
end

local function register_treesitter_autocmd(languages)
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Start Tree-sitter for configured parsers",
    callback = function(event)
      local filetype = vim.bo[event.buf].filetype
      local parser = languages.get(filetype, "treesitter", vim.treesitter.language.get_lang)

      if parser and vim.treesitter.language.add(parser) == true then
        vim.treesitter.start(event.buf, parser)
      end
    end,
  })
end

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = install_configured_parsers,
  config = function()
    local languages = require("config.languages")

    register_treesitter_aliases(languages)
    register_treesitter_autocmd(languages)
  end,
}
