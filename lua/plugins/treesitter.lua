return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = function()
    require("nvim-treesitter").install(require("config.languages").treesitter_parsers())
  end,
  config = function()
    local languages = require("config.languages")
    local treesitter = require("nvim-treesitter")
    local parsers = languages.treesitter_parsers()

    treesitter.install(parsers)

    for parser, filetypes in pairs(languages.treesitter_aliases()) do
      vim.treesitter.language.register(parser, filetypes)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("RayTreesitter", { clear = true }),
      desc = "Start Tree-sitter for configured parsers",
      callback = function(event)
        local filetype = vim.bo[event.buf].filetype
        local parser = languages.treesitter_language(filetype)

        if parser and vim.treesitter.language.add(parser) == true then
          vim.treesitter.start(event.buf, parser)
        end
      end,
    })

  end,
}
