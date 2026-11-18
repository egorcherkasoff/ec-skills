# Input

All under `[input]`.

```toml
[input]
middle_click_paste = false      # schema default: true
client_window_drag = true
window_drag_toggle = "none"    # "none" | "floating" | "pinned"
mod_right_double_click = "none"  # "none" | "maximize"
```

- `middle_click_paste = false` disables primary-selection paste (incl. Shift+Insert);
  Ctrl+C/V unaffected. Apps started while disabled need restarting after re-enabling.
- `client_window_drag = false` ignores app move requests (client-side title bars,
  Chromium/Firefox/Electron tab strips). Windows then move via Mod+drag, keybinds, or
  the Umbriel title bar. Client-side resize and `xdg-toplevel-drag-v1` tear-off unaffected.
- `window_drag_toggle`: the other main mouse button during a drag toggles the dropped
  window — `"floating"` tiled/floating, `"pinned"` pinned, `"none"` no change.
  Unsupported transitions (e.g. pinning fullscreen) leave the window unchanged.
- `mod_right_double_click = "maximize"`: a second Mod+right-click on the same window
  within 300 ms and 8 px toggles maximize (same target as a client titlebar
  double-click); the first click then starts resizing only after >8 px movement. A
  `Mod+MouseRight` keybind overrides the built-in button entirely.

## Window drag and resize behavior

- Umbriel title bar shown (`[appearance.title_bar]` or window rule): drag empty space
  moves without a modifier; double-click toggles maximize; presses keep the normal
  cursor until the pointer crosses 10 logical px from the press point (movement
  before an app move request counts). In tiled layouts a title-bar press focuses and
  reveals first; detaches only after the threshold.
- Floating windows resize by dragging frame edges/corners with the left button, no
  modifier — also individually floated windows in tiling layouts. Tiled windows use
  Mod+right-drag.
- Dropping a floating window settles into the usable area — it glides back until at
  least a quarter (10–75 logical px) is visible; nothing else moves a window already
  inside that margin. Dragging out of a region placement or maximize restores normal
  size under the pointer, title bar and content aligned; dropping on another monitor
  maps the restore position to it.
- Edge/corner drop zones: `layout.stacking.drop_zones` (default on in stacking);
  shared monitor edges need a 150 ms dwell before a zone is offered. Tiled, pinned,
  scratchpad, overview, data-device, and toplevel-transfer drags never use zones.
  `window-set-region` / `window-clear-region` work regardless of the pointer within
  stacking.

## Detached tabs and panels

`xdg-toplevel-drag-v1`: a detached tab/panel follows the pointer above ordinary
windows, outside tiling; windows underneath can receive the drop and merge/dock it;
if the app keeps the detached window, normal tiled/floating drag placement applies.
No configuration needed.

## Input capture

InputCapture portal via `xdg-desktop-portal-umbriel`: screen-edge activation,
keyboard + modifiers, pointer motion/buttons/scroll; **Ctrl+Alt+Escape** restores
local control; optional remembered approval via restore tokens; no clipboard, touch,
tablet, or gesture capture. See security reference for permission lifetimes.

## Keyboard

```toml
[input.keyboard]
layout = ""          # empty = system default; "us,de" for multiple
variant = ""
options = ""         # XKB options, e.g. "caps:escape", "compose:ralt", "grp:alt_shift_toggle"
model = ""
repeat_rate = 25     # 0–1000 Hz; 0 disables repeat
repeat_delay = 600   # 0–10000 ms
numlock_toggle = true  # docs example; schema default is false
track_layout = "global"  # "global" | "window"
```

- When none of `layout`/`variant`/`options`/`model` is set, Umbriel uses the X11 keymap
  from `localectl set-x11-keymap` (systemd-localed), read at startup and on every
  reload — `umbriel msg config-reload` applies a changed keymap. Without
  systemd-localed: `XKB_DEFAULT_*` env, then `us`. A `[[input.device]]` rule setting
  any of these keys uses only its own + `[input.keyboard]`'s values. Invalid
  layouts/variants/models log and fall back to the system default (`xkbcli list`
  inspects values). `umbriel keyboard-layouts` lists configured layouts (`*` = active).
- `keyboard-layout-next` (keybind or `umbriel msg`) cycles configured layouts on
  physical keyboards; virtual keyboards keep their app keymap. Held shortcut
  modifiers stay active until released even if another keyboard is idle.
- Lock state (Num/Caps/Scroll) is shared across physical keyboards, including uinput
  devices without LEDs (recorder hotkey helpers, mouse aux interfaces): toggling one
  updates the others before they process further input; ordinary keys from other
  devices don't change locks. Reloads preserve locks; an unchanged keymap also keeps
  held/latched state. New keyboards inherit current locks. `numlock_toggle` sets the
  initial state only — later user choices win over hotplug/reload.
- `track_layout = "window"` remembers the layout per focused surface; never-focused
  surfaces start on the first layout; reloading keyboard config clears the memory.

## Touchpad

```toml
[input.touchpad]
# enabled = true                 # schema default: true
tap = true
# tap_and_drag = false
# drag_lock = "sticky"           # "off" | "timeout" | "sticky"
natural_scroll = true
left_handed = false
# accel_profile = "adaptive"     # "flat" | "adaptive" | custom curve
# sensitivity = 0.5              # -1.0 to 1.0
# scroll_factor = 1.5            # 0.1–10.0, or { horizontal = 2.0, vertical = 1.5 }
# disable_while_typing = true
# disable_on_external_mouse = true
# scroll_method = "edge"         # "two_finger" | "edge" | "none"
# click_method = "clickfinger"   # "button_areas" | "clickfinger"
# tap_button_map = "left_middle_right"  # or "left_right_middle"
```

- Omitted values keep libinput defaults; explicit unsupported settings are logged.
  `tap_and_drag` keeps dragging after a tap while the finger stays down; `drag_lock`
  keeps it after the finger lifts (`"sticky"` = until next tap). `scroll_method`
  selects the scroll gesture for touchpad-class devices; devices support a subset
  (`libinput list-devices`), unsupported values are logged and ignored. A device rule
  setting `scroll_method` replaces that device's `scroll_button` scrolling (incl.
  lock); a rule setting `scroll_button` takes the device away from the
  `[input.touchpad]` gesture. Mice never inherit `[input.touchpad] scroll_method`.
- `scroll_factor` scales continuous two-finger app scrolling (per-axis form allowed);
  the `touchpad_scroll_factor` window rule scales it further per window. Overview
  navigation uses its own factors.

## Mouse

```toml
[input.mouse]
natural_scroll = false
left_handed = false
# accel_profile = "flat"         # omit = device default; custom: "custom 0.2 0.0 0.5 1.0 2.0"
sensitivity = 0.0               # -1.0 to 1.0
scroll_wheel_step = 60          # 1–1000 logical px per layout-scroll action
# scroll_button = "MouseBack"    # hold-to-scroll; MouseLeft/Right/Middle/Back/Forward
# scroll_button_lock = false     # press-toggle instead of hold
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
scroll_method = "edge"
click_method = "clickfinger"

[[input.device]]
name = "Acme Controller Touchpad"
enabled = false
```

Each rule inherits its class (keyboard/touchpad/mouse) settings and replaces only the
keys it contains (any class key works, e.g. mouse `accel_profile`/`sensitivity`).
`enabled = false` turns off any keyboard, touchpad, or mouse. Duplicate rules for the
same device name are rejected.

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

Precedence: focused window > focused output > `map_to_output`. `calibration_matrix`
is six floats passed to libinput.

## Touch

```toml
[input.touch]
enabled = true
map_to_output = "eDP-1"
```

Without `map_to_output`: the output the device reports, else the single built-in panel
(`eDP-`, `LVDS-`, `DSI-`) if exactly one is enabled, else the whole layout. A
touchscreen reports its output via the `WL_OUTPUT` udev property (connector name);
a udev rule can pin each touchscreen without the global setting:

```
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="1234", ATTRS{idProduct}=="5678", ENV{WL_OUTPUT}="DP-1"
```

## Cursor

```toml
[input.cursor]
theme = ""            # empty = environment default
size = 24             # 1–512 logical px
hardware_cursor = true
follows_focus = false
hide_when_typing = false
hide_timeout_ms = 0   # 0 disables; else 1–3600000 ms of inactivity
```

- `hardware_cursor = false` works around cursor flicker/disappearance.
- `follows_focus = true` moves the cursor to a newly focused window after
  keyboard-driven focus and transfer actions; keybind moves (move, swap, consume,
  `window-move-by`) move it to the window's center. New windows, activation requests,
  and replacement focus after a close do not move it; pointer-driven focus and
  gestures don't either. `window-focus-warp <id>` always warps. A cursor hidden by
  `hide_when_typing`/`hide_timeout_ms` stays hidden through these moves and reappears
  at the new position on next pointer activity. Active-workspace output swaps keep
  cursor + seat focus on the invoking output when `false`; when `true` both follow the
  previously focused window to its new output.

## Drag edge scroll

```toml
[input.drag_edge_scroll]
enabled = true        # false disables edge scrolling entirely
trigger_zone = 30     # 1–1000 logical px at each end
delay_ms = 100        # 0–10000; 0 = scroll on zone entry
max_speed = 1500.0    # 1.0–100000.0 logical px/s
```

While a data drag, a tiled window move (Mod+left-click / tab bar), or an overview
card drag is held near either end of a scrolling layout, the layout scrolls so
offscreen columns are reachable; overview rows also scroll at the workspace-axis ends,
carrying the card to a far workspace. Speed ramps from zero at the zone's inner edge
to `max_speed` at the layout's outer edge; zones clamp to half the viewport.

## Focus

```toml
[input.focus]
follows_mouse = "off"        # "off" | "sloppy" | "always"
follows_mouse_max_scroll = 0.5  # viewport widths the layout may scroll to reveal the target; 0.0 = only fully visible; omit = no limit
hover_raises = true
```

- `off` (default): only clicks, keybinds, and activation move focus.
- `sloppy`: pointer motion onto a window focuses it; focus given elsewhere (keybind,
  new window, activation) stays while the pointer remains over its window. After
  layout scrolling, a layout command, a workspace switch, or leaving fullscreen puts
  a different window beneath a still pointer, the next real motion focuses it
  without a border crossing.
- `always`: every real pointer motion focuses the window beneath, even inside the
  current window; after the layout settles (switch, close/minimize, layout command,
  scrolling, leaving fullscreen) the window under a still pointer is focused too,
  without scrolling to reveal it.
- Follows the actual seat focus across tiled, floating, and pinned windows (incl.
  pinned windows that kept focus across a workspace switch). Scrolling or dragging
  under a stationary pointer never changes focus; pointer motion during scrolling
  doesn't either.
- A focused dialog keeps focus while the pointer moves within its parent, so the
  pointer can reach it; crossing back from another window, clicking, or a focus
  command still transfers to the parent. Same with either `hover_raises` value.
- `hover_raises = false` narrows hovering to focus alone — the entered window is not
  raised above neighbors; clicks/keybinds/activation still raise. Only matters when
  `follows_mouse` is not `off`.
- Client pointer/keyboard grabs (open tray menu) survive hovering and output crossing;
  an outside click or explicit focus can still dismiss them.
- X11 `Input=False` without `WM_TAKE_FOCUS` (e.g. Steam OSK): receive pointer input
  without taking keyboard focus; skipped for replacement focus after a close.
  `_NET_WM_WINDOW_TYPE_NOTIFICATION` windows never take keyboard focus.

## Controller desktop input

Steam's desktop controller mappings drive native Wayland windows through Umbriel's
X11 input emulation; permission is asked on first request and remembered for the
session. See the security reference for consent and lock-screen behavior.
