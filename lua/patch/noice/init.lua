-- Orchestrates Noice monkey patches in dependency order.
-- Purpose: keep each patch focused on one concern while still applying them
-- before `require("noice").setup()` in the plugin spec.
-- Implementation: markdown rendering is patched first because hover layout uses
-- its visual width data; layout then owns active hover state. Noice's own hover
-- scrollbar is disabled in plugin config.

local M = {}

function M.patch()
  require("patch.noice.markdown-width").patch()
  require("patch.noice.hover-layout").patch()
end

return M
