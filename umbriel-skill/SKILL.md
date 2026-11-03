---
name: Umbriel
description: Configure the Umbriel Wayland compositor (Noctalia project) — config.toml structure, outputs, keybinds, actions, input, appearance, animations, effects/shaders, layouts, workspaces, window/layer rules, scratchpads, and IPC
---

# Umbriel

Umbriel is a Wayland compositor from the Noctalia project: scrolling/dwindle/master/
stacking layouts, independent workspaces per monitor, scratchpads, GLSL effects, and a
single TOML configuration that live-reloads on save.

## Workflow

1. Identify the topic, then read the matching reference file in this directory before
   writing or editing configuration.
2. The user config is `~/.config/umbriel/config.toml`. Never regenerate it wholesale;
   make targeted edits and preserve unrelated settings.
3. After editing, validate: `umbriel config validate` (exits nonzero on problems and
   prints file/line/column for every diagnostic).
4. Saving the file triggers a live reload of most options. Errors appear in an
   on-screen panel and the last working configuration stays active.
5. Restart-required options: `general.autostart`, `general.xwayland`,
   `general.xwayland_native_resolution`, any `[drm]` key, any `[environment]` change.
   Long-running apps that survive a restart need a full relaunch after environment changes.
6. Unsure a key exists or what type it takes? Run `umbriel config schema --json` on the
   user's machine — it lists every accepted key with path, type, range, accepted values,
   format, and built-in default.
7. Inspect live state with `umbriel windows`, `outputs`, `workspaces`, `layers`,
   `effects`, `color`, `tearing`, `keyboard-layouts`, `submap` (each accepts `--json`);
   run actions with `umbriel msg <action>`.
8. Official docs: <https://docs.noctalia.dev/umbriel/>. The project is young and options
   change between releases — when this skill and the installed binary disagree, the
   installed binary wins; fetch the relevant docs page to confirm.

## Reference index

| Topic | File |
| --- | --- |
| Config file, reload, includes, general/env/events/drm, install & logs | `references/configuration.md` |
| Monitors: `[output.<name>]`, modes, scale, VRR/HDR/10-bit, virtual outputs, DPMS | `references/outputs.md` |
| `[keybinds]`, chord syntax, submaps, hot corners, repeat/cooldown | `references/keybinds.md` |
| Every action usable in keybinds / `umbriel msg` / hot corners | `references/actions.md` |
| Socket protocol, CLI queries, event stream, audio input feed | `references/ipc.md` |
| `[input]`: keyboard, touchpad, mouse, tablet, touch, cursor, focus | `references/input.md` |
| `[colors]`, `[appearance]`, tab bar, blur, shadow | `references/appearance.md` |
| `[animation]`: event tables, curves/springs, custom effects, drag physics | `references/animation.md` |
| `[effects]`: bundled shaders, presets, pools, runtime selection, writing GLSL | `references/effects.md` |
| `[layout]`: scrolling/dwindle/master/stacking, tab groups, struts, sizing, minimize | `references/layout.md` |
| Workspaces (`[[workspace]]`, models, selectors) and `[overview]` | `references/workspaces.md` |
| `[[window_rule]]`, `[[layer_rule]]`, `[[security_context_rule]]`, session lock | `references/rules.md` |
| `[[scratchpad]]` definitions, actions, `spawn_when_empty` | `references/scratchpads.md` |

## Top-level config map

```toml
[general]         # autostart, mod_key, xwayland, cheatsheet...
[drm]             # GPU exclusions (restart required)
[environment]     # env vars for the session (restart required)
[events]          # lid_close / lid_open commands
[screencast]      # dynamic-target confirmation
[include]         # required includes; [include.optional] for optional
[output.<name>]    # per connector ("DP-1") or "<make> <model> <serial>"
[[workspace]]     # per-workspace rules / persistent names
[workspaces]      # back_and_forth, empty_above
[overview]        # zoom, scroll factors, shortcut badges
[keybinds]        # "Chord" = "action" or { action = "...", ... }
[hot_corners.top_left] # + top_right / bottom_left / bottom_right
[input]           # + [input.keyboard|touchpad|mouse|tablet|touch|cursor|focus|drag_edge_scroll]
                  # + [[input.device]] per-device overrides
[layout]          # + [layout.scrolling|dwindle|master|stacking|tabs|struts]
[colors]          # + [colors.border|overview|tab_bar|title_bar]
[appearance]      # + [appearance.title_bar|tab_bar|blur|shadow]
[animation]       # + [animation.<event>] tables, [animation.beziers], [animation.springs]
[effects]         # + [effects.preset.<name>], [effects.pool.<name>]
[[window_rule]]   # per-app behavior
[[layer_rule]]    # layer-shell blur etc.
[[scratchpad]]    # named scratchpads
[[security_context_rule]] # sandboxed-client protocol grants
```

## Common pitfalls

- `Mod` in chords is `general.mod_key` (Super by default, Alt when nested).
- Action arguments are separate words inside the bind string, never colon-joined:
  `"spawn kitty"`, `"workspace-switch 3"`, not `"spawn:kitty"`. Flags `--output`,
  `--window`, `--name` qualify some actions; quotes group words with spaces.
- Including a bundled effect's `effect.toml` only registers the preset; you must also
  select it (`[effects] border = "pulse"` or `[animation.windows_in] effect = "reveal"`).
- Defining any `[[scratchpad]]` removes the implicit `default` scratchpad; every
  scratchpad action then needs the name as its last word (`scratchpad-toggle music`).
- TOML types are semantic: `default_workspace = 2` (int) is a 1-based position,
  `default_workspace = "2"` (string) is a name. In action selectors, `--name 2` forces
  the name instead of the position.
- Window rules: every matching rule contributes; when two set the same field, the later
  rule wins. Regexes match anywhere — anchor with `^...$` for exact matches.
- `[include]` files apply in list order and the including file applies last; tables
  merge, rule lists accumulate, plain arrays and scalars are replaced by the last setter.
- Only floating windows minimize (title bar, taskbar, `window-minimize`); tiled, pinned,
  fullscreen, and scratchpad windows cannot. `window-toggle-floating` needs a tiling
  layout — stacking windows already float.
- X11 support needs `Xwayland` installed and on `PATH`; it starts lazily.
