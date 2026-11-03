# Entry Scripts & Lifecycle

An entry script defines **global functions** that Noctalia calls, and drives its
surface through injected globals (`barWidget`, `shortcut`, `launcher`,
`desktopWidget`, `panel`, `layer`, `noctalia`, and `ui`). The top level runs once
when the entry loads: initialize state and register `noctalia.state.watch` handlers
there.

Start every script with `--!nonstrict`; the injected globals are not declared in
strict Luau.

## Callback matrix

| Function | Widget | Shortcut | Launcher | Desktop | Panel | Layer | Service | When |
| --- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | --- |
| `update()` | ✓ |  |  | ✓ | ✓ | ✓ | ✓ | every update interval |
| `onClick()` / `onRightClick()` | ✓ | ✓ |  |  |  |  |  | pointer press |
| `onMiddleClick()` | ✓ |  |  |  |  |  |  | middle press |
| `onScroll(axis, steps, startsGesture)` | ✓ |  |  |  |  |  |  | wheel/touchpad over the widget |
| `onHover(entered)` | ✓ |  |  |  |  |  |  | pointer enter/leave on the widget |
| `onAudioSpectrum(valuesCsv, stateCsv)` | ✓ |  |  |  |  |  |  | audio spectrum frame for an audio-reactive widget |
| `onQuery(text)` |  |  | ✓ |  |  |  |  | launcher text changed behind the prefix |
| `onActivate(id)` |  |  | ✓ |  |  |  |  | launcher result selected |
| `onEnable()` |  |  |  |  |  |  | ✓ | plugin explicitly enabled successfully |
| `onSuspend()` / `onResume()` |  |  |  |  |  |  | ✓ | system sleep/wake (`plugin_api 48`, unreleased) |
| `onOpen(context)` / `onClose()` |  |  |  |  | ✓ |  |  | panel opened / closed |
| `onKey(chord, pressed)` |  |  |  |  | ✓ |  |  | a `capture_keys` chord while focused |
| `onFrameTick(deltaMs)` |  |  |  | ✓ | ✓ | ✓ |  | after `setNeedsFrameTick(true)` |
| `onIpc(event, payload)` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | `noctalia msg plugin …` |
| `onConfigChanged()` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | plugin or watched shell setting changed |
| `onExit(signal, reason)` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | runtime about to be destroyed |

`update()` is **not** called for shortcuts or launcher providers — set their
presentation at the top level and from callbacks.

## Bar widget

A bar widget patches the built-in glyph/text row imperatively, or replaces it with
a declarative tree (`barWidget.render`). Imperative calls update persistent
presentation state until replaced; after `render()` activates a tree, `setText`,
`setGlyph`, `setImage`, `setFont`, `setColor`, and `setGlyphColor` have no visible
effect.

```lua
--!nonstrict
barWidget.setGlyph("puzzle")
barWidget.setText("Hello")
barWidget.setTooltip("Click me")

function onClick()
  barWidget.setText("Clicked")
end
```

### `barWidget.*`

| Method | Returns | Description |
| --- | --- | --- |
| `setText(text)` | nothing | Text label; empty hides it |
| `setGlyph(name)` | nothing | Named glyph; removes any image |
| `setImage(path [, watch [, width [, height]]])` | nothing | Image; relative paths resolve from the plugin dir, `~` expands. `watch` reloads when the source changes; omit dimensions for natural size |
| `setTooltip(content)` | nothing | Plain string, one key/value row, or array of rows; `nil`/empty clears |
| `clearTooltip()` | nothing | Equivalent to `setTooltip(nil)` |
| `setFont(family [, baseline])` | nothing | Family from `noctalia.loadFont`; baseline `text` (default), `textFixedHeight`, `inkCentered`, `pictographic` |
| `setColor(color [, mode])` | nothing | Palette role or hex. Default mode keeps the widget's configured color for `on_surface`; pass `"script"` to use it literally |
| `setGlyphColor(color [, mode])` | nothing | Same semantics for the glyph |
| `setVisible(visible)` | nothing | Show/hide the whole capsule |
| `isVertical()` | bool | Bar orientation |
| `outputName()` | string/nil | Connector of the monitor this placement is on |
| `render(tree)` | nothing | Replace the glyph/text row with a `ui.*` tree |

Tooltip forms:

```lua
barWidget.setTooltip("CPU: 42%")
barWidget.setTooltip({ "CPU", "42%" })
barWidget.setTooltip({
  { key = "CPU", value = "42%" },
  { "Memory", "6.2 GiB" },
})
```

If you toggle a tooltip frequently, keep a `hasTooltip` flag and only call
`clearTooltip()` when one is set. The official timer plugin does this because
clearing a tooltip that was never set has crashed in some 5.x builds.

Colors: `barWidget.setColor("primary")`, `barWidget.setGlyphColor("#FFF59B")`,
`barWidget.setColor("on_surface", "script")`. Palette roles are resolved live, so
the widget follows theme changes.

Custom fonts:

```lua
local font = noctalia.loadFont("fonts/bongocat.otf")
if font then
  barWidget.setFont(font, "pictographic")
end
```

### Scroll

```lua
local volume = 50

function onScroll(axis, steps, startsGesture)
  if axis ~= "vertical" then return end
  volume = math.clamp(volume - steps * 5, 0, 100)
  barWidget.setText(tostring(volume) .. "%")
end
```

- `axis` is `"vertical"` or `"horizontal"`.
- `steps` is whole wheel detents: negative up/left, positive down/right.
- `startsGesture` is `true` only on the first step of a gesture in a direction
  (stopped or reversed). Ramp values on every step; step through a list only when
  `startsGesture` is true.
- The bar widget instance's `enable_scroll` host setting (default `true`) gates
  delivery. A bound scroll action takes precedence over `onScroll`.
- Scroll events the widget does not define are left for the bar underneath.

### Pointer bindings and gesture defaults

A user binding in `[widget.<name>.actions]` takes precedence over the script's
callback. A manifest `[widget.actions]` table supplies defaults. Gestures nobody
binds still reach `onClick` / `onRightClick` / `onScroll`.

Every widget has a built-in `middle` binding that opens its settings. `onMiddleClick`
does not fire unless the manifest or user config sets `middle = "none"`.

`onClick` and `onRightClick` fire for widget-level presses; inline declarative
controls consume their own clicks, while the rest of the capsule still reaches the
widget-level handler.

### Declarative bar UI

```lua
function update()
  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = 6, align = "center" }, {
    ui.glyph({ name = "cpu", size = 14 }),
    ui.label({ text = readLoad(), fontWeight = "bold" }),
    ui.button({ glyph = "refresh", glyphSize = 12, variant = "ghost", onClick = "onRefresh" }),
  }))
end
```

Constraints:

- The capsule clips to bar thickness: keep the tree one control tall (row on a
  horizontal bar, column on a vertical bar).
- No keyboard focus: `ui.input`, `ui.select`, and `ui.scroll` are skipped with a
  warning. Pointer controls work.
- A slider consumes vertical wheel events over itself, so the widget's `onScroll`
  does not see them.
- Drag/drop works in bar widgets (API 38), confined to the widget's extent.
- Ticks stay on `noctalia.setUpdateInterval`; bar widgets have no frame tick.
- Audio-reactive widgets may define `onAudioSpectrum(valuesCsv, stateCsv)`. Both
  arguments are CSV strings; the official `bongocat` plugin shows parsing the
  spectrum values and the state fields.

Use `barWidget.render` for composite content (multiple labels, badges, inline
buttons); keep the imperative API for simple glyph/text widgets.

## Control-center shortcut

```lua
--!nonstrict
local on = false

local function render()
  shortcut.setLabel(on and "On" or "Off")
  shortcut.setIcon("bulb")          -- setIcon(on [, off])
  shortcut.setActive(on)
  shortcut.setEnabled(true)
end

render()

function onClick()
  on = not on
  render()
end

function onRightClick()
  noctalia.notify("Shortcut", "right click")
end
```

| Method | Description |
| --- | --- |
| `setLabel(text)` | tile label |
| `setIcon(on [, off])` | glyph for active/inactive state |
| `setActive(bool)` | highlight state |
| `setEnabled(bool)` | enable/disable the tile |

There is no `update()` callback for shortcuts. Set the initial state at the top
level and re-render from `onClick` / `onRightClick`.

## Launcher provider

The user types the manifest `prefix` (shown as `/ex`); everything after it is
passed to `onQuery(text)`. Publish results with `launcher.setResults(query,
results)`. `onActivate(id)` runs when a result is selected.

### Result shape

```lua
{
  id = "unique-id",          -- passed to onActivate unless `query` is set
  title = "Row title",
  subtitle = "Secondary text",
  glyph = "language",        -- Tabler/Nerd-Font name
  icon = "themed-icon",      -- themed icon name instead of glyph
  badge = "=",               -- drawn in place of glyph/icon
  query = "french ",         -- selecting rewrites input to this provider's query
  score = 10,                -- higher sorts first, then insertion order
}
```

- `query` passed to `setResults` **must echo** the `text` from `onQuery`; late
  results map back to the query they answer. The latest query wins. An empty list
  clears the provider's results.
- `launcher.setQuery(text)` replaces the launcher input and keeps it open. Use it
  from `onActivate` for drill-in navigation. Pass the **sub-query without the
  prefix**; the host adds this provider's prefix. A result-level `query` field does
  the same declaratively, with no `onActivate` needed.
- An `onActivate` that does not call `setQuery` closes the launcher normally.
- Queries run off the UI thread; publish a synchronous placeholder first, then call
  `setResults` again from an HTTP/subprocess callback.
- Use `noctalia.fuzzyScore(pattern, text)` for local fuzzy ranking; `nil` means no
  match. `debounce_ms` in the manifest avoids a network call per keystroke.

```lua
--!nonstrict
function onQuery(text)
  if text == "" then
    launcher.setResults(text, { { id = "hint", title = "Type something" } })
    return
  end

  launcher.setResults(text, { { id = "loading", title = "Translating…", glyph = "loader" } })

  noctalia.http({ url = endpoint(text) }, function(res)
    launcher.setResults(text, {
      { id = res.body, title = res.body, subtitle = "Enter to copy", glyph = "language" },
    })
  end)
end

function onActivate(id)
  noctalia.copyToClipboard(id, "text/plain")
end
```

## Service

A service is a headless singleton with no output. It is the natural owner of
polling, network connections, timers, and shared state.

```lua
--!nonstrict
local count = 0

noctalia.setUpdateInterval(noctalia.getConfig("interval") or 1000)

function update()
  count += 1
  noctalia.state.set("tick", count)
end

function onConfigChanged()
  noctalia.setUpdateInterval(noctalia.getConfig("interval") or 1000)
end
```

Behavior:

- `update()` runs on the service's update interval; values below 16 ms are clamped.
- Without `onConfigChanged()`, a plugin-setting change restarts the service runtime
  (the top-level chunk re-runs). With it, settings update in place and timers,
  caches, and connections survive.
- `onEnable()` (API 17) runs after an explicit enable succeeds, and when the user
  re-enables a disabled plugin. It does **not** run on ordinary startup, source
  update, script reload, or settings-driven restart. Use top-level initialization
  for normal startup.
- `onSuspend()` / `onResume()` (API 48, unreleased in 5.4.1) are called on logind
  sleep/wake. Reconnect sockets and reset time baselines in `onResume()`;
  `noctalia.nowMs()` is wall-clock and spans the whole sleep.
- `onOutputsChanged()` is called when the output set or geometry changes. Use it to
  re-read `noctalia.outputs()`.
- Services have no output, so IPC must use the `all` target.
- `noctalia.state` survives a service restart but is process-lifetime; key cached
  data by the config it depends on or it will serve stale results.

## Panel

A panel is a pop-up surface opened by entry id. Its UI is a declarative `ui.*` tree
and it can take keyboard focus, so interactive controls are available.

```lua
--!nonstrict
local enabled = true

local function render()
  panel.render(ui.column({ gap = 12 }, {
    ui.row({ align = "center", justify = "space_between" }, {
      ui.label({ text = "My Panel", fontSize = 16, fontWeight = "bold", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = "closePanel" }),
    }),
    ui.toggle({ checked = enabled, onChange = "onToggle" }),
  }))
end

function onOpen(context)     -- context is the optional string from panel-open
  render()
end

function onToggle(value)
  enabled = value == "true"
  render()
end

function closePanel()
  panel.close()
end
```

### `panel.*`

| Method | Description |
| --- | --- |
| `render(tree)` | Replace the panel's UI tree; call again from state-changing callbacks |
| `close()` | Ask the host to close the panel |
| `openContextMenu(request)` | Native context menu from a `ui.button`'s `onRightClick` (API 28) |
| `setWantsSecondTicks(bool)` | Run `update()` on second boundaries (API 18) |
| `setNeedsFrameTick(bool)` | Deliver `onFrameTick(deltaMs)` every frame while open (API 18) |

- Panel size is host-owned: declare `width` / `height` in the manifest. There is no
  runtime `setSize`.
- Render in `onOpen`; until the first `render()` the panel is only as tall as its
  padding.
- Ticks stop on close and resume on the next open. Frames are coalesced.
- `onClose()` runs when the panel closes; the runtime remains alive, so release
  expensive resources (GPU monitoring, streams) explicitly there.
- `onOpen(context)` receives the optional context string from
  `noctalia msg panel-open <id> [context]`. `noctalia.togglePanel(id)` takes no
  context.
- Persistent panels (`persistent = true`): always floating, no outside-click
  dismissal, `keyboard_focus = "exclusive"` rejected, no `ui.select` dropdowns.
- `keyboard_focus = "none"`: never takes focus, cannot combine with
  `capture_keys`; requires `dismiss_on_outside_click = false`.
- `capture_keys`: declared chords only; a focused text input wins first; Escape is
  always host-owned; captured chords outrank shell navigation keybindings inside
  that panel only; key repeat is filtered to one press/release.

### Panel context menus

`panel.openContextMenu(request)` must be called directly from a `ui.button`'s
`onRightClick` callback. The host keeps the pointer coordinates and serial private.
It returns `false` when no live direct pointer callback is active.

```lua
local selectedId = "clip-42"

function openEntryMenu()
  panel.openContextMenu({
    items = {
      { kind = "header", label = "Clipboard" },
      { id = "copy", label = "Copy" },
      { kind = "item", id = "pin", label = "Pin" },
      { kind = "separator" },
      { id = "delete", label = "Delete", enabled = selectedId ~= "" },
    },
    onActivate = "onEntryMenuAction",
    context = selectedId,
    maxVisible = 12,
  })
end

function onEntryMenuAction(actionId, entryId)
  if actionId == "copy" then copyEntry(entryId) end
end
```

Action items need a unique `id`; `kind = "item"` is optional; headers and separators
are non-interactive. At least one enabled action is required, at most 64 items;
`maxVisible` accepts 1–30. IDs/callback names are limited to 128 bytes and labels to
512 bytes. The menu closes on activation, outside click, Escape, panel close/reload,
or plugin disable.

## Layer surface

A layer is a plugin-owned layer-shell surface. It is lazy: nothing exists until
`visible = true` loads it or an entry calls `noctalia.layer.show(id)`.

```lua
--!nonstrict
layer.render(ui.column({ fill = "#000000", flexGrow = 1 }, {}))
```

- One runtime and surface per target output while shown. Hiding destroys both, so
  runtime state does not survive a hide. Outputs added later are covered when
  `output = "all"` or matches their connector.
- `layer.render(tree)` uses the same `ui.*` vocabulary as panels.
- `layer.setNeedsFrameTick(true)` delivers `onFrameTick(deltaMs)` while shown;
  `deltaMs` is a string, use `tonumber`.
- `layer.outputName()` returns the current connector.
- Pointer and keyboard input drive controls while the layer has focus; with
  `keyboard = "none"` keys never reach it. `keyboard = "on_demand"` focus behavior
  is compositor-dependent.
- IPC targets a layer instance by connector or `all`.
- `noctalia.layer.show/hide/configure` accept the local entry id (`"saver"`, not
  `"me/plugin:saver"`). Configure takes camelCase `layer`, `anchors`, `width`,
  `height`, `margins`, `exclusiveZone`, `keyboard`, `clickThrough`, `output`;
  changes last until the plugin reloads.
- Lock surfaces always stay above every layer.

## Desktop widget

```lua
--!nonstrict
local color = noctalia.getConfig("color")

local function render()
  desktopWidget.render(ui.column({ gap = 10, align = "center" }, {
    ui.label({ text = os.date("%H:%M"), fontSize = 32, fontWeight = "bold", color = color }),
    ui.button({ text = "Ping", variant = "primary", onClick = "ping" }),
  }))
end

function ping()
  noctalia.notify("Desktop widget", "button clicked")
end

function update()
  desktopWidget.setWantsSecondTicks(true)
  render()
end
```

- `desktopWidget.render(tree)` hands the tree to the host; the host diffs it against
  the previous tree.
- `setWantsSecondTicks(true)` runs `update()` on second boundaries.
- `setNeedsFrameTick(true)` additionally delivers `onFrameTick(deltaMs)` every
  frame; frames are coalesced.
- The user owns position, size, rotation, and flipping; the script only renders
  content and reads declared settings.
- No keyboard focus: use pointer controls. `ui.input` / `ui.select` are not
  appropriate.
- Tooltips are not shown in desktop widgets.

## Shared lifecycle

### Config changes

`onConfigChanged()` is available to every entry. The exact behavior depends on the
kind and the setting source:

- **Plugin settings:** widgets, desktop widgets, and panels are rebuilt; services
  update in place if they define `onConfigChanged()`, otherwise their runtime
  restarts.
- **Shell settings read via `getSetting`:** the host calls `onConfigChanged()` in
  place when the entry defines it; otherwise it reloads the entry script. Only paths
  the script actually read are watched.

### Exit and cleanup

```lua
function onExit(_signal, reason)
  if reason == "disable" then
    noctalia.runAsync("systemctl --user stop my-plugin.service")
  elseif reason == "uninstall" then
    noctalia.runAsync("systemctl --user disable --now my-plugin.service")
  end
end
```

- `signal` is `2` (`SIGINT`), `15` (`SIGTERM`), or `0` for every other teardown.
- `reason` requires API 17: `"disable"`, `"uninstall"`, `"reload"`, or `"shutdown"`.
- `onExit` has the normal callback budget. It cannot run after `SIGKILL`, a crash,
  or an abrupt process death.
- A detached `noctalia.runAsync(command)` (no callback) outlives the VM. Make cleanup
  idempotent and provide a retry path. An uninstall command must not rely on plugin
  files that may disappear immediately.
- Removing an already-disabled plugin cannot invoke its exit hooks.

### Modules

```lua
local format = require("./lib/format.luau")
```

Requires API 22. The path must be a string starting with `./` or `../` and ending
in `.luau`. There are no package search paths or implicit extensions. Each entry
keeps its own module cache; requiring the same canonical path returns the cached
value. A module runs in the entry's VM but gets its own global environment:
`noctalia.*` and `ui.*` are visible, module globals are private. A module must
return exactly one non-`nil` value. Circular imports fail with the full chain.
Editing a successfully loaded module hot-reloads the owning entry. A module that
failed to load is not cached or watched; touch the entry to retry.

### Hot reload

- `.luau` edits hot-reload automatically, including successfully loaded modules.
- Manifest changes are picked up on the next config reload:
  `noctalia msg config-reload`.
- A settings change reloads or rebuilds the affected entry; services can opt into
  in-place updates with `onConfigChanged()`.

## IPC targets

`noctalia msg plugin <author/plugin:entry> <target[:bar-name]> <event> [payload]`
dispatches to `onIpc(event, payload)`.

| Target | Selects |
| --- | --- |
| `focused` | the instance on the focused output |
| `DP-1` | the instance on that connector |
| `focused:default` / `DP-1:top` | a specific bar instance |
| `all` | every matching instance; required for services, panels, shortcuts, and other singletons |

Everything after `<event>` is passed through as the payload string unchanged.

```bash
noctalia msg plugin me/hello:hello focused set "Hi there"
noctalia msg plugin me/hello:ticker all refresh
noctalia msg panel-toggle me/hello:panel
noctalia msg panel-open me/hello:panel "some-context"
noctalia msg panel-close me/hello:panel
noctalia msg plugin me/hello:service all toggle
```
