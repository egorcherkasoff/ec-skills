# Configuration

## File locations and lookup

Without `-c`, Umbriel checks in order:

1. `$XDG_CONFIG_HOME/umbriel/config.toml`
2. Each `$XDG_CONFIG_DIRS/umbriel/config.toml`
3. The packaged `share/umbriel/config.toml`

Use `umbriel -c <path>` to select one exact file. Umbriel never creates or modifies a
user configuration automatically.

Starting config (packaged example is `examples/config.toml` upstream):

```sh
mkdir -p ~/.config/umbriel
cp /usr/share/umbriel/config.toml ~/.config/umbriel/config.toml
```

Manual installs place it at `/usr/local/share/umbriel/config.toml`. Nix users should
prefer `programs.umbriel.settings` (Home Manager / hjem).

## Reload and diagnostics

- Umbriel watches the active configuration and applies valid changes on save. Most
  options reload immediately; restart-required ones are called out below.
- If a reload fails, the last working configuration stays active and retries on next save.
- Warnings/errors appear in a panel on the primary output. A warning-only panel closes
  after 10 s; an error stays until the next successful reload.

```sh
umbriel config validate        # check a config without a running session
umbriel config schema          # per-section option counts
umbriel config schema --json   # every key: path, type, range, values, format, default
```

`name[]` in schema output marks array-of-table entries (e.g. `window_rule[].match.app_id`);
`<name>` marks a user-chosen name (e.g. `output.<name>.scale`). JSON also includes the
binary's `version` and `revision`.

Restart-required options: `general.autostart`, `general.xwayland`,
`general.xwayland_native_resolution`, everything under `[drm]`, everything under
`[environment]`.

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
  ...) collect entries; plain arrays and scalars are replaced by the last setter;
  setting a rule list to `[]` discards earlier entries.
- Every file must be valid TOML. Duplicate device/workspace selectors and a preset
  defined in two files are errors even across files. At startup a bad include set means
  defaults + error banner (unless `[drm]` is set, which refuses to start); on reload the
  previous config is kept.
- If any included file defines `[drm]`, also declare `[drm]` in the main file.

## General

```toml
[general]
autostart = ["noctalia", "kitty"]   # string array; restart required
mod_key = "Super"                   # Super default, Alt when nested
xwayland = true                     # restart required
xwayland_native_resolution = false  # restart required
show_cheatsheet = true
focus_on_activate = false
honor_restored_maximize = false
```

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `autostart` | string array | `[]` | Started once with the session. Restart. No activation token or recorded placement. |
| `mod_key` | string | Super / Alt nested | What `Mod` means in keybinds. |
| `xwayland` | bool | `true` | Lazy Xwayland start for X11 apps. Requires `Xwayland` on `PATH`. |
| `xwayland_native_resolution` | bool | `false` | X11 apps see physical output size (sharp on scaled outputs; X11 UIs look smaller). Games benefit most. |
| `show_cheatsheet` | bool | `true` | Show keybind cheatsheet at startup. |
| `focus_on_activate` | bool | `false` | Let activation requests focus/reveal their target. |
| `honor_restored_maximize` | bool | `false` | Honor app maximize requests during window opening. |

## DRM devices

Only for leaving a GPU unopened in a native session. Omit for automatic discovery.
Restart required.

```toml
[drm]
ignored_pci_addresses = ["0000:01:00.0"]
# ignored_devices = ["/dev/dri/by-path/pci-0000:01:00.0-card"]
```

Limits: native sessions only; startup fails if no allowed GPU initializes; secondary
GPUs must support the primary's DMA-BUF formats/modifiers; software rendering is
incompatible; with exclusions `WLR_BACKENDS` supports only `drm` (+ optional `libinput`).
Umbriel does not bind/unbind PCI drivers — configure that in the host tooling.

## Environment

```toml
[environment]
ELECTRON_OZONE_PLATFORM_HINT = "auto"
SDL_VIDEODRIVER = "wayland"
```

- Applies to Umbriel and commands started in its session; published to the systemd user
  manager in managed native sessions. Nested sessions don't touch the host environment.
- Names must match `[A-Za-z_][A-Za-z0-9_]*`; values must be strings.
- Cannot override: `WAYLAND_DISPLAY`, `WAYLAND_SOCKET`, `DISPLAY`, `UMBRIEL_SOCKET`,
  `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, `XDG_SESSION_TYPE`.
- Changes require restart; restart long-running apps too. Removing a key does not clear
  a value already published to the user manager — `systemctl --user unset-environment NAME`.

## Events

```toml
[events]
lid_close = "notify-send 'The laptop lid is closed!'"
lid_open  = "notify-send 'The laptop lid is open!'"
```

- Runs the command for the current lid state once at startup (after IPC socket ready),
  then on each state change. Multiple lid switches: combined state stays closed while
  any switch is closed.
- Common pattern (remove panel from desktop instead of powering off):

```toml
[events]
lid_close = "umbriel msg output-disable eDP-1"
lid_open  = "umbriel msg output-enable eDP-1"
```

## Screencast

```toml
[screencast]
disable_dynamic_confirmation = false
```

`disable_dynamic_confirmation = true` applies set/follow screencast actions immediately
without the first-use confirmation panel (can expose another window/output accidentally).

## Scratchpad implicit default

With no `[[scratchpad]]` entries there is one implicit scratchpad named `default`:
`"Mod+Shift+Space" = "window-move-to-scratchpad"`, `"Mod+Space" = "scratchpad-toggle"`.
Defining named scratchpads removes it. See `references/scratchpads.md`.

## Idle inhibition

Honored only while the application surface is mapped and visible (hidden workspace,
scratchpad, disabled output, or locked session suspends the inhibitor).

## Installation quick reference

- Arch: AUR `umbriel-git`. Fedora: Terra `umbriel-nightly`. openSUSE: OBS `umbriel-git`.
- Debian/Ubuntu: NickH APT repo at `pkg.noctalia.dev` (amd64/arm64; trixie-backports,
  sid, Ubuntu 26.04).
- Guix: `midnight` channel → `umbriel`, `xdg-desktop-portal-umbriel`.
- NixOS: `inputs.umbriel.url = "github:noctalia-dev/umbriel"` + module
  `programs.umbriel.enable = true` (installs DM session, portal; `portalPackage = null`
  to opt out of the portal). Cachix: `https://umbriel.cachix.org` with key
  `umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw=`; do not set
  `inputs.umbriel.inputs.nixpkgs.follows` when using the cache; track the `cachix`
  branch for cached commits.
- Manual: C++23, Meson, Ninja, just, pkg-config, wayland-scanner + deps from PACKAGING.md;
  `just release && sudo just install` (default prefix `/usr/local`, `just prefix="$HOME/.local" release`).
- Start via display manager or `start-umbriel` from a TTY. `start-umbriel` loads the
  login profile (bash/zsh/fish), not interactive rc files. Run `umbriel` directly only
  for nested/dev sessions.

## Logs

- Main log: `$XDG_CACHE_HOME/umbriel/umbriel.log` (fallback `~/.cache/umbriel/umbriel.log`).
  Rotates to `umbriel.log.1` at 1 MiB.
- With a TTY on stdout/stderr, raw output goes to `.../umbriel-stderr.log`.
