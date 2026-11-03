# Scratchpads

Scratchpads store windows outside workspaces for quick show/hide. Their windows float and
appear together; scratchpads are global and roam between outputs.

- Moving a window to a scratchpad stores it.
- Toggling shows/hides stored windows.
- Restoring returns a window to its saved output/workspace.

## Default scratchpad

Without `[[scratchpad]]` entries, one implicit `default` exists:

```toml
[keybinds]
"Mod+Shift+Space" = "window-move-to-scratchpad"
"Mod+Space" = "scratchpad-toggle"
"Mod+Ctrl+Space" = "window-restore-from-scratchpad"
"Mod+Tab" = "scratchpad-focus-next"
```

Typical flow: store with `Mod+Shift+Space`, toggle with `Mod+Space`, cycle members with
`Mod+Tab`, restore with `Mod+Ctrl+Space`.

## Named scratchpads

Defining any named scratchpad removes the implicit `default`; every scratchpad action
must then carry the scratchpad name as its last word. Names unique; `default` reserved.
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

`scratchpad-toggle` shows everything. For one-at-a-time, bind `scratchpad-window-show-next`
and `scratchpad-window-show-previous`:

- On a hidden scratchpad, either shows only the most recently focused window.
- Again: hides that one and shows the next/previous (wrapping).
- While `scratchpad-toggle` is showing all, either keeps only the window after/before the
  focused one.
- `scratchpad-toggle` hides whichever way it was shown.
- A window moved in (or summoned by `default_focused = true`) while one-at-a-time becomes
  the shown one; closing/restoring it hides the scratchpad.

## Auto-assigning new windows

```toml
[[scratchpad]]
name = "terminal"

[[window_rule]]
match.app_id = "^scratchpad-terminal$"
default_scratchpad = "terminal"
# default_focused = true   # summon the scratchpad when it opens
```

E.g. `foot --app-id scratchpad-terminal` opens hidden in `terminal` (use
`default_scratchpad = "default"` when no named ones exist). The window remembers where it
would otherwise have opened — `default_output`, `default_workspace`, `default_floating`
control the restore destination. A hidden scratchpad keeps new windows hidden unless
`default_focused = true`.

## Launch on demand

```toml
[[scratchpad]]
name = "monitor"
spawn_when_empty = "foot btop"

[[window_rule]]
match.app_id = "^btop$"
default_scratchpad = "monitor"
```

Toggling an empty scratchpad runs the command instead of nothing. If a matching window
arrives within 10 s, the scratchpad shows on the invoking output focused. Toggling while
pending hides it (the window joins hidden). No window in 10 s ⇒ expiry; next toggle runs
the command again. Once non-empty, toggling never spawns again. The implicit `default`
has no `spawn_when_empty`.

## Actions

| Action | Does |
| --- | --- |
| `window-move-to-scratchpad [<name>]` | Store the focused workspace window |
| `scratchpad-toggle [<name>]` | Show/hide; empty ⇒ `spawn_when_empty` |
| `window-restore-from-scratchpad [<name>]` | Restore one remembered window (must be visible) |
| `window-toggle-scratchpad [<name>]` | Store focused, or restore when already selected |
| `scratchpad-focus-next [<name>]` | Focus next visible member |
| `scratchpad-window-show-next [<name>]` / `scratchpad-window-show-previous [<name>]` | One-at-a-time navigation |

`window-focus <id>` summons a hidden member before focusing; `window-focus-warp <id>`
also warps the cursor. Bare forms work only with the implicit `default`.

## Output choice, visibility, focus

- The pointer selects the output where a hidden scratchpad appears. Toggling a visible
  scratchpad from another output moves it there; same output hides it. One scratchpad
  visible per output, different outputs can show different scratchpads.
- Showing focuses the most recently focused member; hiding returns focus to a workspace
  window. The overview hides visible scratchpads without dropping members. A dialog
  parented to a visible member joins it unless a rule says otherwise. Backdrop dim/blur
  affect only the showing output.
- Members remember source output, workspace, and tiled/floating state; if gone, they
  restore to the scratchpad's current output and active workspace. Fullscreen, pinned,
  and maximize-to-edges are cleared on entry; `[animation.scratchpad]` may apply a new
  presentation while stored.
- Dragging a member doesn't restore it; dragging to another output moves the whole
  scratchpad, preserving relative positions. Output disconnect temporarily relocates it
  and it returns when the output does (unless deliberately moved).
- Border colors via window rules (`match.is_scratchpad = true`); show/hide fades, dim,
  blur, and entry sizing under `[animation.scratchpad]`. Normal size/fullscreen/maximize/
  close actions work on a focused member; layout-relative actions need restoring first.

## Troubleshooting

- Toggle does nothing ⇒ no stored windows.
- Restore / focus-next does nothing ⇒ show the scratchpad first.
- Named action does nothing ⇒ the name word doesn't match a configured scratchpad.
- Wrong monitor ⇒ move the pointer before showing.
