return {
  "mini.sessions",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  config = function()
    require("ray.features.sessions").setup()
  end,
}
