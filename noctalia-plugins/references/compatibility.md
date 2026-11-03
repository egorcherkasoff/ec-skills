# Plugin API Compatibility

`plugin_api` is the **oldest** Noctalia plugin API level the plugin requires. It is
independent of the plugin's own version and of the Noctalia release version. API
levels are cumulative: use the lowest level that includes every capability you use.

- **Noctalia 5.4.1 (latest stable):** supports plugin API **3–43**.
- **Development/docs builds:** up to **49**; levels 44–49 are marked "Unreleased"
  and a 5.4.1 shell labels them incompatible.

Verify on the target machine:

```bash
noctalia --version
noctalia msg plugins list
```

`incompatible` means the running shell is too old for the declared level.
`held-back (vX needs plugin API Y)` means a source has a newer plugin version than
the shell can run; the previously installed compatible copy is retained.

## Levels

| API | Noctalia | Introduced |
| ---: | --- | --- |
| 3 | v5.0.0-beta.3 | Mandatory `plugin_api` declaration, replacing `min_noctalia` |
| 4 | v5.0.0-beta.4 | `noctalia.httpStream()` for streaming HTTP responses |
| 5 | v5.0.0-beta.4 | `ui.dragSource()` / `ui.dropZone()` in panels |
| 6 | v5.0.0-beta.4 | `string_map` setting type |
| 7 | v5.0.0-beta.4 | `allow_insecure_tls` HTTP option |
| 8 | v5.0.0-beta.4 | `dismiss_on_outside_click` panel option |
| 9 | v5.0.0-beta.5 | Luau closures in UI tree callback props |
| 10 | v5.0.0-beta.5 | `keyboard_focus` panel option |
| 11 | v5.0.0-beta.5 | `persistent` panel option |
| 12 | v5.0.0-beta.5 | `systemStats()`, `cpuCores()`, `nowMs()` |
| 13 | v5.0.0-beta.5 | `capture_keys` panel option and `onKey` callback |
| 14 | v5.0.0-beta.5 | `[widget.actions]` gesture defaults |
| 15 | v5.0.0-beta.6 | `openSettings()` |
| 16 | v5.0.0-beta.6 | Per-interface network rates, sample timestamps, disk mount/stat APIs |
| 17 | v5.0.0-beta.7 | Services start on enable; `onExit(signal, reason)` with reload/disable/uninstall/shutdown |
| 18 | v5.0.0-beta.7 | `panel.setNeedsFrameTick()` and panel `onFrameTick` |
| 19 | v5.0.0-beta.7 | Timezone support on `formatTime`, `isValidTimezone`, `timeFormat`, `dateFormat` |
| 20 | v5.0.0-beta.7 | `sound.load()` / `sound.play()` |
| 21 | v5.0.0-beta.8 | `ui.markdown`, `submitOnEnter`, `stickToBottom` / `onScroll` / `scrollToBottomRev` |
| 22 | v5.0.0-beta.8 | `require("./path.luau")` relative modules with hot reload |
| 23 | v5.0.0-beta.8 | `readFileAsync()` |
| 24 | v5.0.0-beta.9 | Argument-array form of `runAsync()` |
| 25 | v5.0.0-beta.9 | `wallpaperPath()` and `setWallpaperMask()` |
| 26 | v5.0.0-beta.9 | `getSetting(path)` |
| 27 | v5.0.0-beta.9 | `frameVisible` on `ui.input` |
| 28 | v5.0.0-beta.9 | `panel.openContextMenu()` |
| 29 | v5.0.1 | `ui.graph` `onPointerMove` / `onPointerLeave` |
| 30 | v5.0.1 | `layer` option for floating panels |
| 31 | v5.2.0 | `getColor(role)` |
| 32 | v5.2.0 | `tooltip` prop on box/row/column/image |
| 33 | v5.3.0 | `revealKey` on `ui.scroll` |
| 34 | v5.3.0 | `hover_highlight` widget option |
| 35 | v5.4.0 | `idle.watch()` / `idle.unwatch()` for every entry kind |
| 36 | v5.4.0 | `[[layer]]` entries, `layer.*`, `noctalia.layer.show/hide/configure` |
| 37 | v5.4.0 | `calendarEvents()` |
| 38 | v5.4.0 | Drag/drop in bar widgets; `grabCursor`, `onClick`, `expandOnDrag` |
| 39 | v5.4.0 | `osd.show(icon, value, opts)` |
| 40 | v5.4.0 | `ui.pixelStream` and the companion protocol |
| 41 | v5.4.0 | `ui.colorPicker` |
| 42 | v5.4.0 | Panel `height = "content"` and `max_height` |
| 43 | v5.4.0 | Container color roles; `surface_variant`/`outline` retired |
| 44 | Unreleased | Palette JSON format 2 |
| 45 | Unreleased | `noctalia.umbriel.action` |
| 46 | Unreleased | `setGpuMonitoring(bool)`; `systemStats()` no longer enables GPU probes |
| 47 | Unreleased | `secret = true` settings and credential-aware config export |
| 48 | Unreleased | Service `onSuspend()` / `onResume()` |
| 49 | Unreleased | Panel `layer = "follow"` default |

## Choosing a level

| Plugin shape | Typical minimum |
| --- | --- |
| Bar widget with text/glyph/tooltip, clicks, settings, IPC | 3 |
| Panel with basic controls, service, shared state | 3 |
| Launcher provider | 3 |
| Closures in `ui` callbacks | 9 |
| Persistent panel / keyboard capture | 11 / 13 |
| System stats widget | 12 |
| Relative modules | 22 |
| Safe subprocess arguments | 24 |
| Shell-config awareness | 26 |
| Theme colors in Lua | 31 |
| Idle-driven overlay | 35–36 |
| OSD / layer / color picker | 36–41 |
| Container color roles | 43 |

Do not declare `plugin_api` equal to the shell release. A plugin using only baseline
features should stay at 3 so it runs on every v5 shell.

## Catalog releases for older shells

When you raise `plugin_api`, older shells lose the plugin unless the source catalog
names an older revision they can still run. Add a `[[plugin.release]]` row for each
API level in your history, newest first:

```toml
[[plugin]]
id = "me/hello"
version = "2.0.0"
plugin_api = 9
# ...

[[plugin.release]]
plugin_api = 3
version = "1.4.0"
rev = "5082ed5f85e795513b8485e4cedc66d5a2c816ff"
```

Each row needs `plugin_api`, `version`, and a full 40-character `rev`. A host picks
the newest release its API range allows and exports that exact commit. Rows at or
above the tip's own level are dropped. Release rows apply to `git` sources only; a
`path` source has no revisions to export. The `update-catalog.py` script in the
official/community repos generates rows from history (needs full clone history).
