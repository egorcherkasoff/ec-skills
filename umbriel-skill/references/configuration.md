# Configuration

## File locations and lookup

Without `-c`, Umbriel checks in order:

1. `$XDG_CONFIG_HOME/umbriel/config.toml`
2. Each `$XDG_CONFIG_DIRS/umbriel/config.toml`
3. The packaged `share/umbriel/config.toml`

Use `umbriel -c <path>` to select one exact file. Umbriel never creates or modifies a
user configuration automatically.

Starting config (packaged example is upstream `examples/config.toml`):

```sh
mkdir -p ~/.config/umbriel
cp /usr/share/umbriel/config.toml ~/.config/umbriel/config.toml
```

Manual installs place it at `/usr/local/share/umbriel/config.toml`. Nix users should
prefer `programs.umbriel.settings` (Home Manager / hjem).

## Reload and diagnostics

- Umbriel watches the active configuration and applies valid changes on save. Most
  options reload immediately; restart-required ones are listed below. A failed reload
  keeps the last working configuration and retries on the next save.
- Warnings/errors appear in a panel on the primary output. A warning-only panel closes
  after 10 s; an error stays until the next successful reload.
- Every diagnostic is also written to `umbriel.log` with the same file, line, and
  column. Diagnostics are logged where a load's outcome is decided; a refused
  `umbriel config set` / `config replace` writes nothing (load rolled back).

```sh
umbriel config validate          # check a file without starting the compositor
umbriel config validate --json   # one JSON object: valid, path, diagnostics[]
umbriel config schema            # per-section option counts
umbriel config schema --json     # every key: path, type, range, values, format, default
```

- `config validate` prints every diagnostic with file/line/column and exits nonzero on
  any problem. `--json` (or `-j`) prints `{"valid", "path", "diagnostics"}`; each
  diagnostic has `severity` (`"error"` / `"warning"`), `message`, `file`, `line`,
  `column` (location fields `null` when unknown); exit status is unchanged.
- `config schema --json` also prints the binary's `version` and `revision` (`null` for
  a build outside git). `name[]` marks array-of-table entries
  (e.g. `window_rule[].match.app_id`); `<name>` marks a user-chosen name
  (e.g. `output.<name>.scale`).

Restart-required options: `general.autostart`, `general.xwayland`,
`general.xwayland_native_resolution`, `general.xwayland_xsettings`, everything under
`[drm]`, everything under `[environment]`. `general.xwayland_primary_output` and
`general.nvidia_sync_workaround` apply on reload.

## Runtime overrides

Change values in the running session without editing the file:

```sh
umbriel config set input.touchpad.enabled false
umbriel config get input.touchpad.enabled
umbriel config unset input.touchpad.enabled
umbriel config unset --all
```

- `set <key> <value>` takes a dotted key (as in `config schema --json`) and a TOML
  value. Quote strings for shell and TOML: `config set appearance.title_bar.font
  "'Inter 10'"`; quote key segments holding dots/punctuation: `'output."HDMI-A-1".scale'`.
- A table/array value replaces what the file holds at that key: rule lists such as
  `[[window_rule]]` cannot be extended one entry at a time; `include` cannot be set.
- Overrides live in memory only — never written, last until exit, stay on top of the
  file through reloads and `config-replace`. A value producing any new error or warning
  is refused and changes nothing (the reply lists why). Relative shader/profile paths
  need a file to resolve against — use absolute paths in overrides.
- `get <key>` prints the active value (override, else file, else built-in default);
  strings bare, other values as JSON; a table key prints the whole table. `--json`
  replies `{"value": ..., "override": true|false}`. `unset <key>` drops one override;
  `unset --all` drops every override.

## Include

```toml
[include]
files = [
  "appearance.toml",
  "keybinds.toml",
]

[include.optional]
files = [
  "~/.config/umbriel/noctalia.toml",
]
```

- Paths are relative to the file containing the include. `~`, `$VAR`, `${VAR}` expand.
- Missing optional files are ignored *and watched*: creating one later triggers a reload.
- Files apply in list order; the including file applies last.
- Merge semantics: tables merge by key; rule lists (`[[window_rule]]`, `[[workspace]]`,
  ...) collect entries; plain arrays and scalars are replaced by the last file that sets
  them; setting a rule list to `[]` discards entries collected earlier.
- Every file must be valid TOML. Duplicate device or workspace selectors, and an
  effect preset defined in two files, are errors even when they come from different
  files. At startup any configuration error means default configuration plus an error
  banner; a reload keeps the previous configuration.
- If any included file defines `[drm]`, also declare `[drm]` in the main file — this
  prevents an incomplete GPU exclusion policy from loading when an include is
  unavailable.

## General

```toml
[general]
autostart = ["noctalia", "kitty"]
mod_key = "Super"
xwayland = true
xwayland_native_resolution = false
xwayland_xsettings = true
xwayland_primary_output = ""
nvidia_sync_workaround = true
show_cheatsheet = true
focus_on_activate = false
attach_modal_dialogs = true
honor_restored_maximize = false
```

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `autostart` | string array | `[]` | Started once with the session. Restart. No activation token or recorded placement. |
| `mod_key` | string | Super / Alt nested | What `Mod` means in keybinds. Schema enum: Super, Alt, Ctrl, Shift. |
| `xwayland` | bool | `true` | Lazy Xwayland start for X11 apps; `Xwayland` must be on `PATH`. Restart. |
| `xwayland_native_resolution` | bool | `false` | X11 apps see physical output size. Restart. |
| `xwayland_xsettings` | bool | `true` | Announce scale and cursor theme via XSETTINGS. Off to run your own (`xsettingsd`). Restart. |
| `xwayland_primary_output` | string | `""` | Connector or monitor identity published as X11 primary. Applies on reload. |
| `nvidia_sync_workaround` | bool | `true` | Wait for GPU completion on composed NVIDIA outputs without explicit sync. Applies on reload. |
| `show_cheatsheet` | bool | `true` | Show the keybind cheatsheet at startup. |
| `focus_on_activate` | bool | `false` | Let activation requests focus/reveal their target. |
| `attach_modal_dialogs` | bool | `true` | Attach a modal dialog to its parent: follows it and holds its input. |
| `honor_restored_maximize` | bool | `false` | Honor app maximize requests during window opening, until opening layout is acknowledged. |

- Xwayland starts when the first X11 application connects. X11 bounding shapes clip
  windows to visible regions (holes, separate rectangles); shape changes apply live and
  are preserved in overview previews, window captures, and close animations. Input
  shapes stay independent, so click-through overlays can keep drawing.
- X11 apps have no per-output scale. Default: logical size, upscaled on outputs with
  scale > 1 (soft). With `xwayland_native_resolution = true` they see physical size: a
  `3840x2160` output at scale `1.25` appears as `3840x2160`, not `3072x1728` — sharp,
  but non-scaling X11 UIs look smaller. Games benefit most.
- With `xwayland_xsettings = true`, XSETTINGS readers (GTK, Chromium, Electron, Steam)
  get the interface scale — the largest output scale at native resolution, else `1` —
  plus `[input.cursor]` `theme` and `size` (scaled the same way). At native resolution
  X11 has one scale for every output, so smaller-scale outputs look larger.

### X11 primary monitor

Some X11 games and Wine apps enumerate resolutions from the X11 primary monitor,
independently of window placement:

```toml
[general]
xwayland_primary_output = "DP-1"
```

- Accepts the same connector names and monitor identities as output sections
  (`umbriel outputs` lists them); matching is case-insensitive. An identity follows a
  display between ports; a connector selects a physical port. With several identical
  matches, the first in internal layout order wins — use a connector to distinguish.
- Applied on reload, when the monitor becomes available, and whenever the lazy
  Xwayland server restarts. Stable across focus/pointer moves. A disconnected or
  disabled monitor clears the X11 primary until it returns.
- Removing the key or setting `""` clears Umbriel's selection once, then leaves X11
  primary selection unmanaged. With the key omitted at startup, externally selected
  primaries are preserved.
- Xwayland receives the layout translated to nonnegative coordinates: the monitor at
  Umbriel's `[0, 0]` need not be at Xwayland's origin. `focus_at_startup` only places
  the cursor. Games caching monitor info may need relaunching.

### NVIDIA synchronization

`nvidia_sync_workaround = true` waits for GPU rendering to finish before presenting a
composed output frame when the renderer uses the NVIDIA driver and the output has no
explicit synchronization timeline — reduces flicker from unreliable implicit sync.
Outputs with explicit sync continue using GPU fences without the extra wait. The wait
can cause stutter or frame drops when rendering exceeds a refresh interval; set `false`
to disable (sync-related flicker may return). Applies to subsequent composed frames on
reload, survives renderer recovery. Capture synchronization is independent of it.

## DRM devices

Only for leaving a GPU unopened in a native session. Omit for automatic discovery.
Restart required.

```toml
[drm]
ignored_pci_addresses = ["0000:01:00.0"]
# ignored_devices = ["/dev/dri/by-path/pci-0000:01:00.0-card"]
```

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `ignored_devices` | string array | `[]` | Absolute card or render-node paths; prefer stable `/dev/dri/by-path` links. |
| `ignored_pci_addresses` | string array | `[]` | PCI addresses in `domain:bus:slot.function` form. |

Limits: native sessions only; startup fails if no allowed GPU initializes; secondary
GPUs must support the primary's DMA-BUF formats/modifiers; software rendering is
incompatible; with exclusions `WLR_BACKENDS` supports only `drm` (+ optional
`libinput`). Umbriel does not bind/unbind PCI drivers — configure that lifecycle in
libvirt or equivalent host tooling.

## Environment

```toml
[environment]
ELECTRON_OZONE_PLATFORM_HINT = "auto"
SDL_VIDEODRIVER = "wayland"
```

- Applies to Umbriel and commands started in its session; also published to the
  systemd user manager in managed native sessions. Nested sessions don't touch the host
  environment.
- Names must match `[A-Za-z_][A-Za-z0-9_]*`; values must be strings.
- Cannot override: `WAYLAND_DISPLAY`, `WAYLAND_SOCKET`, `DISPLAY`, `UMBRIEL_SOCKET`,
  `LIBEI_SOCKET`, `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, `XDG_SESSION_TYPE`.
- Changes require restart; fully quit and relaunch long-running applications that
  survived it. Removing a key does not clear a value already published to the user
  manager — `systemctl --user unset-environment NAME`, or wait for the user manager to
  exit.

## Events

```toml
[events]
lid_close = "notify-send 'The laptop lid is closed!'"
lid_open  = "notify-send 'The laptop lid is open!'"
```

- Runs the command for the current lid state once at startup (after the compositor IPC
  socket is ready), then on each state change — also covers signing in while the lid is
  already closed/open. Multiple lid switches: combined state stays closed while any
  switch is closed. Device removal/re-addition during suspend does not repeat a command
  unless the combined state actually changed.
- Common pattern (remove panel from desktop instead of powering off):

```toml
[events]
lid_close = "umbriel msg output-disable eDP-1"
lid_open  = "umbriel msg output-enable eDP-1"
```

## Screencast

Target-changing screencast actions ask for confirmation the first time they are used
during an active single-source share. Dismissing the panel cancels only the pending
action (invoking again asks again); approval lasts until the share ends.

```toml
[screencast]
disable_dynamic_confirmation = false
```

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `disable_dynamic_confirmation` | bool | `false` | Apply set/follow actions immediately without first-use confirmation — can expose another window or output after an accidental key press. |

## Global shortcuts

Override an application's registered shortcuts by exact application ID and shortcut ID:

```toml
[global_shortcuts."org.example.App"]
"push-to-talk" = "Mod+Shift+M"
"toggle-overlay" = ""
```

- Values use the keyboard chord syntax from keybinds; an empty string disables the
  shortcut. Mouse buttons, wheel events, modifier-only chords, and submaps are rejected.
  Invalid entries reject the configuration load (failed reload keeps current config).
- An override takes priority over the approved stored trigger and the application's
  preferred trigger, but does not change the stored preference; removing it restores
  that preference. New shortcut IDs still require physical approval. Explicit overrides
  can assign printable keys — choose carefully.
- Keybinds in the default submap, Ctrl+Alt+Escape, and VT-switch chords stay reserved.
  Live conflicts follow registration order. Reloading rebinds affected sessions and
  stops any held activation whose binding changed. `Mod` follows `general.mod_key`
  (native/nested default included).

## Scratchpads

With no `[[scratchpad]]` entries, Umbriel provides one implicit scratchpad named
`default` (`"Mod+Shift+Space" = "window-move-to-scratchpad"`,
`"Mod+Space" = "scratchpad-toggle"`). To configure several, give each a unique name and
include it in its actions. Defining a named scratchpad removes the implicit `default`:

```toml
[[scratchpad]]
name = "terminal"

[[scratchpad]]
name = "music"

[keybinds]
"Mod+Space" = "scratchpad-toggle terminal"
"Mod+M" = "scratchpad-toggle music"
```

See `references/scratchpads.md` for window assignment and behavior.

## Idle inhibition

Honored only while the application surface is mapped and visible. Switching away from
its workspace, hiding it in a scratchpad, disabling its output, or locking the session
suspends the inhibitor until the surface becomes visible again.
