local M = {}

function M.offset(filetype, text)
  local offset = {
    filetype = filetype,
    text = text,
    text_align = "left",
    highlight = "BufferLineOffset",
    separator = true,
  }

  return {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options.offsets = opts.options.offsets or {}
      table.insert(opts.options.offsets, offset)
    end,
  }
end

return M
