# Layout

One layout mode per workspace. Default global; override per output, then per workspace rule.

```toml
[layout]
mode = "scrolling"   # "scrolling" | "dwindle" | "master" | "stacking"
```

| Mode | Arrangement | Best for |
| --- | --- | --- |
| `scrolling` | Fixed-size columns in a scrollable strip | Many readable windows without shrinking |
| `dwindle` | Each new window splits an existing tile | Flexible recursive tiling |
| `master` | Primary windows beside a stack | Keeping main windows prominent |
| `stacking` | Independently positioned, overlapping windows | Moving and resizing freely |

Per-output default (incl. dynamic workspaces): `[output.DP-1.layout] mode = "master"`.
Runtime: `workspace-set-layout <mode>` (argument forms: `references/actions.md`).

## Stacking layout

```toml
[layout]
mode = "stacking"

[appearance.title_bar]
mode = "on"
```

- Every ordinary window opens floating at its preferred size, centered; oversized automatic
  windows shrink proportionally to fit the usable area (incl. title bars and margins);
  client-driven size changes keep automatic placement centered until you move the window.
- New windows shift diagonally when they would completely cover another window whose upper-left
  corner is visible: the offset clears the decorated title bar (min 32 logical px) and wraps to
  fresh diagonals at the output boundary, incl. several windows at once. Placement includes
  title bars and borders. Dialogs center over their parent; explicit position rules win.
- Title bars enable modifier-free dragging and close/maximize buttons. Dragging updates position
  continuously — maximize/restore use the current position even while the pointer is held. Region
  placement animations start where you release and keep the pre-drag restore box;
  `appearance.drag_opacity` still applies.
- Directional focus uses window geometry, incl. overlaps; `window-toggle-floating` is rejected.
  Switching to a tiling layout re-tiles windows floated by the layout (windows floated by a rule
  or before entering stay floating); moving a layout-floated window to a tiling workspace also
  tiles it there.

### Drop zones and region placement

```toml
[layout.stacking]
drop_zones = true   # default
```

- On by default: drag an ordinary eligible window by its title bar, a client-side move control,
  or Mod+drag to preview a half-screen edge / quarter-screen corner placement. Targets respect
  panels, struts, gaps, borders, title bars, and client size limits in logical coordinates; both
  layout-floated and explicitly floating windows can use them. `drop_zones = false` keeps free
  dragging without previews or placement but leaves existing placements and `window-set-region` /
  `window-clear-region` available. Per-workspace override: `layout.stacking.drop_zones` in a
  `[[workspace]]` rule.
- `window-set-region <region>` selects a half or quarter; repeating it keeps the region; changing
  regions preserves the original normal box. `window-clear-region` restores that box (no-op on an
  unplaced window). A maximized window returns to its retained region with `window-set-region`;
  fullscreen windows reject new placement; maximize/fullscreen round trips within stacking
  preserve the placement.
- Individual floats above scrolling/dwindle/master cannot use drop zones or create region
  placements. Leaving stacking clears region metadata: layout-floated windows re-tile, explicit
  floats keep geometry and stay floating, maximize/fullscreen state intact. Returning to stacking
  does not revive an old region.

## Shared settings

```toml
[layout]
gap = 8
extent_presets = [0.333, 0.5, 0.667]
new_exits_fullscreen = []   # "tiled", "floating", "pinned", "all", or an array
client_maximize = "column"  # or "edges"
```

- `gap` (0–500): logical px between windows.
- `extent_presets` (each 0.1–4.0): fractions used by primary and secondary extent cycle actions,
  in any order; cycling steps by size. Above `1.0` = scrolling columns only.
- `new_exits_fullscreen`: which arriving windows make a fullscreen window on the workspace leave
  fullscreen. A window arrives by opening there, moving from another workspace or output,
  drag-and-drop, or returning from a scratchpad. Empty array (default) = off.
- `client_maximize`: what a tiled or stacking window's own maximize button (or title bar
  double-click) does — `"column"` (like `window-toggle-maximize`) or `"edges"` (like
  `window-toggle-maximize-to-edges`).

Leaving fullscreen values: `"tiled"` = tiled window in Dwindle/Master; `"floating"` = floating, not
pinned; `"pinned"` = pinned window; `"all"` = any window. A string selects one kind, an array
several. In scrolling, a tiled window opens as a column beside the fullscreen one and the strip
scrolls to it — never exits fullscreen.

### Struts

`[layout.struts] left / right / top / bottom` (each −65535..65535, default 0). Positive = extra
reserved space inside layer-shell exclusive zones; negative = tiled windows extend beneath panels
or beyond an output edge. Floating windows and popups ignore struts. All layouts support
`Mod+Right-drag` resizing (edge = one axis, corner = both).

## Scrolling layout

```toml
[layout.scrolling]
default_extent_fraction = 0.5     # 0.1-4.0; unset = app chooses (packaged config uses 0.5)
center_underfull_strip = true
center_focused = "never"           # "never" | "always" | "on_overflow"
center_on_overview_select = false  # center the overview-picked column on close (column-center)
```

- Columns keep their extents; the strip moves through the output; a column can stack several
  windows. The strip is perpendicular to the output's workspace axis (vertical workspaces ⇒
  horizontal strip; horizontal ⇒ vertical).
- Window rules `default_scrolling_extent` (fraction) and `default_scrolling_extent_px` (highest
  precedence) override. Output default: `[output.DP-1.layout.scrolling] default_extent_fraction =
  0.4`; a workspace rule overrides both. Reload affects new columns only.
- Focus on a hidden column scrolls just enough to reveal it. Dragged windows show an insertion
  preview and drop into a new or existing column.
- `center_focused = "on_overflow"`: a column centers when it and the column focus came from cannot
  share the viewport; a refitting width change puts the pair back side by side at the edge focus
  came from. Closing or sending away, moving or resizing the focused column, or going fullscreen/
  edges-maximized applies the same rule to the column that took its place. A lone column never
  centers itself; `center_underfull_strip` decides where it rests.
- Closing a focused column focuses the nearest surviving column and restores its most recently
  focused member. With `input.focus.follows_mouse` `"sloppy"` or `"always"`, closing a focused
  window beneath the pointer focuses the tiled window occupying that position after reflow (also
  when another row in the same column expands into the stationary pointer).
- Three-finger swipe along the workspace axis switches workspaces; across it scrolls the strip
  (direction follows `input.touchpad.natural_scroll`).
- App drag-and-drop near a scrolling edge, or rearranging a tiled window by Mod+left-click or its
  tab, auto-pans the strip after a short delay, faster toward the edge, stopping when the pointer
  moves away or the drag ends; a window revealed under a stationary pointer becomes the drop
  target. Zone/delay/speed: `[input.drag_edge_scroll]` (see `references/input.md`).

### Wide columns

Scrolling columns may span several viewports: extent fractions up to `4.0` fill
`fraction × (viewport + gap) - gap` px (`2.0` = two viewports with the gap). Above `1.0` =
scrolling only; other layouts clamp to one viewport, floating cycles skip unrealizable presets
(`window-set-*` accepts the wider range; the layout clamps). A wide column pans like a longer
strip (`layout-scroll-left` / `-right` / `-drag`; a swipe rests at either edge); refocusing keeps
the pan; focus arriving from a neighbor shows that side's edge. Interactive resize grows to the
same ceiling but stops when the pointer reaches the output edge — use extent actions, or drag,
scroll, then drag again. A client-chosen width, including a client minimum, still fits one
viewport.

### Vertical strips (horizontal workspace axis)

Screen directions stay literal: left/right move within a lane; up/down move between lanes; strip
scroll toward up/left moves toward strip start. Bind wheel navigation to `window-focus-up` /
`window-focus-down` instead of left/right.

## Dwindle layout

```toml
[layout.dwindle]
preserve_split = false
new_toward_cursor = false
```

- New windows split the focused tile along its longer edge; without `preserve_split`, split
  directions may adapt as geometry changes. The new window takes right/bottom by default;
  `new_toward_cursor` takes the pointer's side of the tile's center (default when the pointer is
  on another output or the overview is open; the focused tile still splits; the axis does not
  change).
- Directional `window-move-*` (incl. `-or-output` / `-or-workspace` variants; `column-move-left` /
  `-right` do the same here) take the window out of its tile and split the tile they enter (longer
  edge, half nearer origin); the tile left goes back to its sibling, so windows passed shrink only
  while inside and keep their place. Moving toward a single neighbor sharing its split trades
  sides; `window-swap-*` exchanges two windows without changing tiles. `layout-toggle-split` flips
  the focused tile's split between side by side and stacked, keeping its ratio; the flipped split
  stays fixed, like a directional drop.
- No multi-window columns: moving one into Dwindle creates separate tiles. No tabs.

## Master layout

```toml
[layout.master]
position = "left"              # "left" | "right" | "center" (center = between two stacks)
default_width_fraction = 0.55  # 0.1-0.9
new_on_top = true
new_becomes_master = false
```

First window becomes master; later windows join the stack unless `new_becomes_master`.
`layout-master-count-increase` / `-decrease` move windows between areas. Center mode balances
stack windows left/right. Primary extent = master area; secondary = rows within an area. The
master area and each stack can be tabbed as wholes.

## Tab groups

A tab group gives its windows one box and shows one tab; a bar along one edge has a slot per
window (look: `references/appearance.md`). Scrolling: a group is one row of its column, resizes
like any row; a column can hold several groups. Master: the master area and each stack tab as
wholes. Dwindle tiles hold one window — no tabs.

`column-toggle-tabbed` (built in as `Mod+W`; rebind under `[keybinds]` if the config lists its
own) tabs the focused window with the windows stacked next to it, up to the nearest group above
and below (whole column when none); on a tab it stacks the group again. `column-set-display
<normal|tabbed>` does either; the focused window becomes the active tab. In scrolling,
`window-move-up` / `-down` treat a group as one row: a tab steps out toward the move keeping the
group's height; a lone window steps into a group it meets as its nearest tab.

| Task | How |
| --- | --- |
| Switch tabs | Click a slot, wheel over the bar, `column-focus-tab-next` / `-previous`, `column-focus-tab <index>` |
| Add a tab | `window-move-up` / `-down` into the group, consume into a column whose last row is a group, `window-consume-from-left` / `-right` while a tab is focused, or drop on the bar or group middle |
| Window beside a group | Move a tab out, or drop near the group's top/bottom edge |
| Remove a tab | Move out, drag its slot out, expel, float, or move away |
| Reorder | `column-move-tab-next` / `-previous`, or drop between slots |
| Move a group | Mod+drag it (scrolling), or drag its card in the overview |
| Resize | Drag the edge beside it, or secondary extent actions on any tab |
| Bar visibility | `column-toggle-tab-bar` / `column-hide-tab-bar` / `column-show-tab-bar` |
| Close a tab | Middle-click its slot (with `middle_click_closes`) |

Focusing a window by any means (keybind, click, activation, IPC) shows its tab; focus entering a
group lands on the active tab; focus moves within a column step over a group to its active tab (a
tabbed master area steps through its tabs). Hidden tabs stay mapped and sized to the group —
switching is instant, never resizes — and are told they are suspended (recent GTK/Chromium apps
stop drawing; others still get frame callbacks at hidden-workspace rate); a hidden tab asking for
attention lights its slot with the urgent color. A group with a hidden bar still works: tabs take
the bar's space and actions/focus switch them; hiding one bar leaves others alone; `visible` under
`[appearance.tab_bar]` hides every bar a group has not shown itself. Dropping on a bar inserts
between the two slots under the pointer; on the middle half of a group adds where new tabs go; near
the top/bottom edge lands beside the group. A master area that empties restarts with
`default_display` when a window next arrives.

```toml
[layout.tabs]
default_display = "normal"       # "tabbed" starts new columns/master areas as groups
new_tab_position = "end"         # or "after_active"
wrap_focus = true
scroll_switches_tabs = true
middle_click_closes = false
```

`[[workspace]]` entries override `layout.tabs` per workspace; window rule
`default_column_display` sets the display of the column a window opens in.

## Sizing behavior

Primary/secondary extent axes: scrolling = column extent / a row; dwindle = horizontal / vertical
splits; master = master fraction / a row; floating = width / height (of the output's usable area,
respecting app min/max hints; resizing a maximized float leaves maximization and keeps the new
size; extent actions do nothing while fullscreen). `window-set-*` assigns an exact fraction;
`window-modify-*` changes it by a signed amount; `window-cycle-*` walks `layout.extent_presets`.
Client minimum sizes: apps may enforce a minimum larger than their tile; oversized content is
clipped, never covers neighbors — disable app-specific minimums in the app's settings.

### Floating windows

- Floating `window-move-left/right/up/down` move to the usable-area edge (inside struts, gap,
  borders), keeping the other axis; at an edge, `-or-output` / `-or-workspace` variants send the
  window onward.
- Focusing a floating window reveals the workspace's floats above fullscreen without leaving
  fullscreen; clicking or explicitly focusing the fullscreen window covers them again (with
  focus-follows-mouse, hovering it takes keyboard focus while floats stay visible until clicked).
  An independent float doesn't take focus over fullscreen unless a rule sets
  `default_focused = true`; parented dialogs and activation requests keep their usual behavior.

### Dialogs

Parented dialogs stay above their parent, centered over its visible area. Modal dialogs
(xdg-dialog-v1, or xdg-foreign parented like a portal file chooser) attach to the parent: centered
on its frame, kept on screen, following it to any workspace, output, unplugged refuge, scratchpad,
pin, fullscreen, scrolled/moved column, drag, or overview drop (shows over the parent's card).
While attached, focusing/clicking the parent focuses the dialog; the parent is shaded by
`[animation.dialogs] dim`. Placing actions aimed at the dialog (move to workspace, float, pin,
scratchpad) act on the parent; closing and killing still reach it; Mod-drag drags the parent.
Placement window rules (`default_workspace`, `default_output`, `default_scratchpad`,
`default_pinned`, `default_position`, `default_floating`, size and maximize defaults) do not apply
while attached. The dialog detaches when it stops being modal or closes; if the parent closes
first it becomes an ordinary floating window. `[general] attach_modal_dialogs = false` or a rule's
`attach_to_parent = false` keeps dialogs ordinary; either takes effect on reload.

### Minimize

Only floating windows minimize: `window-minimize`, the title bar's or app's minimize button, or a
taskbar. Tiled, pinned, fullscreen, and scratchpad windows do not minimize; apps and the title bar
offer minimize only while the window floats. Tiling a minimized window (e.g. switching its
workspace to a tiling layout) shows it again.

A minimized window keeps workspace, position, size, and stacking; stays in taskbars and in
`umbriel windows` (reports `minimized`); minimizing the focused window moves focus to another
window on the workspace. Focus cycling, directional focus, `window-focus-last`, and the overview
skip minimized windows. Returns via taskbar activate/unminimize, a valid activation token
(relaunch, notification click), `window-focus` / `window-focus-warp`, or an attaching modal
dialog. Without a taskbar, `window-restore-minimized` restores the most recently minimized window
of the active workspace (repeat for older); for a specific window, `umbriel msg window-focus <id>`
from `umbriel windows --json`. `workspace-toggle-show-desktop` minimizes every floating window of
the active workspace; once none is left to hide, the next toggle restores every minimized window of
that workspace (including ones minimized another way) and returns focus to the window that had it.

### Maximize and fullscreen

- `window-toggle-fullscreen`: fills the complete output, ignoring struts and panel exclusive
  zones. A floating window moved through a tiled workspace while fullscreen and back to a stacking
  workspace keeps its normal size and position; leaving fullscreen restores the original floating
  box. Entering fullscreen during a resize still restores the requested size afterward.
- Visible floating windows above fullscreen require composition on that output; direct scanout can
  resume once fullscreen covers them (other scanout requirements permitting).
- `window-toggle-maximize`: fills the layout area — tiled columns keep struts and gaps; floating
  fills the usable area inside the same margin and follows gap/border/strut/usable-area changes.
- A maximized window stays maximized across float/unfloat; the maximize binding after that round
  trip restores the extent from before the initial maximize, and repeated cycles preserve it until
  manual unmaximize. Unmaximizing while floating restores the remembered floating size/position
  (never floated ⇒ restore size comes from its tile before maximization).
- `window-toggle-maximize-to-edges`: removes struts, gaps, borders; panel exclusive zones remain.
  An enabled title bar stays at the top, reserves its height above the content, keeping restore
  reachable. Applies to tiled and floating windows.
- `client_maximize = "edges"`: a tiled or stacking window's own maximize button (or title bar
  double-click) behaves like `window-toggle-maximize-to-edges`; in stacking, `"column"` keeps the
  normal floating maximize inside layout margins. Floating windows above tiling layouts keep
  normal floating maximize. The `window-toggle-maximize` action always keeps its normal behavior —
  bind `-to-edges` for a keybind. Windows without their own maximize control never send the
  request. Unmaximizing runs the toggle in reverse: edges leave first; a window whose column is
  also full-width leaves the column on the next unmaximize. A maximize restored at open under
  `honor_restored_maximize` follows the same policy in tiled and stacking. On a
  `default_maximize` tile the edges sit above the rule's full-width column, so unmaximizing takes
  two steps; without a client request the rule opens the column only.
