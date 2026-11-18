# Effects

GLSL programs run on animation events, window borders, windows, whole outputs, and around the
pointer. Every effect is off until you select one; presets are bundled files you include or
`[effects.preset.<name>]` tables.

## Bundled presets

Under `share/umbriel/effects/<kind>/<name>/`; include a preset's `effect.toml`, then select it —
including alone only registers the preset. NixOS uses a store path instead of `/usr/share`. Append
to existing `[include]` / `[effects]` / `[animation.windows_in]` tables instead of repeating them.

```toml
[include]
files = [
  "/usr/share/umbriel/effects/border/pulse/effect.toml",
  "/usr/share/umbriel/effects/animation/reveal/effect.toml",
]

[effects]
border = "pulse"

[animation.windows_in]
effect = "reveal"
```

| Preset | Kind | Selector |
| --- | --- | --- |
| `reveal` | animation | `[animation.windows_in] effect` (also `windows_out`) |
| `squash` | animation | `[animation.windows_move] effect` |
| `pulse` | border | `[effects] border` |
| `audio` | border | `[effects] border`; brightness follows the lowest external spectrum band; dim without a feed |
| `scanlines` | window | `[effects] window` |
| `vignette` | screen | `[effects] screen` |
| `glow` | cursor | `[effects] cursor` |
| `trail` | cursor | Purple/lavender/moon-yellow tail; fixed palette, editable in `cursor/trail/shader.glsl` |
| `trail-path` | cursor | Two-second curved tail coloured along its length |

## Selectors and per-target overrides

```toml
[effects]
border = "pulse"
window = ""            # "" selects nothing
screen = "vignette"
cursor = "glow"

[[window_rule]]
match.app_id = "^mpv$"
border_effect = "off"
window_effect = "scanlines"

[output."HDMI-A-1"]
screen_effect = "off"
```

| Key | Default | Description |
| --- | --- | --- |
| `border` | `""` | Border preset/pool for the focused window, or every decorated, non-urgent, non-fullscreen window with `border_unfocused`. |
| `window` | `""` | Window preset/pool for every window. |
| `screen` | `""` | Screen preset/pool for every output. |
| `screen_cast` | `""` | Screen preset/pool replacing `screen` on an output while a client captures that output whole (portal screen share); other outputs keep theirs. Reaches viewers only with `in_capture`. |
| `cursor` | `""` | Cursor preset/pool, shared across outputs. |
| `max_fps` | `0` | 0–240 cap for frames drawn only because an effect animates; `0` follows each output's refresh rate. |
| `in_capture` | `false` | Include window/screen/cursor effects in screencopy and image-copy captures. Border effects always appear. Raw export-DMA-BUF is not advertised; use screencopy or image-copy clients. |
| `border_unfocused` | `false` | Draw the border effect on every decorated, non-urgent, non-fullscreen window, focused or not. |

Capture protection always omits protected windows, regardless of `in_capture`. The cursor effect has
no per-window or per-output override. Where each kind draws:

- **animation** — via `[animation.<event>] effect`; the event's `enabled`, `duration_ms`, and
  `curve` own the timeline.
- **border** — the focused window's ring while decorated, not fullscreen, not urgent (every such
  window with `border_unfocused`); `padding` reserves transparent space around the ring.
- **window** — over each window in place regardless of focus (incl. undecorated, fullscreen),
  following it through open/close/move, workspace switches, and the overview. A floating CSD window
  with `corner_radius = 0` also has its transparent margin shaded.
- **screen** — over the whole output after everything else except the cursor effect and the
  software cursor.
- **cursor** — a square of `radius` logical px around the pointer (`0` = whole output), after the
  screen effect, only on the pointer's output, clipped at its edges, before the software cursor;
  never shades the cursor image or affects a hardware cursor; hides with the compositor pointer (a
  client hiding its own cursor image doesn't). Motion-history shaders expand the rect over the
  retained path plus `radius` padding.

Session lock detaches screen and cursor effects, never shades the lock surface.

## Presets

`[effects.preset.<name>]`: `kind` required; `shader` is a GLSL file relative to the naming TOML,
watched, reloads with the configuration; missing/unreadable ⇒ diagnostic + inert until it appears;
no `shader` ⇒ inert.

| Key | Kinds | Default | Description |
| --- | --- | --- | --- |
| `kind` | all | required | `animation`, `border`, `window`, `screen`, `cursor` |
| `shader` | all | none | GLSL path, ≤ 256 KiB; without it the preset is inert |
| `palette` | all | `false` | Supply `[colors]` accent/status colors to the program |
| `padding` | border | `0` | Transparent space around the ring, 0–1024 |
| `speed` | border | `1.0` | Multiplier on `umbriel_time`, 0–10; `0` holds time at zero |
| `animated` | border | `true` | `false` freezes `umbriel_time` at zero |
| `overlay` | border | `""` | A window preset drawn on the window while the border effect applies |
| `light.spread` | border | `80` | Light spill from the ring, 1–256 logical px; defining `[...light]` enables light |
| `light.intensity` | border | `1.0` | Light gain, 0–4 |
| `light.threshold` | border | `0.5` | Ring brightness needed to emit, 0–1 |
| `radius` | cursor | `0` | Padding around pointer/path, 0–4096; `0` = whole output |

Border light is built from the ring in buffer pixels (brightness varies across output scales);
stacks below panels and pinned windows, above a dragged window. Namespace shared with pools: names
non-empty, not `off`, no `/` (which separates an action selector from its target). A colliding pool
is rejected while the preset stays valid. Keys foreign to the kind are reported unknown; the same
preset name in two files is an error.

```toml
[effects.preset.tint]
kind = "window"
shader = "tint.glsl"
palette = true

[effects]
window = "tint"
```

## Pools

A pool picks a stable preset per owner before its first rendered frame:

```toml
[effects.pool.borders]
kind = "border"
choose = ["pulse", "quiet"]
selection = "unused_first"

[effects]
border = "borders"
```

| Key | Meaning |
| --- | --- |
| `kind` | Required: `border`, `window`, `screen`, `cursor` (no animation pools) |
| `choose` | Required ordered array of preset names of that kind |
| `selection` | `unused_first` (default; least-held, ties in list order), `round_robin`, `random` |

Define/include member presets separately; definitions and references may sit in different included
files. Invalid/duplicate members drop individually (first valid kept); an empty pool is inert,
selectable, cannot cycle (`cycle` reports `pool is empty`); pools cannot contain pools. Accepted by
the four `[effects]` selectors, window rules' `border_effect` / `window_effect`, output
`screen_effect`, and matching runtime actions; animation bindings and border `overlay` stay
preset-only. Owners: each mapped window has independent border+window slots, each present output a
screen slot, the session one cursor slot. Holdings count only unsuppressed owners assigned from that
pool — hidden/scratchpad windows, unfocused borders, disabled outputs, and failed/inert programs
still hold; plain presets, other pools, overlays, and closing snapshots do not; visibility and
drawing gates do not allocate. Pool change: a valid remembered member for the destination wins, then
the current member if it belongs, then a fresh policy pick; a focus rule that changes the winning
selector resolves it; releasing a holding never redistributes other owners.

## Runtime selection

Sixteen `effect-*` actions (see `references/actions.md`) operate independently on the four slots:

```sh
umbriel msg effect-window-set scanlines
umbriel msg effect-border-cycle borders
umbriel msg effect-window-toggle
umbriel msg effect-window-reset
umbriel msg effect-screen-set vignette --output HDMI-A-1
umbriel msg effect-cursor-set glow
```

Window/border actions default to the focused window; screen actions use the preferred output.
`set`/`cycle` accept `--window <window-id>` or `--output <output>` (output names may contain
slashes); toggle/reset take a plain-word target; cursor actions take none. Explicit screen targets
can address present disabled outputs — their cached selection shows when enabled again.

- `set <name>` installs a runtime override, clears suppression, makes a fresh policy pick for a
  pool. `cycle [pool]` advances that pool (or the underlying current pool; a member absent from the
  requested pool uses its policy), installs an override, clears suppression; one-member pools cycle
  fine.
- `set off` suppresses without replacing the selector or losing history; repeating does nothing.
  `toggle` flips suppression when a member exists and can always unsuppress, even if a reload emptied
  the selection; toggling an empty unsuppressed slot succeeds without changing it. Suppression
  releases the holding and hides a border's overlay; rules/reloads keep updating the underlying
  selection while suppressed.
- `reset` clears override, suppression, history, and cached assignment, then resolves the
  configuration afresh. Runtime overrides beat rules and defaults; invalid names, kinds, targets,
  or payloads fail without changing state; a valid inert/failed program stays selected and renders
  plainly.
- Unrelated reloads and renderer recovery retain assignments; effects reloads prune invalid
  history, retain still-valid members, drop deleted/wrong-kind overrides with an owner-specific
  diagnostic, and preserve suppression. Unmap clears a window's state after copying closing visuals
  (remap fresh); output disable retains state, disconnect/reconnect starts fresh. Runtime state is
  never written to disk.

## Inspection

`umbriel effects` (and `--json`): presets with program states (`inert`, `unreferenced`, `failed`,
`compiled`), pools with exact hold counts, the cursor selection, and window/output owners (slots
report `name`, `pool`, `source` `default|rule|runtime`, `suppressed`; border slots add `overlay`).
Only reached pools compile their members; named keybinds and enabled hot corners prepare programs
before their first trigger, an IPC-only name compiles synchronously on first selection. Suppressed
runtime overrides remain roots; inactive pool history does not. Inspection never picks, compiles, or
binds; screen assignments are under `effects`, not `outputs`. `umbriel windows --json` and
`subscribe windows` include per-window `border_effect` / `window_effect`.

## Writing shaders

GLSL ES 1.00 fragment code without `#version`, `main`, or precision qualifiers. Entry point per
kind — `vec4 animation(vec2 uv)`, `vec4 border(vec2 uv)`, `vec4 window(vec2 uv)`, `vec4 screen(vec2
uv)`, `vec4 cursor(vec2 uv)`: `uv` normalized over the drawn rectangle, `(0,0)` top left; return
premultiplied RGBA.

| Name | Meaning |
| --- | --- |
| `umbriel_sample(vec2 uv)` | Input under the rectangle (captured window for animations, native ring for borders, on-screen pixels for window/screen/cursor) |
| `umbriel_sample_previous(vec2 uv)` | This effect's previous result (allocates two extra buffers per target) |
| `umbriel_size` | Drawn size in effect logical px, before overview zoom |
| `umbriel_scale` | Buffer px per effect logical px, incl. overview zoom |
| `umbriel_expand` | Fraction the rect extends past the window per side; non-zero only for an animation under drag physics |
| `umbriel_time` | Seconds on the animation clock × border `speed`; single-precision, never wrapped — fine motion loses precision after long uptimes (`sin`/`cos` reduce to one revolution, stay correct) |
| `umbriel_palette_count` / `umbriel_palette_at(float t)` | `4` for palette presets (wrapping accent_primary, accent_secondary, warning, error), `0` otherwise; transparent black without a palette |
| `umbriel_audio_spectrum(position)` | Interpolated spectrum intensity 0–1, or 0 without a feed (see below) |
| `umbriel_audio_available()` | `1` while the audio feed has fresh snapshots, else `0` |

Animations add `umbriel_progress`, `umbriel_clamped_progress`, `umbriel_linear_progress`,
`umbriel_direction`, `umbriel_random_seed`; workspace reveal shaders also read
`umbriel_sample_incoming(vec2 uv)`. Borders add `umbriel_border_hole` (client rect in uv),
`umbriel_border_radius` (corner radii, logical px), `umbriel_border_distance(vec2 uv)` (signed
logical px to the client rect, negative inside; the client hole is always cut out). Cursor effects
add `umbriel_pointer` (pointer position in uv), short `umbriel_pointer_history[8]` (oldest first;
position in uv, age in seconds, one reserved component; samples expire after 300 ms, ~32 ms spacing
while the newest tracks each motion event) and the 2-second `umbriel_pointer_path[64]` (same units;
4th component = stable birth phase wrapping every 60 s, useful for colour/particle seeds).
`umbriel_pointer_count` reports the active length of either. The drawn rectangle encloses the
samples plus `radius` padding — use `umbriel_size` for logical-px distances. History resets on
hide, output crossing, lock and program changes. Reading motion history requests frames only while
samples remain (no extra buffers); reading `umbriel_time` still requests continuous frames. `trail`
presets draw a Catmull-Rom curve through the samples, so fast circles stay round.

### Audio input

An external analyser (see `references/ipc.md`) supplies 64 bands, 0–1, lowest to highest.
`umbriel_audio_spectrum(position)` clamps to `[0,1]` and interpolates at `position * 63` (`0.0` =
lowest band). Band values are quantized to 8-bit before interpolation; the coordinate is normalized
low-to-high with no promised Hz centers/edges. Availability tracks fresh snapshots, including
all-zero input from silence or idle capture; all bands and availability are zero without a feed.
Bands are visual intensity, not calibrated loudness. Audio works without `umbriel_time` —
`animated` and `speed` only affect time. Changed input redraws visible consumers at `max_fps`;
identical input requests nothing. Each output holds its snapshot between eligible frames; all
passes of a composition, including closing copies, use that value.

### What a window effect sees

At rest, a window effect reads the output framebuffer after the window is drawn — through a
translucent window it sees and may rewrite the desktop behind it. While an animation encloses the
window (opening, closing, moving, a workspace switch, the overview, or drag physics) it reads that
animation's capture instead and shades the window's own content over the live desktop.
Backdrop-dependent shaders must tolerate the switch; a border's `overlay` follows the same rule.

### Reload and failures

Referenced presets compile at startup, on effects reload, and during runtime action preparation. A
compile error logs the preset name and driver message (line numbers from the shader file top); the
preset renders plainly until a reload fixes it — opening/closing animations keep their built-in
animation, `style` and `scale` included. Unknown or wrong-kind names are dropped with diagnostics: a
top-level selector selects nothing; a rule/output override falls back to an earlier matching rule
or the `[effects]` default. Shaders are trusted local GPU code — keep them small and side-effect
free.

## Cost

Unreferenced presets/pools add no work. Border effects: ring capture + one program pass per frame
on each window they draw (focused, or every decorated non-urgent non-fullscreen window with
`border_unfocused`); extra frames only while the program reads `umbriel_time` and its clock
advances, capped by `max_fps`. Light adds a second pass plus a blurred pyramid where the ring draws,
and a blend on every output the light reaches. Window effects: pixel copy + one pass per window per
frame. Screen/cursor effects: one pass over the output or radius square; both disable direct
scanout on that output. Drag physics costs only while a window is held or settling. With
`in_capture = false`, a pending screencopy or image-copy capture composes the frame twice whenever
any window/screen/cursor effect is visible on that output.
