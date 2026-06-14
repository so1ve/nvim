local formatters = require("ray.config.formatters")
local unpack = require("ray.utils").unpack

local tsserver_language_settings = {
  updateImportsOnFileMove = { enabled = "always" },
  suggest = {
    completeFunctionCalls = true,
  },
}

local function move_to_file(command, client)
  local action, uri, range = unpack(command.arguments)

  if not action or not uri or not range then
    return
  end

  local function move(new_file)
    client:request("workspace/executeCommand", {
      command = command.command,
      arguments = { action, uri, range, new_file },
    })
  end

  local file = vim.uri_to_fname(uri)

  client:request("workspace/executeCommand", {
    command = "typescript.tsserverRequest",
    arguments = {
      "getMoveToRefactoringFileSuggestions",
      {
        file = file,
        startLine = range.start.line + 1,
        startOffset = range.start.character + 1,
        endLine = range["end"].line + 1,
        endOffset = range["end"].character + 1,
      },
    },
  }, function(_, result)
    local files = result and result.body and result.body.files

    if not files then
      return
    end

    files = vim.deepcopy(files)
    table.insert(files, 1, "Enter new path...")

    vim.ui.select(files, {
      prompt = "Select move destination:",
      format_item = function(item)
        return vim.fn.fnamemodify(item, ":~:.")
      end,
    }, function(item)
      if item and item:find("^Enter new path") then
        vim.ui.input({
          prompt = "Enter move destination:",
          default = vim.fn.fnamemodify(file, ":h") .. "/",
          completion = "file",
        }, function(new_file)
          if new_file then
            move(new_file)
          end
        end)
      elseif item then
        move(item)
      end
    end)
  end)
end

local function attach_vtsls(client)
  client.commands = client.commands or {}
  client.commands["_typescript.moveToFileRefactoring"] = function(command)
    move_to_file(command, client)
  end
end

local function typescript_language(treesitter)
  return {
    treesitter = treesitter,
    lsp = { "vtsls", "eslint", "unocss" },
    tools = formatters.prettier_tools,
    formatters = formatters.prettier_formatters,
  }
end

return {
  languages = {
    typescript = typescript_language("typescript"),
    javascript = typescript_language("javascript"),
    typescriptreact = typescript_language("tsx"),
    javascriptreact = typescript_language("javascript"),
  },
  servers = {
    vtsls = {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      on_attach = attach_vtsls,
      settings = {
        complete_function_calls = true,
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            maxInlayHintLength = 30,
            completion = {
              enableServerSideFuzzyMatch = true,
            },
          },
        },
        typescript = tsserver_language_settings,
        javascript = tsserver_language_settings,
      },
    },
  },
  plugins = {
    {
      "nvim-neotest/neotest",
      optional = true,
      dependencies = {
        {
          "marilari88/neotest-vitest",
          url = "https://github.com/JarmoCluyse/neotest-vitest.git",
          commit = "28259d282068628f078295a1a23317ae918934d9",
        },
      },
      opts = {
        adapters = {
          ["neotest-vitest"] = {},
        },
      },
    },
  },
}
