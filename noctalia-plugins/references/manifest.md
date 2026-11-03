# Manifest & Settings

The manifest is static: Noctalia parses it to discover the plugin, its entries, its
settings, and its compatibility level. Script changes hot-reload; manifest changes
are picked up on the next config reload.

## Directory layout

```text
my-plugin/
  plugin.toml            # manifest (required)
  widget.luau            # entry script(s)
  panel.luau
  service.luau
  lib/format.luau        # optional relative module (plugin_api 22)
  translations/en.json   # optional but required for settings labels
  data.txt               # any runtime asset
  README.md              # required for the community store
  thumbnail.webp         # required for the community store
```

The plugin id is `<author>/<plugin>`. In a source repo the directory name must be
the part after `/`, so `me/hello` lives in `hello/`. Local installs may use any
directory name; the id in `plugin.toml` is authoritative.

## Minimal manifest

```toml
id = "me/hello"          # required, globally unique
name = "Hello"           # required
version = "1.0.0"        # required, exactly MAJOR.MINOR.PATCH
plugin_api = 3           # required, oldest API level the plugin needs
author = "me"
license = "MIT"          # optional, defaults to MIT
icon = "puzzle"          # optional, Tabler glyph name
description = "A friendly greeter."

[[widget]]
id = "hello"
entry = "widget.luau"
```

## Top-level fields

| Field | Required | Notes |
| --- | --- | --- |
| `id` | yes | `<author>/<plugin>`; globally unique |
| `name` | yes | display name |
| `version` | yes | `MAJOR.MINOR.PATCH`, decimal, no leading zeros, no prerelease/build suffix |
| `plugin_api` | yes | positive integer; minimum API level, not the shell version |
| `author` | no | author name |
| `license` | no | defaults to `MIT` |
| `deprecated` | no | soft status marker in listings |
| `icon` | no | glyph name |
| `description` | no | store description |
| `tags` | no | array of catalog search tags |
| `dependencies` | no | external tools/packages the user should install; metadata only, does not block enabling |

`plugin_api` is cumulative: leave it unchanged until the plugin adopts a capability
introduced by a newer level. See `compatibility.md` for the complete table.

## Entry kinds

Each entry declares an `id` unique within the plugin, an `entry` file, and optional
settings. The entry is addressed as `<author>/<plugin>:<entry-id>`.

| Table | Kind | Runs |
| --- | --- | --- |
| `[[widget]]` | bar widget | placed on a bar; ticks and handles pointer/IPC |
| `[[shortcut]]` | control-center tile | toggle tile in the control center |
| `[[launcher_provider]]` | launcher provider | answers queries behind a prefix |
| `[[desktop_widget]]` | desktop widget | tile on the desktop; declarative UI |
| `[[panel]]` | panel | pop-up surface opened by id; declarative UI |
| `[[layer]]` | layer surface | plugin-owned layer-shell surface; declarative UI |
| `[[service]]` | headless service | background loop with no UI; feeds other entries |

### `[[widget]]`

```toml
[[widget]]
id = "hello"
entry = "widget.luau"
hover_highlight = false          # optional, plugin_api 34; put BEFORE sub-tables

  [[widget.setting]]
  key = "label"
  type = "string"
  label_key = "settings.label.label"
  default = "Hello"

[widget.actions]                 # optional gesture defaults, plugin_api 14
right = "media toggle"
scroll_up = "volume-up"
```

- A user binding in `[widget.<name>.actions]` takes precedence over the script's
  `onClick` / `onRightClick` / `onScroll`.
- Every widget has a built-in `middle` binding that opens its settings, so
  `onMiddleClick` does not fire unless `middle = "none"` is declared here or in the
  user's config.
- `hover_highlight = false` disables only the bar's whole-widget hover tint; it
  must appear before any `[widget.*]` sub-table or TOML attaches it to that table.
- Gesture keys: `left`, `right`, `middle`, `back`, `forward`, `scroll_up`,
  `scroll_down`, `scroll_left`, `scroll_right`.
- Action values: an IPC command such as `"panel-toggle control-center calendar"`,
  a shell command prefixed with `"exec "`, or `"none"`.

### `[[panel]]`

```toml
[[panel]]
id = "panel"
entry = "panel.luau"
width = 420
height = 410
placement = "floating"           # attached | floating (default floating)
position = "center"              # auto | center | screen anchor
open_near_click = false
dismiss_on_outside_click = true  # plugin_api 8
keyboard_focus = "on_demand"     # on_demand | exclusive | none, plugin_api 10
persistent = false               # plugin_api 11
capture_keys = ["space", "ctrl+r"] # plugin_api 13
```

| Key | Notes |
| --- | --- |
| `width`, `height` | positive logical px, `"fill"`, or (height only) `"content"` with `max_height` (plugin_api 42). `"fill"` requires `placement = "floating"` |
| `placement` | `attached` anchors to the bar edge; `floating` is detached |
| `position` | `auto`, `center`, or `top_left` / `top_center` / `top_right` / `center_left` / `center_right` / `bottom_left` / `bottom_center` / `bottom_right` |
| `open_near_click` | open near the widget that toggled it instead of at `position` |
| `dismiss_on_outside_click` | default `true`; set `false` for auth-style prompts |
| `keyboard_focus` | initial focus: `on_demand` (default), `exclusive`, or `none`. `none` requires `dismiss_on_outside_click = false` and cannot combine with `capture_keys` |
| `persistent` | stays outside the one-panel slot; requires `dismiss_on_outside_click = false`; `keyboard_focus = "exclusive"` is rejected |
| `capture_keys` | chords delivered to the panel's `onKey(chord, pressed)` while focused; declared chords only; Escape is always the host's cancel; Super chords rejected |
| `layer` | floating panel layer: `follow` (default), `top`, or `overlay`. Declaring any `layer` value in the manifest requires plugin_api 30; declaring `follow` explicitly requires 49 |

The host injects four panel settings under `[plugin_settings."author/plugin"]`:
`<entry>_placement`, `<entry>_position`, `<entry>_open_near_click`, and
`<entry>_layer` where applicable. Do not declare them yourself unless you need a
custom key.

Panel `height = "content"` follows the rendered tree up to `max_height`; content
taller than that needs a `ui.scroll` with `flexGrow = 1`. Persistent panels cannot
use `height = "content"`, and cannot use `ui.select` dropdowns.

### `[[layer]]`

A layer is a plugin-owned layer-shell surface. Requires `plugin_api >= 36`; a
manifest with `[[layer]]` below 36 is rejected.

```toml
[[layer]]
id = "saver"
entry = "saver.luau"
layer = "overlay"                # background | bottom | top | overlay (default top)
anchors = ["top", "bottom", "left", "right"]
keyboard = "exclusive"           # none | on_demand | exclusive
exclusive_zone = -1              # integer >= -1 or "auto"
click_through = false
output = "all"                   # all | focused | connector name
visible = false                  # show as soon as the plugin loads
```

| Key | Notes |
| --- | --- |
| `layer` | `background`, `bottom`, `top` (default), or `overlay` |
| `anchors` | any distinct subset of `top`/`bottom`/`left`/`right`; empty centers the surface |
| `width`, `height` | logical px, 0–65536; `0` stretches when anchored on both opposite edges, otherwise sizes to content |
| `margins` | table with integer `top`, `right`, `bottom`, `left`; missing sides are 0 |
| `exclusive_zone` | `-1` ignores other zones, `0` reserves none, `n` reserves n px; `auto` reserves the surface extent perpendicular to its single anchored edge |
| `keyboard` | `none` (default), `on_demand`, or `exclusive`; `on_demand` focus behavior is compositor-dependent, `exclusive` takes every key while shown |
| `click_through` | empty input region; pointer reaches below |
| `output` | `all` (default), `focused` (picked when shown), or a connector name |
| `visible` | `false` (default); `true` shows the layer as soon as the plugin loads |

The surface namespace is fixed to
`noctalia-plugin:<author>/<plugin>:<entry>` for compositor layer rules. Layers do
not support entry-level settings; use plugin-level `[[setting]]`.

### `[[desktop_widget]]`

```toml
[[desktop_widget]]
id = "desktop"
entry = "desktop.luau"

  [[desktop_widget.setting]]
  key = "color"
  type = "color"
  label_key = "settings.color.label"
  default = "primary"
```

The user places, sizes, rotates, and flips the tile in the desktop-widget editor.
The manifest cannot set position or size. Desktop widgets cannot take keyboard
focus, so use pointer controls, not `ui.input` / `ui.select`.

### `[[shortcut]]`

```toml
[[shortcut]]
id = "toggle"
entry = "shortcut.luau"
```

The script sets the label, icon, active state, and enabled state. Add the tile from
Settings → Control Center shortcuts.

### `[[launcher_provider]]`

```toml
[[launcher_provider]]
id = "finder"
entry = "finder.luau"
prefix = "ex"                    # bare word; user types /ex
glyph = "list-search"            # default result icon
include_in_global_search = false # also answer un-prefixed searches
debounce_ms = 0                  # wait after last keystroke before onQuery
```

`prefix` is shown in the launcher's `/` overview; do not include the `/` yourself.
Set `debounce_ms` for network-backed providers so `onQuery` is not called on every
character.

### `[[service]]`

```toml
[[service]]
id = "ticker"
entry = "ticker.luau"
```

A service is a singleton with no output. It participates in IPC only with the
`all` target.

## Settings schema

Settings become typed controls in the settings GUI and are read with
`noctalia.getConfig(key)`. Only declared keys resolve.

### Scopes

| Scope | Declaration | Edited in | Read by |
| --- | --- | --- | --- |
| plugin-level | `[[setting]]` at manifest root | Settings → Plugins (gear) | every entry; seeded into all |
| widget | `[[widget.setting]]` under a `[[widget]]` | that bar widget's settings | that widget |
| panel | `[[panel.setting]]` under a `[[panel]]` | Settings → Plugins (gear) | that panel |
| desktop widget | `[[desktop_widget.setting]]` under a `[[desktop_widget]]` | that desktop widget's settings | that widget |

When a widget setting and a plugin setting share a key, the widget value wins for
that widget. Layer entries have no entry settings. Use plugin-level settings for
services and shortcuts.

### Fields

```toml
[[setting]]
key = "interval"
type = "int"
label_key = "settings.interval.label"
description_key = "settings.interval.description"
default = 5
min = 1
max = 3600
```

| Field | Notes |
| --- | --- |
| `key` | required config key |
| `type` | `string`, `string_list`, `string_map` (API 6), `bool`, `int`, `double`, `select`, `file`, `folder`, `glyph`, `color` |
| `label_key` | required translation key |
| `description_key` | optional translation key |
| `default` | must match the type |
| `min` / `max` | for `int` / `double` |
| `options` | for `select`: array of `{ value, label_key }`; both required |
| `extensions` | for `file`: array such as `[".toml", ".json"]`; empty allows any |
| `visible_when` | `{ key = "other_key", values = ["true"] }`; values are strings |
| `advanced` | hide behind the "show advanced" toggle |
| `secret` | API 47 (unreleased in 5.4.1): credential for string, string_list, or string_map; export can omit/blank it |

`file` and `folder` store strings but render with a browse button. Users can still
type a path.

`string_map` stores string keys to string values and returns an associative Luau
table. Its default is a TOML table:

```toml
plugin_api = 6

[[widget.setting]]
key = "output_glyphs"
type = "string_map"
label_key = "settings.output_glyphs.label"
default = { "eDP-1" = "laptop", "DP-1" = "monitor" }
```

`select` example:

```toml
[[setting]]
key = "mode"
type = "select"
label_key = "settings.mode.label"
default = "auto"
options = [
  { value = "auto", label_key = "settings.mode.auto" },
  { value = "manual", label_key = "settings.mode.manual" },
]
```

### Reading settings

```lua
local interval = noctalia.getConfig("interval")   -- plugin-level, seeded everywhere
local label = noctalia.getConfig("label")         -- widget entry setting
local offline = noctalia.getSetting("shell.offline_mode") -- shell config, read-only
local firstBar = noctalia.getSetting("bar.order[0]")      -- arrays are zero-based
```

- `getConfig` reads the calling entry's declared plugin/entry settings. A `select`
  setting returns the selected option's `value` string; this is different from
  `ui.select`'s `onChange`, which reports an index.
- `getSetting` reads any effective shell config by TOML dotted path. Reading an
  unknown path warns and returns `nil`.
- If a shell setting the entry read changes, `onConfigChanged()` runs in place; if
  the entry has no such callback, the script reloads. Reads are tracked per entry.
- Widgets, desktop widgets, and panels are rebuilt when their plugin settings
  change, so their next `getConfig` already sees new values. Services are
  long-lived: define `onConfigChanged()` to keep timers/caches and update in place,
  otherwise the host restarts the service runtime.

## Translations

Settings labels and descriptions are always translation keys. The text lives in
`translations/<lang>.json`; a plugin with settings needs at least
`translations/en.json`. Files may be nested or flat with dotted keys:

```json
{
  "settings.interval.label": "Refresh seconds",
  "settings.interval.description": "How often the service refreshes data.",
  "panel.title": "My Panel"
}
```

or:

```json
{
  "settings": {
    "interval": {
      "label": "Refresh seconds",
      "description": "How often the service refreshes data."
    }
  }
}
```

Use `noctalia.tr(key)`, `noctalia.tr(key, { name = value })`, `noctalia.trp(key,
count)`, and `noctalia.trp(key, count, subst)`. The plural helper prefers
`<key>.one` / `<key>.other`, then the bare key. Missing keys fall back to the key
itself.

## Manifest checks performed by the shell

- `id`, `name`, `version`, and `plugin_api` are mandatory.
- `version` must be exactly `MAJOR.MINOR.PATCH` with no suffixes.
- `plugin_api` must be a positive integer in the supported range.
- `string_map` requires API 6; `[widget.actions]` API 14; panel options have their
  own minimums; `[[layer]]` requires API 36.
- `secret = true` is only valid on string, string_list, or string_map settings.
- Entry ids must be unique within the plugin.
- Invalid layer values fail with a message such as
  `layer entry 'saver': layer must be "background", "bottom", "top", or "overlay"`.

`noctalia plugins lint <dir>` catches settings problems before the shell does.
