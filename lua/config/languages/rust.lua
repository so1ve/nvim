local macro_expansion_bufnr

local function macro_expansion_lines(result)
  local title = "Recursive expansion of the " .. result.name .. " macro"
  local lines = {
    "// " .. string.rep("=", #title),
    "// " .. title,
    "// " .. string.rep("=", #title),
    "",
  }

  vim.list_extend(lines, vim.split(result.expansion, "\n", { plain = true }))

  return lines
end

local function open_macro_expansion(result)
  if macro_expansion_bufnr and vim.api.nvim_buf_is_valid(macro_expansion_bufnr) then
    vim.api.nvim_buf_delete(macro_expansion_bufnr, { force = true })
  end

  local lines = macro_expansion_lines(result)
  macro_expansion_bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(macro_expansion_bufnr, 0, -1, false, lines)
  vim.bo[macro_expansion_bufnr].bufhidden = "wipe"
  vim.bo[macro_expansion_bufnr].filetype = "rust"
  vim.bo[macro_expansion_bufnr].modifiable = false

  vim.cmd("botright vsplit")
  vim.api.nvim_win_set_buf(0, macro_expansion_bufnr)
  vim.api.nvim_win_set_height(0, math.min(math.max(#lines, 4), math.floor(vim.o.lines * 0.4)))
end

local function expand_macro(bufnr)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })[1]

  if not client then
    vim.notify("rust-analyzer is not attached", vim.log.levels.WARN)

    return
  end

  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

  client:request("rust-analyzer/expandMacro", params, function(err, result)
    if err then
      vim.notify(err.message or "Failed to expand macro", vim.log.levels.ERROR)

      return
    end

    if not result then
      vim.notify("No macro under cursor", vim.log.levels.INFO)

      return
    end

    vim.schedule(function()
      open_macro_expansion(result)
    end)
  end, bufnr)
end

local function attach_rust_keymaps(_, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "RustExpandMacro", function()
    expand_macro(bufnr)
  end, { desc = "Expand macro at caret" })

  vim.keymap.set("n", "<leader>ce", function()
    expand_macro(bufnr)
  end, { buffer = bufnr, desc = "Expand macro" })
end

return {
  languages = {
    rust = {
      treesitter = "rust",
      lsp = { "rust_analyzer" },
      formatters = { "rustfmt" },
    },
  },
  servers = {
    rust_analyzer = {
      on_attach = attach_rust_keymaps,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            features = "all",
          },
          check = {
            command = "clippy",
          },
          rustfmt = {
            rangeFormatting = {
              enable = true,
            },
          },
        },
      },
    },
  },
}
