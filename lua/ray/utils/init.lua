local M = {}

local function unpack_values(values, index, last)
  if index > last then
    return nil
  end

  return values[index], unpack_values(values, index + 1, last)
end

-- handwritten unpack, since builtin unpack has been deprecated
-- handles nil as well
function M.unpack(values, first, last)
  if not values then
    return nil
  end

  return unpack_values(values, first or 1, last or #values)
end

return M
