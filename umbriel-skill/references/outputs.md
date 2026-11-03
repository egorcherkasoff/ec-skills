# Outputs

Output sections configure monitors by connector name (`DP-1`, `eDP-1`, ...) or by
monitor identity `"<make> <model> <serial>"` (the `Config name` from `umbriel outputs`):

```toml
[output.DP-1]
mode = "3840x2160@165"
position = [0, 0]
scale = 1.25
focus_at_startup = true

[output."Microstep MSI G2712F CD6T084401192"]
mode = "1920x1080@180"
```

- Use monitor identity when settings should follow one display between ports; use a
  connector when they belong to a physical port. If both match, the monitor section wins.
  Matching is case-insensitive.
- Without a matching section, Umbriel enables outputs that advertise a preferred mode, a
  display identity, or no fixed mode list. A connector with modes but neither preferred
  mode nor identity stays disabled — add a section with `enabled = true` to force it.
- When an output disconnects or is disabled, its workspaces/windows move temporarily to
  another enabled output and return with layout intact when it comes back.

Run `umbriel outputs` (or `--json`) inside a session to list names and available modes.

## Settings

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | bool | `true` | Turn the monitor on/off logically. |
| `focus_at_startup` | bool | `false` | Move cursor to this monitor at startup. |
| `mode` | string | preferred | `"WIDTHxHEIGHT[@REFRESH]"`, e.g. `"2560x1440@165"`. Unadvertised modes are tried as custom; fallback is preferred mode + warning. |
| `position` | `[x, y]` | automatic | Top-left in logical coordinates. Omit for left-to-right automatic placement. Explicitly positioned outputs must touch/overlap for pointer movement. |
| `scale` | float | `1.0` | 0.25 to 4.0. |
| `transform` | string | `"normal"` | `normal`, `90`, `180`, `270`, `flipped`, `flipped-90`, `flipped-180`, `flipped-270`. |
| `vrr` | string | `"disabled"` | `"disabled"`, `"always"`, `"fullscreen"`. |
| `tearing` | bool | `false` | Allow async page flips for eligible fullscreen windows. |
| `direct_scanout` | bool | `true` | Allow eligible fullscreen buffers to bypass composition. |
| `hdr` | string | `"off"` | `"off"`, `"on"`, `"auto"` (fullscreen with HDR metadata), `"fullscreen"` (any fullscreen). |
| `sdr_white` | float | `203` | SDR reference white in cd/m² while HDR active. |
| `bit_depth` | int | `8` | `8` or `10` (SDR render format). |
| `workspaces` | int / string array / `"dynamic"` | `"dynamic"` | Workspace inventory for this output. |
| `min_workspaces` | int | `1` | Floor for a dynamic output (do not combine with fixed inventory). |
| `cyclic_workspaces` | bool | `false` | Wrap workspace steps around the ends. |
| `workspace_axis` | string | `"vertical"` | `"vertical"` or `"horizontal"`. |
| `layout.scrolling.default_extent_fraction` | float | inherited | Initial scrolling-column extent on this output. |
| `screen_effect` | string | inherited | Screen effect preset/pool for this output, or `"off"`. |

Positions are logical (post-scale/transform): a 3840x2160 output at scale 1.25 is
3072 logical wide, so a neighbor to its right starts at x = 3072.

Multi-monitor example:

```toml
[output.DP-1]
mode = "3840x2160@165"
position = [0, 0]
scale = 1.25
workspaces = 5

[output.DP-2]
mode = "2560x1440@144"
position = [1300, -1440]
scale = 1.0
workspaces = ["VIDEO"]

[output.HDMI-A-1]
mode = "1920x1080@60"
position = [3072, 0]
scale = 1.0
workspaces = ["CHAT", "STATS"]
```

## VRR

```toml
[output.DP-1]
vrr = "fullscreen"
```

`"disabled"` never; `"always"` when supported; `"fullscreen"` while the active workspace
has a fullscreen window. A focused window can override via a `vrr` window rule.
Unsupported outputs warn and stay fixed-refresh.

## Tearing

Output-level opt-in (`tearing = true`); async presentation only for an eligible
fullscreen window that requests it or matches a `tearing = true` window rule (a rule can
also veto). `umbriel tearing` inspects eligibility and fallback reasons.

## HDR

```toml
[output.DP-1]
hdr = "auto"
sdr_white = 203
```

- `"auto"` needs HDR metadata from the app. Untagged XWayland content can't be detected —
  use native Wayland HDR or `hdr = "on"`.
- Native Wayland Proton builds may need `PROTON_ENABLE_WAYLAND=1` and `DXVK_HDR=1`;
  fully restart Steam after changing session env.
- Native DRM: EDID CTA HDR static metadata feeds the BT.2020 PQ description (mastering
  range, MaxCLL/MaxFALL). Nested/virtual outputs have no EDID metadata.
- `umbriel color` (and `--json`) inspects active output color metadata.
- Screenshots from screencopy clients get an SDR view while HDR is active.
- Gamma control (Night Light) is suspended during HDR and restored on return to SDR.
- Monitors may blank briefly on SDR↔HDR switches.

## Bit depth (10-bit SDR)

```toml
[output.DP-1]
bit_depth = 10
```

- Tries XR30/XB30 (`DRM_FORMAT_XRGB2101010`/`XBGR2101010`) render formats; falls back to
  8-bit with `bit_depth_fallback_reason` in `umbriel color --json`.
  `bit_depth_active` reports the committed format.
- With 10-bit active, blur/effects intermediates upgrade to FP16 when the renderer
  supports it.
- Does not guarantee a 10-bit panel link — that depends on EDID/cable/driver.
- VRR requested too: formats tested with VRR first, then without; failed commit retries
  same format without VRR.
- Direct scanout may engage less often (client buffer must match KMS plane format
  exactly); set `direct_scanout = false` to disable it per output.
- Screencopy clients (`grim`, Noctalia) receive raw XR30/XB30 buffers during 10-bit SDR.

## Direct scanout

Disable if fullscreen content corrupts/flickers: `direct_scanout = false` (applies on
reload; may increase GPU use). `WLR_SCENE_DISABLE_DIRECT_SCANOUT=1` before starting
Umbriel disables it everywhere.

## Virtual outputs

```sh
umbriel output-create stream 2560x1440@120
umbriel output-destroy stream
```

- Name: ASCII letters, digits, `-`, `_`, `.`; must not collide with an existing output
  (case-insensitive). `output-create` prints the final name.
- Mode form `WIDTHxHEIGHT[@HZ]`; default 1280x720. Change later via an output section or
  `wlr-randr`. Useful for remote desktop / game streaming (e.g. Sunshine).
- `output-destroy` accepts only virtual outputs; windows move away like an unplug.

## Disabling an output

```toml
[output.HDMI-A-1]
enabled = false
```

Persistent disabled state; workspaces/windows retained and return when re-enabled.
Output-management tools can temporarily override until a changed output policy in the
config reapplies. Temporary logical actions:

```sh
umbriel msg output-disable eDP-1
umbriel msg output-enable eDP-1
umbriel msg output-toggle eDP-1
```

Disabled outputs are absent from whole-desktop screenshots. A temporary choice survives
the output disappearing/returning in the same session; identity monitors keep the choice
across connectors.

## DPMS

```sh
umbriel msg dpms-off          # all configured outputs
umbriel msg dpms-off:DP-1
umbriel msg dpms-on:DP-1
```

Powers monitors off without removing workspaces. Input wakes all monitors when every
output is off. `enabled = false` outputs unaffected. DPMS never moves windows or removes
the output from captures.

## Live reconfiguration

`wlr-randr`, `kanshi`, `wdisplays` can change enabled state, mode, position, scale,
transform, adaptive sync at runtime. Lasts until another tool request or a changed
output-state policy in the config; identical/unrelated reloads are inert.

## Machine-specific overrides

Keep output config in a machine-specific include:

```toml
[include]
files = [
  "src/general.toml",
  "src/keybinds.toml",
  "machines/monolith.toml",
]
```
