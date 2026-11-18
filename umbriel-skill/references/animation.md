# Animation

Settings under `[animation]`. Top-level values are defaults; each event table overrides them.

```toml
[animation]
enabled = true
duration_ms = 250
curve = "easeout"

[animation.windows_in]
enabled = true
curve = "spring:1,900"
style = "popin"
scale = 0.5

[animation.windows_out]
enabled = true
curve = "spring:1,1400"
style = "popin"
scale = 0.8

[animation.windows_move]
enabled = true
curve = "spring:1,800"

[animation.windows_resize]
enabled = true
curve = "spring:1,900"

[animation.windows_opacity]
enabled = true
curve = "spring:1,900"

[animation.workspaces]
style = "slide"
enabled = true
curve = "spring:1,800"

[animation.overview]
enabled = true
curve = "spring:1,800"
workspace_curve = "spring:1,1000"

[animation.scratchpad]
enabled = true
curve = "spring:1,800"
dim = 0.8
blur = false

[animation.dialogs]
enabled = true
dim = 0.3

[animation.border]
enabled = true
curve = "spring:1,900"

[animation.dim_unfocused]
enabled = false
dim = 0.0

[animation.layers]
enabled = false
```

## Event tables

| Table | Additional fields | Transition |
| --- | --- | --- |
| `[animation.windows_in]` | `style`, `scale` | Window opening |
| `[animation.windows_out]` | `style`, `scale` | Window closing |
| `[animation.windows_move]` | none | Position during moves, reflow, maximize, restore |
| `[animation.windows_resize]` | `wait_for_redraw`, no `effect` | Size during the same changes |
| `[animation.windows_opacity]` | none, no `effect` | Focus changes to window-rule opacity and backdrop blur |
| `[animation.workspaces]` | `style` | Workspace switching |
| `[animation.overview]` | `workspace_curve` | Overview open/close and filmstrip movement |
| `[animation.scratchpad]` | `dim`, `blur` | Scratchpad show/hide and its backdrop |
| `[animation.dialogs]` | `dim`, no `effect` | Shade over a window while a modal dialog is attached |
| `[animation.border]` | none | Focus-border color |
| `[animation.dim_unfocused]` | `dim` | Unfocused-window opacity |
| `[animation.layers]` | none | Layer-shell map/unmap |
| `[animation.windows_drag]` | `physics` plus drag-physics keys below | Drag physics |

- Every event except `windows_drag` accepts `enabled` (default `true`; `dim_unfocused` and `layers` default `false`), `duration_ms` (1–10000), `curve`.
- A spring curve picks its own duration — `duration_ms` has no effect for that event.
- `windows_in` styles: `popin`, `zoom`, `slide`, `fade`, `none`; `windows_out`: `fade`, `slide`, `popin`, `zoom`.
- `scale` (0.1–1.0) applies to `popin`: an opening window grows from it, a closing window shrinks toward it, both fade.
- `windows_move` moves while `windows_resize` sizes — a slow move can resize quickly. While the size animates, the latest frame is stretched to fit; with `windows_resize` disabled the size changes at once while the window still moves. Differing timelines can briefly overlap neighbours during a reflow. Borders/shadows follow the layout size even before the app redraws; a tiled window settling smaller than its tile (e.g. a terminal sized to whole character cells) leaves a transparent strip inside its border.
- `overview.workspace_curve` controls filmstrip movement after wheel/keyboard/touchpad navigation. A released touchpad gesture keeps finger speed when its curve is a spring — `[animation.workspaces]` for the three-finger switch, `[animation.overview]` for the four-finger open/close, `workspace_curve` for the filmstrip; any other curve starts from rest.
- Scratchpad `dim` (opacity of the black layer over the output behind a visible scratchpad) and `blur` (blurs it when `[appearance.blur]` is enabled) stay active without a fade when animation is disabled.
- Dialogs `dim` (0.0–1.0, default `0.3`): opacity of the black shade over a window while a modal dialog is attached; fades in/out with attach/detach, stays without a fade when animation is disabled.
- With `windows_out` disabled, a closing tiled window's last frame stays until the switch — the wallpaper never shows in the space it leaves.

## wait_for_redraw

```toml
[animation.windows_resize]
enabled = false
wait_for_redraw = true
```

`wait_for_redraw` (default `false`) turns a layout change that resizes windows into a single switch: every window keeps appearing as it was (a newly opened window not yet visible) until each resized window has redrawn — at its new size or a nearby size it picks itself, as terminals sizing to whole character cells do — then all windows appear in their final place and size in the same frame, without moving there. Layout changes that only move windows still animate with `windows_move`. Mouse tile resize works the same way, one step at a time: each step waits for resized windows to redraw before following the pointer, so the edge may trail a fast drag, but no frame is stretched. A slow or unresponsive client is waited for at most 150 ms; then the switch happens anyway and that window's frame is stretched until it redraws. Only applies while the size does not animate: with `windows_resize` or all animation disabled.

## Window opacity

`[animation.windows_opacity]` fades between the opacity and window/title-bar blur defined by window rules when focus changes. Enabled by default with the same timing as `[animation.border]`: `curve = "spring:1,900"`, 250 ms fallback for duration-based curves. Top-level `duration_ms`/`curve` supply defaults; each table overrides independently.

```toml
[animation.windows_opacity]
enabled = true
duration_ms = 200
curve = "easeinoutcubic"
```

`enabled = false` → immediate focus changes. With a non-spring curve, `duration_ms` sets the fade length; a spring derives its own. Refocusing mid-fade starts from the current appearance. Border colors keep using `[animation.border]`; disabling that table does not disable opacity or blur fades. `[animation.dim_unfocused]` adds its own opacity multiplier independently of window rules.

## Curves

Built-ins: `linear`, `ease`, `easeout`, `snappy`, `bounce`, `elastic`. Or:

```toml
curve = "0.05,0.9,0.1,1.0"   # cubic Bézier; x coords must be 0–1
curve = "spring:1,1000"       # spring:<damping>,<stiffness>
```

Spring behavior: damping < 1 overshoots; = 1 no overshoot; > 1 slower approach. Greater stiffness settles faster.

Reusable named curves:

```toml
[animation.beziers]
myBezier = [0.05, 0.9, 0.1, 1.05]

[animation.springs]
myBounce = { damping = 0.5, stiffness = 200 }
```

Then `curve = "myBezier"` / `"myBounce"`. Schema ranges: named-spring damping 0.01–5.0, stiffness 1.0–10000.0.

## Custom effects

Any event except `windows_drag` can run a custom program: define/select an `animation` preset with `effect`. The event's `enabled`/`duration_ms`/`curve` still own the timeline. Umbriel ships `reveal`, `squash`, and `workspace_wipe`:

```toml
[include]
files = [
  "/usr/share/umbriel/effects/animation/reveal/effect.toml",
  "/usr/share/umbriel/effects/animation/squash/effect.toml",
]

[animation.windows_in]
duration_ms = 300
curve = "easeout"
effect = "reveal"

[animation.windows_out]
duration_ms = 250
curve = "easeout"
effect = "reveal"

[animation.windows_move]
effect = "squash"
```

- `windows_in`/`windows_out` without an effect keep their built-in fade and `style`; with an effect selected, `style` and `scale` are ignored.
- A running event keeps its program; a reload affects the next event.
- `windows_resize`, `windows_opacity`, and `dialogs` accept no `effect` (schema agrees).
- Adjust `/usr` for the package prefix. Writing presets/shaders and reload behavior: see `references/effects.md`.

### Animation uniforms

| Name | Meaning |
| --- | --- |
| `umbriel_progress` | Eased progress, including overshoot |
| `umbriel_clamped_progress` | Eased progress clamped 0–1 |
| `umbriel_linear_progress` | Progress before easing |
| `umbriel_direction` | `1` entering, `-1` leaving |
| `umbriel_random_seed` | Four stable random values for the transition |

### Targets

`windows_in`/`windows_out`/`windows_move`/`dim_unfocused` process the window + subsurfaces as one target; `border` the ring alone; `scratchpad` the show/hide fade plus dim/blur backdrops; `layers` a layer surface's own tree; `workspaces`/`overview` whole workspace or overview trees (they see the results of inner effects). Effects composite descendants before ancestors.

## Drag physics

```toml
[animation.windows_drag]
physics = true
stiffness = 36.0
damping = 6.5
coupling = 100.0
pointer_response = 2.0
max_displacement_px = 200.0
settle_after_pause_s = 0.25
```

With drag physics on, the dragged window bends like an elastic sheet pinned under the pointer, trails its motion, and settles when released or held still. Needs the animation master switch. Border, window, and overlay effects keep rendering on the deformed window; a window closed mid-drag keeps its shape while fading. Re-grabbing while settling continues the motion. Only the window's own content deforms; the drop shadow follows within the window's shadow bounds. Under `popin`/`zoom` closing styles, the closing snapshot's clip grows by the deformation margin, so a CSD extending past geometry can remain visible while it fades.

| Key | Default | Range | Effect |
| --- | --- | --- | --- |
| `stiffness` | 36.0 | 1.0–10000.0 | How strongly each point returns to rest |
| `damping` | 6.5 | 1.0–100.0 | Wobble decay; low = springy |
| `coupling` | 100.0 | 0.0–10000.0 | Rigidity between neighbouring points; low = jelly-like |
| `pointer_response` | 2.0 | 0.0–10.0 | How far pointer motion loads the sheet; 0 = rigid |
| `max_displacement_px` | 200.0 | 1.0–4000.0 | Excursion cap, logical px |
| `settle_after_pause_s` | 0.25 | 0.1–5.0 | Rendering pause after which the sheet snaps back; ordinary frames never trigger it at any refresh rate |

Out-of-range values are clamped to their range with a logged diagnostic and apply from the next drag.

## Workspace reveal

`animation.workspaces.style` accepts `"slide"` (default) or `"reveal"`. Reveal keeps both workspaces at their resting positions while an animation shader combines two full-output scenes (wallpaper, windows, decorations, shell surfaces). Application content stays live, including during workspace swipes; native navigation still controls focus, direction, and settling.

```toml
[include]
files = ["/usr/share/umbriel/effects/animation/workspace_wipe/effect.toml"]

[animation.workspaces]
style = "reveal"
effect = "workspace_wipe"
enabled = true
duration_ms = 300
curve = "easeout"
```

Reveal requires an animation preset with a shader; a missing or invalid selection produces a configuration diagnostic and uses slide. Shader compilation failures are reported by the effect registry. If reveal composition fails, navigation resumes native slide at the current progress. Disabling workspace animation ends the transition. `effects.in_capture` still controls persistent window/screen effects in captures; the workspace transition itself remains visible.

Reveal shaders use output-wide UVs: `umbriel_sample(uv)` = outgoing scene, `umbriel_sample_incoming(uv)` = incoming scene; return the final scene pixel — e.g. `mix(umbriel_sample(uv), umbriel_sample_incoming(uv), umbriel_clamped_progress)` crossfades. A shader reading only `umbriel_sample` shows only the outgoing scene. `umbriel_sample_previous` reads this effect's previous result.
