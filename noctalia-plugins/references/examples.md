# Examples & Recipes

These are complete patterns rather than full store plugins. Each manifest fragment
assumes the plugin id `me/example`; rename it to your own globally unique id.
Function-valued UI callbacks require `plugin_api >= 9`; context menus require 28;
layers require 36. Raise the manifest level if a recipe uses them.

## Service → widget → panel

The standard shape: a headless service owns the data, and every UI entry is a thin
client via `noctalia.state`.

`plugin.toml`:

```toml
id = "me/example"
name = "Example"
version = "1.0.0"
plugin_api = 3
author = "me"

[[setting]]
key = "interval"
type = "int"
label_key = "settings.interval.label"
default = 1000
min = 250
max = 60000

[[widget]]
id = "bar"
entry = "bar.luau"

  [[widget.setting]]
  key = "glyph"
  type = "glyph"
  label_key = "settings.glyph.label"
  default = "activity"

[[panel]]
id = "panel"
entry = "panel.luau"
width = 360
height = 240
placement = "floating"
position = "center"

[[service]]
id = "ticker"
entry = "service.luau"
```

`service.luau`:

```lua
--!nonstrict
local count = 0

local function applyInterval()
  noctalia.setUpdateInterval(noctalia.getConfig("interval") or 1000)
end

applyInterval()

function update()
  count += 1
  noctalia.state.set("count", count)
end

function onConfigChanged()
  applyInterval()
end
```

`bar.luau`:

```lua
--!nonstrict
local glyph = noctalia.getConfig("glyph")
local count = noctalia.state.get("count") or 0

local function render()
  barWidget.setGlyph(glyph)
  barWidget.setText(tostring(count))
  barWidget.setTooltip(noctalia.tr("tooltip", { count = count }))
end

noctalia.state.watch("count", function(value)
  count = value
  render()
end)

function onClick()
  noctalia.togglePanel("me/example:panel")
end

function update()
  render()
end

render()
```

`panel.luau`:

```lua
--!nonstrict
local count = noctalia.state.get("count") or 0

local function render()
  panel.render(ui.column({ gap = 12 }, {
    ui.label({ text = noctalia.tr("panel.title"), fontSize = 16, fontWeight = "bold" }),
    ui.label({ text = noctalia.tr("panel.count", { count = count }), color = "primary" }),
    ui.button({ text = noctalia.tr("panel.close"), variant = "primary", onClick = "closePanel" }),
  }))
end

noctalia.state.watch("count", function(value)
  count = value
  render()
end)

function onOpen()
  render()
end

function closePanel()
  panel.close()
end
```

`translations/en.json`:

```json
{
  "tooltip": "{count} ticks",
  "panel.title": "Ticker",
  "panel.count": "Count: {count}",
  "panel.close": "Close",
  "settings.interval.label": "Interval (ms)",
  "settings.glyph.label": "Bar glyph"
}
```

## Launcher provider with async HTTP and drill-in

```toml
[[launcher_provider]]
id = "find"
entry = "finder.luau"
prefix = "fd"
glyph = "search"
debounce_ms = 250
include_in_global_search = false
```

```lua
--!nonstrict
local endpoint = "https://api.example.com/search?q="

function onQuery(text)
  if text == "" then
    launcher.setResults(text, {
      { id = "hint", title = "Type a search term", glyph = "search" },
    })
    return
  end

  -- Publish a synchronous placeholder first.
  launcher.setResults(text, { { id = "loading", title = "Searching…", glyph = "loader" } })

  noctalia.http({ url = endpoint .. noctalia.string.urlEncode(text) }, function(res)
    if not res.ok or res.status < 200 or res.status >= 300 then
      launcher.setResults(text, { { id = "error", title = "Request failed", glyph = "alert-circle" } })
      return
    end

    local data = noctalia.json.decode(res.body)
    local rows = {}
    for _, item in ipairs(data.results or {}) do
      table.insert(rows, {
        id = item.id,
        title = item.title,
        subtitle = item.subtitle,
        glyph = "file",
        score = item.score,
      })
    end
    launcher.setResults(text, rows)
  end)
end

function onActivate(id)
  if id == "error" or id == "hint" or id == "loading" then return end
  noctalia.copyToClipboard(id, "text/plain")
end
```

For drill-in, use a result-level `query` or call `launcher.setQuery()` from
`onActivate`:

```lua
function onActivate(id)
  local category = id:match("^cat:(.+)$")
  if category then
    launcher.setQuery(category .. " ")   -- sub-query only; host adds the prefix
    return
  end
  noctalia.copyToClipboard(id, "text/plain")
end
```

The `query` argument to `setResults` must echo the text received by `onQuery`, so
late responses map to the right query. The latest query wins.

## Desktop widget

```toml
[[desktop_widget]]
id = "desktop"
entry = "desktop.luau"

  [[desktop_widget.setting]]
  key = "color"
  type = "color"
  label_key = "settings.color.label"
  default = "primary"

  [[desktop_widget.setting]]
  key = "show_progress"
  type = "bool"
  label_key = "settings.show_progress.label"
  default = true
```

```lua
--!nonstrict
local color = noctalia.getConfig("color")
local showProgress = noctalia.getConfig("show_progress")
local remaining = 0
local total = 0

local function render()
  local rows = {
    ui.label({
      text = remaining > 0 and string.format("%d:%02d", remaining // 60, remaining % 60) or "--:--",
      fontSize = 34,
      fontWeight = "bold",
      color = remaining > 0 and color or "outline_variant",
    }),
  }

  if showProgress then
    table.insert(rows, ui.progress({
      progress = total > 0 and remaining / total or 0,
      fill = color,
      width = 160,
      height = 6,
      radius = 3,
    }))
  end

  table.insert(rows, ui.row({ gap = 8, justify = "center" }, {
    ui.button({ text = "Reset", variant = "destructive", onClick = "onReset" }),
    ui.button({ text = "Start", variant = "primary", onClick = "onStart", enabled = remaining > 0 }),
  }))

  desktopWidget.render(ui.column({ gap = 10, align = "center" }, rows))
end

noctalia.state.watch("timer.remaining", function(value)
  remaining = value
  render()
end)

noctalia.state.watch("timer.total", function(value)
  total = value
  render()
end)

function onReset()
  noctalia.state.set("timer.reset", true)
end

function onStart()
  noctalia.state.set("timer.start", true)
end

function update()
  desktopWidget.setWantsSecondTicks(true)
  render()
end
```

Desktop widgets cannot take keyboard focus; use buttons/sliders, not text inputs.
Position and size belong to the user's desktop-widget layout.

## Layer overlay driven by idle

API 36 for `[[layer]]`, API 35 for `noctalia.idle`.

```toml
id = "me/saver"
name = "Saver"
version = "1.0.0"
plugin_api = 36
author = "me"

[[setting]]
key = "timeout"
type = "int"
label_key = "settings.timeout.label"
default = 120
min = 10

[[service]]
id = "idle"
entry = "service.luau"

[[layer]]
id = "screen"
entry = "screen.luau"
layer = "overlay"
anchors = ["top", "bottom", "left", "right"]
exclusive_zone = -1
keyboard = "exclusive"
output = "all"
```

`service.luau`:

```lua
--!nonstrict
local watch = nil

local function apply()
  if watch ~= nil then
    noctalia.idle.unwatch(watch)
  end

  watch = noctalia.idle.watch(noctalia.getConfig("timeout") or 120, function(idle)
    if idle then
      noctalia.layer.show("screen")
    else
      noctalia.layer.hide("screen")
    end
  end)
end

apply()

function onConfigChanged()
  apply()
end

function onExit()
  if watch ~= nil then
    noctalia.idle.unwatch(watch)
    watch = nil
  end
end
```

`screen.luau`:

```lua
--!nonstrict
layer.render(ui.column({ fill = "#000000", flexGrow = 1, align = "center", justify = "center" }, {
  ui.button({
    text = "Wake",
    variant = "ghost",
    onClick = function()
      noctalia.layer.hide("screen")
    end,
  }),
}))
```

A layer is lazy: nothing exists until shown. It has one runtime per output while
visible, and hiding destroys that runtime, so do not keep state there that must
survive a hide.

## Control-center shortcut

```toml
[[shortcut]]
id = "toggle"
entry = "shortcut.luau"
```

```lua
--!nonstrict
local active = noctalia.state.get("active") == true

local function render()
  shortcut.setLabel(active and noctalia.tr("on") or noctalia.tr("off"))
  shortcut.setIcon("bulb", "bulb-off")
  shortcut.setActive(active)
  shortcut.setEnabled(true)
end

render()

function onClick()
  active = not active
  noctalia.state.set("active", active)
  render()
end

function onRightClick()
  noctalia.openSettings()   -- requires plugin_api 15
end
```

Shortcuts have no `update()`; render at the top level and from callbacks.

## Persisting JSON safely

```lua
--!nonstrict
local dir, dirErr = noctalia.pluginDataDir()
if not dir then
  noctalia.notifyError("Plugin data directory unavailable", dirErr)
end
local path = dir and (dir .. "/state.json") or nil
local state = { count = 0, history = {} }

local function load()
  if not path then return end
  local raw = noctalia.readFile(path)
  if not raw then return end

  local decoded, err = noctalia.json.decode(raw)
  if decoded then
    state = decoded
  else
    noctalia.log("state.json is corrupt: " .. tostring(err))
  end
end

local function save()
  if not path then return end
  local encoded, err = noctalia.json.encode(state, true)
  if not encoded then
    noctalia.notifyError("Could not save state", err)
    return
  end

  local ok, writeErr = noctalia.writeFile(path, encoded)
  if not ok then
    noctalia.notifyError("Could not save state", writeErr)
  end
end

load()
```

Use `pluginDataDir()`, not `pluginDir()`; git installs replace the latter on update.

## Safe subprocess arguments

```lua
--!nonstrict
local function gitFetch(repo, branch, done)
  noctalia.runAsync({ "git", "-C", repo, "fetch", "origin", branch }, function(result)
    if result.exitCode ~= 0 then
      noctalia.notifyError("git fetch failed", result.stderr)
      done(false)
      return
    end
    done(true)
  end)
end
```

Use the argv form for anything dynamic. The string form goes through `/bin/sh -c`
and requires shell quoting.

## Two-way config with `onConfigChanged`

```lua
--!nonstrict
local city = noctalia.getConfig("city")
local country = noctalia.getConfig("country")
local cache = nil

local function key()
  return tostring(city) .. "|" .. tostring(country)
end

local function refresh()
  local requested = key()
  noctalia.http({ url = "https://api.example.com/weather?q="
    .. noctalia.string.urlEncode(tostring(city) .. "," .. tostring(country)) }, function(res)
    if requested ~= key() then return end   -- a newer setting won
    if res.ok and res.status >= 200 and res.status < 300 then
      cache = noctalia.json.decode(res.body)
      noctalia.state.set("weather", cache)
    end
  end)
end

function onConfigChanged()
  city = noctalia.getConfig("city")
  country = noctalia.getConfig("country")
  refresh()
end

refresh()
```

`noctalia.state` survives a service restart, so key any cached data by the config it
depends on or invalidate it when settings change.

## Panel with a scrollable list and context menu

```lua
--!nonstrict
local items = { "alpha", "beta", "gamma" }
local selected = 1

local function render()
  local rows = {}
  for i, item in ipairs(items) do
    table.insert(rows, ui.button({
      key = "item-" .. i,
      text = item,
      variant = i == selected and "secondary" or "ghost",
      onClick = function()
        selected = i
        render()
      end,
      onRightClick = "openMenu",
    }))
  end

  panel.render(ui.column({ gap = 8 }, {
    ui.label({ text = "Items", fontSize = 16, fontWeight = "bold" }),
    ui.scroll({ flexGrow = 1, gap = 4 }, rows),
  }))
end

function onOpen()
  render()
end

function openMenu()
  panel.openContextMenu({
    items = {
      { id = "rename", label = "Rename" },
      { id = "delete", label = "Delete" },
    },
    onActivate = "onMenuAction",
    context = items[selected],
  })
end

function onMenuAction(action, item)
  if action == "delete" then
    for i, value in ipairs(items) do
      if value == item then
        table.remove(items, i)
        break
      end
    end
    selected = math.min(selected, #items)
    render()
  end
end
```

`openContextMenu` must be called from the `onRightClick` callback of a `ui.button`
while the pointer interaction is live; it returns `false` otherwise.
