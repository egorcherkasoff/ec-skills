# Appearance

Colors, window decorations, blur, shadows. Color format: `#RRGGBB` or `#RRGGBBAA`.

## Colors

```toml
[colors]
background = "#141419FF"
text_primary = "#E8E8EAFF"
text_muted = "#8A8A92FF"
accent_primary = "#7AA3FFFF"
accent_secondary = "#F5C96BFF"
warning = "#F5C96BFF"
error = "#FF6B6BFF"
insert_hint = "#7FC8FF80"
backdrop = "#000000FF"
shadow = "#0000007F"
```

| Key | Used for |
| --- | --- |
| `background` | Umbriel panels and banners |
| `text_primary` / `text_muted` | Primary / secondary text |
| `accent_primary` | Titles, key chords, primary emphasis |
| `accent_secondary` | Secondary emphasis, group headings |
| `warning` / `error` | Warning/error text and borders |
| `insert_hint` | Drop-target preview during dragging |
| `backdrop` | Fullscreen background; RGB of the opaque emergency lock blank |
| `shadow` | Window shadow color |

### Border colors

```toml
[colors.border]
focused = "#7AA3FFFF"
unfocused = "#292933FF"
outer = "#1A1A1FFF"
```

`focused`/`unfocused` color the inner border; `outer` the optional outer border. Window
rules `border_color_*` can override per window.

### Overview colors

```toml
[colors.overview]
background_tint = "#10101430"
workspace_background = "#00000044"
badge = "#7AA3FFFF"
```

### Tab bar colors

```toml
[colors.tab_bar]
background = "#1A1A1FFF"
text = "#8A8A92FF"
active = "#7AA3FFFF"
active_text = "#141419FF"
active_unfocused = "#292933FF"
active_unfocused_text = "#E8E8EAFF"
urgent = "#FF6B6BFF"
urgent_text = "#141419FF"
```

### Title bar colors

```toml
[colors.title_bar]
background = "#292933FF"
background_unfocused = "#1A1A1FFF"
text = "#E8E8EAFF"
text_unfocused = "#8A8A92FF"
close = "#FF6B6BFF"
maximize = "#7AA3FFFF"
minimize = "#FFD166FF"
# Glyph colors: <button>_glyph and <button>_glyph_hover per button
# (close_glyph, maximize_glyph_hover, ...).
```

## Window appearance

```toml
[appearance]
prefer_no_csd = true
border_width = 2
outer_border_width = 0
corner_radius = 10
drag_opacity = 0.75
opaque_fullscreen = true
```

| Key | Default | Notes |
| --- | --- | --- |
| `prefer_no_csd` | `true` | Prefer Umbriel's border-only server decoration. Restart apps after changing (fixed at connect time). |
| `border_width` | `2` | Inner border, logical px. |
| `outer_border_width` | `0` | Outer ring, logical px. |
| `corner_radius` | `10` | `0` = square. |
| `drag_opacity` | `0.75` | Opacity while dragging. |
| `opaque_fullscreen` | `true` | Fullscreen windows drawn over backdrop, rule `opacity` ignored. `false` lets translucent fullscreen show desktop / be blurred. |

Borders render outside window content and are included in layout spacing. Window rules
can override `border_width`, `outer_border_width`, `corner_radius` per app.

## Title bar

```toml
[appearance.title_bar]
mode = "off"            # "on" | "negotiated" | "forced" | "off"
height = 28
font = "sans 10"        # Pango description
button_position = "right"   # or "left"
buttons = ["minimize", "maximize", "close"]  # from the title outward
button_corner_radius = -1   # -1 follows the window's corner_radius
button_background = true
button_glyph = "hover"  # "always" | "hover" | "never"
```

- `mode`: `off` (default) hides bars; `negotiated` follows client decoration
  preferences; `on` shows bars for windows without their own; `forced` shows bars on
  everything. Window rules override with `title_bar`; `title_bar_buttons` overrides the
  button list per app.
- Title bars give modifier-free dragging, resizing from the floating frame, and window
  buttons. Enable for the stacking layout (`[layout] mode = "stacking"`).
- The minimize button appears only while the window floats; the app's own maximize
  request follows `layout.client_maximize`.
- Bar hidden while its window is fullscreen.

## Tab bar

```toml
[appearance.tab_bar]
style = "titles"        # "titles" | "indicator"
position = "top"        # top | bottom | left | right
height = 24             # 2–400 logical px (thickness)
font = "sans 10"        # Pango description
padding = 8
tab_gap = 2
corner_radius = -1      # -1 follows appearance.corner_radius
title_format = "{title}"  # {title}, {app_id}, {index} (from 1)
title_align = "center"  # left | center | right
visible = true
hide_when_single = false
max_tabs = 0            # 0 = show all; else 0–64
overflow = "scroll"     # "scroll" | "shrink"
```

- `indicator` style: slots only — pair with small `height` for a thin strip.
- Side positions stack the slots (vertical list); give titles room (e.g. `height = 160`).
- Bar hidden while its window is fullscreen or maximized to edges.
- `visible = false` hides every bar a group hasn't shown itself
  (`column-show-tab-bar` / `column-toggle-tab-bar` per group); tabs keep working.
- `hide_when_single`: no bar, no reserved space while the group holds one window; the
  group persists so the next window becomes a tab.
- `scroll` overflow shows a run following the active tab with `‹` `›` buttons (wrap,
  wheel, and focus all move it).

## Blur

```toml
[appearance.blur]
enabled = true
optimized = true
passes = 3        # 0–8
radius = 5        # 0–100
noise = 0.02      # 0.0–1.0
brightness = 0.9  # 0.0–2.0
contrast = 0.9    # 0.0–2.0
saturation = 1.1  # 0.0–2.0
```

`enabled` is the master switch; surfaces still opt in via window/layer rules. Blur appears
only where a surface is transparent. `optimized = true` shares one cached background blur
per output; `false` blurs directly-behind surfaces at higher cost. The cache follows
background layer-shell updates including animated map/unmap.

## Shadow

```toml
[appearance.shadow]
enabled = true
softness = 10      # 0–200
offset_x = 2       # -200–200
offset_y = 2       # -200–200
```

Shadow falls on everything below the window (floating/pinned/scratchpad overlaps), never
between tiled windows, hidden for fullscreen. During a custom window animation the shadow
follows the shader's visible shape. Window rule `shadow` toggles per app; softness,
offsets, and color stay global.
