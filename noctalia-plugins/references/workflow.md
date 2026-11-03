# Workflow, Testing & Publishing

## Where plugins live

| What | Where |
| --- | --- |
| Hand-placed local plugin | `~/.local/share/noctalia/plugins/<plugin>/` (built-in `local` source) |
| Custom `path` source | any directory you own; read-only to Noctalia, no git operations |
| Git source cache | `~/.local/state/noctalia/plugins/sources/<source>/` |
| Exported git runtime files | `~/.local/state/noctalia/plugins/materialized/<source>/<plugin>/` (do not edit) |
| Persistent plugin data | `noctalia.pluginDataDir()` (usually under the state dir; created `0700`) |

All paths honor `XDG_DATA_HOME`, `XDG_STATE_HOME`, and the `NOCTALIA_*` overrides.
A `path` source is the cleanest development setup: one directory can hold several
plugin subdirectories, edits stay where you wrote them, and Noctalia never rewrites
them.

```toml
# ~/.config/noctalia/config.toml
[[plugins.source]]
name = "my-dev"
kind = "path"
location = "~/dev/noctalia-plugins"
enabled = true
```

Place each plugin at `<location>/<plugin>/plugin.toml`; the directory name should
match the part after `/` in the plugin id (`me/hello` → `hello/`).

## Enable and manage

```bash
noctalia msg plugins list
noctalia msg plugins enable me/hello
noctalia msg plugins disable me/hello
noctalia msg plugins update official
noctalia msg plugins source list
noctalia msg plugins source add my-dev path ~/dev/noctalia-plugins
noctalia msg plugins source add my-repo git https://github.com/me/my-plugins
noctalia msg plugins source remove my-dev
```

Installed does not mean enabled. Enabling a git plugin exports just that plugin's
directory into `materialized/`. Disabling keeps code and settings. The built-in
`official` and `community` sources can be updated/enabled/disabled but not removed
from Settings or IPC.

`[plugins]` in config:

```toml
[plugins]
enabled = ["me/hello"]
auto_update = "all"        # "all" | "official" | "none"; boolean form is invalid
```

The GUI writes runtime overrides to `settings.toml`; a `[plugins].enabled` override
there wins until removed or edited. `auto_update` updates on startup and every six
hours.

## Editor setup (optional)

The official repo ships `noctalia.d.luau`, a Luau definition file declaring every
injected global (`noctalia.*`, `barWidget.*`, `shortcut.*`, `launcher.*`,
`desktopWidget.*`, `panel.*`, `layer.*`, `ui.*`) and the entry callbacks. Point
[luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) at it via
`types.definitionFiles` to get autocomplete and typo diagnostics. Set
`languageMode = "nonstrict"` in `.luaurc` to match `--!nonstrict`. Type annotations
are compiled away at runtime.

When contributing translations to a community plugin, edit only
`translations/en.json`; other locales are maintained through
[Noctalia Translate](https://i18n.noctalia.dev).

## Development loop

1. Write the plugin under your dev directory.
2. Lint offline:
   ```bash
   noctalia plugins lint ~/dev/noctalia-plugins/hello
   ```
3. Enable once; after that `.luau` edits hot-reload automatically.
4. Manifest changes need a config reload:
   ```bash
   noctalia msg config-reload
   ```
5. Drive handlers over IPC:
   ```bash
   noctalia msg plugin me/hello:hello focused set "Hi there"
   noctalia msg plugin me/hello:ticker all refresh
   noctalia msg panel-toggle me/hello:panel
   noctalia msg panel-open me/hello:panel "context"
   noctalia msg panel-close me/hello:panel
   ```
6. Watch the shell log for Luau errors, unknown UI props, and setting warnings.
   `noctalia.log()` writes with the plugin's script context; `notifyError()` is
   useful for user-visible failures during development.
7. Validate any user config you touched:
   ```bash
   noctalia config validate
   ```

### What lint catches

`noctalia plugins lint [path ...]` cross-checks declared settings against the code.
It works without a running shell and exits non-zero on errors.

```text
me/test
  error  w.luau:1  reads undeclared setting 'not_declared'
  warn   plugin  declared setting 'declared_but_unused' (plugin-level) is never read

1 error, 1 warning
```

- **Error:** `getConfig` reads a key with no matching declaration.
- **Warning:** a declared setting is never read (dead UI, or code moved).
- Lint also parses the manifest and checks setting types/defaults.

Run it on the plugin directory, not just `plugin.toml`, so scripts are checked.
Fix warnings too: an unused setting is usually a bug or an unfinished feature.

### Debug checklist

| Symptom | Check |
| --- | --- |
| Plugin not listed | id/folder, source enabled, `noctalia msg plugins list` |
| `incompatible` | `plugin_api` too high for the shell |
| `held-back` | source has a newer version requiring a higher API; previous copy retained |
| Nothing renders | entry script syntax error, wrong entry id, widget not added to a bar |
| Bar tree missing controls | `ui.input`/`select`/`scroll` are not available in bars |
| Panel empty | render in `onOpen`; panel only has padding before first render |
| Setting ignored | key not declared, or user `settings.toml` override wins |
| Icon labels blank | missing `translations/en.json` keys or wrong `label_key` |
| Manifest change ignored | `noctalia msg config-reload` |
| IPC does nothing | wrong target; services/panels need `all`; wrong event name |
| Panel too large/small | size is manifest-owned; use `"fill"` or `"content"` + `max_height` |

## User-side configuration

### Bar widget instance

```toml
[widget.hello]
type = "me/hello:hello"
label = "Hi"
glyph = "hand"
show_glyph = true

[widget.hello.actions]
right = "none"             # free the right click for onRightClick
scroll_up = "volume-up"
```

Widget settings are direct keys under `[widget.<name>]`. `string_map` settings use a
subtable:

```toml
[widget.display.output_glyphs]
"eDP-1" = "laptop"
"DP-1" = "monitor"
```

### Panel placement

The host injects `<entry>_placement`, `<entry>_position`, `<entry>_open_near_click`,
and `<entry>_layer`:

```toml
[plugin_settings."me/hello"]
panel_placement = "floating"
panel_position = "center"
panel_open_near_click = false
```

### Desktop widget instance

Desktop widgets are placed and sized by the editor, but the type and settings are
config:

```toml
[desktop_widgets]
enabled = true

[desktop_widgets.widget.hello]
type = "me/hello:desktop"
output = "DP-1"
cx = 960.0
cy = 540.0
box_width = 0.0
box_height = 0.0

[desktop_widgets.widget.hello.settings]
color = "primary"
```

### Plugin settings

```toml
[plugin_settings."me/hello"]
interval = 5
```

`noctalia config export --credentials omit` leaves out settings marked `secret = true`
(API 47, unreleased in 5.4.1); `--credentials blank` empties them.

## Publishing

### Repository layout

A source repo holds many plugins, each in its own subdirectory matching the part
after `/`:

```text
my-plugins/
  catalog.toml
  hello/
    plugin.toml
    widget.luau
    panel.luau
    translations/en.json
    README.md
    thumbnail.webp
  timer/
    plugin.toml
    ...
```

### `catalog.toml`

```toml
[[plugin]]
id = "me/hello"
name = "Hello"
version = "1.0.0"
author = "me"
license = "MIT"
icon = "puzzle"
description = "A friendly greeter."
deprecated = false
plugin_api = 3
tags = ["demo"]
dependencies = ["slurp"]
```

Catalog rows require `id`, `name`, and a positive integer `plugin_api`; rows without
them are ignored. Keep `version`, `plugin_api`, and metadata in sync with
`plugin.toml`.

### Releasing for older shells

Add `[[plugin.release]]` rows when the tip raises `plugin_api`:

```toml
[[plugin]]
id = "me/hello"
version = "2.0.0"
plugin_api = 9

[[plugin.release]]
plugin_api = 3
version = "1.4.0"
rev = "5082ed5f85e795513b8485e4cedc66d5a2c816ff"
```

Rows need a full 40-character `rev`; the host installs the newest release its API
range allows. Release rows only apply to git sources. Generate them by walking
`git log -- <subdir>/plugin.toml` newest-first and keeping each revision that lowers
the API level; `update-catalog.py` in the official/community repos automates this
(requires full history, `fetch-depth: 0`).

### Community store submission

Open a PR against
[`noctalia-dev/community-plugins`](https://github.com/noctalia-dev/community-plugins).
Its README has the submission rules. A submission ships:

- `plugin.toml` and every entry script/asset it loads;
- `README.md` (the store detail page renders it);
- `thumbnail.webp`;
- `translations/en.json`.

CI validates all of it and regenerates `catalog.toml` on merge. Directory names are
first-come in that repo, so pick a unique plugin name. README images must be inside
the plugin directory (PNG/JPEG/WebP/GIF); remote URLs and paths outside it render as
alt text. Images show at their pixel size times UI scale, shrunk to page width and
at most 480 px tall. Animated GIFs show their first frame.

`official-plugins` is maintained by the core team and does not accept third-party
plugins.

### Release checklist

- [ ] `noctalia plugins lint <dir>` clean.
- [ ] Plugin enabled and exercised on the target shell.
- [ ] `plugin_api` is the minimum, not the shell version.
- [ ] Version bumped in both `plugin.toml` and `catalog.toml`.
- [ ] `translations/en.json` covers every settings label/description and UI string.
- [ ] README and thumbnail included; screenshots are inside the plugin directory.
- [ ] No absolute paths, no secrets, no writes to `pluginDir()`.
- [ ] Cleanup in `onExit`; no leaked subprocesses or streams.
- [ ] If raising `plugin_api`, add catalog release rows for older shells.
