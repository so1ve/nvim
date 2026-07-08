local M = {}

local names = {
  [vim.diagnostic.severity.ERROR] = "Error",
  [vim.diagnostic.severity.WARN] = "Warn",
  [vim.diagnostic.severity.INFO] = "Info",
  [vim.diagnostic.severity.HINT] = "Hint",
}

local signs = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "󰌵",
}

function M.sign(severity)
  return signs[severity] or "•"
end

function M.sign_group(severity)
  return "DiagnosticSign" .. (names[severity] or "Info")
end

function M.setup()
  vim.diagnostic.config({
    float = {
      border = "rounded",
      close_events = { "BufHidden", "CursorMoved", "CursorMovedI", "InsertCharPre" },
      format = function(diagnostic)
        return diagnostic.message:gsub("\n", " \n") .. (diagnostic.code and "" or " ")
      end,
      header = "",
      max_width = 80,
      prefix = function(diagnostic)
        return " " .. M.sign(diagnostic.severity) .. " ", "DiagnosticFloating" .. (names[diagnostic.severity] or "Info")
      end,
      source = "if_many",
      suffix = function(diagnostic)
        return diagnostic.code and (" [" .. diagnostic.code .. "] ") or "", "Comment"
      end,
    },
    severity_sort = true,
    signs = { text = signs },
    update_in_insert = false,
    virtual_text = false,
    virtual_lines = false,
  })
end

return M
