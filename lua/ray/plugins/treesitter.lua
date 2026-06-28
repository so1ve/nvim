local extra_parsers = {
  "bash",
  "diff",
  "gitcommit",
  "lua",
  "markdown",
  "markdown_inline",
  "regex",
  "vim",
}

local function configured_parsers()
  return require("ray.config.languages").collect("treesitter", {
    extra = extra_parsers,
    fallback = vim.treesitter.language.get_lang,
  })
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

return {
  "so1ve/tiny-treesitter.nvim",
  lazy = false,
  opts = {
    ensure_installed = configured_parsers(),
    auto_install = true,
  },
  config = function(_, opts)
    local languages = require("ray.config.languages")

    require("tiny-treesitter").setup(opts)

    register_treesitter_aliases(languages)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(event)
        local filetype = vim.bo[event.buf].filetype

        local parser = languages.get(filetype, "treesitter", vim.treesitter.language.get_lang)

        if parser and vim.treesitter.language.add(parser) == true then
          vim.treesitter.start(event.buf, parser)
        end
      end,
    })
  end,
}
