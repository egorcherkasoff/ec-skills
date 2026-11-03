# Runtime API (`noctalia.*`)

Most `noctalia.*` functions are synchronous. Functions that start subprocesses,
HTTP requests, downloads, streams, or sound loads return a boolean immediately to
say whether the work was accepted, then deliver results to a callback.

## Runtime and settings

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.setUpdateInterval(ms)` | nothing | How often this entry's `update()` runs. Values below 16 ms are clamped |
| `noctalia.log(msg)` | nothing | Write to the shell log with this plugin's script context |
| `noctalia.isDarkMode()` | bool | Whether the palette is dark; tracks `[theme].shell_mode` when pinned |
| `noctalia.getColor(role)` | hex string / nil | Active palette role as `#RRGGBB`; API 31 |
| `noctalia.getSetting(path)` | config value / nil | Read effective shell config by TOML dotted path; API 26 |
| `noctalia.focusedOutputName()` | string / nil | Focused output connector, falling back to the preferred interactive output |
| `noctalia.getConfig(key)` | setting value / nil | Read a declared plugin or entry setting |

```lua
local interval = noctalia.getConfig("interval")
local offline = noctalia.getSetting("shell.offline_mode")
local firstBar = noctalia.getSetting("bar.order[0]")   -- arrays are zero-based
local primary = noctalia.getColor("primary")
```

- Only declared settings resolve. An undeclared `getConfig` key logs a warning and
  returns `nil`.
- `getSetting` reads the shell's effective config, not the plugin's settings. Tables
  and arrays become Luau tables; array indices are zero-based.
- When a value an entry read through `getSetting` changes, its
  `onConfigChanged()` runs, or the script reloads if it defines none. Only paths
  actually read are watched.

## Outputs, wallpaper, and panels

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.outputs()` | array | Connected outputs: `{ name, description, width, height, x, y, scale, focused }` |
| `noctalia.setWallpaperEnabled(connector, enabled)` | nothing | Toggle Noctalia's wallpaper surface on one output; runtime-only |
| `noctalia.setWallpaper(path)` | nothing | Apply and persist a wallpaper on every output |
| `noctalia.setWallpaper(connector, path)` | nothing | Apply and persist on one output |
| `noctalia.wallpaperDirectory()` | string / nil | Resolved wallpaper folder for the current theme mode |
| `noctalia.wallpaperPath(connector)` | string / nil | Configured wallpaper source for an output; API 25 |
| `noctalia.setWallpaperMask(connector, { path, wallpaperPath })` | nothing | Grayscale occlusion mask for desktop widgets on the output; API 25 |
| `noctalia.setWallpaperMask(connector, nil)` | nothing | Clear this runtime's mask; API 25 |
| `noctalia.togglePanel("author/plugin:panel")` | nothing | Open or close a plugin panel by full entry id |
| `noctalia.openSettings()` | nothing | Open Settings at this plugin's page; API 15 |

- `outputs()` uses the DRM connector name in `name`, the same string compositor
  tools expect.
- `setWallpaper` behaves like the built-in wallpaper panel. Prefer it and
  `togglePanel` over shelling out to the `noctalia` CLI.
- Masks use the wallpaper source's intrinsic pixel dimensions and Noctalia's fill
  mode. Pixel `0` leaves widgets visible, `255` erases them, intermediate values
  feather. `wallpaperPath` must exactly match `noctalia.wallpaperPath(connector)`.
  One plugin runtime owns an output mask at a time; masks are cleared when it
  unloads.
- `openSettings()` takes no id and can only open the calling plugin's page. It logs
  a warning if the plugin declares no settings. Plugins read config but cannot write
  it; use `openSettings()` for user-facing configuration, or `pluginDataDir()` for
  internal state.

## Dialogs and application icons

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.openColorPicker(initialColor, onClose)` | bool | Native color picker; callback gets canonical `#RRGGBB` or `nil` on cancel. One pending callback per entry |
| `noctalia.appIconPath(appId, sizePx)` | string / nil | Resolve an app id to an icon file path using the taskbar's lookup |

`appIconPath` matches desktop entries by id, then `StartupWMClass`, then resolves
the icon name through the XDG icon theme. Unknown input is treated as a raw icon
name, so `"folder-music"` works directly. The result plugs into `ui.image` `path`.
Resolution scans the filesystem on a cache miss; cache results instead of resolving
on every `update()`.

## Time, notifications, clipboard, calendar

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.formatTime(pattern)` | string | Format current local time with Noctalia clock/filename tokens |
| `noctalia.formatTime(pattern, unixSeconds)` | string | Format a specific Unix timestamp |
| `noctalia.formatTime(pattern, unixSeconds, timezone)` | string | Format in an IANA timezone; API 19. Invalid zones fall back to local |
| `noctalia.timeFormat()` | string | Current `[shell].time_format`; API 19 |
| `noctalia.dateFormat()` | string | Current `[shell].date_format`; API 19 |
| `noctalia.isValidTimezone(name)` | bool | Empty (system local) or a known IANA zone; API 19 |
| `noctalia.nowMs()` | number | Wall-clock milliseconds since epoch; API 12 |
| `noctalia.notify(title, body)` | nothing | Informational notification; `body` optional |
| `noctalia.notifyError(title, body)` | nothing | Error notification; `body` optional |
| `noctalia.copyToClipboard(text, mime)` | bool | Copy text with explicit MIME, e.g. `"text/plain"` or `"text/uri-list"` |
| `noctalia.clipboardText()` | string / nil | Latest text clipboard content |
| `noctalia.calendarEvents()` | table / nil | Synced calendar events, or `nil` before first sync; API 37 |

`%s` in `formatTime()` expands to Unix epoch seconds. `formatTime()` and
`os.time()` are whole-second; `nowMs()` is the only sub-second clock.

`calendarEvents()` returns a read-only merged view of the shell's configured
accounts. Recurring events are expanded into concrete instances. Each entry:

| Field | Description |
| --- | --- |
| `id` | stable provider/iCal UID |
| `title` | summary |
| `calendarName` | owning calendar |
| `colorHex` | calendar color, may be empty |
| `location` | raw `LOCATION`, may be empty |
| `url` | resolved http(s) meeting link, may be empty |
| `startMs`, `endMs` | wall-clock milliseconds, same base as `nowMs()` |
| `allDay` | true for midnight-aligned all-day events |

Treat `nil` as "not synced yet", not "no events". Plugins cannot add, edit, or
remove events or read credentials.

## System stats, disks, GPU

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.systemStats()` | table / nil | Snapshot of the host system monitor; API 12 |
| `noctalia.cpuCores()` | array / nil | Per-core CPU percentages; API 12 |
| `noctalia.diskMounts()` | array | Physical block-device filesystems; API 16 |
| `noctalia.diskStats(path)` | table / nil | Usage snapshot for an absolute or `~/` path; API 16 |
| `noctalia.setGpuMonitoring(enabled)` | bool | Acquire/release GPU sampling; API 46, unreleased in 5.4.1 |

`systemStats()` returns a copy of the latest sample. `nil` when
`[system.monitor]` is disabled. The first call opts into CPU temperature sampling
until the entry unloads. It does **not** enable GPU probes.

| Field | Notes |
| --- | --- |
| `sampledAtMs` | latest aggregate sample; API 16 |
| `cpu.usagePercent` | 0–100 |
| `cpu.tempC` | absent when no sensor |
| `cpu.freqMhz`, `cpu.maxFreqMhz` | absent when unavailable |
| `ram.usagePercent`, `ram.usedMb`, `ram.totalMb` | |
| `swap.usedMb`, `swap.totalMb` | |
| `gpu.tempC`, `gpu.usagePercent`, `gpu.vramUsedBytes`, `gpu.vramTotalBytes` | each absent when that probe is unavailable; may be stale |
| `net.rxBytesPerSec`, `net.txBytesPerSec` | totals across interfaces |
| `net.interfaces` | receive/transmit rates keyed by interface; API 16 |
| `loadAvg` | 1, 5, 15 minute load averages |

Absent sensors are `nil`, not `0`, so test `if stats.gpu.tempC ~= nil then`.
Values refresh on the configured poll intervals, not on every call.

`setGpuMonitoring(true)` acquires a request; `false` releases it. Repeated calls
with the same value do not accumulate. Returns `false` if the monitor service is
unavailable; retry later. Acquire only while displaying GPU data and release when
the display closes or changes metric. The global `gpu_poll_seconds = 0` still
disables all GPU probing.

`diskMounts()` returns `{ path, source, filesystem }` for physical filesystems,
deduplicated by source and sorted by path. `diskStats()` returns
`usagePercent`, `totalBytes`, `freeBytes`, `availableBytes`; the first call opts the
path into sampling until the plugin unloads.

`cpuCores()` opts into per-core sampling (one extra `/proc/stat` read per second).
Two reads are needed, so expect `nil` for up to a second. Cores are in `/proc/stat`
order; offline cores are absent and positions are not core ids.

## Subprocesses and environment

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.runAsync(cmdOrArgv)` | bool | Start a detached process; no output capture |
| `noctalia.runAsync(cmdOrArgv, cb [, timeoutMs])` | bool | Run and capture output, then `cb(result)`; timeout is clamped to 50–60000 ms |
| `noctalia.runStream(cmd, onLine)` | bool | Long-lived shell command; `onLine(line)` per stdout line |
| `noctalia.runInTerminal(cmd)` | bool | Run a shell command in a terminal |
| `noctalia.commandExists(name)` | bool | Executable on `PATH` |
| `noctalia.processMatches(cb, ...needles)` | bool | Async check that a running command line matches all needles; `cb(matched)` |
| `noctalia.flatpakAppInstalled(id)` | bool | Flatpak app id installed |
| `noctalia.portalAvailable()` | bool | Desktop portal available |
| `noctalia.getenv(name)` | string / nil | Read an environment variable |
| `noctalia.expandPath(path)` | string | Expand `~/Pictures` to an absolute user path |

`runAsync` accepts a shell string (runs through `/bin/sh -c`) or an argument array
(API 24; executes the program directly, one value per argument, no shell parsing).
The optional third argument is a timeout in milliseconds, clamped to 50–60000.
Use the argv form whenever settings, user input, paths, URLs, or other dynamic
values are involved:

```lua
noctalia.runAsync({ "git", "-C", checkoutDir, "fetch", "origin", branch }, function(result)
  if result.exitCode ~= 0 then
    noctalia.log(result.stderr)
  end
end)
```

Shell operators (`|`, `>`, `$VAR`, command substitution) work only in the string
form. Values concatenated into a shell string must be shell-quoted; argv avoids
that requirement.

`runAsync(cmdOrArgv, cb)` calls `cb(result)` once with:

```lua
{
  exitCode = 0,
  stdout = "...",
  stderr = "...",
  timedOut = false,
  stdoutTruncated = false,
  stderrTruncated = false,
}
```

`runStream` is for long-running processes; active streams are terminated when the
script reloads, the entry is removed, or Noctalia stops the plugin.

`runInTerminal` uses `$TERMINAL` when set (the value must not include `-e`),
otherwise it discovers a terminal on `PATH`.

## Filesystem and persistence

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.readFile(path)` | string, or `nil, err` | Read bytes |
| `noctalia.readFileAsync(path, cb)` | bool | Async bounded read; API 23 |
| `noctalia.writeFile(path, content)` | bool, optional error | Replace contents; new files are `0600`, existing mode preserved |
| `noctalia.mkdirAll(path)` | bool, optional error | Create directory and parents; existing directory is success |
| `noctalia.removeFile(path)` | bool, optional error | Delete a file; refuses directories |
| `noctalia.renameFile(from, to)` | bool, optional error | Rename/move a file |
| `noctalia.fileExists(path)` | bool | Existence check |
| `noctalia.fileInfo(path)` | table, or `nil, err` | `{ size, mtime, isDir }`; mtime in Unix seconds |
| `noctalia.listDir(path)` | array, or `nil, err` | Filenames |
| `noctalia.pluginDir()` | string / nil | This plugin's runtime directory |
| `noctalia.pluginDataDir()` | string, or `nil, err` | Persistent per-plugin data directory, created `0700` |
| `noctalia.loadFont(path)` | string, or `nil, err` | Register a font file and return its family name |

Path resolution:

- `~` expands to `$HOME`.
- Absolute paths are used as-is.
- Relative paths resolve against the plugin's own directory.

Plugins are trusted code, so these helpers are not sandboxed.

`readFileAsync()` is for sysfs, procfs, and small local files. Reads are limited to
4 MiB, at most four outstanding reads per plugin runtime, and late completions from
a reloaded/stopped runtime are discarded. Use synchronous `readFile()` only when the
file is immediately available.

### Persisting data across restarts

`noctalia.state` is in-memory only. Write real data to `noctalia.pluginDataDir()`:

```lua
local dir, dirErr = noctalia.pluginDataDir()
if not dir then
  noctalia.notifyError("Plugin data directory unavailable", dirErr)
  return
end

local path = dir .. "/data.json"
local encoded, encodeErr = noctalia.json.encode(myTable)
if not encoded then
  noctalia.notifyError("Could not encode data", encodeErr)
  return
end
noctalia.writeFile(path, encoded)

local raw = noctalia.readFile(path)
if raw then
  myTable = noctalia.json.decode(raw)
end
```

Do **not** persist inside `noctalia.pluginDir()`: for git-installed plugins that
directory is a runtime copy rewritten on update, so saved data is lost. The data
directory follows `NOCTALIA_STATE_HOME`, survives updates, and is scoped to your
plugin id.

## Sound

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.sound.load(name, path, onLoaded)` | bool | Async decode; `onLoaded(ok, error)`; API 20 |
| `noctalia.sound.play(name)` | nothing | Play a loaded sound; API 20 |

```lua
local function onLoaded(ok, err)
  if not ok then
    noctalia.notifyError("Could not load click sound", err)
    return
  end
  noctalia.sound.play("click")
end

if not noctalia.sound.load("click", "sounds/click.ogg", onLoaded) then
  noctalia.notifyError("Could not queue click sound")
end
```

Paths resolve like filesystem paths. Bundled relative assets need no manifest
declaration. A `true` return means accepted, not decoded. At most eight loads may be
pending per runtime; requesting a name with a pending load returns `false`. Sound
names are scoped to one runtime; reloading cancels pending callbacks and releases
cached names. Playback honors `[audio].sound_volume`; the shell sound toggles do not
affect it. Triggering the same sound while it is already playing is suppressed.

## Idle

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.idle.watch(seconds, callback, options)` | number | `callback(true)` after idle, `callback(false)` on input; returns watch id; API 35 |
| `noctalia.idle.unwatch(id)` | bool | Remove a watch; `false` for unknown id; API 35 |

```lua
local id = noctalia.idle.watch(300, function(idle)
  if idle then noctalia.layer.show("saver") else noctalia.layer.hide("saver") end
end)

noctalia.idle.unwatch(id)
```

- `seconds` must be positive; fractions are allowed and rounded up to ms.
- At most eight watches per entry runtime; a ninth raises an error.
- Watches use `ext-idle-notify-v1` and work from every entry kind. They are released
  automatically when the runtime reloads or stops.
- By default inhibitors count: Wayland idle inhibitors, Noctalia caffeine, and
  D-Bus `org.freedesktop.ScreenSaver` inhibits. If a D-Bus inhibit starts while the
  watch reports idle, it reports `false`; when it lifts, the timeout restarts.
- `{ ignoreInhibitors = true }` counts only real input (`ext-idle-notify` v2). On
  v1-only compositors it falls back to honoring inhibitors and logs once.
- Idle watches never change the shell's `[idle]` behaviors (lock, screen off,
  suspend).

## Umbriel compositor (API 45, unreleased in 5.4.1)

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.umbriel.action(request, callback)` | bool | Send one typed action to the running Umbriel IPC socket |

`request` is the typed action request from Umbriel's IPC reference without `cmd`:
an `action` name plus one field per argument. Noctalia adds `cmd = "action"`. A
table that sets `cmd` itself, or has no non-empty `action` string, raises a Lua
error. Umbriel validates unknown, missing, or mistyped fields.

```lua
noctalia.umbriel.action({ action = "workspace-switch", workspace = "WEB", output = "DP-1" })

noctalia.umbriel.action({ action = "workspace-set-layout", layout = "dwindle" }, function(ok, err)
  if not ok then noctalia.notifyError("Layout change failed", err) end
end)
```

- Returns `false` without sending when no Umbriel socket is found
  (`UMBRIEL_SOCKET` unset and `$XDG_RUNTIME_DIR/umbriel-$WAYLAND_DISPLAY.sock`
  missing). Otherwise returns `true`.
- `callback(true, nil)` follows when Umbriel accepts; `callback(false, err)` on
  rejection, unreachable socket, or no reply within two seconds. Without a callback
  it is fire-and-forget. At most 16 callbacks may be pending per runtime.
- Prefer this over `runAsync({ "umbriel", "msg", ... })`: no process, no `PATH`
  dependency, typed values.

## Layers

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.layer.show(entryId)` | nothing | Show this plugin's `[[layer]]` entry; API 36 |
| `noctalia.layer.hide(entryId)` | nothing | Hide and destroy its surfaces/runtimes; API 36 |
| `noctalia.layer.configure(entryId, props)` | nothing | Change live and future instances; API 36 |

`entryId` is the local id (`"saver"`, not `"me/plugin:saver"`); an id containing
`:` or `/` raises a Lua error. Unknown ids warn. Any entry of the plugin may call
these. `show`/`hide` are idempotent and apply asynchronously on the main thread.

`configure` takes camelCase keys with the same value sets as the manifest:

```lua
noctalia.layer.configure("banner", {
  layer = "top",
  anchors = { "top", "left", "right" },
  width = 0,
  height = 0,
  margins = { top = 0, right = 0, bottom = 0, left = 0 },
  exclusiveZone = "auto",
  keyboard = "on_demand",
  clickThrough = false,
  output = "focused",
})
```

Configured values last until the plugin reloads (a settings change or update), then
return to the manifest values.

## OSD

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.osd.show(icon, value, opts)` | nothing | Show the shell OSD; API 39 |

```lua
noctalia.osd.show("wifi", "VPN connected")
noctalia.osd.show("wifi-off", "VPN disconnected", { inactive = true })
noctalia.osd.show("brightness-low", "40%", { progress = 0.4 })
noctalia.osd.show("volume-high", "", { progress = 0.4 })
```

`icon` is a glyph name and must not be empty. `value` defaults to empty. `opts`:
`progress` 0–1 (clamped; NaN errors) and `inactive` boolean. A wrong type raises an
argument error at the call. The popup shares the shell OSD slot, so a newer volume or
brightness change replaces it. Users can disable plugin popups with
`[osd.kinds].custom = false`; nothing shows while OSD is disabled.

## HTTP, downloads, streams

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.http(request, cb)` | bool | Async request; `cb(response)` |
| `noctalia.httpStream(request, onLine, onClose)` | handle / nil | Long-lived streaming request; API 4 |
| `noctalia.download(url, dest, cb)` | bool | Download to a file; `cb(ok)` boolean |

Request table:

```lua
{
  url = "https://example.com",          -- only required field
  method = "GET",
  body = "",
  headers = { "Accept: application/json" },
  basic_username = "user",
  basic_password = "pass",
  follow_redirects = false,
  allow_insecure_tls = false,           -- API 7; disables cert/hostname checks
}
```

`http()` calls `cb(response)` once:

```lua
{ ok = true, status = 200, body = "..." }
```

`ok` is transport success, not the HTTP status; check `status` for 2xx/4xx/5xx.
HTTP and downloads honor `[shell] offline_mode = true` and do not connect.

`allow_insecure_tls` disables certificate-chain and hostname verification for the
request and HTTPS redirects. Keep it false unless the endpoint is trusted and cannot
use a publicly trusted certificate. It does not disable proxy certificate
verification.

`download()` resolves `dest` like other filesystem paths, so a relative destination
writes inside the plugin directory.

### `httpStream`

Keeps the connection open and delivers each response body line to `onLine(line)`
(CR trimmed). Use it for server-sent events. Headers travel through the native HTTP
client, so credentials never appear in a process command line.

```lua
local stream = noctalia.httpStream({
  url = "http://homeassistant.local:8123/api/stream",
  headers = { "Accept: text/event-stream", "Authorization: Bearer " .. token },
}, function(line)
  handleLine(line)
end, function(result)
  if not result.ok then reconnect() end
end)

stream.stop()   -- idempotent; suppresses onClose
```

- Returns a handle with `stop()`, or `nil` if the stream could not start.
- `onClose` fires exactly once when the transfer ends (server close, network error,
  fully read HTTP error), unless stopped.
- Non-2xx responses are not special-cased: their body still streams to `onLine`
  and the status arrives in `onClose` (`ok = true, status = 401` for a rejected
  token).
- There is no overall transfer timeout; reconnecting after `onClose` is the caller's
  job. Active streams are cancelled on script reload, entry removal, or plugin stop.
- With `[shell] offline_mode = true`, the stream never connects and `onClose` fires
  with `ok = false`.

## Translations and data helpers

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.tr(key)` | string | Translated string, falling back to the key |
| `noctalia.tr(key, subst)` | string | Replace `{name}` placeholders from a table |
| `noctalia.trp(key, count)` | string | Plural helper: prefers `<key>.one` / `<key>.other`, then bare key |
| `noctalia.trp(key, count, subst)` | string | Plural with substitutions; `{count}` is available |
| `noctalia.json.decode(str)` | value, or `nil, err` | Parse JSON |
| `noctalia.json.encode(value)` | string, or `nil, err` | Compact JSON |
| `noctalia.json.encode(value, true)` | string, or `nil, err` | Pretty JSON |
| `noctalia.string.trim(str)` | string | Trim whitespace |
| `noctalia.string.urlEncode(str)` | string | Percent-encode for URLs |
| `noctalia.string.urlDecode(str)` | string | Decode percent-encoded text |
| `noctalia.fuzzyScore(pattern, text)` | number / nil | Native fuzzy match; `nil` means no match |

`json.*` and `string.*` are synchronous pure transforms. Prefer
`string.urlEncode()` when building query strings for `http()` / `download()`.

## Shared state across entries

Entries are isolated VMs and do not share Lua memory. Exchange **plain values**
through the per-plugin state channel:

| Method | Returns | Description |
| --- | --- | --- |
| `noctalia.state.set(key, value)` | nothing | Publish a plain value |
| `noctalia.state.get(key)` | value / nil | Read the latest value |
| `noctalia.state.watch(key, fn)` | nothing | Call `fn(value)` whenever the key changes |

Values are **copied** across entries, so they must be strings, numbers, booleans, or
tables of those — not functions. The channel is **in-memory only**, not saved to
disk, and cleared when the plugin stops. It survives a service runtime restart, so
key cached data by the config it depends on or invalidate it in
`onConfigChanged()`.

```lua
-- ticker.luau (service)
local n = 0
noctalia.setUpdateInterval(1000)

function update()
  n += 1
  noctalia.state.set("count", n)
end

-- widget.luau
noctalia.state.watch("count", function(value)
  barWidget.setText(tostring(value))
end)
```

## Limits worth remembering

| Area | Limit |
| --- | --- |
| `setUpdateInterval` | below 16 ms clamped |
| `readFileAsync` | 4 MiB per read, 4 outstanding per runtime |
| `sound.load` | 8 pending per runtime |
| `idle.watch` | 8 watches per entry runtime |
| `umbriel.action` | 16 pending callbacks per runtime (API 45, unreleased in 5.4.1) |
| context menu | 64 items, `maxVisible` 1–30 |
| drag/drop | payload 16 KiB; names/values 256 bytes; 16 `accepts` entries |
| pixel stream | dimensions 1–4096, at most 4,194,304 pixels |
