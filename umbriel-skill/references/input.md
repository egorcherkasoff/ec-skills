# Input

All under `[input]`.

```toml
[input]
middle_click_paste = false
client_window_drag = true
window_drag_toggle = "none"
```

- `middle_click_paste = false` disables primary-selection paste (incl. Shift+Insert);
  Ctrl+C/V unaffected. Apps started while disabled need restarting after re-enabling.
- `client_window_drag = false` ignores app move requests (client-side title bars,
  Chromium/Firefox/Electron tab strips). Windows then move via Mod+drag or keybinds only.
  Client-side resize unaffected.
- `window_drag_toggle`: what the other main mouse button does during a window drag —
  `"none"`, `"floating"` (toggle tiled/floating on drop), `"pinned"` (toggle pinned).

## Keyboard

```toml
[input.keyboard]
layout = ""          # empty = system default; "us,de" for multiple
variant = ""
options = ""         # XKB options, e.g. "caps:escape", "compose:ralt", "grp:alt_shift_toggle"
model = ""
repeat_rate = 25     # 0–1000 Hz; 0 disables repeat
repeat_delay = 600   # 0–10000 ms
numlock_toggle = true
track_layout = "global"  # or "window"
```

- Invalid layouts/variants/models fall back to system default with a log entry.
  `xkbcli list` inspects values.
- `track_layout = "window"` remembers the layout per focused surface; unfocused-new
  surfaces start on the first layout; reloading keyboard config clears remembered layouts.
- `keyboard-layout-next` action cycles layouts on physical keyboards (virtual keyboards
  keep their app keymap). `umbriel keyboard-layouts` lists configured layouts (`*` = active).

## Touchpad

```toml
[input.touchpad]
tap = true
natural_scroll = true
left_handed = false
# accel_profile = "adaptive"        # "flat", "adaptive", or custom curve
# sensitivity = 0.5                 # -1.0 to 1.0
# scroll_factor = 1.5               # 0.1 to 10.0; or { horizontal = 2.0, vertical = 1.5 }
# disable_while_typing = true
# disable_on_external_mouse = true
# click_method = "clickfinger"      # "button_areas" | "clickfinger"
# tap_button_map = "left_middle_right"  # or "left_right_middle"
```

Omitted values keep libinput defaults. `scroll_factor` affects continuous two-finger app
scrolling (overview uses its own factors).

## Mouse

```toml
[input.mouse]
natural_scroll = false
left_handed = false
# accel_profile = "flat"            # omit = device default; custom: "custom 0.2 0.0 0.5 1.0 2.0"
sensitivity = 0.0                   # -1.0 to 1.0
scroll_wheel_step = 60              # 1–1000 logical px per layout-scroll action
# scroll_button = "MouseBack"       # hold-to-scroll; MouseLeft/Right/Middle/Back/Forward
# scroll_button_lock = false        # press-toggle instead of hold
```

`scroll_wheel_step` affects layout scroll actions, not application scrolling.

## Per-device overrides

Match the case-sensitive `Device` name from `libinput list-devices`:

```toml
[[input.device]]
name = "Acme Split Keyboard"
layout = "us"
variant = "colemak_dh"
model = "pc104angle"
repeat_rate = 40
repeat_delay = 250

[[input.device]]
name = "Acme Precision Touchpad"
tap = true
natural_scroll = false
left_handed = false
click_method = "clickfinger"

[[input.device]]
name = "Acme Gaming Mouse"
accel_profile = "flat"
sensitivity = 0.0
```

Each rule inherits its class (keyboard/touchpad/mouse) settings and replaces only the
keys it contains. Duplicate rules for the same device name are rejected.

## Tablet

```toml
[input.tablet]
enabled = true
map_to_output = "DP-1"
map_to_focused_output = false
map_to_focused_window = false
left_handed = false
calibration_matrix = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0]
```

Precedence: focused window > focused output > `map_to_output`.

## Touch

```toml
[input.touch]
enabled = true
map_to_output = "eDP-1"
```

Without `map_to_output`: the output the device reports, else the single built-in panel
(`eDP-`, `LVDS-`, `DSI-`) if exactly one is enabled, else the whole layout.

## Cursor

```toml
[input.cursor]
theme = ""            # empty = environment default
size = 24             # 1–512 logical px
hardware_cursor = true
follows_focus = false
hide_when_typing = false
hide_timeout_ms = 0   # 0 disables; else 1–3600000
```

- `hardware_cursor = false` works around cursor flicker/disappearance.
- `follows_focus = true` warps the cursor on keyboard-driven focus changes (not pointer
  focus, gestures, or replacement focus). `window-focus-warp <id>` always warps.
- Active-workspace output swaps keep cursor+focus on the invoking output when false.

## Drag edge scroll

```toml
[input.drag_edge_scroll]
enabled = true
trigger_zone = 30    # 1–1000 logical px at each end
delay_ms = 100       # 0–10000
max_speed = 1500.0   # 1.0–100000.0 logical px/s
```

During a data drag or tiled window move (Mod+left-click / tab bar) held near either end
of a scrolling layout, the strip scrolls to reach offscreen columns. Speed ramps from
zero at the zone's inner edge to `max_speed` at the layout's outer edge. Zone clamps to
half the viewport.

## Focus

```toml
[input.focus]
follows_mouse = false
follows_mouse_max_scroll = 0.5
```

- `follows_mouse = true`: pointer motion into a window focuses it (tiled, floating,
  pinned incl. cross-workspace). Scrolling/dragging under a stationary pointer doesn't.
- `follows_mouse_max_scroll`: how far the layout may scroll to reveal the window, in
  viewport widths. `0.0` = only fully visible windows; omit = no limit.
