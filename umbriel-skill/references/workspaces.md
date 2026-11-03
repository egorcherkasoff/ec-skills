# Workspaces and Overview

Each output has its own workspaces.

## Models

### Dynamic (default)

```toml
[output.DP-1]
workspaces = "dynamic"   # or omit
min_workspaces = 3       # floor, not maximum
```

Keeps an empty workspace at the end, creates another when it gains a window, prunes empty
inactive anonymous workspaces. Global `[workspaces] empty_above = true` keeps an
additional empty workspace at the beginning. Up to 64 workspaces per output.

Persistent named workspaces inside a dynamic inventory:

```toml
[[workspace]]
name = "CHAT"
layout.mode = "master"

[[workspace]]
name = "STATS"
output = "DP-1"
layout.mode = "dwindle"
```

Names are case-sensitive and output-local; an entry without `output` applies to every
dynamic output. Named workspaces persist while empty.

### Static

```toml
[output.DP-1]
workspaces = 5                          # fixed count, anonymous
[output.DP-2]
workspaces = ["WEB", "CHAT", "VIDEO"]   # exact ordered names
```

A count creates anonymous positions; a string list creates exact names (position `3` and
name `"3"` are different selectors). Never pruned.

### Reload behavior

Workspace changes apply on valid reload; matching names/positions preserved; windows from
removed workspaces move to the nearest survivor. Switching to dynamic keeps active and
populated workspaces plus the required empty one.

## Workspace axis

```toml
[output.DP-1]
workspace_axis = "horizontal"   # default "vertical"
```

`vertical`: workspaces stack top-to-bottom, scrolling strip runs left-right.
`horizontal`: workspaces side-by-side, strip runs top-bottom. Three-finger swipe along
the axis switches workspaces; across it pans the strip. Overview follows the same
arrangement.

## Selectors (for actions)

- Bare digits `1`–`64`: one-based position.
- Other text: exact case-sensitive name.
- `--name <name>` forces name lookup even for all-digit names.
- `--output <output>` scopes either form to one output.
- Duplicate names resolve on the pointer-preferred output when possible; otherwise
  ambiguous. On dynamic outputs, an out-of-range numeric position selects the last
  workspace.

## Cyclic workspaces

`cyclic_workspaces = true` on an output wraps `workspace-next`/`previous`,
`window-move-to-workspace[-silent]-next`/`previous`, `window-move-or-workspace-up`/`down`
at column edges, and `column-move-to-workspace-next`/`previous`. Dynamic outputs wrap at
the trailing empty workspace; static at both ends.

## Global settings

```toml
[workspaces]
back_and_forth = false   # selecting active workspace returns to previous on that output
empty_above = false      # leading empty workspace on dynamic outputs
```

## Inspect

```sh
umbriel workspaces          # * DP-1: 1 [scrolling] (focused) ...
umbriel workspaces --json   # id, name, index, output, layout, occupancy, active, focused
```

## Workspace rules

Select with exactly one of `name` or `index`, optionally restricted with `output`:

```toml
[[workspace]]
name = "VIDEO"
output = "DP-2"
layout.mode = "dwindle"
layout.gap = 4
```

On dynamic outputs `name` also creates the workspace; `index` follows whatever occupies
the position. On static outputs rules only customize existing inventory members.

Combine least→most specific: global `[layout]` → output scrolling extent → rule without
`output` → rule with `output`. Later replaces earlier; strut edges resolve independently.

Available fields: `name`, `index`, `output`, `layout.mode`, `layout.gap`,
`layout.struts.{left,right,top,bottom}`, `layout.extent_presets`,
`layout.new_exits_fullscreen`, `layout.scrolling.default_extent_fraction`,
`layout.scrolling.center_underfull_strip`, `layout.scrolling.center_focused`,
`layout.master.position`, `layout.master.default_width_fraction`,
`layout.master.new_on_top`, `layout.master.new_becomes_master`,
`layout.dwindle.preserve_split`, `layout.dwindle.new_toward_cursor`,
`layout.stacking.drop_zones`, plus `layout.tabs` overrides.

Example:

```toml
[[workspace]]
index = 4
output = "DP-1"
layout.gap = 0
layout.struts.top = 24
layout.scrolling.default_extent_fraction = 0.667
```

## Overview

```toml
[overview]
zoom = 0.5                     # preview scale 0.1–0.75
scroll_factor_horizontal = 1.0
scroll_factor_vertical = 1.0
background_blur = true
workspace_wallpaper = true
shortcuts = true
shortcut_keys = "1234567890"   # ≥ 2 unique printable ASCII chars
```

Open with `Mod+O` or `overview-toggle`. Opening temporarily hides scratchpads and pinned
windows.

- Click a window to focus + close; middle-click closes it; drag to another preview moves
  it (dropping into a gap on dynamic outputs creates a workspace; static accepts existing
  previews only). Destination layout shows an insertion preview.
- Wheel navigates along the axis; Shift+wheel across. Two-finger scroll and three-finger
  swipes navigate continuously; four-finger swipe opens/closes.
- Normal keybinds stay active; directional focus selects cards; output actions keep
  fallback behavior. Current output follows the cursor.
- One card carries the full focused-border color (target of window actions); each other
  workspace keeps a fainter marker for its focus target.
- Shortcut badges: unmodified key sequences per visible card; multi-key labels when cards
  exceed keys; Backspace removes the last key; Escape clears a pending sequence first,
  else closes the overview. Normal keybinds take precedence; `shortcuts = false` disables.
- Cards reuse each window's borders, corner radius, opacity, blur. Badge color:
  `colors.overview.badge`. Background blur uses `[appearance.blur]`.
