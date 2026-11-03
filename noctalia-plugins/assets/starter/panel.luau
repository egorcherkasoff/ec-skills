--!nonstrict
-- Starter panel: a small declarative ui.* tree that reads shared state.

local tick = noctalia.state.get("tick") or 0
local isOpen = false

local function render()
  panel.render(ui.column({ gap = 12 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({
        text = noctalia.tr("panel.title"),
        fontSize = 16,
        fontWeight = "bold",
        color = "primary",
        flexGrow = 1,
      }),
      ui.button({ glyph = "close", variant = "ghost", onClick = "closePanel" }),
    }),
    ui.label({
      text = noctalia.tr("panel.tick", { tick = tick }),
      color = "on_surface",
    }),
    ui.label({
      text = noctalia.tr("panel.hint"),
      color = "on_surface_variant",
    }),
    ui.button({
      text = noctalia.tr("panel.close"),
      variant = "primary",
      onClick = "closePanel",
    }),
  }))
end

noctalia.state.watch("tick", function(value)
  tick = value
  if isOpen then
    render()
  end
end)

function onOpen(_context)
  isOpen = true
  render()
end

function onClose()
  isOpen = false
end

function closePanel()
  panel.close()
end
