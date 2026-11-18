# Outputs

Output sections configure monitors by connector name (`DP-1`, `eDP-1`, ...) or by monitor
identity `"<make> <model> <serial>"` (the `Config name` from `umbriel outputs`):

```toml
[output.DP-1]
mode = "3840x2160@165"
position = [0, 0]
scale = 1.25
focus_at_startup = true

[output."Microstep MSI G2712F CD6T084401192"]
mode = "1920x1080@180"
```

- Identity: settings follow one display between ports; connector: settings belong to a
  physical port. Both match → monitor section wins. Matching is case-insensitive.
- Without a matching section, Umbriel enables outputs advertising a preferred mode, a
  display identity, or no fixed mode list; a connector with modes but neither stays
  disabled (avoids stale DRM connector state) — add a section with `enabled = true`.
- Unadvertised modes are tried as custom; on failure the preferred advertised mode
  applies with a warning (HDR/bit-depth preferences are retried on it; a temporary render
  failure after an accepted backend test retries the current candidate).
- Disconnect/disable: populated workspaces each move into their own temporary workspace on
  another enabled output (appended, target's configured workspaces untouched) — anonymous
  ones get numeric labels, named keep names (keybinds keep working) and layout rules. All
  are restored when the same connector returns, and windows opened there return with them
  (an explicit move into a local workspace cancels the return; tiling edits return while
  tiled windows stay mapped). The receiving output's native same-named workspace wins name
  lookup — qualify the displaced one: `workspace-switch WEB --output DP-1`. Receiver: the
  first enabled output in internal order, skipping ones at the 64-workspace limit; if all
  are full, displaced windows share a local workspace until home returns (empty
  temporaries are removed; with no outputs, windows wait and recover when one returns).

## VR displays

- Native DRM: displays marked non-desktop by the driver are offered via `drm-lease-v1`;
  a VR runtime leases the headset directly while Umbriel manages ordinary monitors — no
  headset-specific configuration. Non-desktop displays get no workspaces, never appear in
  `umbriel outputs`, and stay outside the desktop even if leasing is unavailable.
- Locking the session or switching VT revokes leases; the runtime must acquire a new one
  after unlock (restart may be needed).

## Settings

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | bool | `true` | Turn the monitor on or off. |
| `focus_at_startup` | bool | `false` | Move the pointer to this monitor at startup. |
| `mode` | string | preferred | `"WIDTHxHEIGHT[@REFRESH]"`, e.g. `"2560x1440@165"`. |
| `position` | `[x, y]` | automatic | Top-left in logical coordinates. Omit → automatic left-to-right placement; explicitly positioned outputs must touch/overlap for pointer movement. |
| `scale` | float | `1.0` | 0.25 to 4.0. |
| `transform` | string | `"normal"` | `normal`, `90`, `180`, `270`, `flipped`, `flipped-90`, `flipped-180`, `flipped-270`. |
| `vrr` | string | `"disabled"` | `"disabled"`, `"always"`, `"fullscreen"`, `"fullscreen_any"`. |
| `tearing` | bool | `false` | Allow async page flips for eligible fullscreen windows. |
| `direct_scanout` | bool | `true` | Allow eligible fullscreen buffers to bypass composition. |
| `hdr` | string | `"off"` | `"off"`, `"on"`, `"auto"` (fullscreen with HDR metadata), `"fullscreen"` (any fullscreen). |
| `sdr_white` | float | `203` | SDR reference white in cd/m² while HDR is active, 80–1000. |
| `sdr_transfer` | string | `"gamma22"` | Transfer curve for untagged SDR on HDR outputs: `"gamma22"` or `"srgb"`. |
| `color_profile` | string | `"none"` | SDR panel characterization: `"none"`, `"edid"`, or an ICC profile path. |
| `sdr_gamut` | string | `"native"` | Untagged SDR gamut policy while characterized: `"native"` or `"srgb"`. |
| `bit_depth` | int | `8` | SDR render bit depth: `8` or `10`. |
| `workspaces` | int / string array / `"dynamic"` | `"dynamic"` | Workspace inventory for this output (1–64). |
| `min_workspaces` | int | `1` | Floor for a dynamic output (1–64); don't combine with a fixed inventory. |
| `cyclic_workspaces` | bool | `false` | Wrap workspace steps around the inventory ends. |
| `workspace_axis` | string | `"vertical"` | `"vertical"` or `"horizontal"`. |
| `layout.mode` | string | inherited | Per-output layout mode: `"scrolling"`, `"dwindle"`, `"master"`, `"stacking"`. |
| `layout.scrolling.default_extent_fraction` | float | inherited | Initial scrolling-column extent, 0.1–4.0; new columns only. |
| `screen_effect` | string | inherited | Screen preset/pool for this output, or `"off"` to disable `effects.screen` here. |
| `screen_cast_effect` | string | inherited | Same for `effects.screen_cast`, used only while a client captures this output whole; or `"off"`. |

`workspaces` accepts `"dynamic"`/omitted (grows and shrinks), an int (fixed anonymous
count), or a string array (fixed ordered names). Workspace transfers can grow/shrink a
fixed inventory for the session; changing the inventory config reapplies the configured
one. `cyclic_workspaces = true` wraps steps around inventory ends — applies to
`workspace-next`/`previous`, `window-move-to-workspace-next`/`previous` (and `-silent-`),
`window-move-or-workspace-up`/`down` at the column edge, `column-move-to-workspace-next`/
`previous`; on a dynamic output the trailing empty workspace is last (one more step wraps
to the first), a static inventory wraps directly at both ends.

`[output.DP-1.layout]` `mode` sets the layout mode for every workspace on the output,
incl. dynamic ones created later; matching workspace rules override it. `mode` directly
under `[output.<name>]` is the display mode, not the layout. Per-output
`layout.scrolling.default_extent_fraction` overrides the global initial column width;
reload affects new columns only. `screen_effect` and `screen_cast_effect` name an
`[effects.preset.<name>]` or `[effects.pool.<name>]` of kind screen, or `"off"` to disable
`effects.screen` or `effects.screen_cast` on this output. Positions are logical
(post-scale/transform): a 3840x2160 output at scale 1.25 occupies 3072x1728 logical units,
so a right-hand neighbor starts at x = 3072.

## VRR

| Value | Behavior |
| --- | --- |
| `"disabled"` | Never enable adaptive sync. |
| `"always"` | Keep adaptive sync enabled when supported. |
| `"fullscreen"` | While the active workspace has a fullscreen window. |
| `"fullscreen_any"` | While any workspace on the output has a fullscreen window, active or not. |

`fullscreen_any` keeps VRR on while switching from a fullscreen game to another workspace
on the same output and back; state flips only when the first window enters fullscreen and
the last leaves or closes. `fullscreen` turns off as soon as the active workspace has no
fullscreen window. A focused window can override via a `vrr` window rule (`"disabled"`,
`"always"`, or `"fullscreen"` following the focused window's own state); unsupported
outputs warn and stay fixed-refresh.

## Tearing

Output-level opt-in `tearing = true`; async presentation only for an eligible fullscreen
window that requests it or matches a `tearing = true` window rule (a rule can also veto a
client request). `umbriel tearing` inspects eligibility and fallback reasons.

## HDR

```toml
[output.DP-1]
hdr = "auto"       # off | on | auto | fullscreen
sdr_white = 203    # 80–1000
sdr_transfer = "srgb"  # optional, default "gamma22"
```

- `sdr_white` sets composed SDR brightness and the reference white of the HDR encoding
  advertised to Wayland apps (reload updates descriptions and notifies apps; SDR-only
  outputs keep nominal 80 cd/m²). Runtime override until disconnect or an
  output-state-changing reload restores the configured value:
  `umbriel msg output-sdr-white 203 [--output DP-1]` (`umbriel color` reports it).
- `auto` advertises an HDR encoding on supported outputs before switching, so native
  Wayland Wine/Proton detect HDR before their first HDR frame; output stays SDR until
  fullscreen content supplies HDR metadata. Positive MaxCLL at or below the surface's
  reference white keeps SDR unless HDR mastering luminance is also supplied (a PQ-buffered
  SDR browser doesn't flip the monitor); unknown peak → the description's encoding and
  headroom. Activation needs a passing backend test; on failure the encoding is withdrawn
  until a config/mode change retests. Windowed HDR and failed activation get highlight
  compression into SDR instead of clipping; untagged SDR renders normally.
- `sdr_transfer` (HDR outputs only, on reload): `gamma22` keeps legacy SDR appearance;
  `srgb` decodes untagged SDR with the piecewise sRGB curve (lighter darks, matches apps
  converting SDR→PQ that way). Effect color controls and SDR capture encoding follow;
  explicit client descriptions keep their declared transfer; inert while SDR.
- Untagged XWayland content is undetectable — use a native Wayland HDR path or
  `hdr = "on"`. Some native Proton builds need `PROTON_ENABLE_WAYLAND=1` + `DXVK_HDR=1`;
  fully restart Steam after changing session env.
- Native Wayland apps and Wine share `wp_color_manager_v1`, incl. Windows scRGB
  (absolute: linear 1.0 = 80 cd/m² even when `sdr_white` changes). Nested Gamescope HDR
  works through it (PQ or scRGB) with no extra Umbriel option/layer rule — output must
  support HDR, Gamescope's HDR settings on; clients needing an already-active HDR target
  require `hdr = "on"`.
- Native DRM: EDID CTA HDR static metadata (primaries, min/max content luminance, MaxFALL)
  feeds the BT.2020 PQ description; EDID-omitted values stay undefined; nested/virtual
  outputs have none. Independent of `sdr_white`.
- `umbriel color [--json]`: `mastering_display_primaries`, `mastering_luminance`,
  `max_cll`, `max_fall` per output; `transfer_function`/`primaries` read `"none"` without
  an active HDR encoding, `"custom"` for explicit primary coordinates.
- Capture during HDR: shm screencopy/image-copy get an 8-bit SDR view; DMA-BUF may retain
  10-bit storage (still SDR values); raw export-DMA-BUF not advertised. Window captures
  (incl. portal previews) honor client metadata, convert HDR→SDR; captures, overview
  previews, and snapshots preserve the client's color description.
- Gamma control (Night Light): the ramp's white endpoint adjusts the image in linear
  light before PQ encoding — works during HDR, keeps highlight headroom (warming changes
  colors). Custom gamma-curve calibration is SDR-only; the latest full table is kept and
  restored on return to SDR. HDR white-point adjustment covers the whole display incl.
  the cursor, needs composition, and is excluded from SDR screenshots/recordings. Brief
  black on SDR↔HDR switches is normal.

## Color profile and SDR gamut

Wide-gamut panels render untagged (sRGB) SDR oversaturated (vivid reds/greens); Umbriel
can characterize the display and convert during composition:

```toml
[output.DP-1]
color_profile = "edid"  # "none" (default) | "edid" | ICC path; priority ICC > edid > none
sdr_gamut = "srgb"      # "native" (default) | "srgb", meaningful only when characterized
```

- Paths: relative resolves against the config file's dir (includes too); `~`/`~/`
  expands to `$HOME` only; `"none"`/`"edid"` are reserved (literal files need `./edid` or
  an absolute path); must be a readable regular file (no dirs/FIFOs/devices).
- Failures fall down the chain and never fail the output: unusable value → keep `"none"`
  + warning; unresolvable path or unparseable ICC → `"edid"` + warning. Nested/headless
  outputs have no EDID → uncharacterized. Profile re-read is keyed on mtime — `cp -p` and
  archive extraction often keep the old timestamp, leaving the old characterization live.
- `sdr_gamut`: `"native"` stages no transform (bit-identical to uncharacterized);
  `"srgb"` maps untagged SDR into the panel's colorimetry — the oversaturation fix,
  white-preserving. Tagged apps: under `"srgb"` output/preferred descriptions advertise
  the panel's colorimetry (clients convert pre-compositing); under `"native"` they
  advertise the sRGB destination actually written (tagged pixels unchanged).
- ICC import: matrix-shaper profiles with one shared per-channel curve only; sRGB and
  gamma 2.2 → named curves, exact powers stated as such, others sampled to a LUT
  (non-monotone tables flattened first); LUT-based profiles or differing channel curves
  rejected + fallback; `vcgt` ignored. Advertised curves apply as stated (named, exact
  power, or profile bytes + 1024-entry decode table, worst error 0.002 of an 8-bit code);
  parametric-only pipelines get a named transfer via `get_preferred_parametric`.
- While a mapping is staged: direct scanout is disabled (`color_profile = "none"`
  restores it) and SDR frames leave the 8-bit fast path for FP16 composition with
  per-damage re-encode (more GPU work/power on redraws). Output screenshots/recordings
  show the mapped result; window captures keep the client's colorimetry, so a window can
  differ from the screen.
- Client-imported ICC (color-management protocol): only the three exactly renderable
  curves are accepted; over-budget ICC bytes, too many creators, or an unusable fd →
  protocol error and disconnect.
- `umbriel color [--json]`: `color_profile`, `color_profile_resolved` (reports `edid`
  after a fallback), `sdr_gamut`, `mapping staged`/`sdr_gamut_staged`,
  `panel_primaries`, `panel_transfer`; JSON adds active bit depth + fallback reason.
  ICC support is built with lcms2 (see PACKAGING.md for the build option).

## Bit depth

`bit_depth = 10` requests XR30 (`DRM_FORMAT_XRGB2101010`) or XB30 (`XBGR2101010`) — XB30
first if already active, else XR30; falls back to 8-bit if neither commits. HDR uses
10-bit independently. With 10-bit active, blur/effects intermediates go FP16 if the
renderer supports FP16 targets + half-float linear filtering, else stay 8-bit. Render
format only — panel link depth depends on EDID/cable/driver. `umbriel color --json`:
`bit_depth` (configured), `bit_depth_active` (XR30/XB30), `bit_depth_fallback_reason`
(empty while HDR is active).

- VRR also requested: formats are tested with VRR first (same order), then without; a
  failed commit retries the same format without VRR; the other format is not tried; else
  8-bit. HDR follows the same retry rule before SDR fallback.
- Direct scanout stays governed by `direct_scanout` but may engage less often (client
  buffer must exactly match what KMS accepts for the plane); `direct_scanout = false`
  disables it per output.
- Screencopy/capture: shm screencopy and image-copy use an 8-bit format even for XR30/XB30
  (also the SDR view during HDR, for client compatibility); DMA-BUF capture may retain
  the negotiated 10-bit storage; raw export-DMA-BUF is unavailable.

## Window capture resolution

Window screenshots/sharing render at the window's current output scale: a fullscreen
window on a 3200x2000 output at scale 2.5 captures at 3200x2000 px (logical 1280x800);
fractional dimensions round up; moving the window or changing its output's scale resizes
ongoing sessions' buffers. Larger buffers cost memory, rendering, copying, possibly
encoding (scale 2.5 = 6.25x the pixels of scale 1); apps supplying low-res buffers keep
only that detail. Idle capture sources don't render; stopping the last session releases
the output swapchain.

## Direct scanout

- Disable for fullscreen corruption/flicker: `direct_scanout = false` (applies on reload;
  can raise GPU use/power). `WLR_SCENE_DISABLE_DIRECT_SCANOUT=1` before starting Umbriel
  disables it on every output.
- `umbriel outputs` shows `Direct scanout: active|inactive (<reason>)` for the latest
  backend-accepted commit (rejected commits don't change it; not a presentation
  confirmation). `--json` adds `direct_scanout.commits`, `direct_scanout.scanout_commits`,
  `direct_scanout.commit_seq` (wrapping 32-bit); counters survive reloads and power
  cycles, reset on compositor restart or output destroy+recreate. The log records
  scanout on/off/window changes once the state held 0.5s — the same settle as
  subscription notifications; counter increments alone don't push events, query
  `outputs` for immediate state.
- Inactive reason (the first condition that ruled it out):

| Reason | Meaning |
| --- | --- |
| `disabled` | `direct_scanout = false` or `WLR_SCENE_DISABLE_DIRECT_SCANOUT` set. |
| `no_candidate` | Nothing on the output, or what is visible is not a client buffer. |
| `composited` | Multiple surfaces visible: overlays, popups, borders, translucent window, or a window not covering the output. |
| `effects` | A screen, window, or animation effect is drawing on the output. |
| `color_conversion` | Gamma table, color transform, HDR white point, or the window's color description needs conversion. |
| `capture` | An HDR output is being captured as SDR. |
| `cropped` | The window is clipped, e.g. mid-animation. |
| `transform` | The buffer's transform differs from the output's. |
| `modeset` | The output is changing mode or format this frame. |
| `render_locked` | A capture or animation needs the output composited. |
| `software_cursor` | The cursor is drawn in software over the window. |
| `rejected` | The display driver refused the buffer (format/modifier). |
| `debug_damage` | Damage highlighting is on. |

- Triage: snapshot `umbriel outputs --json` before launch and again while the problem is
  visible (before opening overlays or switching workspaces; add `umbriel color --json`).
  A `scanout_commits` increase means scanout commits were accepted during the interval
  even if `active` is now false — it doesn't identify the window or the cause. One
  directory per run; keep HDR and app arguments unchanged when comparing on/off.

## Virtual outputs

```sh
umbriel output-create stream 2560x1440@120
umbriel output-destroy stream
```

A monitor with no display behind it: has workspaces, takes windows, capturable like any
output — a target for remote desktop and game streaming (see `references/streaming.md`).
Name: ASCII letters, digits, `-`, `_`, `.`; must not collide with an existing output
(case-insensitive); `output-create` prints the final name. Mode form
`WIDTHxHEIGHT[@HZ]`, default 1280x720; change later via an output section or
`wlr-randr --output stream --custom-mode 2560x1440@120Hz`. `output-destroy` accepts only
virtual outputs; its windows move to another output as when a monitor is unplugged.

## Disabling an output

```toml
[output.HDMI-A-1]
enabled = false
```

Persistent disabled state; workspaces/windows are retained and return when re-enabled.
Output-management tools can override temporarily until a changed output-state policy in
the config reapplies the file; identical or unrelated reloads are inert. Temporary logical
actions (usable directly from lid event commands):

```sh
umbriel msg output-disable eDP-1
umbriel msg output-enable eDP-1
umbriel msg output-toggle eDP-1
```

Windows move to another enabled output while their home is unavailable, then return; a
disabled output is absent from whole-desktop screenshots. A temporary choice survives the
output disappearing and returning in the same session: with a display identity it follows
that monitor across connectors (a different identified monitor on the old connector
doesn't inherit it); outputs without identity stay keyed to their connector name.

## DPMS

```sh
umbriel msg dpms-off          # every configured output
umbriel msg dpms-off DP-1
umbriel msg dpms-on DP-1
```

Powers monitors off without removing workspaces, moving windows, removing the output
from the logical desktop, or excluding it from whole-desktop capture. Input wakes all
monitors when every output is powered off. Outputs with `enabled = false` are unaffected.

## Live reconfiguration

`wlr-randr`, `kanshi`, `wdisplays` can change enabled state, mode, position, scale,
transform, and adaptive sync at runtime. Changes last until another tool request or a
changed output-state policy in the configuration; identical/unrelated reloads are inert.

## Multi-monitor example

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

The primary output is 3072 logical units wide, so the HDMI output begins at x = 3072.

## Machine-specific overrides

Keep output config in a machine-specific include when sharing one base configuration:

```toml
[include]
files = [
  "src/general.toml",
  "src/keybinds.toml",
  "machines/monolith.toml",
]
```

Each output keeps its screen pool assignment while disabled; disconnecting releases it
and reconnecting starts from configuration (`umbriel effects --json` to inspect
assignments). The cursor effect has one session-wide selection shared by all outputs.
