-- Blink completion documentation Noice renderer patch.
-- Purpose: make blink.cmp documentation use Noice's markdown renderer, matching
-- LSP hover styling, markdown handling, and code-block highlighting.
-- Behavior: empty documentation closes the popup, `detail` is prepended as a
-- fenced code block when it is not already present, and the source buffer
-- filetype is used as Noice's fallback language for unlabeled code fences.
-- Implementation: monkey-patches blink's documentation `show_item()` so resolved
-- items are drawn through the configured draw hook, with Noice-backed default
-- rendering and a final empty-buffer guard before the window opens.

local M = {}

local function has_text(value)
  return type(value) == "string" and value:find("%S") ~= nil
end

local function has_lines(lines)
  for _, line in ipairs(lines) do
    if has_text(line) then
      return true
    end
  end

  return false
end

local function context_filetype(context)
  local bufnr = context and context.bufnr

  if type(bufnr) == "number" and vim.api.nvim_buf_is_valid(bufnr) then
    return vim.bo[bufnr].filetype
  end

  return vim.bo.filetype
end

local function format_documentation(documentation)
  if type(documentation) ~= "string" and type(documentation) ~= "table" then
    return {}
  end

  return require("noice.lsp.format").format_markdown(documentation)
end

local function append_detail(lines, detail, filetype)
  if not has_text(detail) then
    return lines
  end

  local text = table.concat(lines, "\n")

  if text:find(detail, 1, true) then
    return lines
  end

  if has_text(filetype) then
    filetype = filetype:match("^[^%.]+")
  else
    filetype = ""
  end

  local detail_lines = vim.split(("```%s\n%s\n```"):format(filetype, vim.trim(detail)), "\n")

  if #lines > 0 then
    table.insert(detail_lines, "")
    vim.list_extend(detail_lines, lines)
  end

  return detail_lines
end

local function render(bufnr, lines, filetype)
  local noice_config = require("noice.config")

  vim.api.nvim_buf_clear_namespace(bufnr, noice_config.ns, 0, -1)

  local message = require("noice.message")("lsp")
  -- Noice hover passes `ft` to the markdown renderer. Doing the same here keeps
  -- unlabeled fenced code blocks highlighted as the source language instead of
  -- falling back to plain text.
  require("noice.text.markdown").format(
    message,
    table.concat(lines, "\n"),
    { ft = filetype }
  )
  message:render(bufnr, noice_config.ns)
  require("noice.text.markdown").keys(bufnr)
end

local function buffer_has_content(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  return has_lines(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
end

function M.draw(opts)
  local item = opts.item
  local docs = format_documentation(item.documentation)
  local filetype = context_filetype(opts.context)

  local lines = append_detail(docs, item.detail, filetype)

  if not has_lines(lines) then
    opts.window:close()

    return
  end

  local bufnr = opts.window:get_buf()
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  render(bufnr, lines, filetype)
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  vim.api.nvim_set_option_value("modified", false, { buf = bufnr })
end

function M.patch()
  local docs = require("blink.cmp.completion.windows.documentation")

  if docs._ray_noice_docs_patched then
    return
  end

  docs._ray_noice_docs_patched = true

  local config = require("blink.cmp.config").completion.documentation
  local sources = require("blink.cmp.sources.lib")
  local menu = require("blink.cmp.completion.windows.menu")

  -- Keep blink's upstream flow intact. The only differences are the Noice-backed
  -- default renderer and the empty-buffer guard before opening the popup.
  function docs.show_item(context, item)
    docs.auto_show_timer:stop()
    if item == nil or not menu.win:is_open() then
      return docs.win:close()
    end

    sources
      .resolve(context, item)
      :map(function(resolved)
        local valid_documentation = type(resolved.documentation) == "table"
          or type(resolved.documentation) == "string"
        local valid_detail = type(resolved.detail) == "string"

        if not valid_documentation and not valid_detail then
          docs.close()

          return
        end

        if docs.shown_item ~= resolved then
          local docs_buf = docs.win:get_buf()
          local default_impl = function(opts)
            M.draw(vim.tbl_extend("force", {
              context = context,
              item = resolved,
              window = docs.win,
              config = config,
            }, opts or {}))
          end
          local draw = type(resolved.documentation) == "table" and resolved.documentation.draw
            or config.draw

          vim.api.nvim_set_option_value("modifiable", true, { buf = docs_buf })
          draw({
            item = resolved,
            context = context,
            window = docs.win,
            config = config,
            default_implementation = default_impl,
          })
          vim.api.nvim_set_option_value("modifiable", false, { buf = docs_buf })

          if not buffer_has_content(docs_buf) then
            docs.close()

            return
          end
        end

        docs.shown_item = resolved

        if menu.win:get_win() then
          docs.win:open()
          docs.win:set_cursor({ 1, 0 })
          docs.update_position()
        end
      end)
      :catch(function(err)
        vim.notify(err, vim.log.levels.ERROR, { title = "blink.cmp" })
      end)
  end
end

return M
