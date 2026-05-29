local M = {}

function M.setup()
  local snippets = require("mini.snippets")
  local gen_loader = snippets.gen_loader

  snippets.setup({
    snippets = {
      gen_loader.from_lang({
        lang_patterns = {
          javascriptreact = { "**/javascript.json" },
          typescript = { "**/javascript.json" },
          typescriptreact = { "**/javascript.json" },
          vue = { "**/vue.json", "**/javascript.json" },
        },
      }),
    },
    mappings = {
      expand = "",
      jump_next = "",
      jump_prev = "",
    },
    expand = {
      insert = function(snippet)
        return snippets.default_insert(snippet, {
          empty_tabstop = "",
          empty_tabstop_final = "",
        })
      end,
    },
  })
end

return M
