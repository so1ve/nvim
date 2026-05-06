local M = {}

local hover_method = vim.lsp.protocol.Methods.textDocument_hover

local function handler()
  if package.loaded["noice.config"] then
    local ok, hover = pcall(require, "noice.lsp.hover")

    if ok and hover.on_hover then
      return hover.on_hover
    end
  end

  return vim.lsp.handlers[hover_method]
end

local function trim_empty_lines(lines)
  local first = 1
  local last = #lines

  while lines[first] == "" do
    first = first + 1
  end

  while lines[last] == "" do
    last = last - 1
  end

  local trimmed = {}

  for index = first, last do
    table.insert(trimmed, lines[index])
  end

  return trimmed
end

local function markdown_lines(result)
  if not (result and result.contents) then
    return nil
  end

  local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  local trimmed = trim_empty_lines(lines)

  return #trimmed > 0 and trimmed or nil
end

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

  local hover_handler = handler()
  local pending = #clients
  local first_context
  local first_config

  local function finish()
    pending = pending - 1

    if pending > 0 then
      return
    end

    local merged = {}

    for index = 1, #providers do
      local lines = responses[index]

      if lines then
        if #merged > 0 then
          vim.list_extend(merged, { "", "---", "" })
        end

        vim.list_extend(merged, lines)
      end
    end

    if #merged == 0 then
      return
    end

    hover_handler(nil, {
      contents = {
        kind = vim.lsp.protocol.MarkupKind.Markdown,
        value = table.concat(merged, "\n"),
      },
    }, first_context, first_config)
  end

  for _, entry in ipairs(clients) do
    local params = vim.lsp.util.make_position_params(nil, entry.client.offset_encoding)

    entry.client:request(hover_method, params, function(_, result, ctx, config)
      responses[entry.index] = markdown_lines(result)
      first_context = first_context or ctx
      first_config = first_config or config
      finish()
    end, 0)
  end
end

return M
