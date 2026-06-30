vim.pack.add({ "https://github.com/zuqini/zpack.nvim" })

require("zpack").setup({
  spec = {
    { import = "ray.plugins" },
  },
  defaults = {
    lazy = true,
    confirm = false,
  },
})
