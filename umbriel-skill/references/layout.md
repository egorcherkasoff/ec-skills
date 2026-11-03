# Layout

One layout mode per workspace; set the default globally, exceptions via workspace rules.

```toml
[layout]
mode = "scrolling"   # "scrolling" | "dwindle" | "master" | "stacking"
```

| Mode | Arrangement | Best for |
| --- | --- | --- |
| `scrolling` | Fixed-size columns in a scrollable strip | Many readable windows without shrinking |
| `dwindle` | Each new window splits an existing tile | Flexible recursive tiling |
| `master` | Primary windows beside a stack | Keeping main windows prominent |
| `stacking` | Independently positioned, overlapping windows | Free-moving and resizing |

Change at runtime: `workspace-set-layout <mode>` (or `toggle`, `toggle scrolling master`).

## Stacking layout

```toml
[layout]
mode = "stacking"

[appearance.title_bar]
mode = "on"
```

Every ordinary window opens floating at its preferred size, centered, shifting
diagonally when it would fully cover another window (offset ≥ 32 logical px, wrapping at
the output boundary). Dialogs center over their parent; explicit position rules win.
Enable title bars for modifier-free dragging and close/maximize buttons.

- Directional focus uses window geometry, including overlaps.
- `window-toggle-floating` is rejected; switching to a tiling layout re-tiles
  layout-floated windows (explicitly floated ones stay floating).
- `window-set-region <region>` / `window-clear-region` place/restore halves and quarters
  (see `references/actions.md`).

### Drop zones and region placement

```toml
[layout.stacking]
drop_zones = true   # default
```

Drag an eligible window by title bar, client-side move control, or Mod+drag to preview a
half-screen edge or quarter-screen corner placement; targets respect panels, struts,
gaps, borders, title bars, and client size limits. `drop_zones = false` keeps free
dragging but leaves `window-set-region`/`window-clear-region` available; override per
workspace with `layout.stacking.drop_zones` in a `[[workspace]]` rule. Leaving stacking
clears region metadata.

## Shared settings

```toml
[layout]
gap = 8
extent_presets = [0.333, 0.5, 0.667]
new_exits_fullscreen = []   # "tiled", "floating", "pinned", "all", or array
client_maximize = "column"  # or "edges"
```

- `gap`: logical px between windows.
- `extent_presets`: fractions used by `window-cycle-*-extent` actions; values `0.1`–`4.0`
  (above `1.0` = scrolling columns only); cycling steps by size.
- `new_exits_fullscreen`: which arriving windows (open, moved, dropped, restored) make a
  fullscreen window leave fullscreen. Empty array (default) = off. In scrolling, a tiled
  window opens beside the fullscreen column and the strip scrolls — never exits fullscreen.
- `client_maximize`: what a tiled window's own maximize button does — `"column"` (like
  `window-toggle-maximize`) or `"edges"` (like `window-toggle-maximize-to-edges`).

### Struts

```toml
[layout.struts]
left = 0
right = 0
top = 0
bottom = 0
```

Positive = extra reserved space inside layer-shell exclusive zones; negative = tiled
windows extend beneath panels/beyond edges. Floating windows and popups ignore struts.

All layouts support `Mod+Right-drag` resizing (edge = one axis, corner = both).

## Scrolling layout

```toml
[layout.scrolling]
default_extent_fraction = 0.5   # 0.1–4.0; unset = application chooses
center_underfull_strip = true
center_focused = "never"        # "never" | "always" | "on_overflow"
center_on_overview_select = false
```

- Columns keep their extents; the strip moves through the output; a column can stack
  several windows. The strip is perpendicular to the output's workspace axis.
- When `default_extent_fraction` is unset, apps choose their initial extent. Window rules
  `default_scrolling_extent` (fraction) and `default_scrolling_extent_px` (pixels,
  highest precedence) override. Output override:
  `[output.DP-1.layout.scrolling] default_extent_fraction = 0.4`. Reload affects new
  columns only.
- Focus on a hidden column scrolls just enough to reveal it.
- `center_focused = "on_overflow"`: center a column only when it and the column focus came
  from can't share the viewport; refit puts them back side by side. Closing/sending/
  moving/resizing/fullscreening the focused column applies the same rule.
- Closing a focused column focuses the nearest survivor and restores its most recently
  focused member. With `follows_mouse = true`, closing under the pointer focuses the
  window that occupies the position after reflow.
- Three-finger swipe along workspace axis switches workspaces; across it scrolls the strip
  (direction follows `input.touchpad.natural_scroll`).
- App drag-and-drop or tiled-window drag near a scrolling edge auto-scrolls the strip
  (see `[input.drag_edge_scroll]`).

### Wide columns

Scrolling columns may span several viewports: extent fractions up to `4.0` fill
`fraction × (viewport + gap) - gap` pixels. Values above `1.0` apply only to scrolling;
other layouts clamp to one viewport and floating cycles skip unrealizable presets. Wide
columns pan like a longer strip; interactive resize stops when the cursor reaches the
output edge — use extent actions or scroll-and-drag again to grow further.

### Vertical strips (horizontal workspace axis)

Left/right move within a lane; up/down move between lanes; strip scroll toward up/left
moves toward strip start. Bind wheel navigation to `window-focus-up`/`-down` instead of
left/right.

## Dwindle layout

```toml
[layout.dwindle]
preserve_split = false
new_toward_cursor = false
```

- New windows split the focused tile along its longer edge; without `preserve_split`
  split directions may adapt. New window takes right/bottom half by default;
  `new_toward_cursor` takes the pointer's side (default applies when the pointer is on
  another output or the overview is open).
- Directional `window-move-*` take the window out of its tile and split the tile it moves
  into (longer edge, half nearer origin). Windows it passes shrink only while inside.
  Moving toward a single sibling that shares its split trades sides. `window-swap-*`
  exchanges without changing tiles.
- `layout-toggle-split` flips the focused tile's split between side by side and stacked,
  keeping its ratio.
- No multi-window columns: moving one into Dwindle creates separate tiles. Tabbing refused.

## Master layout

```toml
[layout.master]
position = "left"              # "left" | "right" | "center"
default_width_fraction = 0.55
new_on_top = true
new_becomes_master = false
```

First window becomes master; later windows join the stack unless `new_becomes_master`.
`layout-master-count-increase`/`-decrease` move windows between areas. Center mode
balances the stack left/right. Primary extent = master area; secondary = rows.
Master/stack areas can be tabbed as wholes.

## Tab groups

A tab group shares one box, shows one tab, draws a bar (see `references/appearance.md`)
along one edge. Scrolling: a group is one row of its column. Master: master area and each
stack tabbed as wholes. Dwindle tiles hold one window — no tabs.

`column-toggle-tabbed` (built in as `Mod+W`) tabs the focused window with the windows
stacked next to it (whole column when no groups); on a tab it stacks the group again.
`column-set-display <normal|tabbed>` does either; focused window becomes the active tab.

| Task | How |
| --- | --- |
| Switch tabs | Click slot, wheel over bar, `column-focus-tab[-next|-previous|<index>]` |
| Add a tab | `window-move-up`/`-down` into the group, consume into a column whose last row is a group, `window-consume-from-left`/`-right` while a tab is focused, drop on the bar or group middle |
| Window beside a group | Move a tab out, or drop near the group's top/bottom edge |
| Remove a tab | Move out, drag slot out of bar, expel, float, or move away |
| Reorder | `column-move-tab-next`/`-previous`, drop between slots |
| Resize | Drag the edge or secondary extent actions on any tab |
| Bar visibility | `column-toggle-tab-bar` / `-hide-` / `-show-` |
| Close a tab | Middle-click slot (with `middle_click_closes`) |

```toml
[layout.tabs]
default_display = "normal"       # "tabbed" starts new columns/master areas as groups
new_tab_position = "end"         # or "after_active"
wrap_focus = true
scroll_switches_tabs = true
middle_click_closes = false
```

`[[workspace]]` entries can override `layout.tabs` per workspace; window rule
`default_column_display` sets the display of the column a window opens in.

## Sizing behavior

- Scrolling: primary = column extent, secondary = a row.
- Dwindle: primary = horizontal splits, secondary = vertical splits.
- Master: primary = master fraction, secondary = a row.
- Floating: primary = width, secondary = height (of the output's usable area; respects
  app min/max hints; resizing a maximized float leaves maximization).

`window-set-*` assigns exact fraction; `window-modify-*` changes by signed delta
(clamped); `window-cycle-*` walks `layout.extent_presets`.

Client minimum sizes: oversized content is clipped, never covers neighbors — disable
app minimums in the app's settings for smaller tiles.

### Floating windows, dialogs

- Floating `window-move-left/right/up/down` move to the usable-area edge (inside struts,
  gap, borders); at an edge, `-or-output`/`-or-workspace` variants send it onward.
- Focusing a floating window reveals the workspace's floats above fullscreen without
  leaving fullscreen. An independent float doesn't take focus over fullscreen unless a
  rule sets `default_focused = true`.
- Parented dialogs stay above their parent, centered over its visible area. Modal dialogs
  (xdg-dialog-v1 / xdg-foreign) stay centered as either moves, drag the parent, shade it
  (`[animation.dialogs] dim`), and take focus/column actions for the parent; placement
  rules don't apply to them while attached. `[general] attach_modal_dialogs = false` or a
  rule's `attach_to_parent = false` keeps dialogs ordinary.
- Extent actions do nothing while fullscreen.

### Minimize

Only floating windows minimize: `window-minimize`, the title bar's or app's minimize
button, or a taskbar. Tiled, pinned, fullscreen, and scratchpad windows do not minimize.
Tiling a minimized window shows it again.

A minimized window keeps workspace, position, size, and stacking; stays in taskbars and
`umbriel windows` (reports `minimized`); focus cycling, directional focus,
`window-focus-last`, and the overview skip it. It returns via a taskbar, a valid
activation token, `window-focus`/`window-focus-warp`, or an attached modal dialog.
`window-restore-minimized` restores the most recent one on the workspace (repeat for
older). `workspace-toggle-show-desktop` minimizes every floating window of the workspace;
once none is left to hide, the next toggle restores all minimized ones.

### Maximize and fullscreen

- `window-toggle-fullscreen`: whole output, ignores struts and exclusive zones.
- `window-toggle-maximize`: fills the layout area (tiled columns keep struts/gaps;
  floating fills usable area and follows margin changes).
- `window-toggle-maximize-to-edges`: no gaps, struts, borders; panel zones remain. An
  enabled title bar stays reachable at the top.
- A maximized window stays maximized across float/unfloat; unmaximize restores the
  remembered extent/box.
- `client_maximize = "edges"` changes only the app's own maximize button; the
  `window-toggle-maximize` action still fills the column.
