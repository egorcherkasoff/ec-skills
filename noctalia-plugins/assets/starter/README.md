# Hello — Noctalia v5 starter

A minimal but complete plugin with:

- a bar widget with widget-level settings and IPC;
- a floating panel with a declarative `ui.*` tree;
- a headless service that publishes shared state;
- plugin-level and widget-level settings;
- translations.

## Try it

```bash
cp -r . ~/.local/share/noctalia/plugins/hello
noctalia plugins lint ~/.local/share/noctalia/plugins/hello
noctalia msg plugins enable me/hello
```

Add the `hello` widget to a bar, open the panel:

```bash
noctalia msg panel-toggle me/hello:panel
```

Change the label at runtime:

```bash
noctalia msg plugin me/hello:hello focused set "Hi there"
```

Edit `.luau` files while the plugin is enabled to hot-reload them. Manifest edits
need `noctalia msg config-reload`.

## Publishing

Before submitting to the community store, add a `thumbnail.webp`, fill out this
README for the store page, bump `version` in `plugin.toml`, and add the plugin to
the source repo's `catalog.toml`.
