# Keybinds

Bindings live under `[keybinds]`. See `references/actions.md` for the action list.

```toml
[keybinds]
"Mod+T" = "spawn kitty"
"Mod+Q" = "window-close"
"Mod+Left" = "window-focus-left"
"Mod+Right" = "window-focus-right"
"Mod+I" = "overview-toggle"
```

Action arguments are separate words inside the string: `"workspace-switch 3"`,
`"window-move-to-workspace CHAT --output DP-2"`, `"spawn grim screenshot.png"`. Quotes
and backslash escapes group a word containing spaces (`"workspace-switch 'My web'"`).

## Modifiers and special keys

| Modifier | Notes |
| --- | --- |
| `Mod` | `general.mod_key`; Super on DRM, Alt when nested |
| `Shift` | |
| `Ctrl` / `Control` | |
| `Alt` | |
| `Super` / `Logo` / `Win` | |

- Wheel: `WheelUp`, `WheelDown`, `WheelLeft`, `WheelRight`
- Mouse: `MouseLeft`, `MouseRight`, `MouseMiddle`, `MouseBack`, `MouseForward`
- Bare keys like `XF86AudioMute` are valid.
- Mouse/wheel binds require at least one modifier (`"Mod+MouseMiddle" = "layout-scroll-drag"`).
- A modifier can be bound by itself: `"Mod" = "spawn noctalia msg panel-toggle launcher"`.
  Modifier-only binds fire on release when no other key/button/scroll/touch/gesture input
  occurred while held (pointer motion alone does not cancel).

Matched binds consume their press and release; unbound input reaches the app normally.

## Table form options

```toml
"Mod+Return" = { action = "spawn kitty", repeat = false }
"XF86MonBrightnessDown" = { action = "spawn noctalia msg brightness-down 10", allow_when_locked = true }
"Mod+Shift+Escape" = { action = "shortcuts-inhibit-toggle", allow_when_inhibited = true, repeat = false }
"Mod+WheelUp" = { action = "workspace-previous", cooldown_ms = 150 }
"Mod+WheelDown" = { action = "workspace-next", cooldown_ms = 150 }
```

| Field | Effect |
| --- | --- |
| `repeat` | Binds repeat using keyboard rate/delay (including `spawn`); `false` disables for this bind. Scratchpad visibility/cycling and built-in `Mod+Q`/`Mod+O` never repeat. |
| `allow_when_locked` | Run while the session is locked (only for safe actions, e.g. brightness). |
| `allow_when_inhibited` | Run while keyboard-shortcuts inhibition (games/remote desktop) is active. Keep one escape bind available. |
| `cooldown_ms` | Suppress repeated actions for a period while still consuming matching input. |

## Submaps

Temporary keybind layers. Enter with `submap <name>`, leave one level with `submap reset`.
Prefix bindings inside a submap with `submap[name],`:

```toml
[keybinds]
"Mod+S" = { action = "submap screencapture", repeat = false }
"submap[screencapture],1" = { action = "spawn grim screenshot.png", submap = "reset" }
"submap[screencapture],2" = { action = "submap region", repeat = false }
"submap[screencapture],Escape" = "submap reset"
"submap[region],R" = { action = "spawn grim -g \"$(slurp)\" screenshot.png", submap = "reset" }
"submap[region],Escape" = "submap reset"
```

The optional `submap` field transitions after the action (`"reset"` for one-shots).
A default-context `"Escape" = "submap reset"` matches even outside a submap — use only if
bare Escape should be consumed globally. `umbriel submap` prints the active layer;
subscribe to `submap` events for panels.

## Keyboard layouts

Bindings match the symbol from the active layout; with multiple layouts Umbriel also
checks the same physical key for a printable ASCII symbol in other layouts (keeps
`Mod+T` working on non-Latin layouts). A keyboard with only a non-Latin layout has no
ASCII fallback — add an alternate layout or bind the keysym name.

## Hot corners

```toml
[hot_corners.top_left]
enabled = true
delay_ms = 500
action = "overview-open"
```

Sections: `top_left`, `top_right`, `bottom_left`, `bottom_right`.
`enabled` (default false), `delay_ms` (default 500, range 0–10000), `action` (any
keybind action). Inactive while the output's focused window is fullscreen or an
exclusive-keyboard layer surface (launcher) is mapped; the overview does not block them.
Effect `set`/`cycle` names are validated at load, including submap binds and disabled
corners.

## Cheatsheet

Lists active keybinds; opens at startup when `general.show_cheatsheet` is true.
`cheatsheet-toggle` / `-open` / `-close`. Any non-modifier key or mouse button closes it;
bound actions still run.

## Example sets

Noctalia shell integration:

```toml
"Mod" = "spawn noctalia msg panel-toggle launcher"
"Mod+V" = "spawn noctalia msg panel-toggle clipboard"
"Mod+W" = "spawn noctalia msg panel-toggle wallpaper"
"Mod+P" = "spawn noctalia msg screenshot-region"
"Mod+Escape" = "spawn noctalia msg panel-toggle session"
```

Direct primary extents:

```toml
"Mod+A" = "window-set-primary-extent 0.333"
"Mod+S" = "window-set-primary-extent 0.5"
"Mod+D" = "window-set-primary-extent 0.667"
"Mod+F" = "window-set-primary-extent 1.0"
"Mod+R" = "window-cycle-primary-extent"
"Mod+Shift+R" = "window-cycle-primary-extent-back"
```

Scroll-wheel navigation:

```toml
"Mod+WheelUp" = "window-focus-left"
"Mod+WheelDown" = "window-focus-right"
"Mod+Shift+WheelUp" = "column-move-left"
"Mod+Shift+WheelDown" = "column-move-right"
```

Media/brightness (needs `wpctl`, `playerctl`, `brightnessctl`):

```toml
"XF86AudioRaiseVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
"XF86AudioLowerVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
"XF86AudioPlay" = "spawn playerctl play-pause"
"XF86AudioNext" = "spawn playerctl next"
"XF86AudioPrev" = "spawn playerctl previous"
"XF86MonBrightnessUp" = "spawn brightnessctl set +5%"
"XF86MonBrightnessDown" = "spawn brightnessctl set 5%-"
```
