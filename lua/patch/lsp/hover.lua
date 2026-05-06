local M = {}

local docs = require("noice.lsp.docs")
local format = require("noice.lsp.format")
local markdown = require("noice.text.markdown")

local hover_method = vim.lsp.protocol.Methods.textDocument_hover

local function has_hover_content(result)
  if not (result and result.contents) then
    return false
  end

  for _, line in ipairs(vim.lsp.util.convert_input_to_markdown_lines(result.contents)) do
    if line ~= "" then
      return true
    end
  end

  return false
end

local function show_hover(entries, providers)
  local message = docs.get("hover")

  if message:focus() then
    return
  end

  local shown = false

  for index = 1, #providers do
    local entry = entries[index]

    if entry then
      if shown then
        message:newline()
        markdown.horizontal_line(message)
      end

      format.format(message, entry.result.contents, { ft = vim.bo[entry.ctx.bufnr].filetype })
      shown = true
    end
  end

  if not message:is_empty() then
    docs.show(message)
  end
end

-- added support for multiple hover providers which is not natively supported by noice.nvim
-- https://github.com/folke/noice.nvim/issues/1052
function M.show(providers)
  local clients = {}
  local responses = {}

  for index, provider in ipairs(providers) do
    local client = vim.lsp.get_clients({ bufnr = 0, method = hover_method, name = provider })[1]

    if client then
      table.insert(clients, { index = index, client = client })
    end
  end

  if #clients == 0 then
    return
  end

  local pending = #clients

  local function finish()
    pending = pending - 1

    if pending > 0 then
      return
    end

    show_hover(responses, providers)
  end

  for _, entry in ipairs(clients) do
    local params = vim.lsp.util.make_position_params(nil, entry.client.offset_encoding)

    entry.client:request(hover_method, params, function(_, result, ctx)
      if has_hover_content(result) then
        responses[entry.index] = { result = result, ctx = ctx }
      end

      finish()
    end, 0)
  end
end

return M
