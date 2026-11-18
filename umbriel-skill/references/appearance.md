# Appearance

Colors, window decorations, title bar, tab bar, blur, shadows. Colors use `#RRGGBB` or `#RRGGBBAA`.

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
| `text_primary` / `text_muted` | Primary / secondary (help, status) text |
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

`focused`/`unfocused` color the inner border; `outer` colors the optional outer border. A window rule can override any of them per matched window.

### Overview colors

```toml
[colors.overview]
background_tint = "#10101430"
workspace_background = "#00000044"
badge = "#7AA3FFFF"
```

`background_tint` tints the desktop behind the overview; `workspace_background` sits behind each workspace preview; `badge` colors shortcut badges.

### Tab bar colors

```toml
[colors.tab_bar]
background = "#1A1A1FFF"         # slots neither active nor urgent
text = "#8A8A92FF"
active = "#7AA3FFFF"             # active tab slot in the focused column
active_text = "#141419FF"
active_unfocused = "#292933FF"   # active tab slot in any other column
active_unfocused_text = "#E8E8EAFF"
urgent = "#FF6B6BFF"             # hidden tab asking for attention
urgent_text = "#141419FF"
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
| `prefer_no_csd` | `true` | Advertise preference for server decorations; the optional title bar is configured separately. Restart apps after changing (decoration protocol availability is fixed at connect time). |
| `border_width` | `2` | Inner border, logical px (0–100). |
| `outer_border_width` | `0` | Outer ring, logical px (0–100). |
| `corner_radius` | `10` | Radius of the complete decorated window (0–100); `0` = square. |
| `drag_opacity` | `0.75` | Opacity while dragging (0.0–1.0). |
| `opaque_fullscreen` | `true` | Draw fullscreen over the backdrop, ignoring window-rule `opacity`. |

With `opaque_fullscreen = false`, a translucent fullscreen window (rule opacity < 1 or app-drawn transparency) shows the desktop behind it and can be blurred; other fullscreen windows stay opaque and skip blur. X11 bounding-shape cutouts show what is behind the window with either setting. Borders render outside window content and are included in layout spacing; window rules override `border_width`, `outer_border_width`, and `corner_radius` per matched window.

## Title bar

Optional server-side title bar on decorated windows in every layout:

```toml
[appearance.title_bar]
mode = "off"                       # "off" | "negotiated" | "on" | "forced"
height = 28                        # 16–128 logical px
font = "sans 10"                   # Pango description
title_align = "left"               # left | right | center
button_position = "right"          # left | right
buttons = ["minimize", "maximize", "close"]
button_size = -1
button_gap = 8                     # 0–100
button_padding = -1                # 0–100; -1 = space above buttons
button_corner_radius = -1          # 0–100; -1 follows window corner_radius
button_glyph = "hover"             # always | hover | never
button_glyph_size = -1             # 1–128
button_glyph_stroke = -1           # 0.5–16.0
button_background = true

[colors.title_bar]
background = "#292933FF"           # focused window
background_unfocused = "#1A1A1FFF"
text = "#E8E8EAFF"
text_unfocused = "#8A8A92FF"
close = "#FF6B6BFF"                # button backgrounds
maximize = "#7AA3FFFF"
minimize = "#FFD166FF"
# Per button: <name>_glyph and <name>_glyph_hover (close_glyph,
# close_glyph_hover, maximize_glyph, ...); all default "#141419FF".
```

### Modes

- `"off"` (default): hide Umbriel's title bar.
- `"negotiated"`: show for Wayland windows only when decoration negotiation selects server-side decorations.
- `"on"`: follow client decoration preferences; show when no preference is known.
- `"forced"`: show regardless of client preference.

Both xdg-decoration and the older server-decoration protocol are tracked; xdg-decoration wins if a window uses both. A client that creates an xdg-decoration object and accepts the compositor's default still negotiates server-side decorations and gets a bar; explicit client-side requests suppress it. `"negotiated"` follows the same preferences but hides the bar when neither protocol is in use (avoids bars on apps with their own headerbars or intentionally frameless windows). Managed Xwayland windows follow their decoration hints in `"on"`/`"negotiated"`; popups and unmanaged Xwayland windows never get a bar. App-drawn headerbars stay part of application content — `prefer_no_csd = true` still advertises the preference to apps that negotiate.

### Geometry

- `buttons` lists buttons from the title outward; the last sits at the bar's edge (default puts close outermost on either side). Each of `minimize`/`maximize`/`close` may appear once; omit a name to hide it; `[]` = bar without buttons.
- `title_align`: `"left"` (default)/`"right"` align within the space beside the buttons; `"center"` centers on the whole bar, shifting only as far as needed to clear the buttons.
- `button_size`: `-1` derives from `height`; explicit values 1..height are drawn exactly — when it and `height` differ in parity, the button sits one px closer to the top.
- On narrow windows the padding then the gap shrink to fit; buttons keep their size, and the innermost buttons that still do not fit are left out (their space drags the window). The frame's rounded corners impose a minimum inset keeping title and complete buttons visible; larger `button_padding` still applies.
- `button_corner_radius` is capped at half the button size (circles at larger values); `0` = square buttons.
- Geometry follows `button_position`, scales with output and overview zoom, updates on reload. Independent of `height`.

### Glyphs

Buttons draw X (close), outlined square (maximize), underscore (minimize). `button_glyph`: `"always"` | `"hover"` (default — while hovered or pressed) | `"never"`. `button_glyph_size` never exceeds the button; `button_glyph_stroke` is the symbol's line width; both `-1` derive from `button_size` (symbol spans half the button, stroke one twelfth). `button_background = false` removes colored backgrounds, leaving symbols; buttons keep click targets while symbols are hidden. `button_glyph = "never"` + `button_background = false` hides the controls and returns their space to the title. Glyph colors support alpha and are not auto-adjusted — pick lighter glyphs on dark bars. Disabled buttons keep their idle glyph color and appear dimmed; backgrounds keep hover/pressed feedback.

### Interaction and state

- Drag empty bar space with the left button to move; double-click toggles maximize; buttons activate on release inside the same button. Enabled buttons show a pointing cursor on hover.
- Floating windows have modifier-free resize grips around borders and corners even when the bar is hidden — also individually floated windows in tiling layouts.
- `background`/`text` apply to the focused window; `_unfocused` variants to others. Colors and settings reload live.
- Maximize button disabled for fixed-size windows; minimize shows only while the window can minimize (tiled and pinned windows don't have one). Tab group members show the tab bar instead.
- Fullscreen hides the bar; normal maximize and maximize-to-edges keep it (its maximize button or a double-click restores). Maximized-to-edges bar: square corners, top of the usable area, borders/shadows hidden.
- The bar occupies space inside a tile's allocation — configured sizes, IPC window coordinates, and window captures still describe application content. Borders and shadows wrap bar + content together.

### Blur on the title bar

The bar follows its window's `blur`, `blur_optimized`, `blur_ignore_alpha` rules plus global `[appearance.blur]`. Give `background`/`background_unfocused` transparency (e.g. `"#292933CC"`) to see the blur; the alpha threshold applies to the bar's own color independently of app content. Opaque bar backgrounds stay opaque with blur enabled, including after leaving overview or switching focus; no layer rule needed; dragging, overview previews, and close animations keep the blur. Rounded windows keep a straight join between the bar and transparent content; the outer frame keeps its corners, and hiding the bar restores rounding to the content's top.

### Window rules

`title_bar` rule values: `"on"`, `"negotiated"`, `"forced"`, `"off"`. An omitted rule inherits the global mode; an explicit rule overrides it — `"forced"` can enable a bar with global `"off"`, `"on"` restores automatic selection, `"off"` hides, a `"negotiated"` rule requires negotiation for matched Wayland windows. Existing windows update when their preference or matching rule changes, or on reload. `title_bar_buttons` replaces `buttons` for matched windows:

```toml
[[window_rule]]
match.is_dialog = true
title_bar_buttons = ["close"]
```

## Tab bar

```toml
[appearance.tab_bar]
style = "titles"          # "titles" | "indicator"
position = "top"           # top | bottom | left | right
height = 24               # thickness, 2–400 logical px
font = "sans 10"          # Pango description
padding = 8               # 0–64
tab_gap = 2               # 0–64
gap = -1                  # bar↔window space, 0–500; -1 follows layout gap
corner_radius = -1        # -1 follows appearance.corner_radius
title_format = "{title}"  # {title}, {app_id}, {index} (from 1)
title_align = "center"    # left | center | right
visible = true
hide_when_single = false
max_tabs = 0              # slots shown at once, 0–64; 0 = all
overflow = "scroll"       # "scroll" | "shrink"
```

- `indicator` style: slots only — pair with a small `height` for a thin strip. `titles` shows each tab's title in its slot.
- Side positions stack slots into a vertical list (titles read across); give titles room (e.g. `height = 160`). The group reserves the bar plus its `gap`.
- Bar hidden while its window is fullscreen or maximized to edges.
- `visible = false` hides every bar a group hasn't shown itself; `column-show-tab-bar` / `column-toggle-tab-bar` still toggle one group's bar whatever this says; tabs keep working from the keyboard.
- `hide_when_single`: no bar, no reserved space while the group holds one window; the group persists, so the next window to join becomes a tab.
- `overflow = "scroll"`: slots keep their size, a run of tabs follows the active one, `‹`/`›` end buttons (`▴`/`▾` on a side bar) select prev/next, wrapping last→first; the wheel, tab actions, and focus move the active tab, and the strip follows one slot at a time. `"shrink"` narrows slots until every tab fits.
- Titles are drawn at the output's scale and cached — switching tabs never re-renders them; a scrolled bar renders only the tabs it shows.
- A window without a title shows its app id in `title_format`.

## Blur

```toml
[appearance.blur]
enabled = true
optimized = true
passes = 2         # 0–8
radius = 5         # 0–100
noise = 0.02       # 0.0–1.0
brightness = 0.9   # 0.0–2.0
contrast = 0.9     # 0.0–2.0
saturation = 1.1   # 0.0–2.0
```

`enabled` is the master switch; surfaces still opt in via window/layer rules. Blur appears only where a surface is transparent. `optimized = true` shares one cached background blur per output (samples the background beneath the window stack; cache follows background layer-shell updates, including animated map/unmap; unchanged commits requesting only frame callbacks reuse it); `false` blurs the surfaces directly behind each translucent surface at higher rendering cost.

## Shadow

```toml
[appearance.shadow]
enabled = true
softness = 10      # 0–200
offset_x = 2       # -200–200
offset_y = 2       # -200–200
```

Shadow falls on everything below the window (floating, pinned, scratchpad overlaps), never between tiled windows; hidden for fullscreen. During a custom window animation the shadow follows the shader's visible shape. A window rule toggles the shadow per matched window; softness, offsets, and color stay global.
