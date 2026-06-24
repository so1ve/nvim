# Lua module boundaries

This directory uses four runtime buckets with intentionally narrow meanings:

- `features/`: user-facing workflows that compose editor behavior, plugins, or commands.
- `integrations/`: adapters for specific plugins or reusable plugin-facing APIs.
- `utils/`: plugin-agnostic helpers that are safe to reuse from any layer.
- `patch/`: monkey patches and helpers used only by local plugin patches.

If a module `require`s a concrete plugin, it should usually live in `features/` or `integrations/`, not `utils/`.
If a module exists only to support monkey patches, it belongs in `patch/`.
