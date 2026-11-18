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

Application global shortcuts use a separate `global_shortcuts` table. Configured
keybinds in the default submap always take priority over application shortcuts,
including explicit overrides.

## Default keybinds

The packaged starting configuration (`examples/config.toml`) binds these, among others.
`Mod` is Super on a native session and Alt when nested. Change the launcher and
terminal commands under `[keybinds]` if you use another shell or terminal.

| Shortcut | Action |
| --- | --- |
| `Mod` | Toggle the Noctalia launcher |
| `Mod+Return` | Open kitty |
| `Mod+Q` | Close the focused window |
| `Mod+Escape` | Quit (asks for confirmation) |
| `Mod+F1` | Cycle window focus |
| `Mod+H/J/K/L` or arrows | Focus adjacent window |
| `Mod+Shift+arrows` | Move column left/right or window up/down |
| `Mod+Comma` / `Mod+Period` | Consume left / consume right |
| `Mod+R` / `Mod+F` | Cycle width / toggle fullscreen |
| `Mod+T` | Toggle floating for the focused window |
| `Mod+P` | Toggle pin for the focused window |
| `Mod+W` | Toggle tabs for the focused column |
| `Mod+O` | Toggle the overview |
| `Mod+1..9` | Switch workspace on focused monitor |
| `Mod+Shift+1..9` | Move focused window to workspace and follow |

## Modifiers and special keys

| Modifier | Notes |
| --- | --- |
| `Mod` | `general.mod_key` (enum `Super`/`Alt`/`Ctrl`/`Shift`); Super on DRM, Alt when nested |
| `Shift` | |
| `Ctrl` / `Control` | |
| `Alt` | |
| `Super` / `Logo` / `Win` | |

- Wheel: `WheelUp`, `WheelDown`, `WheelLeft`, `WheelRight`
- Mouse: `MouseLeft`, `MouseRight`, `MouseMiddle`, `MouseBack`, `MouseForward`
- Bare keys like `XF86AudioMute` are valid.
- Mouse/wheel binds require at least one modifier (`"Mod+MouseMiddle" = "layout-scroll-drag"`).
- A modifier can be bound by itself: `"Mod" = "spawn noctalia msg panel-toggle launcher"`.
  Modifier-only binds are release bindings cancelled by other key/button/scroll/touch/gesture
  input while the modifier is held (pointer motion alone does not cancel). Unlike explicit
  release actions, they forward the modifier press and release to clients.

Matched binds consume their press and release; unbound input reaches the app normally.

## Table form

```toml
"Mod+Return" = { action = "spawn kitty", repeat = false }
"Mod+Space" = { action = "overview-open", release = "overview-close", repeat = false }
"submap[resize],Mod+H" = { release = "submap reset" } # release-only
"XF86MonBrightnessDown" = { action = "spawn noctalia msg brightness-down 10", allow_when_locked = true }
"Mod+Shift+Escape" = { action = "shortcuts-inhibit-toggle", allow_when_inhibited = true, repeat = false }
"Mod+WheelUp" = { action = "workspace-previous", cooldown_ms = 150 }
"Mod+WheelDown" = { action = "workspace-next", cooldown_ms = 150 }
```

| Field | Effect |
| --- | --- |
| `action` | Action run on press. Optional when `release` is set. |
| `release` | Action run once when the key/button is released (see Release bindings). |
| `repeat` | Bool, default `true`. Press bindings repeat using the keyboard rate/delay, including `spawn`, so held volume/brightness keys keep stepping. `false` disables per bind. Never repeat: release actions, modifier-only binds, scratchpad visibility/cycling actions, built-in `Mod+Q`/`Mod+O`. |
| `allow_when_locked` | Run while the session is locked. Only for actions safe without an unlocked session (e.g. brightness). |
| `allow_when_inhibited` | Available while keyboard-shortcuts inhibition is active (and in normal mode). |
| `cooldown_ms` | Int 0–3600000, default 0. Suppresses repeated actions for a period while still consuming matching input. Press and release bindings on the same chord have independent cooldowns. |
| `submap` | Submap transition applied after the action (`"reset"` for one-shots). |

## Release bindings

Keyboard and mouse-button chords fire on press by default; the `release` field runs an
action once when the key or button is released. `action` is optional when `release` is
set. A pressed release binding stays armed until its key or button is released, even if
a submap changes, the configuration reloads without changing that binding, or the
session locks. On release it runs only if it is still allowed — a locked session skips
it unless it sets `allow_when_locked`. A release action never confirms a visible
confirmation dialog; only a press does.

```toml
# Push to talk: unmute on press, mute on release.
"Mod+MouseBack" = { action = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0", release = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1", repeat = false }
```

## Keyboard shortcuts inhibition

Games and remote-desktop clients can ask Umbriel to pass keyboard shortcuts through;
`shortcuts-inhibit-toggle` enables passthrough manually, even without a client request.
Keys that would trigger ordinary bindings then reach the client; pointer and wheel binds
are unaffected. Bindings with `allow_when_inhibited = true` stay available in either mode.
Keep one escape binding:

```toml
"Mod+Shift+Escape" = { action = "shortcuts-inhibit-toggle", allow_when_inhibited = true, repeat = false }
```

Manual passthrough belongs to the exact keyboard-focused surface: it pauses when focus
moves to another surface and resumes when that surface regains focus; popups do not
inherit it; destroying the surface clears its manual state. The toggle requires an
unlocked session with a focused surface; locking preserves the setting for when focus
returns after unlocking. A window rule with `allow_shortcuts_inhibit = false` denies
automatic client requests, but the manual toggle still enables passthrough for those
windows. When the client already has an allowed inhibitor, the toggle activates or
deactivates that inhibitor; rule changes preserve a manual deactivation; if the client
creates one while manual passthrough is active, one toggle disables both sources
together; destroying a client inhibitor does not clear an existing manual setting.

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
subscribe to `submap` events for panels/scripts.

## Keyboard layouts

Bindings match the symbol from the active layout; with multiple layouts Umbriel also
checks the same physical key for a printable ASCII symbol in other layouts (keeps
`Mod+T` working on non-Latin layouts). A keyboard with only a non-Latin layout has no
ASCII fallback — add an alternate layout or bind the active XKB keysym name.

## Hot corners

```toml
[hot_corners.top_left]
enabled = true
delay_ms = 500
action = "overview-open"
```

Sections `top_left`, `top_right`, `bottom_left`, `bottom_right`; run the action after the
pointer rests in an output corner. `enabled` (bool, default false), `delay_ms` (int
0–10000, default 500), `action` (any action accepted by a keybind).

Inactive while:
- the output's focused window is fullscreen — the check follows the output containing the
  corner, even when keyboard focus is on another monitor; a fullscreen window on a
  different output or an inactive workspace does not block, nor does a retained
  fullscreen window after another window on that output takes focus;
- an exclusive-keyboard layer surface (e.g. a launcher) is mapped — while the overview is
  open, exclusive-keyboard layers do not block hot corners.

Named effect `set`/`cycle` arguments are checked against preset/pool kind when the
configuration loads, including submap bindings and disabled hot corners; invalid
references reject the binding or clear the corner action with a source diagnostic (only
the final retained action is checked after replacements). Keybinds and enabled corners
pre-compile all reached pool members and border overlays; disabled corners contribute no
compilation roots. See `references/effects.md`.

## Cheatsheet

Lists active keybinds; opens at startup when `general.show_cheatsheet` is true (default
true). `cheatsheet-toggle` / `-open` / `-close` from a bind or `umbriel msg`. Any
non-modifier key or mouse button closes it; normal bound actions still run.

## Example sets

Noctalia shell integration:

```toml
"Mod" = "spawn noctalia msg panel-toggle launcher"
"Mod+V" = "spawn noctalia msg panel-toggle clipboard"
"Mod+W" = "spawn noctalia msg panel-toggle wallpaper"
"Mod+P" = "spawn noctalia msg screenshot-region"
"Mod+Escape" = "spawn noctalia msg panel-toggle session"
```

Resizing the focused window (primary/secondary meaning per layout:
`references/layout.md` → sizing behavior):

```toml
"Mod+A" = "window-set-primary-extent 0.333"
"Mod+S" = "window-set-primary-extent 0.5"
"Mod+D" = "window-set-primary-extent 0.667"
"Mod+F" = "window-set-primary-extent 1.0"
"Mod+R" = "window-cycle-primary-extent"
"Mod+Shift+R" = "window-cycle-primary-extent-back"
"Mod+Minus" = "window-modify-primary-extent -0.02"
"Mod+Equal" = "window-modify-primary-extent +0.02"
"Mod+Ctrl+Minus" = "window-modify-secondary-extent -0.02"
"Mod+Ctrl+Equal" = "window-modify-secondary-extent +0.02"
```

`window-modify-*` delta is a fraction of the viewport (of the usable area for floating
windows); it may start with `+`, must not be zero, range `-0.9`–`0.9`.

Scroll-wheel navigation:

```toml
"Mod+WheelUp" = "window-focus-left"
"Mod+WheelDown" = "window-focus-right"
"Mod+Shift+WheelUp" = "column-move-left"
"Mod+Shift+WheelDown" = "column-move-right"
```

Media/brightness via Noctalia shell IPC (volume/brightness OSDs show; binds stay
available while the session is locked):

```toml
"XF86AudioRaiseVolume" = { action = "spawn noctalia msg volume-up", allow_when_locked = true }
"XF86AudioLowerVolume" = { action = "spawn noctalia msg volume-down", allow_when_locked = true }
"XF86AudioMute" = { action = "spawn noctalia msg volume-mute", allow_when_locked = true, repeat = false }
"XF86AudioPlay" = { action = "spawn noctalia msg media toggle", allow_when_locked = true, repeat = false }
"XF86AudioNext" = { action = "spawn noctalia msg media next", allow_when_locked = true }
"XF86AudioPrev" = { action = "spawn noctalia msg media previous", allow_when_locked = true }
"XF86MonBrightnessUp" = { action = "spawn noctalia msg brightness-up", allow_when_locked = true }
"XF86MonBrightnessDown" = { action = "spawn noctalia msg brightness-down", allow_when_locked = true }
```

Direct utilities without the shell (need `wpctl`, `playerctl`, `brightnessctl`):

```toml
"XF86AudioRaiseVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
"XF86AudioLowerVolume" = "spawn wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
"XF86AudioPlay" = "spawn playerctl play-pause"
"XF86AudioNext" = "spawn playerctl next"
"XF86AudioPrev" = "spawn playerctl previous"
"XF86MonBrightnessUp" = "spawn brightnessctl set +5%"
"XF86MonBrightnessDown" = "spawn brightnessctl set 5%-"
```
