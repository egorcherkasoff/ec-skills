# Animation

Settings under `[animation]`. Top-level values are defaults; each event overrides them.

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
curve = "spring:1,900"

[animation.workspaces]
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
scale = 0.0
maximize = false
fullscreen = false

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
| `[animation.windows_move]` | none | Move, resize, reflow, maximize, restore |
| `[animation.workspaces]` | none | Workspace switching |
| `[animation.overview]` | `workspace_curve` | Overview open/close and filmstrip |
| `[animation.scratchpad]` | `dim`, `blur`, `scale`, `maximize`, `fullscreen` | Scratchpad windows and backdrop |
| `[animation.border]` | none | Focus-border color |
| `[animation.dim_unfocused]` | `dim` | Unfocused-window opacity |
| `[animation.layers]` | none | Layer-shell map/unmap |
| `[animation.windows_drag]` | `physics` (default `false`), its only key | Drag physics |

- Every event except `windows_drag` also accepts `enabled`, `duration_ms`, `curve`.
- A spring curve picks its own duration — `duration_ms` has no effect for that event.
- `windows_in` styles: `popin`, `zoom`, `slide`, `fade`, `none`.
  `windows_out` styles: `fade`, `slide`, `popin`, `zoom`.
- `scale` applies to `popin`: opening grows from it, closing shrinks toward it, both fade.
- `overview.workspace_curve` controls filmstrip movement after wheel/keyboard/touchpad
  navigation. A released touchpad gesture keeps finger speed when its curve is a spring.
- Scratchpad `dim`/`blur` stay active without a fade when animation is disabled;
  `scale`, `maximize`, `fullscreen` set the stored-window presentation.

## Curves

Built-ins: `linear`, `ease`, `easeout`, `snappy`, `bounce`, `elastic`. Or:

```toml
curve = "0.05,0.9,0.1,1.0"      # cubic Bézier; x coords must be 0–1
curve = "spring:1,1000"          # spring:<damping>,<stiffness>
```

Spring behavior: damping < 1 overshoots; = 1 no overshoot; > 1 slower approach.
Higher stiffness settles faster.

Reusable named curves:

```toml
[animation.beziers]
myBezier = [0.05, 0.9, 0.1, 1.05]

[animation.springs]
myBounce = { damping = 0.5, stiffness = 200 }
```

Then `curve = "myBezier"` or `curve = "myBounce"`.

## Custom effects

Any event except `windows_drag` can run a custom program: define/select an `animation`
preset with `effect`. Event `enabled`/`duration_ms`/`curve` still own the timeline.
Umbriel ships `reveal` and `squash`:

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

- With an effect selected, `style` and `scale` are ignored.
- A running event keeps its program; reload affects the next event.
- Writing presets/shaders: see `references/effects.md`.

### Animation uniforms (in shaders)

| Name | Meaning |
| --- | --- |
| `umbriel_progress` | Eased progress, including overshoot |
| `umbriel_clamped_progress` | Eased progress clamped 0–1 |
| `umbriel_linear_progress` | Progress before easing |
| `umbriel_direction` | `1` entering, `-1` leaving |
| `umbriel_random_seed` | Four stable random values for the transition |

### Targets

`windows_in`/`windows_out`/`windows_move`/`dim_unfocused` process the window + subsurfaces
as one target; `border` the ring alone; `scratchpad` the show/hide fade plus dim/blur
backdrops; `layers` a layer surface's own tree; `workspaces`/`overview` whole trees (they
see inner-effect results). Effects composite descendants before ancestors.

## Drag physics

```toml
[animation.windows_drag]
physics = true
```

The dragged window bends like an elastic sheet pinned under the pointer, trails, and
settles when released or held still. Requires the animation master switch. Border/window/
overlay effects keep rendering on the deformed window; a window closed mid-drag keeps its
shape while fading. Re-grabbing while settling continues the motion. Under `popin`/`zoom`
closing styles, the closing snapshot's clip grows by the deformation margin so a CSD
extending past geometry can remain visible.
