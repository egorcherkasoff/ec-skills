# Workspaces

Each output has its own workspaces: choose a dynamic or fixed model, then use `[[workspace]]`
rules to customize individual entries. The overview UI is covered in
[workspaces-overview.md](workspaces-overview.md).

## Models

### Dynamic (default)

```toml
[output.DP-1]
workspaces = "dynamic"   # or omit; default "dynamic"
min_workspaces = 3        # floor, not maximum (int 1-64, default 1)
```

Keeps an empty workspace at the end and creates another when that workspace gains a window;
empty inactive anonymous workspaces are removed again. Closing the last window keeps the
current workspace active — cleanup runs after you leave it and the workspace transition
finishes; a client that keeps its closed toplevel alive does not block cleanup. An empty
anonymous workspace reserved for a starting application disappears from the visible list
once you leave it (Umbriel retains its destination privately and restores it when the
application's toplevel claims it); an unused startup token leaves no selectable empty
workspace behind. Global `[workspaces] empty_above = true` keeps a leading empty
workspace. Up to 64 workspaces per output.

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

Names are case-sensitive and output-local; an entry without `output` applies independently
to every dynamic output. Named workspaces remain when empty while anonymous neighbors keep
their normal dynamic lifecycle.

### Static

```toml
[output.DP-1]
workspaces = 5                          # fixed count, anonymous positions
[output.DP-2]
workspaces = ["WEB", "CHAT", "VIDEO"]   # exact ordered names
```

A count creates anonymous positions; a string list creates exact names, so position `3` and
name `"3"` are different selectors. Static workspaces are never pruned.

### Reload behavior

Workspace changes apply on a valid configuration reload; matching names and positions are
preserved where possible; windows from a removed workspace move to the nearest remaining
workspace. Switching to a dynamic model keeps active and populated workspaces, then
restores the required empty workspace.

## Workspace axis

```toml
[output.DP-1]
workspace_axis = "horizontal"   # default "vertical"
```

| Value | Behavior |
| --- | --- |
| `"vertical"` | Workspaces stack top-to-bottom; scrolling layouts run left-to-right. |
| `"horizontal"` | Workspaces sit side-by-side; scrolling layouts run top-to-bottom. |

A three-finger swipe along the axis changes workspaces; a swipe across it moves the
scrolling strip. The overview follows the same arrangement.

## Selectors

Used by actions such as `workspace-switch` and `window-move-to-workspace`:

- Bare digits `1`-`64`: one-based position.
- Other text: exact case-sensitive name.
- `--name <name>`: forced name lookup, including all-digit names.
- `--output <output>`: restricts either form to one output; a named selector can also use a
  workspace's unavailable original output to find an evacuated workspace.

```sh
workspace-switch 3
workspace-switch 3 --output DP-2
workspace-switch CHAT --output DP-2
workspace-switch --name 3 --output DP-2
```

- Duplicate names resolve on the pointer-preferred output when possible; otherwise the
  selector is ambiguous. On dynamic outputs, a numeric position beyond the current count
  selects the last workspace.
- Evacuated named workspaces keep their names even when appended at different positions on
  another output. Within one output a native workspace takes precedence over evacuated
  workspaces with the same name; multiple evacuated workspaces sharing a name are ambiguous
  unless qualified by their original output (`workspace-switch --name 4 --output DP-1`
  follows the named workspace `"4"` while `DP-1` is unavailable; `workspace-switch 4
  --output DP-1` remains a position on a live `DP-1`). Disabled outputs are excluded from
  global name lookup.
- Window-move bindings also work on a focused scratchpad window: they remove it from the
  scratchpad and restore its saved tiled or floating state on the destination workspace;
  the `-silent` variants keep the current workspace active.

## Cyclic workspaces

`cyclic_workspaces = true` on an output (default `false`) wraps `workspace-next`/`previous`,
`window-move-to-workspace[-silent]-next`/`previous`, `window-move-or-workspace-up`/`down`
at column edges, and `column-move-to-workspace-next`/`previous`. Dynamic outputs wrap at
the trailing empty workspace; static at both ends.

## Moving a workspace between outputs

- `workspace-move-to-output-next` / `-previous`: move the active workspace through the same
  output order as `output-focus-next`/`-previous`, wrapping at either end.
- `workspace-move-to-output-left` / `-right` / `-up` / `-down`: select an adjacent output.
- `workspace-move-to-output <destination> [<workspace>] [--output <output>] [--name <name>]`:
  destination by connector or monitor identity, or `current` for the pointer-preferred
  output. Omit `<workspace>` to move the active one; a supplied workspace uses the same
  position/name selection as `workspace-switch`; `--output` qualifies the source and
  `--name` an explicit name (including numeric ones).

```sh
umbriel msg workspace-move-to-output DP-2
umbriel msg workspace-move-to-output DP-2 WEB --output DP-1
umbriel msg workspace-move-to-output current WEB --output DP-1
umbriel msg workspace-move-to-output DP-2 --name 3 --output DP-1
```

Behavior:

- The workspace keeps its stable ID, explicit name, layout, and its windows, including
  floating ones. Pinned windows stay on their output even when the workspace they were
  pinned on moves.
- It is inserted immediately after the destination's active workspace and becomes active
  there; keyboard focus follows. The source shows the preceding workspace (or the following
  one if the first workspace moved); an output losing its only workspace receives an empty
  replacement. Moving an inactive workspace leaves the source output's active workspace
  selected; moving to its own output succeeds without changing selection or order. Unknown,
  disabled, or ambiguous destinations are rejected; a move is also rejected if the
  destination already has the same explicit name or has reached the 64-workspace limit.
- Moves work for empty workspaces and fixed inventories; they change the runtime inventory
  without editing configuration. Dynamic outputs maintain their empty-workspace sentinels
  and minimum count. Explicit names stay with transferred workspaces; anonymous labels
  follow their new positions.
- The transferred layout persists until a relevant configuration reload applies layout rules
  again; changing workspace inventory configuration reapplies the configured inventories,
  including named `[[workspace]]` declarations. Output qualifiers in selectors refer to the
  workspace's current output — scripts should read the JSON `output` field rather than infer
  it from the stable ID.

## Global settings

```toml
[workspaces]
back_and_forth = false   # selecting the active workspace returns to the previous one on that output
empty_above = false      # keep a leading empty workspace on dynamic outputs
```

## Inspect

```sh
umbriel workspaces          # * DP-1: 1 [scrolling] (focused) / DP-1: 2 [dwindle]
umbriel workspaces --json
```

JSON entries carry a stable `id`, display `name`, one-based `index`, `output`, `active`,
`focused`, and the effective `layout`; the 0.1.0 binary also exposes `occupied`,
`window_count`, `focused_window`, `named`, `previous`, `urgent`, and `layout_override`.

## Workspace rules

Select with exactly one of `name` or `index`, optionally restricted with `output`:

```toml
[[workspace]]
name = "VIDEO"
output = "DP-2"
layout.mode = "dwindle"
layout.gap = 4
```

On dynamic outputs `name` also creates the workspace; `index` follows whichever workspace
currently occupies the position. On static outputs rules only customize members already
present in the configured inventory.

Combine least→most specific, later values replacing earlier ones: global `[layout]` →
matching output layout defaults (`layout.mode`, `layout.scrolling.default_extent_fraction`)
→ matching rule without `output` → matching rule with `output`. Strut edges resolve
independently, so a rule can override only `layout.struts.top`.

Fields (ranges/values per the 0.1.0 schema):

| Key | Description |
| --- | --- |
| `name` | Exact name; creates it on matching dynamic outputs. |
| `index` | Current one-based position, 1-64. |
| `output` | Restrict to a connector or monitor name. |
| `layout.mode` | `"scrolling"`, `"dwindle"`, `"master"`, or `"stacking"`. |
| `layout.gap` | Window gap, int 0-500. |
| `layout.struts.{left,right,top,bottom}` | Signed logical pixels per edge, ±65535. |
| `layout.extent_presets` | Extent-cycle fractions (float array, 0.1-4.0 each). |
| `layout.new_exits_fullscreen` | Which arriving windows exit fullscreen: `"tiled"`, `"floating"`, `"pinned"`, `"all"`, or an array. |
| `layout.client_maximize` | A tiled/stacking window's own maximize request: `"column"` or `"edges"`. |
| `layout.stacking.drop_zones` | Edge/corner drag previews and placement in stacking; default `true`. |
| `layout.scrolling.default_extent_fraction` | Initial scrolling-column extent, 0.1-4.0. |
| `layout.scrolling.center_underfull_strip` | Center or start-align an underfull strip. |
| `layout.scrolling.center_focused` | When focus changes center a column: `"never"`, `"always"`, `"on_overflow"`. |
| `layout.scrolling.center_on_overview_select` | Center the column picked in the overview. |
| `layout.master.position` | Master area `"left"`, `"right"`, or `"center"`. |
| `layout.master.default_width_fraction` | Master-area fraction, 0.1-0.9. |
| `layout.master.new_on_top` | New stack windows at top or bottom. |
| `layout.master.new_becomes_master` | Give the master slot to new windows. |
| `layout.dwindle.preserve_split` | Keep split directions fixed. |
| `layout.dwindle.new_toward_cursor` | Open new windows on the pointer's side of the split. |
| `layout.tabs.*` | Tab overrides: `default_display` (`"normal"`/`"tabbed"`), `middle_click_closes`, `new_tab_position` (`"end"`/`"after_active"`), `scroll_switches_tabs`, `wrap_focus`. |

Examples:

```toml
[[workspace]]
output = "HDMI-A-1"
name = "CHAT"
layout.mode = "scrolling"
layout.scrolling.center_focused = "always"

[[workspace]]
output = "HDMI-A-1"
name = "STATS"
layout.mode = "dwindle"

[[workspace]]
index = 4
output = "DP-1"
layout.gap = 0
layout.struts.top = 24
layout.scrolling.default_extent_fraction = 0.667
```
