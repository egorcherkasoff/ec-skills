--!nonstrict
-- Starter bar widget: shows a configurable label and glyph, reflects the service
-- tick, opens the panel on click, and accepts IPC to change its label.

local label = noctalia.getConfig("label")
local glyph = noctalia.getConfig("glyph")
local showGlyph = noctalia.getConfig("show_glyph")
local tick = noctalia.state.get("tick") or 0

-- Settings changes rebuild the widget, so this top-level call is enough.
noctalia.setUpdateInterval(noctalia.getConfig("refresh_ms") or 1000)

local function render()
  if showGlyph then
    barWidget.setGlyph(glyph)
  end
  barWidget.setText(label)
  barWidget.setTooltip({
    { key = "Tick", value = tostring(tick) },
    { key = "Label", value = label },
  })
end

noctalia.state.watch("tick", function(value)
  tick = value
  render()
end)

function update()
  render()
end

function onClick()
  noctalia.togglePanel("me/hello:panel")
end

function onIpc(event, payload)
  if event == "set" then
    label = payload
    render()
  end
end

render()
