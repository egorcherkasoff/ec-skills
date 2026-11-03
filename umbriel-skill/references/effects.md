# Effects

GLSL programs run on animation events, the focused window's border, on windows, whole
outputs, and around the pointer. Every effect is off until selected.

## Bundled effects

Install under `share/umbriel/effects/<kind>/<name>/`. Include a preset's `effect.toml`,
then select it — including alone only registers the preset:

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

If `[include]` / `[effects]` tables already exist, append to their arrays / add keys to
the existing tables instead of repeating them. Adjust `/usr` for the package prefix.

| Preset | Kind | Selector |
| --- | --- | --- |
| `reveal` | animation | `[animation.windows_in] effect` (also `windows_out`) |
| `squash` | animation | `[animation.windows_move] effect` |
| `pulse` | border | `[effects] border` |
| `audio` | border | `[effects] border`; brightness follows external audio level |
| `scanlines` | window | `[effects] window` |
| `vignette` | screen | `[effects] screen` |
| `glow` | cursor | `[effects] cursor` |
| `trail` | cursor | Noctalia-inspired purple/lavender/moon-yellow motion tail |
| `trail-path` | cursor | Two-second curved tail colored along its length |

## Selectors and per-target overrides

```toml
[effects]
border = "pulse"
window = ""          # "" selects nothing
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
| `border` | `""` | Border preset/pool for the focused window |
| `window` | `""` | Window preset/pool for every window |
| `screen` | `""` | Screen preset/pool for every output |
| `cursor` | `""` | Cursor preset/pool, session-wide (no per-window/output override) |
| `max_fps` | `0` | 0–240 cap for effect-only frames; `0` = follow refresh rate |
| `in_capture` | `false` | Include window/screen/cursor effects in screencopy and image-copy captures (border effects always appear; export-dmabuf always sees the display frame) |

Where each kind draws:

- **animation** — via `[animation.<event>] effect`; the event owns the timeline.
- **border** — on the focused window's ring while decorated, not fullscreen, not urgent.
  `padding` reserves transparent space around the ring.
- **window** — over each window in place regardless of focus (incl. undecorated,
  fullscreen), following it everywhere. A floating CSD window with `corner_radius = 0`
  also gets its transparent margin shaded.
- **screen** — over the whole output after everything except the cursor effect and
  software cursor.
- **cursor** — in a square of `radius` logical px around the pointer (`0` = whole output),
  on the pointer's output only, clipped at edges; never shades the cursor image or affects
  a hardware cursor; hides with the pointer. Motion-history shaders expand the rect over
  the retained path plus `radius` padding.

Session lock detaches screen and cursor effects.

## Presets

`[effects.preset.<name>]` — `kind` required, `shader` is a GLSL file relative to the TOML
file naming it. The shader file is watched; missing/unreadable ⇒ inert preset with
diagnostic. Presets and pools share a namespace; names non-empty, not `off`, no `/`.

| Key | Kinds | Default | Description |
| --- | --- | --- | --- |
| `kind` | all | required | `animation`, `border`, `window`, `screen`, `cursor` |
| `shader` | all | none | GLSL path, ≤ 256 KiB; without it the preset is inert |
| `palette` | all | `false` | Supply `[colors]` accent/status colors to the program |
| `padding` | border | `0` | Transparent space around ring, 0–1024 |
| `speed` | border | `1.0` | Multiplier on `umbriel_time`, 0–10; `0` holds time at zero |
| `animated` | border | `true` | `false` freezes `umbriel_time` at zero |
| `overlay` | border | `""` | A window preset drawn on the window while the border applies |
| `light.spread` | border | `80` | Light spill from the ring, 1–256 logical px; defining `[...light]` enables light |
| `light.intensity` | border | `1.0` | 0–4 |
| `light.threshold` | border | `0.5` | Ring brightness needed to emit, 0–1 |
| `radius` | cursor | `0` | Padding around pointer/path, 0–4096; `0` = whole output |

Border light is built from ring buffer pixels (brightness varies across output scales);
stacks below panels and pinned windows, above a dragged window.

Example custom preset:

```toml
[effects.preset.tint]
kind = "window"
shader = "tint.glsl"
palette = true

[effects]
window = "tint"
```

Unknown keys for a kind are reported; same preset name in two files is an error.

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
| `kind` | `border`, `window`, `screen`, `cursor` (no animation pools) |
| `choose` | Required ordered array of preset names of that kind |
| `selection` | `unused_first` (least-held, ties in list order), `round_robin`, `random` |

- Define/include member presets separately. Invalid/duplicate members drop individually
  (first valid occurrence kept). Empty pool = inert, selectable, cannot cycle.
- Pools accepted by `[effects]` selectors, window rules, output `screen_effect`, runtime
  actions. Animation bindings and border `overlay` stay preset-only.
- Owners: each mapped window has independent border+window slots; each present output a
  screen slot; the session one cursor slot. Holds count unsuppressed owners from that pool
  (hidden/scratchpad windows, unfocused borders, disabled outputs, failed programs still hold).

## Runtime selection

Sixteen `effect-*` actions (see `references/actions.md`) operate on the four slots:

```sh
umbriel msg effect-window-set scanlines
umbriel msg effect-border-cycle borders
umbriel msg effect-window-toggle
umbriel msg effect-window-reset
umbriel msg effect-screen-set vignette --output HDMI-A-1
umbriel msg effect-cursor-set glow
```

Semantics: `set <name>` installs a runtime override, clears suppression, fresh policy
pick for a pool. `cycle [pool]` advances the pool (or the current underlying pool),
installs override, clears suppression. `set off` suppresses without forgetting the
selection; `toggle` flips suppression; `reset` clears override, suppression, history, and
cached assignment. Runtime overrides beat rules and defaults. Runtime state is not
written to disk; unmap/output-reconnect starts fresh; unrelated reloads retain
assignments; effects reloads prune invalid history and wrong-kind overrides.

## Inspection

`umbriel effects` (and `--json`): `presets` (state: `inert`, `unreferenced`, `failed`,
`compiled`), `pools` (policy, ordered members with hold counts), `cursor`, `owners`
(windows sorted by id, then outputs by name; slots report `name`, `pool`, `source`
`default|rule|runtime`, `suppressed`; border slots add `overlay`). Inspection never
compiles or binds. `umbriel windows --json` exposes per-window `border_effect` /
`window_effect`.

## Writing shaders

GLSL ES 1.00 fragment code without `#version`, `main`, or precision qualifiers. Entry
point per kind: `vec4 animation(vec2 uv)`, `vec4 border(vec2 uv)`, `vec4 window(vec2 uv)`,
`vec4 screen(vec2 uv)`, `vec4 cursor(vec2 uv)` — `uv` normalized over the drawn rectangle,
`(0,0)` top left; return premultiplied RGBA.

Available everywhere:

| Name | Meaning |
| --- | --- |
| `umbriel_sample(vec2 uv)` | Input under the rectangle (captured window for animations, native ring for borders, on-screen pixels for window/screen/cursor) |
| `umbriel_sample_previous(vec2 uv)` | This effect's previous result (allocates two extra buffers per target) |
| `umbriel_size` | Drawn size in effect logical px, before overview zoom |
| `umbriel_scale` | Buffer px per effect logical px, incl. overview zoom |
| `umbriel_expand` | Fraction the rect extends past the window; non-zero only for animation under drag physics |
| `umbriel_time` | Seconds on the animation clock × border `speed`; float precision never wraps |
| `umbriel_palette_count` / `umbriel_palette_at(float t)` | `4` for palette presets (wrapping accent_primary, accent_secondary, warning, error), `0` otherwise |
| `umbriel_audio_level()` / `umbriel_audio_available()` | External audio 0–1 / freshness (see IPC audio feed) |

Animations add `umbriel_progress`, `umbriel_clamped_progress`, `umbriel_linear_progress`,
`umbriel_direction`, `umbriel_random_seed`. Borders add `umbriel_border_hole`,
`umbriel_border_radius`, `umbriel_border_distance(vec2 uv)` (signed logical px to the
client rect; the client hole is always cut out). Cursor effects add `umbriel_pointer`
(uv), short `umbriel_pointer_history[8]` (pos, age s, reserved; samples expire 300 ms,
~32 ms spacing), and the 2-second `umbriel_pointer_path[64]` (4th component = stable
birth phase wrapping every 60 s) with `umbriel_pointer_count` for either variant.

At rest a window effect reads the output framebuffer after the window is drawn (sees the
desktop through transparency); while an animation encloses the window it reads that
capture instead. Backdrop-dependent shaders must tolerate the switch.

Failures: compile errors log with preset name + driver message (line numbers from the
shader file top); the preset renders plainly until a reload fixes it. Unknown or
wrong-kind names are dropped with diagnostics; rule/output overrides fall back to earlier
rules or the `[effects]` default.

## Cost notes

Unreferenced presets/pools cost nothing. Border effects: capture + one pass per frame on
the focused window (extra frames only while `umbriel_time` advances, capped by `max_fps`);
light adds a pass plus a blurred pyramid and blends. Window effects: copy + pass per
window per frame. Screen/cursor effects: one pass and disable direct scanout on that
output. With `in_capture = false`, a pending capture composes the frame twice when effects
are visible.
