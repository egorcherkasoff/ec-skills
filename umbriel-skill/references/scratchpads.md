# Scratchpads

A scratchpad stores windows outside normal workspaces for quick show/hide. Its windows
float and appear together; scratchpads are global and roam between outputs.

- Moving a window to a scratchpad stores it.
- Toggling a scratchpad shows/hides its stored windows.
- An empty scratchpad can be opened and receive newly launched windows.
- Restoring a window returns it to its saved output and workspace.

`[[scratchpad]]` keys (all named pads; the implicit `default` has none of them):

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string | — | Unique name; `default` reserved. |
| `spawn_when_empty` | string | `""` | Shell command run when toggling open an empty pad. |
| `hide_when_empty` | bool | `false` | Hide the pad when its last window closes or hides itself. |
| `proportional_size` | bool | `false` | Keep width/height as proportions of usable area across monitors. |

## Default scratchpad

Without `[[scratchpad]]` entries, one implicit `default` exists. The packaged config binds
it without a name suffix:

```toml
[keybinds]
"Mod+Shift+Space" = "window-move-to-scratchpad"
"Mod+Space" = "scratchpad-toggle"
"Mod+Ctrl+Space" = "window-restore-from-scratchpad"
"Mod+Tab" = "scratchpad-focus-next"
```

Typical flow: store with `Mod+Shift+Space`, toggle with `Mod+Space`, cycle members with
`Mod+Tab`, restore with `Mod+Ctrl+Space`. You can also press `Mod+Space` before opening
any windows, then use your normal launch binding — the new window opens directly in the
scratchpad.

## Named scratchpads

Defining any named scratchpad removes the implicit `default`; every scratchpad action
must then carry the configured name. Names must be unique; `default` is reserved.
Removing a scratchpad on reload restores its windows to their saved destinations.

```toml
[[scratchpad]]
name = "terminal"

[[scratchpad]]
name = "music"

[keybinds]
"Mod+Shift+Space" = "window-toggle-scratchpad terminal"
"Mod+Space" = "scratchpad-toggle terminal"
"Mod+Shift+M" = "window-toggle-scratchpad music"
"Mod+M" = "scratchpad-toggle music"
```

## One window at a time

`scratchpad-toggle` shows everything. For one-at-a-time, bind
`scratchpad-window-show-next` / `scratchpad-window-show-previous`:

```toml
[keybinds]
"Mod+Alt+Space" = "scratchpad-window-show-next"
"Mod+Alt+Shift+Space" = "scratchpad-window-show-previous"
```

- On a hidden scratchpad, either shows only the most recently focused window.
- Again: hides that one and shows the next/previous (wrapping).
- While `scratchpad-toggle` is showing all, either keeps only the window after/before the
  focused one.
- `scratchpad-toggle` hides the pad whichever way it was shown. Both styles coexist on the
  same scratchpad.
- A window moved in while one-at-a-time is active becomes the one on show, as does one a
  `default_focused` rule brings in. Closing or restoring the shown window hides the pad.

## Assigning new windows automatically

### Launching into the open scratchpad

Opening a scratchpad makes it the **launch destination** on that output, even when empty.
Its backdrop appears immediately; an empty pad has no window receiving keyboard input.
Window-relative bindings leave the workspace windows behind it untouched. Applications
opened through `spawn` join that pad without a window rule; launchers passing a trusted
XDG activation token carry the destination to the new window.

- The destination is recorded at launch. Hiding the pad before the app maps leaves its
  new window hidden in that pad. Replacing the pad with another does not redirect the
  pending launch or focus its arriving window.
- Focusing a workspace window or clicking the exposed workspace background makes
  subsequent launches use the workspace again; the pad stays visible.
- Closing the last member leaves the empty pad open — toggle to dismiss, or set
  `hide_when_empty` to hide it automatically. Restoring the last member hides the pad. A
  one-at-a-time pad also hides when its shown window closes.
- Explicit output, workspace, scratchpad, or enabled-pinning rules take priority over the
  captured destination. Unrelated windows without a launch token keep normal placement.
  Activating an existing application window does not move it into the scratchpad.

### Window rules

```toml
[[scratchpad]]
name = "terminal"

[[window_rule]]
match.app_id = "^scratchpad-terminal$"
default_scratchpad = "terminal"
# default_focused = true   # summon the scratchpad when the window opens
```

E.g. `foot --app-id scratchpad-terminal` opens hidden in `terminal` (use
`default_scratchpad = "default"` when no named pads exist). The window remembers where and
how it would otherwise have opened — `default_output`, `default_workspace`, and
`default_floating` control that restore destination.

## Launching an application on demand

`spawn_when_empty` runs a shell command when the pad is toggled open while empty:

```toml
[[scratchpad]]
name = "monitor"
spawn_when_empty = "foot btop"
```

- The launched app's first window joins the pad through its launch token — **no matching
  window rule needed**. The empty pad is visible while the app starts. Explicit placement
  rules still take priority.
- Toggling while the launch is pending hides the pad; the window still joins the pad when
  it maps, hidden until the next toggle. Reopening within 10 s does not duplicate the
  command; after that interval, opening the empty pad can run it again.
- Once the pad holds a window, toggling only shows/hides it. The implicit `default` has
  no `spawn_when_empty`.

### Hiding an emptied scratchpad

`hide_when_empty` hides the pad when its last window closes or hides itself, so the next
toggle shows it and runs `spawn_when_empty` in one press:

```toml
[[scratchpad]]
name = "terminal"
spawn_when_empty = "foot"
hide_when_empty = true
```

Only losing the **last** window hides the pad: an explicitly opened empty pad stays open
while its app starts; closing one of several windows leaves the pad open; a hidden pad
stays hidden. If the closed window had keyboard focus, focus returns to the workspace. A
window joining later (e.g. a pending launch) arrives hidden. Works without
`spawn_when_empty`.

## Actions

| Action | Does |
| --- | --- |
| `window-move-to-scratchpad [<name>]` | Store the focused workspace window |
| `scratchpad-toggle [<name>]` | Show/hide, incl. empty; empty + `spawn_when_empty` runs the command |
| `window-restore-from-scratchpad [<name>]` | Restore one remembered window (pad must be visible) |
| `window-toggle-scratchpad [<name>]` | Store focused, or restore when already selected |
| `scratchpad-focus-next [<name>]` | Focus next visible member (pad must be visible) |
| `scratchpad-window-show-next [<name>]` | Show only the next member, hiding the one on show |
| `scratchpad-window-show-previous [<name>]` | Show only the previous member, hiding the one on show |

The name argument is optional only for the implicit `default`. `window-focus <window-id>`
summons a matching hidden member before focusing it; `window-focus-warp <window-id>` also
warps the cursor to it.

## Choosing an output

The pointer selects the output where a hidden scratchpad appears. Toggling a pad already
visible on another output moves it to the invoking output; toggling again on the same
output hides it. Only one scratchpad can be visible per output; different outputs can show
different scratchpads.

### Proportional sizing across monitors

Scratchpad windows keep their logical-pixel size by default. `proportional_size = true`
preserves each window's width/height as proportions of the usable area when it moves to
another monitor (88% of one monitor's usable width ≈ 88% on the next, subject to app size
limits).

- Manual resizing establishes the proportions for the next transfer; the initial window
  size rule is not reapplied. Show/hide/move within the same monitor does not resize; nor
  do changes to that monitor's scale, mode, or panels.
- Fullscreen and maximized windows keep fitting their monitor; their saved normal size
  follows the setting. Restoring a window or moving it to a workspace ends proportional
  sizing: floating windows keep their current size, tiled windows follow the destination
  layout.

## Visibility and focus

- Showing a populated pad focuses its most recently focused member; hiding returns focus
  to a workspace window.
- The workspace overview hides every visible pad without dropping members; while it is
  open (including its closing animation), scratchpad actions and window rules do not show
  a pad.
- A dialog parented to a visible member joins the pad unless a window rule explicitly
  chooses another destination.
- Backdrop dim and blur affect only the output showing the pad.

## Restoring windows

Each member remembers source output, workspace, and tiled/floating state; if gone, it
restores to the pad's current output and active workspace. Fullscreen, pinned, and
maximize-to-edges state are cleared on entry — the window floats at its current size. A
window opening into a pad via `default_scratchpad` takes size, position, fullscreen, and
maximize-to-edges state from its window rules.

## Moving scratchpad windows

- Workspace move bindings remove the focused member and send it to the selected
  workspace, restoring its saved tiled/floating state:
  `window-move-to-workspace <workspace> [--output <output>]` follows the window;
  `window-move-to-workspace-silent ...` keeps the current workspace active. Next/previous
  variants start from the active workspace on the pad's output. Other members stay;
  moving the last member out hides the pad.
- Dragging a member does not restore it. Dragging one member to another output moves the
  whole pad there, preserving the other members' relative positions.
- Output disconnect: the pad temporarily moves to another enabled output and returns when
  the original output does, unless deliberately moved elsewhere.

## Appearance and window actions

Scratchpad windows use regular border colors unless a window rule matches:

```toml
[[window_rule]]
match.is_scratchpad = true
border_color_focused = "#E5C07BFF"
border_color_unfocused = "#5C4A2AFF"
```

Show/hide transitions and backdrop dim/blur live under `[animation.scratchpad]` (see the
animation reference). Normal window size, centering, fullscreen, maximize, and close
actions work on a focused member; layout-relative actions require restoring it first.

## Troubleshooting

- Empty pad hard to distinguish ⇒ check its backdrop dim/blur settings.
- Restore / focus-next does nothing ⇒ show the scratchpad first.
- Named action does nothing ⇒ check the suffix against configured names.
- Appears on the wrong monitor ⇒ move the pointer before showing it.
- Tiling, pinning, or layout-relative actions fail ⇒ restore the window first.
