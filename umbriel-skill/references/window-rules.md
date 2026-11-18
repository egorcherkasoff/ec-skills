# Window Rules

Window rules apply settings to matching applications. Every matching rule contributes
its values; when two set the same field, the later rule wins. Selectors are optional —
a rule with none matches every window.

```toml
[[window_rule]]
match.app_id = "^firefox$"
default_workspace = 2
```

## Matching

| Selector | Description |
| --- | --- |
| `match.app_id` | Regex against the application ID |
| `match.title` | Regex against the window title |
| `match.xdg_tag` | Regex against a client-defined XDG toplevel tag |
| `match.content_type` | `"none"`, `"photo"`, `"video"`, `"game"` |
| `match.layout` | Workspace layout: `"scrolling"`, `"dwindle"`, `"master"`, `"stacking"` — one name or array, any match suffices, empty array = no constraint |
| `match.is_focused` | Current focus state |
| `match.is_floating` | Current floating state |
| `match.is_maximized_to_edges` | Maximized-to-edges state; accepts `false`, updates on keybind, app request, or title bar |
| `match.is_pinned` | Current pinned state |
| `match.is_scratchpad` | Current scratchpad state |
| `match.is_alone` | Alone in its workspace's tiled layout (floats don't count) |
| `match.is_only_window` | Only window on its workspace, floating ones included |
| `match.is_dialog` | Application named a parent window for it |
| `match.is_cast_target` | A screencast/screenshot is capturing this window |
| `match.at_startup` | During or after the first 60 seconds |

- Regexes match any part — anchor `^...$` for exact. `app_id`, `title`, `xdg_tag` take
  one pattern or an array; empty array = no constraint.
- `match.layout` follows the workspace layout, including for floating windows, and
  refreshes on layout change or workspace move. A window without a workspace never
  matches a non-empty layout selector — use it for while-open settings, not placement.
- State selectors update while open. Opening settings resolve before a rule's own state
  changes take effect: a rule cannot select on the floating/pinned state it creates.
- Inspect with `umbriel windows` / `umbriel focused-window`. Prefer `app_id` (titles
  change). Plain-text listing prints `-` for an empty title; matching literal `-`
  selects nothing — use `match.title = "^$"` for a client-supplied empty title.

## Settings applied when a window opens

| Key | Description |
| --- | --- |
| `default_output` | Connector or monitor name |
| `default_workspace` | Int = 1-based position (1–64); string = exact case-sensitive name (must exist via static inventory or named workspace rule); `default_output` restricts either form |
| `default_scratchpad` | `"default"` (implicit) or a configured scratchpad name |
| `default_fullscreen` | Open fullscreen |
| `default_floating` | `true` floats, `false` tiles (dialogs float by default) |
| `default_maximize` | Open maximized in normal layout bounds (full column width; the client's own maximize request is governed by layout `client_maximize` instead) |
| `default_maximize_to_edges` | Open maximized without gaps, struts, or borders |
| `default_focused` | Override focus for the new window; `true` also reveals a floating window above fullscreen |
| `default_pinned` | Open pinned above normal windows (opens floating, so never alone) |
| `default_scrolling_column` | Join matching windows into one named scrolling column (name local to a workspace) |
| `default_scrolling_column_order` | Order inside the named column |
| `default_column_display` | `"tabbed"` or `"normal"` for the column the window opens in |
| `attach_to_parent` | `false` keeps a modal dialog an ordinary window that placement rules apply to (default: attaches to parent, ignores them); rechecked on reload |

Applied once per opening value. Rules recheck when the first post-map title arrives and
when the effective content type first changes `none` → non-`none` (covers late-identity
apps, Wine/Proton children); each value applies at most once across those checks.
Later identity changes refresh only the while-open settings. Named
`default_workspace` targets stay valid when their output is gone and the workspace
evacuated; a name plus `default_output` can select that output's evacuated workspace
even if another workspace on the receiving output has the same name. Missing or
ambiguous targets fall back to normal placement. A rule matching the parent covers its
dialogs — portal file pickers carry the portal's app id (`xdg-desktop-portal-gtk`), so
match the parent to opt them out; a rule matching the dialog itself wins.

```toml
[[window_rule]]
match.app_id = "^org\\.mozilla\\.firefox$"
attach_to_parent = false
```

X11 special cases:

- Client-placed X11 popups (notifications, popup menus, dropdowns, tooltips) bypass
  window rules entirely and don't appear in `umbriel windows`. Torn-off menus marked
  `_NET_WM_WINDOW_TYPE_MENU` stay managed unless override-redirect. An app publishing
  its popup type/override-redirect after opening switches to popup handling, restores
  client position/size, clears maximize/fullscreen. Client-placed popups also wait for
  pending Xwayland geometry events before first visibility (no stale-position flash).
- `_NET_WM_WINDOW_TYPE_NOTIFICATION` windows keep client-requested position/size from
  the first visible frame, never take keyboard focus, need no placement rule; a popup
  switching to notification returns focus to the active window.
- Wine/Proton native Wayland context menus surface as untitled, unparented
  `xdg_toplevel` windows: normal rules but no popup anchor — can open centered or
  maximized, hover focus can return to the app. Fix: X11 driver via Proton launch
  options `PROTON_ENABLE_WAYLAND=0 PROTON_USE_WAYLAND=0 %command%`, restart; the main
  window should report `xwayland: true` in `umbriel windows --json`. Rules cannot
  supply the missing popup anchor.

## Size and position

| Key | Applies to | Type/limits |
| --- | --- | --- |
| `default_floating_size_px` | Floating | `{ width = 800, height = 600 }` logical px; each axis optional, 1–100000 |
| `default_floating_size` | Floating | Fraction of output usable area, 0.1–1.0 per axis |
| `default_scrolling_extent_px` | Scrolling | Initial logical-px extent along the strip, up to 4 viewports |
| `default_scrolling_extent` | Scrolling | Initial fractional extent along the strip, 0.1–4.0 |
| `default_position` | Floating | `{ x = 32, y = 24, anchor = "bottom_left" }`; logical px in the output's usable area |

Pixel beats fraction. A tiled window remembers floating size/position rules until it
first floats; a floating window remembers its scrolling extent until it first tiles.
Floating size defaults also apply when the initial title arrives between the opening
configure and the first visible buffer; unchanged dimensions are not reapplied over an
app-chosen size. Apps can resize themselves after. Anchors: `center`, `top_left`,
`top_right`, `bottom_left`, `bottom_right`, `top`, `bottom`, `left`, `right` (default
`center`); right/bottom anchors measure inward.

## Scratchpad placement

```toml
[[scratchpad]]
name = "terminal"

[[window_rule]]
match.app_id = "^scratchpad-terminal$"
default_scratchpad = "terminal"
default_floating_size = { width = 0.7, height = 0.7 }
```

With no named scratchpads defined, use `"default"`. A hidden scratchpad keeps the new
window hidden unless `default_focused = true` (which also reveals it above fullscreen).
The window opens with the size/position from `default_floating_size*`/
`default_position` (centered if no position), or fullscreen/maximized-to-edges with
`default_fullscreen`/`default_maximize_to_edges`. A window moved in later keeps its
current size/position.

## Named scrolling columns

```toml
[[window_rule]]
match.app_id = "^firefox$"
default_scrolling_column = "browsers"
default_scrolling_column_order = 10

[[window_rule]]
match.app_id = "^chromium$"
default_scrolling_column = "browsers"
default_scrolling_column_order = 20
default_column_display = "tabbed"   # keep the column as tabs
```

Name is local to a workspace; the first matching window creates the column and sets
its extent. `"tabbed"` tabs each matching window with the windows stacked beside it in
the column it joins or creates.

## Settings updated while a window is open

| Key | Description |
| --- | --- |
| `dim_behind` | Darken content below this window on its output; 0.0–1.0, default 0.0 |
| `opacity` | Surface opacity 0.0–1.0 (bypassed in fullscreen unless `appearance.opaque_fullscreen = false`) |
| `blur` | Window blur (including translucent Umbriel title bars) |
| `blur_popups` | Blur descendant XDG popups (popups always blur live content behind them regardless of `blur_optimized`) |
| `blur_ignore_alpha` | Skip blur below an alpha threshold, 0.0–1.0 |
| `blur_optimized` | Override the global optimized-blur choice |
| `confine_pointer` | Keep pointer inside while the window has keyboard focus (default `false`) |
| `touchpad_scroll_factor` | Per-window touchpad scroll multiplier 0.1–10.0, on top of `input.touchpad.scroll_factor`; mouse wheels unaffected |
| `allow_shortcuts_inhibit` | Allow client-requested shortcut inhibition (default `true`); `false` keeps compositor shortcuts available |
| `block_capture` | Omit this window from screenshots and recordings (default `false`) |
| `background_render` | Keep this window drawing while hidden (default `false`) |
| `focus_on_activate` | Per-window activation focus override |
| `vrr` | Override focused output's VRR policy: `"disabled"`, `"always"`, `"fullscreen"` |
| `tearing` | Request (true) or veto (false) asynchronous presentation |
| `hdr` | Override focused output's HDR policy: `"off"`, `"on"`, `"auto"`, `"fullscreen"` |
| `border_color_focused` / `_unfocused` / `_outer` | Independent overrides of `[colors.border]`; unset keys keep the global color |
| `border_width` / `outer_border_width` | Override `appearance.*`, 0–100 |
| `corner_radius` | Override `appearance.corner_radius`, 0–100 |
| `shadow` | Override `appearance.shadow.enabled` (softness, offsets, color stay global) |
| `title_bar` | `"on"` (client preference, or Umbriel's bar if unknown), `"negotiated"` (only when Wayland negotiation picks SSD), `"forced"`, `"off"`; omitted inherits `appearance.title_bar.mode` |
| `title_bar_buttons` | Buttons from the title outward: any of `"minimize"`, `"maximize"`, `"close"`, or `[]`; omitted inherits `appearance.title_bar.buttons` |
| `border_effect` / `window_effect` | Replace `effects.border` / `effects.window` with a preset or pool name, or `"off"` |

Refresh on matching identity/state change and config reload.

### Focus transitions

Focused/unfocused rule opacity and window/title-bar backdrop blur transition smoothly;
timing lives in `[animation.windows_opacity]` (border colors use `[animation.border]`).
Refocusing mid-transition continues from the current appearance; repeated focus
requests keep the clock running. Disable the animation for immediate changes; other
identity/state changes apply rule targets immediately. Enable `[appearance.blur]` for
backdrop blur.

```toml
[animation.windows_opacity]
enabled = true
curve = "spring:1,900"

[[window_rule]]
match.is_focused = false
opacity = 0.75
blur = true

[[window_rule]]
match.is_focused = true
opacity = 1.0
blur = false
```

### Decoration

Rules override every global mode: `"forced"` enables a bar with global `"off"`; `"on"`
can honor CSD with global `"forced"`. `"on"`/`"negotiated"` follow managed Xwayland
decoration hints; a later matching `"on"`/`"negotiated"` rule replaces an earlier
override; changes apply to existing windows. Fullscreen and tiled tab groups still
suppress the bar; forcing one never removes client headerbars, and title bar changes
adjust tiled content space. Border-only overrides (`border_width`,
`outer_border_width`, `corner_radius`, `shadow`) never move other windows — layout
spacing keeps global widths (thinner leaves its gap empty, thicker draws into it).
Apps drawing their own rounded corners/shadow look best with `border_width = 0`,
`corner_radius = 0`, `shadow = false`.

```toml
# Title bars only in stacking (global mode = "off")
[[window_rule]]
match.layout = "stacking"
title_bar = "on"

# Hide only while maximized to edges
[[window_rule]]
match.is_maximized_to_edges = true
title_bar = "off"
```

### Effects

```toml
[[window_rule]]
match.app_id = "^mpv$"
border_effect = "off"
window_effect = "scanlines"
```

Names refer to `[effects.preset.<name>]` or `[effects.pool.<name>]` of the matching
kind. Pool choices stay with the window across focus/title rule changes; returning to
a pool restores its remembered member. Runtime effect overrides beat rules.

## Only tiled column, only window, window being shared

- `match.is_alone` — in scrolling, a column's stacked/tabbed windows are all alone
  together; `default_maximize` and `default_scrolling_extent` act on the column and stay
  applied while its windows share it. In master/dwindle it means the only tiled window.
  Fullscreen/maximize-to-edges cover the whole output, so they apply only while the
  window is also the only tile; any other tiled window removes them. Effects are
  removed when another column appears or the window leaves the column, restored when it
  returns. Floats don't take the match away; `default_pinned = true` windows open
  floating, never alone. Combine with `match.app_id` to scope to one app.
- `match.is_only_window` — the stricter question used by the while-open settings:
  nothing else may occupy the workspace, a float as much as a tile. Pinned (floats
  above the workspace) and scratchpad (has left it) windows don't count as company; the
  rule follows the window as company comes and goes. It does not drive fullscreen/
  maximize/extent — those follow `match.is_alone` (fullscreen and maximize-to-edges
  also require only-tile).
- `match.is_cast_target` — holds while a client captures the window itself (portal
  window share); a whole-output share does not match. The rule's frame is not part of
  the captured image; viewers never see it. A window screenshot also flashes it on.

```toml
[[window_rule]]
match.is_only_window = true
border_width = 0
outer_border_width = 0

[[window_rule]]
match.is_cast_target = true
border_width = 5
border_color_focused = "#40C057FF"
border_color_unfocused = "#40C057FF"

# More patterns
[[window_rule]]
match.app_id = "^steam_app_[0-9]+$"
default_workspace = 4
default_fullscreen = true

[[window_rule]]
match.content_type = "game"
vrr = "always"
```

## Pointer confinement

`confine_pointer = true` — for games that release pointer lock in menus. Applies to
floating, tiled, and fullscreen windows while the window has keyboard focus and the
pointer is inside its visible content. Client-requested pointer locks still work;
confinement resumes when the client releases its lock. Reload updates existing
windows; a later matching `confine_pointer = false` disables it. Escape via focus/
workspace keybind; with focus-follows-mouse, small movements over the just-left window
don't refocus it — leaving/re-entering, clicking, or explicit focus re-enables
confinement. Compositor cursor warps remain available. Suspended during session lock,
overview, compositor move/resize, and client drags.

## Keyboard shortcuts inhibition

`allow_shortcuts_inhibit = false` denies the app's client-requested shortcut
inhibition (default `true`; a later matching rule can re-allow). Use the app ID from
`umbriel windows --json`. Reload or rule-match changes update existing client
inhibitors. The manual `shortcuts-inhibit-toggle` keybind stays available even when a
rule denies requests; toggling an inhibitor off persists across rule changes until
toggled again or the client creates a new inhibitor.

## Background rendering

`background_render = true` — a hidden window (other workspace, hidden tab, hidden
scratchpad) is normally told it is suspended and gets no frame callbacks; apps tying
work to their draw loop can stall. With the rule it keeps receiving frame callbacks at
its output's refresh rate and keeps running, though Umbriel still does not draw it.
Costs the app's background draw CPU/GPU time. Reload updates open windows.

## Capture protection

`block_capture = true` keeps a window visible locally but absent from screenshots and
recordings. Last matching rule wins; `false` removes the window's own protection, but a
protected parent still protects its popups and transients even with a child `false`.

- Output/region captures show the content underneath with its ongoing updates — no
  black rectangle. All layouts, including floats above tiles; a protected tile keeps
  its allocation (no reflow). No change to local visibility, input, focus, geometry.
- Direct window capture is refused; enabling protection stops existing sessions for
  that window, removing it permits a fresh one; frames already copied cannot be
  recalled. Titles/app IDs stay available via window metadata protocols.
- Covers decorations, shadows, overview cards, closing images, regardless of
  `effects.in_capture`. Protected captures redraw the full output (extra GPU time and
  memory); a capture that cannot be composed safely fails while local rendering runs.
- X11 transients with a known owner inherit its protection; an X11 popup without a
  reliable parent is conservatively excluded while any X11 window is protected (can
  hide unrelated X11 menus/notifications). A protected window turning into an
  unmanaged popup keeps protection until managed again. Raw
  `zwlr_export_dmabuf_manager_v1` is not advertised (would bypass the filter); use
  screencopy or image-copy capture clients, including DMA-BUF destinations.

## Dim behind

```toml
[[window_rule]]
match.app_id = "^launcher$"
dim_behind = 0.5
```

While the window is presented, content below it on its output darkens. The window, its
popups, and surfaces above it keep normal brightness. Follows the opening fade; clears
on unmap or leaving the output; suppressed in the overview. Does not intercept pointer
input; several dimming surfaces stack. Refreshes on reload and identity/state changes;
a later matching `dim_behind = 0.0` disables it. Add `match.is_focused = true` to dim
only while focused.
