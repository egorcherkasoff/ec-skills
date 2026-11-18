# Layer Rules

Layer rules apply visual effects to layer-shell surfaces (bars, launchers,
notifications). Run `umbriel layers` to list active namespaces. Every matching rule
contributes its values; later values take precedence.

```toml
[[layer_rule]]
match.namespace = "^noctalia-bar-"
blur = true
blur_ignore_alpha = 0.5
blur_popups = true
```

## Matching

| Selector | Type | Description |
| --- | --- | --- |
| `match.namespace` | regex | Layer surface namespace; one pattern or array, any match suffices |
| `match.layer` | enum | `"background"`, `"bottom"`, `"top"`, `"overlay"` |
| `match.at_startup` | bool | During or after the first 60 seconds |

Regexes match any part — anchor with `^...$` for exact matches. Selectors are
optional: a rule without them matches every layer surface.

## Effects

| Key | Type | Description |
| --- | --- | --- |
| `dim_behind` | float 0.0–1.0 | Darken content below this layer on its output (default 0.0) |
| `blur` | bool | Enable/disable blur for the layer surface (off by default) |
| `blur_popups` | bool | Enable/disable blur for descendant XDG popups |
| `blur_ignore_alpha` | float 0.0–1.0 | Skip blur below an alpha threshold |
| `blur_optimized` | bool | Override the global optimized-blur choice |

Optimized blur samples the cached wallpaper blur, so a surface opening over windows
shows the wallpaper through it instead of the windows. Set `blur_optimized = false` on
surfaces that cover windows (panels, docks, notifications) to blur the live content
behind them — costs GPU time every frame they are visible and something behind them
changes. Surfaces covering only the wallpaper (a bar) keep the cheaper optimized blur.
Popups (bar menus, tooltips) always blur the live content behind them, whatever
`blur_optimized` says.

## Keyboard focus

A layer surface declares its own keyboard interactivity via the layer-shell protocol;
no rule overrides it.

| Interactivity | Behavior |
| --- | --- |
| `none` | Never receives keyboard focus; clicking it leaves the focused window alone |
| `on_demand` | Takes focus when mapped; clicking a window or a focus action moves focus away |
| `exclusive` | Keeps keyboard focus; windows get no keys, focus actions cannot leave it |

Launchers and panels with search fields commonly use `on_demand`.

Fullscreen interaction:

- While a fullscreen window covers an entire output, top-layer surfaces on that output
  stay underneath and cannot receive keyboard focus, even `exclusive`.
- When fullscreen content scrolls partly/completely off-screen, top layers are drawn
  above it and can receive keyboard input.
- Overlay-layer surfaces can take focus over fullscreen.
- Once a top-layer surface is uncovered, `exclusive` reclaims keyboard focus;
  `on_demand` waits to be clicked.

## Dim behind

```toml
[[layer_rule]]
match.namespace = "^vicinae$"
dim_behind = 0.5
```

The dim covers the layer's output, below that layer in the scene stack. The layer, its
popups, and surfaces above it keep normal brightness. Follows the layer's opening fade;
clears on unmap. Requires no keyboard focus and does not intercept pointer input.
Several dimming surfaces stack their dimming; a later matching `dim_behind = 0.0`
disables it.
