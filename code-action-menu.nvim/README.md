# code-action-menu.nvim

A small Neovim LSP code action picker with a lightweight Snacks preview.

It collects available code actions from attached LSP clients, keeps the originating client attached to each item, and
lets you choose an action with Snacks picker, mini.pick, or Neovim's native `vim.ui.select`.

## Features

- `require("code-action-menu").setup(opts)` and `require("code-action-menu").code_action(opts)`
- Picker fallback order: `snacks` → `mini` → `native`
- Rows include an icon, the action title, and the LSP client/source name
- Snacks source labels are right-aligned and dimmed
- Snacks preview shows available edit/command details and falls back to `No preview available`
- Disabled code actions are skipped instead of shown
- Optional `codeAction/resolve` support
- Applies workspace edits before executing commands
- Executes commands through `client:exec_cmd(command, ctx)`
- No hard dependency on Snacks or mini.pick

## Installation

### `lazy.nvim`

```lua
{
  "so1ve/code-action-menu.nvim",
  event = "LspAttach",
  opts = {
    picker = { "snacks", "mini", "native" },
  },
}
```

Then map it from your LSP attach logic:

```lua
vim.keymap.set("n", "<leader>ca", function()
  require("code-action-menu").code_action()
end, { buffer = bufnr, desc = "Code action" })
```

## Configuration

```lua
require("code-action-menu").setup({
  picker = { "snacks", "mini", "native" },
  notify = true,
  icons = {
    quickfix = "󰁨",
    refactor = "󰊕",
    extract = "󰈌",
    inline = "󰏖",
    rewrite = "󰷈",
    source = "󰒓",
    organize_imports = "󰉕",
    fallback = "󰌵",
  },
})
```

`code_action()` accepts the same options for one call. It also accepts `bufnr`, `context`, and `only`:

```lua
require("code-action-menu").code_action({ only = "source.organizeImports" })
```

## Pickers

### Snacks

Uses `snacks.picker` when available. Preview shows available edit/command details.

### mini.pick

Uses `require("mini.pick").start()` when available.

### native

Uses `vim.ui.select` as the final fallback.
