local bufferline = require("integrations.bufferline")
local edgy = require("integrations.edgy")

local function current_file()
  local path = vim.fn.expand("%:p")

  return vim.uv.fs_realpath(path) or path
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvimtools/hydra.nvim",
      "so1ve/tiny-treesitter.nvim",
    },
    opts = {
      adapters = {},
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          require("trouble").open({ mode = "quickfix", focus = false })
        end,
      },
    },
    config = function(_, opts)
      local Hydra = require("integrations.hydra")
      local neotest_namespace = vim.api.nvim_create_namespace("neotest")

      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          end,
        },
      }, neotest_namespace)

      opts.consumers = opts.consumers or {}
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end

          local tree = assert(client:get_position(nil, { adapter = adapter_id }))
          local failed = 0

          for position_id, result in pairs(results) do
            if result.status == "failed" and tree:get_key(position_id) then
              failed = failed + 1
            end
          end

          vim.schedule(function()
            local trouble = require("trouble")

            if trouble.is_open() then
              trouble.refresh()

              if failed == 0 then
                trouble.close()
              end
            end
          end)

          return {}
        end
      end

      local adapters = {}

      for name, config in pairs(opts.adapters) do
        if type(name) == "number" then
          if type(config) == "string" then
            config = require(config)
          end

          table.insert(adapters, config)
        elseif config ~= false then
          local adapter = require(name)

          if type(config) == "table" and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)

            if adapter.setup then
              adapter.setup(config)
            elseif adapter.adapter then
              adapter.adapter(config)
              adapter = adapter.adapter
            elseif meta and meta.__call then
              adapter = adapter(config)
            else
              error("Adapter " .. name .. " does not support setup")
            end
          end

          table.insert(adapters, adapter)
        end
      end

      opts.adapters = adapters
      require("neotest").setup(opts)

      Hydra({
        name = "Test",
        mode = "n",
        body = "<leader>T",
        heads = {
          {
            "r",
            function()
              require("neotest").run.run()
            end,
            { desc = "Nearest", group = "Run" },
          },
          {
            "t",
            function()
              require("neotest").run.run(current_file())
            end,
            { desc = "File", group = "Run" },
          },
          {
            "T",
            function()
              require("neotest").run.run(vim.uv.cwd())
            end,
            { desc = "All files", group = "Run" },
          },
          {
            "l",
            function()
              require("neotest").run.run_last()
            end,
            { desc = "Last", group = "Run" },
          },
          {
            "s",
            function()
              require("neotest").summary.toggle()
            end,
            { desc = "Summary", group = "Inspect" },
          },
          {
            "o",
            function()
              require("neotest").output.open({ enter = true, auto_close = true })
            end,
            { exit = true, desc = "Output", group = "Inspect" },
          },
          {
            "O",
            function()
              require("neotest").output_panel.toggle()
            end,
            { desc = "Output panel", group = "Inspect" },
          },
          {
            "a",
            function()
              require("neotest").run.attach()
            end,
            { exit = true, desc = "Attach", group = "Inspect" },
          },
          {
            "w",
            function()
              require("neotest").watch.toggle(current_file())
            end,
            { desc = "Watch", group = "Control" },
          },
          {
            "S",
            function()
              require("neotest").run.stop()
            end,
            { desc = "Stop", group = "Control" },
          },
          {
            "d",
            function()
              require("neotest").run.run({ strategy = "dap" })
            end,
            { exit = true, desc = "Debug nearest", group = "Control" },
          },
        },
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>T", desc = "Test Hydra" },
    },
  },
  edgy.view_spec("left", edgy.view("Neotest", "neotest-summary", { wo = { winbar = false } })),
  bufferline.offset_spec(bufferline.offset("neotest-summary", "Neotest")),
  edgy.view_spec("bottom", edgy.view("Neotest Output", "neotest-output-panel", { size = { height = 15 } })),
  edgy.neo_tree_exclusion_spec({ "neotest-summary", "neotest-output-panel" }),
}
