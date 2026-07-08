return {
  {
    "mrjones2014/codesettings.nvim",
    lazy = false,
    opts = function()
      local Control = require("codesettings.extensions").Control

      return {
        loader_extensions = {
          "codesettings.extensions.vscode",
          {
            object = function(root, context)
              local gopls = root.gopls

              if #context.path ~= 0 or type(gopls) ~= "table" then
                return Control.CONTINUE
              end

              for _, source in pairs({ gopls.build, gopls.formatting, gopls.ui }) do
                if type(source) == "table" then
                  for key, value in pairs(source) do
                    if gopls[key] == nil then
                      gopls[key] = value
                    end
                  end
                end
              end

              return Control.CONTINUE
            end,
          },
        },
        live_reload = true,
      }
    end,
  },
}
