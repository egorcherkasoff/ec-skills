# Installation

Prefer a distribution package when available (simplest install and upgrade path).
Distribution packages and third-party repositories are maintained by their respective
maintainers — review a repository before installing from it.

## Distribution packages

| Distro | Source | Install |
| --- | --- | --- |
| Arch | AUR `umbriel-git` | `yay -S umbriel-git` |
| Fedora | Terra (nightly builds) | `sudo dnf install umbriel-nightly` |
| openSUSE | Noctalia OBS repo (`umbriel-git`) | see below |
| Debian/Ubuntu | NickH APT repo `pkg.noctalia.dev` | see below; `amd64`/`arm64` only |
| Guix | `midnight` channel | `guix pull`, then `umbriel` + `xdg-desktop-portal-umbriel` |
| Void | `UniversalRepository` | see below |

### openSUSE

Tumbleweed or Slowroll:

```sh
sudo zypper addrepo --refresh --name Noctalia \
  https://download.opensuse.org/repositories/home:neifua:Noctalia/openSUSE_Tumbleweed/home:neifua:Noctalia.repo
sudo zypper refresh && sudo zypper install umbriel-git
```

Use `openSUSE_Slowroll` in the URL for Slowroll.

### Debian and Ubuntu

Add the signing key, then the source matching your distribution (trixie / sid / Ubuntu
26.04 / Ubuntu 26.10):

```sh
wget https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb
sudo dpkg -i nickh-archive-keyring.deb

sudo wget -O /etc/apt/sources.list.d/noctalia-trixie.sources \
  https://pkg.noctalia.dev/deb/noctalia-trixie.sources
# sid: noctalia-unstable.sources  26.04: noctalia-resolute.sources  26.10: noctalia-stonking.sources

sudo apt update
sudo apt install -t trixie-backports umbriel   # Debian trixie
sudo apt install umbriel                        # sid, Ubuntu 26.04/26.10
```

### GNU Guix

Add the third-party `midnight` channel to `~/.config/guix/channels.scm`:

```scheme
(channel
  (name 'midnight)
  (url "https://codeberg.org/stampede/midnight.git")
  (branch "main")
  (introduction
    (make-channel-introduction
      "d97d1568954cfcbf543c9fcdfd5771e2b730ae19"
      (openpgp-fingerprint
        "640A 2C3C E948 22D3 394B 40C3 CAFA EECA 00FF 9B1E"))))
```

`guix pull`, then install `umbriel` and `xdg-desktop-portal-umbriel`. Adding them to
the system configuration makes the Umbriel session available to display managers.

## NixOS

Flake input plus module:

```nix
inputs.umbriel.url = "github:noctalia-dev/umbriel";

{ inputs, ... }: {
  imports = [ inputs.umbriel.nixosModules.default ];
  programs.umbriel.enable = true;
}
```

The module installs Umbriel, registers the display-manager session, enables required
graphics support, and installs/configures `xdg-desktop-portal-umbriel`. Set
`programs.umbriel.portalPackage = null` only when another portal setup provides those
services. Rebuild, then pick Umbriel in the display manager or run `start-umbriel`
from a TTY.

Home Manager (`inputs.umbriel.homeModules.default`) and hjem
(`inputs.umbriel.hjemModules.default`) write the user config from Nix. `settings` is an
attrset serialized to TOML; Home Manager also accepts a raw TOML string or a path:

```nix
programs.umbriel = {
  enable = true;
  settings = {
    general.autostart = [ "noctalia" ];
    layout.gap = 5;
    keybinds."Mod+Return" = "spawn kitty";
  };
};
```

When `settings` is omitted, both modules leave the user configuration path untouched,
so Umbriel loads its packaged configuration.

### Binary cache

Pre-built `x86_64-linux` and `aarch64-linux` packages from Cachix:

```nix
nix.settings = {
  extra-substituters = [ "https://umbriel.cachix.org" ];
  extra-trusted-public-keys = [
    "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
  ];
};
```

Umbriel must use the locked `nixpkgs` input it was built against for the cache to
match: do not set `inputs.umbriel.inputs.nixpkgs.follows`. Track the `cachix` branch
(`github:noctalia-dev/umbriel/cachix`) — it points at the latest commit CI cached
successfully; `main` may point at binaries not built yet.

### Bundled effects

The module links bundled effect presets to a path stable across rebuilds:
`/run/current-system/sw/share/umbriel/effects`. Use it in `[include]` instead of
`/usr/share/umbriel/effects`:

```toml
[include]
files = [
  "/run/current-system/sw/share/umbriel/effects/border/pulse/effect.toml",
]
```

Only `effects` is linked; the example `config.toml` is not (still packaged under
`share/umbriel`). With a Nix-generated config, reference the package directly:
`"${config.programs.umbriel.package}/share/umbriel/effects/border/pulse/effect.toml"`.

## Void Linux

```sh
echo 'repository=https://universalrepo.pages.dev/void' | sudo tee /etc/xbps.d/10-universalrepository.conf
sudo xbps-install -S
sudo xbps-install -S umbriel
```

## Manual build

No automatic upgrade path — prefer a distribution package. UmbrielFX builds as part of
the source tree; no separate SceneFX package is needed.

Install a C++23 compiler, Meson, Ninja, `just`, `pkg-config`, `wayland-scanner`, and
the dev packages listed in upstream `PACKAGING.md`, then:

```sh
git clone https://github.com/noctalia-dev/umbriel.git
cd umbriel
just configure release /usr/local
just release
sudo meson install -C build-release --no-rebuild
```

Release binary: `build-release/umbriel`; `just debug` builds `build-debug/umbriel`.
Release builds omit unit tests, harness clients, and harness-only IPC commands;
packagers can force `-Dtests=disabled -Dharness=disabled`.

- libxkbcommon >= 1.10.0 required at build and runtime (pkg-config `xkbcommon`; Umbriel
  uses its server-side modifier API to preserve keyboard locks and latches).
- X11 window shapes need `xcb-shape` from libxcb. Debian/Ubuntu: `libxcb-shape0-dev`
  (build) + `libxcb-shape0` (runtime). openSUSE: `libxcb-devel` + `libxcb-shape0`.
  Arch, Fedora, Alpine, Nix, Guix, Void bundle the shape library with libxcb.
- `jemalloc` optional, recommended on glibc. Default `-Djemalloc=auto` uses it when the
  dev package is installed; force with `-Djemalloc=enabled|disabled`; `auto` skips it
  on non-glibc.
- Default prefix `/usr/local`, stored in the build directory at configure time. For a
  home prefix, configure it explicitly — the automatic configure in `just release` /
  `just install` does not forward a `prefix=` override, and an existing build directory
  keeps its stored prefix (check with `meson configure build-release`):

```sh
just configure release "$HOME/.local"
just release
just install
```

- User-local installs: put `$HOME/.local/bin` on `PATH` in the login profile, and link
  the session units before starting a native session (session entry lands under
  `$HOME/.local/share/wayland-sessions`; display-manager search paths vary, so the menu
  may need DM configuration; TTY start via `start-umbriel` works regardless):

```sh
systemctl --user link \
  "$HOME/.local/lib/systemd/user/umbriel.service" \
  "$HOME/.local/lib/systemd/user/umbriel-session.target" \
  "$HOME/.local/lib/systemd/user/umbriel-shutdown.target"
systemctl --user daemon-reload
```

### Building with Nix

`nix build` → binary at `result/bin/umbriel`. Development: `nix develop` then
`just debug`. Unit tests, the headless compositor harness, and contributor checks are
described in upstream `CONTRIBUTING.md` (Development Commands).

## Starting Umbriel

Installed display-manager sessions start Umbriel through `start-umbriel`. Select
Umbriel in the display manager, or from a TTY:

```sh
start-umbriel
```

- `start-umbriel` loads the login profile for supported shells (bash, zsh, fish).
  Profile environment, including `PATH`, is available to Umbriel and session
  applications; interactive shell files such as `~/.zshrc` are not loaded.
- In a systemd-managed session, the launcher imports the login environment into the
  user manager before starting Umbriel. Login-profile values take precedence over
  same-named `environment.d` values; user-manager-only variables remain available. The
  direct fallback inherits the same login environment without importing it.
- In a managed native session, startup, autostart, event, and `spawn` commands run in
  scopes bound to the compositor service and are cleaned up when the session ends.
  Requires systemd >= 254.
- The compositor service queues the graphical session targets at startup and reports
  readiness only after its display and IPC sockets are available and the session
  environment is published to systemd and D-Bus. Services ordered after
  `graphical-session.target` — including desktop portals — wait for that readiness;
  configured startup commands wait for the environment import to finish.
- Run `umbriel` directly only for a nested development session or an explicitly
  unmanaged launch.

## Screen sharing

Portal-aware applications (Discord, browsers) need
`xdg-desktop-portal-umbriel`. On rotated or flipped outputs the shared cursor may
appear offset (wlroots 0.20.2 cursor metadata issue).

Picker missing after login:

- Start the session through `start-umbriel` and install the matching `umbriel.service`
  alongside the compositor binary. The packaged service uses `Type=notify` to hold the
  graphical session targets until Umbriel is ready; portal services with
  `After=graphical-session.target` then inherit the published session environment. No
  portal service override is required.
- If still missing, inspect the logs:

```sh
systemctl --user cat umbriel.service
journalctl --user -b \
  -u xdg-desktop-portal.service \
  -u xdg-desktop-portal-umbriel.service \
  -u xdg-desktop-portal-gtk.service \
  --no-pager
```

- A portal already running before the session startup transaction can retain an
  earlier environment. Umbriel does not automatically restart portal services. Nested
  and unmanaged launches lack the packaged service's readiness ordering.

## Logs

- Main log: `$XDG_CACHE_HOME/umbriel/umbriel.log` (fallback `~/.cache/umbriel/umbriel.log`).
  The previous file is kept as `umbriel.log.1` when the current log reaches 1 MiB.
- wlroots messages appear with the `[wlr]` tag at info level and above. Set
  `UMBRIEL_WLR_DEBUG=1` in Umbriel's environment to include wlroots debug output when
  reporting rendering or display problems.
- When stdout/stderr is a TTY, raw writes from Umbriel and its children are redirected
  to `$XDG_CACHE_HOME/umbriel/umbriel-stderr.log`
  (fallback `~/.cache/umbriel/umbriel-stderr.log`).
