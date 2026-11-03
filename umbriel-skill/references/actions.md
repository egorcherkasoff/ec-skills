# Actions

Actions are the compositor's verbs: bind under `[keybinds]`, attach to a hot corner, or
run with `umbriel msg <action>`. `umbriel msg --help` prints the same list, with the same
wording and grouping.

## Argument forms

Arguments follow the action name as separate words. On the command line each word is a
shell argument. In config strings words split on whitespace, and single quotes, double
quotes, and backslash escapes group a word containing spaces, as in
`"Mod+W" = "workspace-switch 'My web'"`. `spawn` takes the rest of a config string
verbatim; on the command line its remaining words are joined with single spaces and run
through the shell, so pass a command needing shell quoting as one quoted argument.
`--output <output>`, `--window <window-id>`, and `--name <name>` qualify some actions;
they may appear anywhere after the action name, with the value as the next word.
`<angle>` forms are required, `[bracket]` forms are optional.

| Form | Meaning |
| --- | --- |
| `<cmd...>` | Command line, run through the shell: `spawn kitty` |
| `<name>` | Submap to enter; `submap reset` leaves one level |
| `<workspace> [--output <output>]` | Bare digits select a 1-based position, other text selects a name, and `--name <name>` selects a name even when it is only digits; `--output <output>` scopes either form |
| `<output>` | Connector or monitor name from `umbriel outputs` |
| `<window-id>` | Window id from `umbriel windows` |
| `[<window-id>]` | The same id; the bare action targets the focused window |
| `[<output>]` | Connector or monitor name. Bare `dpms-off`/`dpms-on` target every configured output |
| `[<scratchpad>]` | Scratchpad name. Bare form = implicit `default` scratchpad (exists only with no named scratchpads) |
| `<fraction>` | `0.1`–`4.0` of the column extent (above `1.0` spans several viewports, scrolling only), or `0.1`–`1.0` of usable area for floating |
| `<delta>` | Signed `-0.9`–`0.9`; result clamps to `0.1` and to the layout ceiling (`4.0` scrolling columns, `1.0` otherwise) |
| `<nits> [--output <output>]` | SDR reference white in cd/m², `80`–`1000`; default output = preferred |
| `<scrolling\|dwindle\|master\|stacking\|toggle [mode1 mode2 ...]>` | `workspace-set-layout` mode; bare `toggle` cycles scrolling→dwindle→master→stacking; `toggle scrolling master` cycles only listed modes (two or more, each once) in order, first from an unlisted mode |
| `<normal\|tabbed>` | `column-set-display` display mode |
| `<index>` | Tab position for `column-focus-tab`, from `1`; negative counts from last (`-1` = last) |
| `[skip-confirmation]` | `session-quit` only: quit without the on-screen confirmation |
| `<anchor> <x> <y> [--window <window-id>]` | `window-move-to` only: anchor + signed logical-px offsets; right/bottom measure inward; kept inside usable area |
| `<delta-x> <delta-y> [--window <window-id>]` | `window-move-by` only: signed logical-px offsets from current position, kept inside usable area |

Effect `set`/`cycle` take the preset or pool name as a word and the target as
`--window <window-id>` (window and border effects) or `--output <output>` (screen
effects): `effect-screen-set cinema --output vendor/panel`. Omit the target for the
focused window / preferred output. Cursor actions take no target. `off` is accepted only
by `set`. Named `set` and successful `cycle` create a runtime override and clear
suppression; `set off` and `toggle` suppress without forgetting the selection; `reset`
clears override, suppression, and history. See `references/effects.md`.

## Apps

| Action | Effect |
| --- | --- |
| `spawn <cmd...>` | Run a command with a launch activation token (first window opens on the pointer-preferred output/workspace; explicit `default_output`/`default_workspace`/`default_scratchpad` rules win) |

## Screencasting

The first set/follow action during an active share opens a confirmation panel; approval
lasts until the share ends. `screencast.disable_dynamic_confirmation = true` skips it.

| Action | Effect |
| --- | --- |
| `screencast-clear` | Pause screencast, stop following |
| `screencast-follow-output` | Follow the focused output |
| `screencast-follow-stop` | Stop following, keep current target |
| `screencast-follow-window` | Follow the focused window (careful: focusing a private window shares it) |
| `screencast-set-output [<output>]` | Share focused or selected output |
| `screencast-set-window [<window-id>]` | Share focused or selected window |

## Focus

| Action | Effect |
| --- | --- |
| `column-focus-first` / `column-focus-last` | First/last column in workspace |
| `column-focus-tab <index>` | Focus tab by position in focused tab group |
| `column-focus-tab-next` / `column-focus-tab-previous` | Next/previous tab (wrap unless `layout.tabs.wrap_focus = false`) |
| `output-focus-down` / `-left` / `-right` / `-up` | Focus output by direction (no wrap) |
| `output-focus-next` / `output-focus-previous` | Next/previous output (wraps) |
| `window-focus <window-id>` | Focus a window, revealing it from a hidden scratchpad |
| `window-focus-down` / `window-focus-up` | Next window down/up in the column |
| `window-focus-last` | Previously focused window |
| `window-focus-left` / `window-focus-right` | Window to the left/right |
| `window-focus-next` / `window-focus-previous` | Next/previous in layout order |
| `window-focus-or-output-down` / `-left` / `-right` / `-up` | Focus directionally, or the output at the edge |
| `window-focus-or-workspace-down` / `-up` | Focus directionally, or the workspace at the edge |
| `window-focus-switch-floating` | Last window of opposite floating state |
| `window-focus-warp <window-id>` | Focus/reveal and warp cursor to it |
| `workspace-focus-last` | Previously active workspace |

## Move & size

| Action | Effect |
| --- | --- |
| `column-center` | Center focused column in viewport |
| `column-move-left` / `column-move-right` | Move focused column one position |
| `column-move-to-first` / `column-move-to-last` | Move focused column to ends |
| `column-move-to-output-down` / `-left` / `-right` / `-up` | Move column to output by direction |
| `layout-master-count-decrease` / `layout-master-count-increase` | Demote last master / promote first stack window |
| `layout-scroll-down` / `-left` / `-right` / `-up` | Pan the scrolling strip |
| `layout-scroll-drag` | Pan strip while bound button held |
| `layout-toggle-split` | Toggle focused tile's dwindle split direction |
| `window-center` | Center focused floating window |
| `window-consume-from-left` / `window-consume-from-right` | Pull neighboring column's window into focused column |
| `window-consume-left` / `window-consume-right` | Stack focused window into neighboring column |
| `window-consume-or-expel-left` / `window-consume-or-expel-right` | Split out or stack in, depending on state |
| `window-cycle-primary-extent` / `-back` | Cycle primary extent presets (reverse) |
| `window-cycle-secondary-extent` / `-back` | Cycle secondary extent presets (reverse) |
| `window-modify-height-down <delta>` / `window-modify-height-up <delta>` | Resize from bottom/top edge |
| `window-modify-primary-extent <delta>` | Change primary extent by fraction |
| `window-modify-secondary-extent <delta>` | Change secondary extent by fraction |
| `window-modify-width-left <delta>` / `window-modify-width-right <delta>` | Resize column from left/right edge |
| `window-move-by <delta-x> <delta-y> [--window <window-id>]` | Move floating window by logical pixels |
| `window-move-down` / `window-move-up` | Move window within column |
| `window-move-left` / `window-move-right` | Move window left/right (layout-dependent) |
| `window-move-or-output-down` / `-left` / `-right` / `-up` | Move, or column to output at edge |
| `window-move-or-workspace-down` / `-up` | Move, or to workspace at edge |
| `window-move-to <anchor> <x> <y> [--window <window-id>]` | Move floating window to anchored position |
| `window-move-to-output-down` / `-left` / `-right` / `-up` / `-next` / `-previous` | Move window to another output |
| `window-set-primary-extent <fraction>` | Set primary extent exactly |
| `window-set-secondary-extent <fraction>` | Set secondary extent exactly |
| `window-set-region <left\|right\|top\|bottom\|top_left\|top_right\|bottom_left\|bottom_right>` | Place the stacking window in a half or quarter |
| `window-clear-region` | Restore the window's normal position and size |
| `window-swap-down` / `-left` / `-next` / `-previous` / `-right` / `-up` | Swap without changing tiles |

`window-set-region` works on ordinary eligible windows in the stacking layout, including
explicitly floating ones; it rejects windows above tiling layouts, tiled, attached,
fullscreen, pinned, and scratchpad windows, and regions smaller than the client minimum.
Repeating a region is idempotent; choosing another preserves the original normal box;
`window-clear-region` restores it. See `references/layout.md`.

## Windows

`window-toggle-floating` requires a tiling layout; windows in a stacking layout already
float and cannot be tiled individually.

| Action | Effect |
| --- | --- |
| `column-hide-tab-bar` / `column-show-tab-bar` / `column-toggle-tab-bar` | Hide/show one group's bar |
| `column-move-tab-next` / `column-move-tab-previous` | Reorder focused tab |
| `column-set-display <normal\|tabbed>` | Stacked or tabbed display |
| `column-toggle-tabbed` | Tab the rows around the window, or stack its tabs |
| `window-close [<window-id>]` | Close focused or given window |
| `window-kill [<window-id>]` | SIGKILL the process owning the window (all its windows die; unsaved work lost) |
| `window-minimize [<window-id>]` | Minimize the focused floating window, or the given window |
| `window-restore-minimized` | Restore the latest minimized window on this workspace |
| `window-toggle-floating [<window-id>]` | Float or tile |
| `window-toggle-fullscreen` | Fullscreen (fills whole output, ignores struts/exclusive zones) |
| `window-toggle-maximize` | Full layout-area width for the focused column |
| `window-toggle-maximize-to-edges` | Maximize without gaps, struts, borders |
| `window-toggle-pinned` | Pin above other windows |

Minimize rules: only floating windows minimize (tiled, pinned, fullscreen, and scratchpad
windows do not); minimized windows keep workspace/position/size, stay in `umbriel windows`
with `minimized`, are skipped by focus cycling and the overview, and come back via a
taskbar, a valid activation, `window-focus`/`-warp`, an attached modal dialog, or
`window-restore-minimized`. See `references/layout.md` → Minimize.

Xwayland note: fullscreen entered via `window-toggle-fullscreen` stays compositor-owned
until an Umbriel action exits it; app-requested fullscreen stays client-controlled.

## Scratchpad

| Action | Effect |
| --- | --- |
| `scratchpad-focus-next [<scratchpad>]` | Focus next visible member |
| `scratchpad-toggle [<scratchpad>]` | Show/hide the scratchpad |
| `scratchpad-window-show-next [<scratchpad>]` / `scratchpad-window-show-previous [<scratchpad>]` | Show only next/previous member |
| `window-move-to-scratchpad [<scratchpad>]` | Store focused window |
| `window-restore-from-scratchpad [<scratchpad>]` | Return member to saved workspace |
| `window-toggle-scratchpad [<scratchpad>]` | Store or restore focused window |

## Workspaces

| Action | Effect |
| --- | --- |
| `column-move-to-workspace <workspace> [--output <output>]` | Move focused column |
| `column-move-to-workspace-next` / `-previous` | Move focused column to next/previous |
| `window-move-to-workspace <workspace> [--output <output>]` | Move focused window |
| `window-move-to-workspace-next` / `-previous` | Move to next/previous |
| `window-move-to-workspace-silent <workspace> [--output <output>]` | Move without following |
| `window-move-to-workspace-silent-next` / `-previous` | Silent move to next/previous |
| `workspace-move-down` / `workspace-move-up` | Reorder workspace in the list (no wrap) |
| `workspace-move-to-output <destination> [<workspace>] [--output <output>]` | Move the active or selected workspace to an output |
| `workspace-move-to-output-down` / `-left` / `-right` / `-up` / `-next` / `-previous` | Move workspace to output |
| `workspace-next` / `workspace-previous` | Switch (no wrap unless `cyclic_workspaces`) |
| `workspace-set-layout <scrolling\|dwindle\|master\|stacking\|toggle [mode1 mode2 ...]>` | Set/cycle layout mode |
| `workspace-swap-active-output-down` / `-left` / `-next` / `-previous` / `-right` / `-up` | Swap active workspace windows with an output |
| `workspace-switch <workspace> [--output <output>]` | Switch to selected workspace |
| `workspace-toggle-show-desktop` | Minimize or restore the workspace's floating windows |

## Overview

| Action | Effect |
| --- | --- |
| `overview-open` / `overview-close` / `overview-toggle` | Workspace overview |

## System

| Action | Effect |
| --- | --- |
| `cheatsheet-close` / `-open` / `-toggle` | Keybind cheatsheet |
| `config-reload` | Reload the configuration file |
| `cursor-hide` / `cursor-show` | Hide cursor until pointer activity / show and restart timeout |
| `dpms-off [<output>]` / `dpms-on [<output>]` | Display power; bare = all configured outputs |
| `effect-border-set <name> [--window <window-id>]` | Select border preset/pool; `off` suppresses |
| `effect-border-cycle [<pool>] [--window <window-id>]` | Cycle border pool |
| `effect-border-toggle [<window-id>]` | Toggle border suppression |
| `effect-border-reset [<window-id>]` | Clear runtime state |
| `effect-cursor-set <name>` / `-cycle [<pool>]` / `-toggle` / `-reset` | Cursor slot (no target) |
| `effect-screen-set <name> [--output <output>]` | Screen preset/pool for output |
| `effect-screen-cycle [<pool>] [--output <output>]` / `-toggle [<output>]` / `-reset [<output>]` | Screen slot ops |
| `effect-window-set <name> [--window <window-id>]` | Window preset/pool |
| `effect-window-cycle [<pool>] [--window <window-id>]` / `-toggle [<window-id>]` / `-reset [<window-id>]` | Window slot ops |
| `keyboard-layout-next` | Cycle configured layouts |
| `output-disable <output>` / `output-enable <output>` / `output-toggle <output>` | Logical output state |
| `output-sdr-white <nits> [--output <output>]` | Set an output's live SDR reference white |
| `session-quit [skip-confirmation]` | Quit session (bare form asks for confirmation) |
| `shortcuts-inhibit-toggle` | Toggle shortcuts inhibition for focused surface |
| `submap <name>` | Enter submap layer / `reset` leaves one |

## Layout differences

| Action group | Scrolling | Dwindle | Master |
| --- | --- | --- | --- |
| Column movement | Reorders columns | Same as window left/right | Exchanges master/stack contents |
| Window left/right | Expels or stacks into neighboring column; moves along lane in vertical strip | Moves into neighboring tile | Moves between master and stack |
| Consume/expel | Joins or splits columns | Swaps directional neighbors | Moves between master and stack |
| Primary extent | Column width | Horizontal splits | Master fraction |
| Secondary extent | A row | Vertical splits | A row |
| Layout scrolling | Pans strip | No effect | No effect |
| Master count | No effect | No effect | Moves window master↔stack |
| Toggle split | Refused | Flips focused tile's split | Refused |
| Tabs | Tabs the focused column | Refused | Tabs master or stack area |

Stacking has no tiles: every ordinary window floats, directional focus uses window
geometry, and `window-toggle-floating` is refused. See `references/layout.md`.

## Notes

- Output direction actions don't wrap; `next`/`previous` variants do. Workspace
  `next`/`previous`/`move-up`/`move-down` don't wrap (unless `cyclic_workspaces`).
- Whole-column moves preserve order, proportions, extent, tab groups, selected tabs, and
  tab-bar visibility overrides. Moving a multi-window column into Dwindle creates
  separate tiles.
- In scrolling, a tab group is one row of its column: `window-focus-up`/`-down` step
  over it; `window-move-up`/`-down` take a tab out or a window in. In a tabbed master
  area they step through its tabs without wrapping.
- An action unavailable in the active layout does nothing from a keybind and returns an
  explanatory error via `umbriel msg`.
- `spawn` records pointer-preferred output/workspace for the launched app's first window;
  `focus_on_activate` governs focus, not placement. Autostart gets no token.
- Bare `session-quit` asks for confirmation; use `session-quit skip-confirmation` only
  for an immediate exit.
