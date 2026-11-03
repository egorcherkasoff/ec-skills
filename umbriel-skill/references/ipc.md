# IPC

Local UNIX socket for queries, actions, and events. Prefer the `umbriel` CLI over raw
socket access.

- Socket path: `$UMBRIEL_SOCKET`, else `$XDG_RUNTIME_DIR/umbriel-$WAYLAND_DISPLAY.sock`.
- One JSON object per line, replies `{"ok": ...}` or `{"err": "..."}`:

```sh
printf '{"cmd":"workspaces"}\n' | socat -t 5 STDIO "$UMBRIEL_SOCKET"
```

## Queries

| Request | CLI |
| --- | --- |
| `{"cmd":"effects"}` | `umbriel effects --json` |
| `{"cmd":"windows"}` | `umbriel windows --json` |
| `{"cmd":"workspaces"}` | `umbriel workspaces --json` |
| `{"cmd":"submap"}` | `umbriel submap --json` |
| `{"cmd":"layers"}` | `umbriel layers --json` |
| `{"cmd":"msg","arg":"<action>"}` | `umbriel msg <action>` |

- Window entries: IDs, app identity, PID (X11: `_NET_WM_PID` or `-1`), geometry,
  workspace, scratchpad membership, `minimized`, tab info (`tabbed`, `tab_index` from 0,
  `tab_hidden`), and effect slots (`border_effect` / `window_effect`).
- Workspace entries: stable `id`, display `name`, one-based `index`, `output`, `layout`,
  occupancy, active/focused. Use the `named` boolean; a named workspace may be called `"2"`.

## Inspection commands

`umbriel outputs`, `color`, `tearing`, `layers`, `keyboard-layouts` — human-readable,
each accepts `--json`. `umbriel color --json` reports HDR mastering metadata
(`mastering_display_primaries`, `mastering_luminance`, `max_cll`, `max_fall`),
`bit_depth` (configured), `bit_depth_active`, and `bit_depth_fallback_reason`.

## Config commands

- `umbriel config validate` — check a config without a running session.
- `umbriel config schema [--json]` — list accepted keys.
- `umbriel config-replace <path>` — load and watch a different absolute config path in
  the running compositor. On success, replaces the watch set; on failure, active config
  unchanged. Warnings don't reject a replacement.

## Virtual outputs

| Request | CLI |
| --- | --- |
| `{"cmd":"output-create","arg":"<name> [mode]"}` | `umbriel output-create <name> [mode]` |
| `{"cmd":"output-destroy","arg":"<name>"}` | `umbriel output-destroy <name>` |

Mode is `WIDTHxHEIGHT[@HZ]`; `output-create` replies with the final name.

## Event stream

```
{"cmd":"subscribe","events":["workspaces","windows"]}
```

The connection first receives current state per family, then a fresh snapshot on change:
`{"event":"workspaces","data":[]}`. Payloads are full snapshots, not deltas — replace
local state. Identical consecutive payloads are omitted. Unknown family returns an error
and closes the subscription.

| Family | Changes reported |
| --- | --- |
| `theme` | Colors and corner radius (mirrors `[colors]`, `[colors.border]`, `[colors.overview]`, `appearance.corner_radius`) |
| `overview` | Overview opened / started closing |
| `keyboard_layout` | Active keyboard layout |
| `windows` | Identity, geometry, focus, state, workspace, scratchpad, effect selection |
| `workspaces` | Inventory, layout, activity, occupancy, output, focus |
| `submap` | Active keybind submap |
| `screencast` | Manual target and focus-following commands |

CLI form (one JSON line per event):

```sh
umbriel subscribe workspaces
umbriel subscribe workspaces,windows
umbriel subscribe submap
umbriel subscribe screencast
umbriel subscribe workspaces | jq -r '.data[] | select(.focused) | "\(.output) \(.name) \(.layout)"'
```

Screencast payload: monotonically increasing `serial` plus one of six kinds —
`{"serial":12,"kind":"window","identifier":"window-id"}`, `{"kind":"output","output":"DP-1"}`,
`follow_window`, `follow_output`, `follow_stop`, `clear`. Every command advances the
serial even when it reselects the same source.

Theme payload example:

```json
{"event":"theme","data":{
  "background":"#141419FF","text_primary":"#E8E8EAFF","text_muted":"#8A8A92FF",
  "accent_primary":"#7AA3FFFF","accent_secondary":"#F5C96BFF","warning":"#F5C96BFF",
  "error":"#FF6B6BFF","insert_hint":"#7FC8FF80","backdrop":"#000000FF","shadow":"#0000007F",
  "border":{"focused":"#7AA3FFFF","unfocused":"#292933FF","outer":"#1A1A1FFF"},
  "overview":{"background_tint":"#10101430","workspace_background":"#00000044","badge":"#7AA3FFFF"},
  "corner_radius":10}}
```

## Audio input (for effect shaders)

One shared 0–1 level for `umbriel_audio_level()` in shaders. Dedicated persistent
connection; `umbriel msg` cannot provide this streaming interface.

```
{"cmd":"effect-audio","version":1,"level":0.65}
```

- `version` must be integer `1`; `level` a finite 0–1 number; no other fields.
- Each request incl. newline ≤ 256 bytes. First accepted measurement claims the feed;
  other producers are rejected while owned. Audio connections accept only `effect-audio`.
- Wait for `{"ok":true}` before the next measurement; ≤ 60/s; replace unsent values with
  the latest. Keep sending during silence (0 = silent). Gain/smoothing/source belong to
  the analyser — Umbriel doesn't capture audio.
- Disconnect, malformed/oversized input, or 250 ms silence closes the feed and clears the
  shader input. Lock/inactive sessions also disconnect. Reconnect with a fresh measurement.
