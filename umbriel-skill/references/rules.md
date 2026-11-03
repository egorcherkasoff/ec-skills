# Window, Layer, and Security-Context Rules

## Window rules

```toml
[[window_rule]]
match.app_id = "^firefox$"
default_workspace = 2
```

Every matching rule contributes its values; when two set the same field, the later rule
wins. State selectors update while the window is open; opening settings resolve before a
rule's own state changes take effect.

### Matching

| Selector | Description |
| --- | --- |
| `match.app_id` | Regex against application ID |
| `match.title` | Regex against window title |
| `match.xdg_tag` | Client-defined XDG toplevel tag |
| `match.content_type` | `"none"`, `"photo"`, `"video"`, `"game"` |
| `match.is_focused` | Current focus state |
| `match.is_floating` | Current floating state |
| `match.is_pinned` | Current pinned state |
| `match.is_scratchpad` | Current scratchpad state |
| `match.is_alone` | Only tiled window on the workspace |
| `match.is_only_window` | Only window at all (tiled or floating) |
| `match.at_startup` | During or after the first 60 seconds |

- Regexes match any part — anchor with `^...$` for exact matches.
- `app_id`, `title`, `xdg_tag` accept one pattern or an array (any match suffices; empty
  array = no constraint).
- No selectors = matches every window.
- Inspect live values with `umbriel windows`. Prefer `app_id` over `title`.

### Settings applied when a window opens

| Key | Description |
| --- | --- |
| `default_output` | Connector or monitor name |
| `default_workspace` | Int = 1-based position; string = exact name (must exist) |
| `default_scratchpad` | `"default"` or a configured scratchpad name |
| `default_fullscreen` | Open fullscreen |
| `default_floating` | Force floating (`true`) or tiling (`false`) |
| `default_maximize` | Open maximized within normal layout bounds |
| `default_maximize_to_edges` | Open maximized without gaps/struts/borders |
| `default_focused` | Whether the new window takes focus |
| `default_pinned` | Open pinned above normal windows (opens floating) |
| `default_scrolling_column` | Join matching windows into one named column (per workspace) |
| `default_scrolling_column_order` | Order inside the named column |
| `default_column_display` | `"tabbed"` or `"normal"` for the column the window opens in |

Applied once per opening value. Rules are rechecked when the first post-map title arrives
and when content type first becomes non-`none` (covers late-identity apps like Wine/Proton
children); each selected value applies at most once across those checks.

Dialogs float by default — `default_floating = false` forces one into the layout.

### Size and position

| Key | Applies to | Description |
| --- | --- | --- |
| `default_floating_size_px` | Floating | `{ width = 800, height = 600 }` logical px |
| `default_floating_size` | Floating | Fraction of output usable area |
| `default_scrolling_extent_px` | Scrolling | Initial logical-px extent along the strip |
| `default_scrolling_extent` | Scrolling | Initial fractional extent |
| `default_position` | Floating | `{ x = 32, y = 24, anchor = "bottom_left" }` |

Pixel values beat fractions; each axis optional. Anchors: `center`, `top_left`,
`top_right`, `bottom_left`, `bottom_right`, `top`, `bottom`, `left`, `right` (right/bottom
measure inward). A tiled window remembers floating rules until it first floats and vice
versa.

### Settings updated while open

| Key | Description |
| --- | --- |
| `opacity` | Surface opacity 0.0–1.0 (bypassed in fullscreen unless `appearance.opaque_fullscreen = false`) |
| `blur` / `blur_popups` / `blur_ignore_alpha` / `blur_optimized` | Blur control for window and its XDG popups |
| `confine_pointer` | Keep pointer inside while window has keyboard focus |
| `focus_on_activate` | Per-window activation focus override |
| `vrr` | Override focused output's VRR policy |
| `tearing` | Request or veto async presentation |
| `hdr` | Override focused output's HDR policy |
| `border_color_focused` / `border_color_unfocused` / `border_color_outer` | Override `[colors.border]` |
| `border_width` / `outer_border_width` / `corner_radius` | 0–100 overrides of `[appearance]` |
| `shadow` | Override `appearance.shadow.enabled` |
| `title_bar` | Override `[appearance.title_bar].mode` per app: `"on"`, `"negotiated"`, `"forced"`, `"off"` |
| `title_bar_buttons` | Override the button list (subset of `minimize`, `maximize`, `close`) |
| `allow_shortcuts_inhibit` | `false` denies the app's automatic keyboard-shortcuts-inhibition requests (manual `shortcuts-inhibit-toggle` still works) |
| `border_effect` / `window_effect` | Effect preset/pool name or `"off"` |

Refresh on matching identity/state change. Decoration overrides never move other windows
(layout spacing uses global widths; a thinner border leaves its gap empty).

Named scrolling columns example:

```toml
[[window_rule]]
match.app_id = "^firefox$"
default_scrolling_column = "browsers"
default_scrolling_column_order = 10

[[window_rule]]
match.app_id = "^chromium$"
default_scrolling_column = "browsers"
default_scrolling_column_order = 20
# add default_column_display = "tabbed" to keep the column as tabs
```

`match.is_alone` (tiled-only) drives fullscreen/maximize/extent behaviors that toggle as
company arrives/leaves. `match.is_only_window` is the stricter check used by the
"updated while open" settings; pinned and scratchpad windows don't count as company.

Examples:

```toml
[[window_rule]]
blur = true                                # blur every window

[[window_rule]]
match.app_id = "^org[.]pulseaudio[.]pavucontrol$"
default_floating = true
default_floating_size = { width = 0.5, height = 0.6 }

[[window_rule]]
match.app_id = "^steam_app_[0-9]+$"
default_workspace = 4
default_fullscreen = true

[[window_rule]]
match.content_type = "game"
vrr = "always"

[[window_rule]]
match.is_focused = false
opacity = 0.85

[[window_rule]]
match.is_focused = true
opacity = 1.0

[[window_rule]]
match.app_id = "^steam_app_.*$"
confine_pointer = true

[[window_rule]]
match.is_scratchpad = true
border_color_focused = "#E5C07BFF"
border_color_unfocused = "#5C4A2AFF"
```

Pointer confinement: applies to floating/tiled/fullscreen while focused and pointer inside
visible content; client locks still work and confinement resumes on release; suspended
during lock, overview, compositor move/resize, client drag. Escape via focus/workspace
keybinds.

## Layer rules

Layer-shell surfaces (bars, launchers, notifications). `umbriel layers` lists namespaces.

```toml
[[layer_rule]]
match.namespace = "^noctalia-bar-"
blur = true
blur_ignore_alpha = 0.5
blur_popups = true
```

| Selector | Description |
| --- | --- |
| `match.namespace` | Regex (one pattern or array) |
| `match.layer` | `"background"`, `"bottom"`, `"top"`, `"overlay"` |
| `match.at_startup` | First 60 seconds |

Settings: `blur`, `blur_popups`, `blur_ignore_alpha`, `blur_optimized`. Layer-shell blur
is off by default; every matching rule contributes; later values win.

Keyboard focus is declared by the surface itself (none / on_demand / exclusive) and no
rule overrides it. While a fullscreen window shows, top-layer surfaces stay under it and
cannot take focus (even `exclusive`); overlay-layer surfaces can. After fullscreen leaves,
`exclusive` reclaims focus; `on_demand` waits for a click.

## Security-context rules (sandboxed clients)

Umbriel implements security-context-v1 (always enabled): sandboxed Wayland connections
lose compositor-wide authority (capture, virtual input, clipboard-manager, layer shell,
session locking, gamma/output config, global window/workspace control, nested contexts).
Portals mediate privileged ops.

Grant extra globals when an app genuinely needs one:

```toml
[[security_context_rule]]
match.sandbox_engine = 'org\.flatpak'
match.app_id = 'org\.example\.ClipboardManager'
allow_globals = [
  "ext_data_control_manager_v1",
  "zwlr_data_control_manager_v1",
]
```

- Selectors `match.sandbox_engine` / `match.app_id` are regexes matched against the
  **complete** value (not substring); one pattern or array; optional (none = all
  restricted clients — avoid broad grants).
- Rules are additive; the base set cannot be removed;
  `wp_security_context_manager_v1` stays blocked even if listed.
- Changes apply to new connections only — restart the app. Invalid entries warn and are
  ignored. Grant both data-control variants unless the app's variant is known.

## Session locking

`ext-session-lock-v1`: desktop stays visible while the locker prepares mapped surfaces
(3 s budget); outputs switch after every active output presented a secure frame. A
stalling locker gets an opaque compositor-owned blank colored by `colors.backdrop`, which
also survives a crashed locker after handoff.
