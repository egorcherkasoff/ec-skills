# IPC

Local UNIX socket for queries, actions, and events — prefer the `umbriel` CLI over
raw socket access. Socket path: `$UMBRIEL_SOCKET`, else
`$XDG_RUNTIME_DIR/umbriel-$WAYLAND_DISPLAY.sock`. One JSON object per line; replies
`{"ok": ...}` or `{"err": "..."}`; commands with arguments send an `args` array of
strings, one per command-line word.

```sh
printf '{"cmd":"workspaces"}\n' | socat -t 5 STDIO "$UMBRIEL_SOCKET"
```

## Queries

| Request | CLI |
| --- | --- |
| `{"cmd":"effects"}` | `umbriel effects --json` |
| `{"cmd":"windows"}` | `umbriel windows --json` |
| `{"cmd":"focused-window"}` | `umbriel focused-window --json` |
| `{"cmd":"workspaces"}` | `umbriel workspaces --json` |
| `{"cmd":"submap"}` | `umbriel submap --json` |
| `{"cmd":"layers"}` | `umbriel layers --json` |
| `{"cmd":"outputs"}` | `umbriel outputs --json` |
| `{"cmd":"input-capture-permissions"}` | `umbriel input-capture-permissions --json` |
| `{"cmd":"input-capture-revoke","args":["<id>"]}` | `umbriel input-capture-revoke <id>` |
| `{"cmd":"global-shortcuts"}` | `umbriel global-shortcuts --json` |
| `{"cmd":"global-shortcuts-revoke","args":["<application>"]}` | `umbriel global-shortcuts-revoke <application>` |

## Actions

Programs run an action with a typed request; `umbriel msg <action> [args...]` parses
its words into the same request. Reply is `{"ok": null}` or `{"err": "..."}`. An
unknown field, missing required field, wrong JSON type, or empty string is rejected
with the field named in the error (verified:
`{"err":"invalid arguments for workspace-switch: unknown field \"window\""}`).
Optional fields are left out, never sent empty.

```
{"cmd":"action","action":"window-focus","window":"<window-id>"}
{"cmd":"action","action":"workspace-set-layout","layout":"toggle","cycle":["scrolling","master"]}
```

| Argument form | Fields |
| --- | --- |
| `<cmd...>` | `command`: string, run through the shell |
| submap `<name>` | `submap`: string |
| `<fraction>`, `<delta>` | `fraction` / `delta`: number |
| `<workspace> [--output <output>]` | `workspace`: position number, or name string even if all digits; optional `output`: string |
| `<output>`, `[<output>]` / `<window-id>`, `[<window-id>]` | `output` / `window`: string, required or optional as in the argument form |
| `[<scratchpad>]` | optional `scratchpad`: string |
| effect `set` / `cycle` | `effect`: string; `set` takes optional `window` (window/border effects) or `output` (screen effects); `cycle` takes optional `pool` and `window`/`output` |
| `<nits> [--output <output>]` | `nits`: number; optional `output`: string |
| layout mode | `layout`: `"scrolling"` \| `"dwindle"` \| `"master"` \| `"stacking"` \| `"toggle"`; with `"toggle"`, optional `cycle`: array of ≥2 distinct names |
| `<normal\|tabbed>` | `display`: `"normal"` or `"tabbed"` |
| `<index>` / region / `[skip-confirmation]` | `index`: integer; `region`: string; optional `skip_confirmation`: boolean |
| `<anchor> <x> <y> [--window <window-id>]` | `anchor`: string; `x`,`y`: integers; optional `window` |
| `<delta-x> <delta-y> [--window <window-id>]` | `dx`,`dy`: integers; optional `window` |

`workspace-move-to-output` requires `destination` (connector, monitor identity, or
`current`); optional `workspace`/`output` select the source (same types as
`workspace-switch`; `output` requires `workspace`):
`{"cmd":"action","action":"workspace-move-to-output","destination":"current","workspace":"WEB","output":"DP-1"}`.

## Entry shapes

- **Windows**: id, app_id, title, pid (X11: published `_NET_WM_PID` or `-1`), x/y/w/h,
  output, workspace, scratchpad, plus `active`, `urgent`, `content_type`, `xdg_tag`,
  `xwayland`. A tab-group member reports `tabbed`, `tab_index` (0-based, `-1`
  outside), `tab_hidden` while another tab shows (text listing marks it `tab`).
  `focused-window` returns the focused window's `windows` entry — the window that
  window actions act on: the seat's focused window wins (a modal dialog itself; a
  visible
  keyboard-holding scratchpad window); while a layer surface or the overview holds
  the keyboard, it falls back to the pointer output's active workspace's remembered
  focus; `{"err":"no focused window"}` when a scratchpad owns the seat with nothing
  focused or nothing is focused. State fields (compositor-decided, ahead of client
  redraw — like geometry):

| Field | Meaning |
| --- | --- |
| `floating` | Outside the tiled layout |
| `region` | Edge placement: `left`/`right`/`top`/`bottom`/`top_left`/`top_right`/`bottom_left`/`bottom_right`, or `null`; retained under maximize/fullscreen within stacking |
| `title_bar` | Server-side title bar enabled in this state |
| `fullscreen`, `maximized`, `maximized_to_edges` | Fullscreen; maximized by toggle or maximize-to-edges (full-width column when tiled); maximized without gaps, struts, or borders |
| `pinned` | Above other windows on every workspace of its output; `workspace` always the output's active one |
| `minimizable`, `minimized` | Minimize supported in current placement (mapped, unattached floating on a workspace, outside scratchpad, not pinned; fullscreen or active move/resize can still reject); hidden by `window-minimize`, app, or taskbar |
| `visible` | On the active workspace (or pinned), not a hidden tab, not minimized, not in a hidden scratchpad; may be scrolled out of view |
| `parent` | Client-named parent id, or `""` |
| `column`, `row` | Scrolling-strip place from 0; `-1` floating and other layouts |

- **Workspaces**: stable `id`, display `name`, one-based `index`, `output`, `layout`
  (`scrolling`/`dwindle`/`master`/`stacking`), `named`, `occupied`, `window_count`
  (mapped windows; pinned excluded from count and occupancy), `active`, `focused`,
  `focused_window` (last-focused id, `""` if none), `urgent` (any window urgent),
  `layout_override` (runtime `workspace-set-layout` active), `previous` (previous
  active workspace per output, same history as `back_and_forth`; false before the
  first switch or after the previous workspace is removed; also in `workspaces`
  events). Use `named`, not the display name — a named workspace may be `"2"`.
- **Layers**: `layer`, `namespace`, `output`, `mapped`, `pid`,
  `keyboard_interactivity` (`none`/`exclusive`/`on_demand`), `focused` while holding
  the keyboard, `exclusive_zone`, `anchor`, `margin`, arranged `x`,`y`,`w`,`h` in
  layout coordinates.
- **Outputs**: every connected output incl. disabled: `name`, `description`, `make`,
  `model`, `serial`, `config_name` (monitor identity or `null`), `physical_size`,
  `enabled`, `powered` (enabled and not DPMS-off), `focused`, `active_workspace` (id),
  `position`, `logical_size`, `usable_area` (after exclusive zones, layout
  coordinates), `transform`, `scale`, `adaptive_sync` (`null` if VRR unsupported),
  `hdr_active`, `direct_scanout`, `modes[]` (`width`, `height`, `refresh_mhz`,
  `preferred`, `current`); a disabled output reports zero `logical_size` and
  `usable_area`. `direct_scanout`: `null` while disabled/powered off, else
  `{active, reason (null while active), window {id, app_id, title} or null}` — latest
  scene buffer accepted by the backend, immediately; commit ≠ presentation.
  Diagnostics: `commits` (accepted scene-buffer commits), `scanout_commits` (those
  via direct scanout incl. brief episodes), `commit_seq` (backend 32-bit sequence;
  wraps, skips non-scene-buffer commits) — survive reloads and power cycles, reset on
  restart or output destroy/recreate; compare same-lifetime snapshots. Scanout
  notifications and logs wait 500 ms of stable state; poll `outputs` for immediate
  state.

## Effect inspection

`umbriel effects` prints tables; `--json` exposes `presets`, `pools`, `cursor`,
`owners` in configuration declaration order (incl. includes). Presets: `name`,
`kind`, `state` — `inert` (missing/empty source), `unreferenced` (no registry entry),
`failed` (compilation failed), `compiled` (usable); border presets add `overlay`.
Pools: `name`, `kind`, `policy`, ordered `members` (`name`, `held`) — holds count
unsuppressed mapped windows, present outputs (incl. disabled), and the session
cursor, independent of visibility/focus. Owners: mapped windows sorted by `id`, then
present outputs by `name`; window slots `border`+`window`, output slots `screen`, the
single cursor as `cursor`. Slots: `name` (selected preset), `pool` (empty for a
plain preset), `source` (`default`/`rule`/`runtime`), `suppressed`, border slots add
`overlay`; empty pools keep their pool name, suppressed/failed selections keep their
names. `windows --json` and `subscribe windows` expose the same shapes as
`border_effect`/`window_effect`. Inspection never picks, compiles, or binds effects —
use `effects`, not `outputs`, for screen selections.

## Input capture permissions

`input-capture-permissions` lists remembered grants: `id`, `application`,
`capabilities`, `persist_mode` (identifiers can be empty, unverified; replies never
contain restore credentials). `input-capture-revoke <id>` (or `all`) forgets the
grant(s) and stops their live sessions; already-forgotten valid IDs succeed; a
state-write error is reported even though matching live sessions are stopped.

## Global shortcuts

`global-shortcuts` lists live and remembered shortcuts grouped by exact `application`
ID; each has `live` (open bridge session) and `shortcuts[]`; without `--json` prints a
readable listing. Inspection never registers or changes ownership; credentials are
never included; an unreadable/locked state store errors rather than listing
incompletely. The same shortcut ID may appear in multiple live sessions and
remembered grants — session numbers distinguish them; offline candidates don't
reserve keys.

| Field | Meaning |
| --- | --- |
| `id`, `description` | Requester-supplied, unverified |
| `session`, `pending` | Live bridge session number (`null` for remembered scope); live registration awaiting physical approval |
| `trigger`, `candidate` | Assigned chord or `null` (assignment even while activation is suppressed); resolved chord before conflicts — remembered entries have candidates but no trigger |
| `source` | `config` / `stored` / `preferred` / `none` |
| `conflict` | `none` / `unassigned` / `disabled` / `reserved` / `in_use` |

`global-shortcuts-revoke <application>` (or `all`) forgets every grant for that
exact ID, deactivates held shortcuts, and closes live sessions incl. pending;
already-forgotten valid IDs succeed; on durable-deletion failure live sessions still
close and the command errors. Successful revocation invalidates stale restore
credentials; config overrides remain; new sessions need fresh approval.

Note: umbriel 0.1.0 (88ba829c) rejects both commands as unknown on CLI and socket.

## Event stream

```
{"cmd":"subscribe","events":["workspaces","windows"]}
```

First the current state of each family, then a fresh snapshot per change:
`{"event":"workspaces","data":[]}`. Payloads are full snapshots, not deltas — replace
local state; identical consecutive payloads are omitted; `windows`, `workspaces`,
`layers`, `outputs` send at most one snapshot per 16 ms (bursts skip intermediate
states, end with the newest). Unknown family errors and closes the subscription.
Floating-window moves and `xdg-toplevel-drag-v1` carried windows report while the
drag is held (`x`/`y` follow the drag position); outside a drag, positions are
layout targets, not animation progress; sizes follow committed client geometry incl.
mouse/keyboard resizes.

| Family | Changes reported |
| --- | --- |
| `theme` | Colors and corner radius (mirrors `[colors]`, `[colors.border]`, `[colors.overview]`, `appearance.corner_radius`) |
| `overview` | Overview opened / started closing |
| `keyboard_layout` | Active keyboard layout |
| `windows` | Identity, geometry, focus, state, visibility, parent, workspace, scratchpad, effect selection |
| `workspaces` | Inventory, layout, activity, occupancy, window count, focused window, urgency, output, focus |
| `submap` | Active keybind submap |
| `screencast` | Manual target and focus-following commands |
| `layers` | Layer surfaces appearing, mapping, closing, moving, resizing, taking/losing keyboard |
| `outputs` | Appearance/leaving, enablement, power, mode, position, scale, transform, VRR, HDR, usable area, focus, active workspace |

Screencast payload: monotonically increasing `serial` plus one of six kinds —
`{"serial":12,"kind":"window","identifier":"window-id"}`,
`{"kind":"output","output":"DP-1"}`, `follow_window`, `follow_output`,
`follow_stop`, `clear`. Every command advances the serial even when it reselects the
same source; portal backends use that edge so a newly authorized manual stream stays
empty until the next target action.

Theme payload mirrors `[colors]`, `[colors.border]`, `[colors.overview]`, and
`appearance.corner_radius`:

```json
{"event":"theme","data":{"background":"#141419FF","text_primary":"#E8E8EAFF","text_muted":"#8A8A92FF","accent_primary":"#7AA3FFFF",
  "accent_secondary":"#F5C96BFF","warning":"#F5C96BFF","error":"#FF6B6BFF","insert_hint":"#7FC8FF80","backdrop":"#000000FF",
  "shadow":"#0000007F","corner_radius":10,"border":{"focused":"#7AA3FFFF","unfocused":"#292933FF","outer":"#1A1A1FFF"},
  "overview":{"background_tint":"#10101430","workspace_background":"#00000044","badge":"#7AA3FFFF"}}}
```

CLI form (one JSON line per event; `--json`/`-j` accepted and change nothing):

```sh
umbriel subscribe workspaces,windows
umbriel subscribe workspaces | jq -r '.data[] | select(.focused) | "\(.output) \(.name) \(.layout)"'
```

## Audio input (for effect shaders)

Shared 64-band 0–1 spectrum for shaders. Dedicated persistent socket connection
(`umbriel msg` cannot stream); audio connections accept only `effect-audio`:

```
{"cmd":"effect-audio","version":2,"bands":[0,...64 finite 0–1 values...]}
```

- `version` must be integer `2`; `bands` exactly 64 finite numbers, 0 to 1, ordered
  low to high; no other fields; requests incl. newline ≤ 4096 bytes (binary rejects v1
  `level` and 63-band requests with `malformed audio request`).
- First accepted snapshot claims the feed; another producer gets
  `{"err":"audio producer already connected"}`. Wait for `{"ok":true}` before the
  next; ≤ 60/s; replace unsent snapshots with the latest. Send on change plus a
  heartbeat every 100 ms while unchanged; decay/clear to zero when capture stops or
  the source switches; zero-valued snapshots keep the feed available.
- Disconnect, malformed/oversized input, or 250 ms without a snapshot closes the feed
  and clears bands and availability; locked/inactive sessions reject audio until
  active and unlocked — reconnect with a fresh snapshot. `ok` means accepted, not
  displayed. Gain/smoothing/source belong to the analyser; Umbriel neither starts
  nor supervises it nor captures audio.

## Inspection commands

`umbriel outputs`, `color`, `tearing`, `layers`, `keyboard-layouts` print
human-readable state; each accepts `--json`. `umbriel color --json` reports HDR
mastering metadata (`mastering_display_primaries`, `mastering_luminance`, `max_cll`,
`max_fall`), `bit_depth` (configured), `bit_depth_active`, `bit_depth_fallback_reason`.

## Config commands

- `umbriel config validate [-c <config>]` — check a config without a running session;
  `--json` lists diagnostics.
- `umbriel config schema [--json]` — count or describe every accepted config key, no
  compositor needed.
- `umbriel config-replace <path>` — load and watch a different absolute config path
  in the running compositor. On success the new file + includes replace the watch set
  and later reloads use it; a missing/unreadable/invalid file errors and leaves the
  active config and watch set unchanged; warnings don't reject. Runtime overrides stay
  applied over the new file.
- Runtime overrides (applied over the file until exit) —
  `{"cmd":"config-set","args":["<key>","<value>"]}`, `config-get` (replies
  `{"ok":{"override":false,"value":"sloppy"}}`), `config-unset <key>|--all`;
  CLI: `config set/get/unset`.

## Virtual outputs

| Request | CLI |
| --- | --- |
| `{"cmd":"output-create","args":["<name>"]}` or `{"cmd":"output-create","args":["<name>","<mode>"]}` | `umbriel output-create <name> [mode]` |
| `{"cmd":"output-destroy","args":["<name>"]}` | `umbriel output-destroy <name>` |

`output-create` replies with the new output's name; mode is `WIDTHxHEIGHT[@HZ]` (e.g.
`1920x1080@60`). Both error on an invalid, taken, or unknown name; `output-destroy`
refuses outputs backed by a real display.
