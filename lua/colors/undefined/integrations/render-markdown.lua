local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  local function heading(level)
    return styles.extend(s.title, { bg = p.markdown_heading_bg[level] })
  end

  return {
    RenderMarkdownH1 = heading(1),
    RenderMarkdownH2 = heading(2),
    RenderMarkdownH3 = heading(3),
    RenderMarkdownH4 = heading(4),
    RenderMarkdownH5 = heading(5),
    RenderMarkdownH6 = heading(6),
    RenderMarkdownH1Bg = { bg = p.markdown_heading_bg[1] },
    RenderMarkdownH2Bg = { bg = p.markdown_heading_bg[2] },
    RenderMarkdownH3Bg = { bg = p.markdown_heading_bg[3] },
    RenderMarkdownH4Bg = { bg = p.markdown_heading_bg[4] },
    RenderMarkdownH5Bg = { bg = p.markdown_heading_bg[5] },
    RenderMarkdownH6Bg = { bg = p.markdown_heading_bg[6] },
    RenderMarkdownCode = { bg = p.bg },
    RenderMarkdownCodeBorder = { bg = p.bg },
    RenderMarkdownCodeInline = { bg = p.bg },
  }
end

return M
