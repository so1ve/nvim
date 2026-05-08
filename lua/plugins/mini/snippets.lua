local M = {}

local function default_snippet_patterns(lang)
  return { lang .. "/**/*.json", lang .. "/**/*.lua", "**/" .. lang .. ".json", "**/" .. lang .. ".lua" }
end

function M.setup()
  local snippets = require("mini.snippets")
  local gen_loader = snippets.gen_loader
  local lang_patterns = {}

  local function add_snippet_file(path, langs)
    for _, lang in ipairs(langs) do
      lang_patterns[lang] = lang_patterns[lang] or default_snippet_patterns(lang)
      table.insert(lang_patterns[lang], 1, path)
    end

    return lang_patterns
  end

  add_snippet_file("shared/javascript.json", {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  })

  snippets.setup({
    snippets = {
      gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/all.json"),
      gen_loader.from_lang({
        lang_patterns = lang_patterns,
      }),
    },
    mappings = {
      expand = "",
      jump_next = "",
      jump_prev = "",
    },
  })
end

return M
