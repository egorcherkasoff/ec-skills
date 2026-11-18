# Workspaces Overview

The overview displays every workspace and lets you navigate, focus, close, and move
windows. Open with `Mod+O` (default) or an overview action such as `overview-toggle`. See
[workspaces.md](workspaces.md) for workspace models, selectors, and rules.

## Settings

```toml
[overview]
zoom = 0.5
scroll_factor_horizontal = 1.0
scroll_factor_vertical = 1.0
background_blur = true
workspace_wallpaper = true
shortcuts = true
shortcut_keys = "1234567890"
```

| Key | Default | Description |
| --- | --- | --- |
| `zoom` | `0.5` | Workspace preview scale, 0.1-0.75. |
| `scroll_factor_horizontal` | `1.0` | Horizontal gesture/wheel sensitivity, 0.1-10.0. |
| `scroll_factor_vertical` | `1.0` | Vertical gesture/wheel sensitivity, 0.1-10.0. |
| `background_blur` | `true` | Blur the desktop behind the overview; uses `[appearance.blur]`. |
| `workspace_wallpaper` | `true` | Show each output's background inside its workspace previews. |
| `shortcuts` | `true` | Show and accept keyboard shortcut badges. |
| `shortcut_keys` | `"1234567890"` | Preferred badge keys; at least two unique printable ASCII characters. |

Preview backgrounds use `colors.overview.workspace_background` when wallpaper mirroring is
disabled or no background surface is available.

## Open and navigate

Opening the overview temporarily hides scratchpads and pinned windows.

- Click a window to focus it and close the overview; middle-click a window to close it.
- Wheel navigates vertically; Shift+wheel horizontally. A four-finger swipe opens or closes
  the overview.
- Two-finger scrolling and three-finger swipes navigate continuously: movement along the
  output's workspace axis moves between workspaces; movement across it pans a scrolling
  workspace preview. Dwindle and master layouts have no strip to pan.
- While a window card drag is held, scrolling stays live and both dimensions use the same
  mechanic: two-finger travel pans the layout strip across the workspace axis and the
  workspace rows along it; holding the card near a screen edge slides whichever dimension
  runs toward it via drag edge scroll (the strip at its ends, the rows at theirs). The rows
  never step to another workspace under the hold; releasing drops the window on the
  workspace under the pointer, which then becomes active.
- Touchpad `natural_scroll` controls gesture direction. The horizontal/vertical overview
  factors adjust gesture distance and wheel sensitivity without changing application
  scrolling.

## Window action target

One card carries the full focused-border color while the overview is open; it is the target
for focus, close, and other window actions. Each other workspace keeps a fainter marker on
the card that will receive focus when it is selected. The current output follows the cursor;
output-changing actions move the cursor to their destination as usual.

## Keyboard

- Normal `[keybinds]` remain active in the overview: directional focus actions select
  neighboring cards; workspace or output actions keep their normal fallback behavior.
- Shortcut badges provide direct, unmodified key sequences for visible window cards; when
  there are more cards than keys, multi-key labels are created. Backspace removes the last
  key from a pending sequence; Escape clears a pending sequence first and only closes the
  overview when none is pending. A normal keybind takes precedence over a badge;
  `shortcuts = false` disables badges.

## Move windows

Drag a window onto another workspace preview to move it. In a dynamic workspace list,
dropping into a gap creates a workspace at that position; static inventories accept drops
only onto existing previews. The destination layout shows an insertion preview before the
drop. Empty dynamic workspaces may disappear immediately after their last window is moved
or closed.

## Appearance

Overview cards reuse each window's borders, corner radius, opacity, blur, and color
presentation. Shortcut badges use `colors.overview.badge`; all overview colors are
configured under `[colors.overview]` (see appearance reference).
