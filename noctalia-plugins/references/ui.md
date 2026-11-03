# Declarative UI (`ui.*`)

Desktop widgets, panels, and layers describe their UI as a retained `ui.*` tree.
Bar widgets can opt in with `barWidget.render(tree)`. Noctalia diffs each render
against the previous tree and updates native controls in place, so re-rendering an
unchanged tree is cheap.

```lua
panel.render(ui.column({ gap = 12, padding = 4 }, {
  ui.label({ text = "Hello", fontSize = 16, fontWeight = "bold", color = "primary" }),
  ui.row({ gap = 8, align = "center" }, {
    ui.button({ text = "Ping", variant = "primary", onClick = "ping" }),
    ui.button({ glyph = "close", variant = "ghost", onClick = "closePanel" }),
  }),
}))
```

Only `ui.column`, `ui.row`, `ui.scroll`, `ui.dragSource`, and `ui.dropZone` host
children. The rest are leaves: `ui.box`, `ui.label`, `ui.markdown`, `ui.glyph`,
`ui.image`, `ui.pixelStream`, `ui.colorPicker`, `ui.separator`, `ui.spacer`,
`ui.progress`, `ui.button`, `ui.graph`, `ui.input`, `ui.select`, `ui.slider`, and
`ui.toggle` take only a props table.

## Constructors and props

| Constructor | Props |
| --- | --- |
| `ui.column` / `ui.row` | `gap`, `padding`, `paddingH`, `paddingV`, `align` (`start`/`center`/`end`/`stretch`), `justify` (`start`/`center`/`end`/`space_between`), `fill`, `radius`, `border`, `borderWidth`, `minWidth`, `minHeight`, `onClick`, `onHover`, `tooltip` |
| `ui.scroll` | column layout props plus `fill`, `radius`, `border`, `borderWidth`, `stickToBottom`, `onScroll`, `scrollToBottomRev`, `revealKey` |
| `ui.label` | `text`, `fontSize`, `color`, `fontWeight` (`thin`…`heavy`), `fontFamily`, `baseline` (`text`/`textFixedHeight`/`inkCentered`/`pictographic`), `maxWidth`, `maxLines`, `textAlign` |
| `ui.markdown` | `text`, `width`, `height` (API 21) |
| `ui.glyph` | `name` (Tabler/Nerd-Font), `size`, `color` |
| `ui.image` | `path` (local file; plugin-relative, `~`, or absolute), `width`, `height`, `radius`, `fit` (`contain`/`cover`/`stretch`), `border`, `borderWidth`, `onClick`, `onHover`, `tooltip` |
| `ui.pixelStream` | `path` (companion socket; plugin-relative, `~`, or absolute), `width`, `height`, `radius`, pointer/keyboard callbacks (API 40) |
| `ui.box` | `fill`, `radius`, `border`, `borderWidth`, `softness`, `width`, `height`, `onClick`, `onHover`, `tooltip` |
| `ui.separator` | `thickness`, `color`, `spacing`, `orientation` (`auto`/`horizontal`/`vertical`) |
| `ui.spacer` | flexible filler; use `flexGrow` |
| `ui.progress` | `progress` (0–1), `fill`, `track`, `marker` (0–1, optional reference line), `markerColor`, `radius`, `width`, `height` |
| `ui.button` | `text`, `glyph`, `fontSize`, `glyphSize`, `variant` (`default`/`primary`/`secondary`/`destructive`/`outline`/`ghost`), `contentAlign` (`start`/`center`/`end`), `controlSize` (`sm`/`md`/`lg`), `tooltip`, `enabled`, `selected`, `onClick`, `onRightClick`, `onHover` |
| `ui.graph` | `values` / `values2` (arrays of 0–1), `color` / `color2`, `lineWidth`, `fillOpacity`, `width`, `height`, `onPointerMove`, `onPointerLeave` (API 29) |
| `ui.toggle` | `checked`, `enabled`, `onChange` |
| `ui.slider` | `min`, `max`, `step`, `value`, `controlSize`, `enabled`, `onChange`, `onDragEnd` |
| `ui.colorPicker` | `value`, `alpha`, `inputs`, `swatches`, `width`, `enabled`, `onChange`, `onChangeEnd` (API 41) |
| `ui.select` | `options` (array of strings), `selectedIndex`, `placeholder`, `controlSize`, `enabled`, `width`, `height`, `onChange` |
| `ui.input` | `value`, `placeholder`, `fontSize`, `controlSize`, `password`, `multiline`, `submitOnEnter`, `frameVisible`, `focus`, `enabled`, `onChange`, `onSubmit` |
| `ui.dragSource` | `dragType`, `payload`, `enabled`, `tooltip`, `previewAncestor`, `liftFromLayout`, `grabCursor`, `onClick` |
| `ui.dropZone` | `accepts`, `value`, `onDrop`, `direction`, `enabled`, `expandOnDrag`, `hitSlop` |

Every control also accepts `width`, `height`, `flexGrow`, `opacity`, `visible`, and
`key`.

## Layout and appearance

- `ui.column`, `ui.row`, and `ui.scroll` stretch their children across the cross
  axis by default, like CSS flexbox. Override per node with `align`; a row of
  vertically centered items uses `align = "center"`.
- `opacity` is **group** opacity: it fades the container and all children,
  including text. For a translucent background with opaque content, use a
  translucent `fill` instead: `fill = "surface_container/0.6"`.
- `controlSize` sets a named height tier: `sm` 32 px, `md` 38 px (default), `lg`
  44 px, scaled with the surface. Use it to align rows of controls. An explicit
  `height` wins.
- `ui.glyph`'s `size` is the glyph size in px, not a height tier.
- `ui.image` loads **local files only**. Download remote previews with
  `noctalia.download(url, dest, cb)` first, then pass the saved path.
- `key` gives a child identity across re-renders, so reordering reuses the same
  native controls and their handlers. Use keys for list rows.
- In bar widgets, `ui.label` and `ui.glyph` inherit the bar/widget font, weight,
  scale, foreground, and icon color unless the prop overrides them. In panels and
  desktop widgets, an unset `color` stays `on_surface`.
- `ui.button` in a bar widget renders compact: it hugs its content instead of the
  taller settings-panel height.

### Colors

Use a palette role, a role with an alpha suffix, or a hex value:

```lua
color = "primary"
color = "primary/0.6"       -- primary at 60% alpha, tracks the theme
color = "#FFCC00"
color = "#FFCC0080"
```

The 28 roles are: `primary`, `on_primary`, `primary_container`,
`on_primary_container`, `secondary`, `on_secondary`, `secondary_container`,
`on_secondary_container`, `tertiary`, `on_tertiary`, `tertiary_container`,
`on_tertiary_container`, `error`, `on_error`, `error_container`,
`on_error_container`, `surface`, `on_surface`, `on_surface_variant`,
`surface_container_low`, `surface_container`, `surface_container_high`,
`surface_container_highest`, `outline_variant`, `shadow`, `scrim`, `hover`,
`on_hover`.

`surface_variant` and `outline` are retired aliases for `surface_container` and
`outline_variant`; using the new names requires `plugin_api = 43`. Use
`noctalia.getColor(role)` (API 31) when you need the hex value in Lua.

## Callbacks

A callback prop is either:

- the **name of a global function** in the entry script, e.g. `onClick = "ping"`;
- a **function closure**, requires `plugin_api = 9`.

Values arrive as **strings**:

- `ui.toggle` `onChange` → `"true"` / `"false"`
- `ui.slider` `onChange` → number (convert with `tonumber`); `onDragEnd` fires
  with no arguments when the interaction ends
- `ui.select` `onChange` → selected index (and optionally the text as a second arg)
- `ui.input` `onChange` / `onSubmit` → text
- `ui.colorPicker` `onChange` / `onChangeEnd` → `#RRGGBB` or `#RRGGBBAA`
- `ui.scroll` `onScroll` → `(offset, maxOffset)` strings
- `ui.graph` `onPointerMove` → `normX`, `normY` strings from `"0.0000"` to `"1.0000"`
- `ui.pixelStream` pointer positions → normalized strings

```lua
ui.button({
  text = "Remove",
  variant = "destructive",
  onClick = function()
    remove(item.id)
    render()
  end,
})
```

Handlers belong to the render that produced them. Re-rendering replaces them; a
click on a node no longer in the current tree does nothing. Give repeated nodes a
`key` so handlers survive a re-render unchanged. Named handlers are required for a
graph's teardown leave, because a closure from the render that dropped the graph is
already superseded.

### Hover

`onHover` works on `ui.row`, `ui.column`, `ui.box`, `ui.image`, and `ui.button`.
The handler receives `state` (`"true"` on enter, `"false"` on leave) and the node's
`key` (empty when none). Only the innermost hovered element reports; hovering an
interactive child makes the container report `"false"`. Every `"true"` is matched
by a `"false"`, including when the node disappears, so a hover flag never sticks.

```lua
function onChipHover(state, key)
  hovered = (state == "true") and key or nil
  render()
end
```

### Clickable containers

`onClick` on `ui.row`, `ui.column`, `ui.box`, or `ui.image` makes the whole
container a click target while keeping its layout. Clickable containers join the
keyboard tab order and activate with Enter/Space. A container with only `onHover`
does not swallow clicks; they pass through to an enclosing click target. An empty
`onClick`/`onHover` name counts as unset.

## Interactive controls

### `ui.input`

- **Uncontrolled**: `value` seeds the field once; after that the host owns the
  text buffer. Re-rendering never overwrites what the user typed. Read edits through
  `onChange` / `onSubmit`; give the input a stable `key`.
- `focus = true` grabs keyboard focus once, when the control is **created**, never
  on later re-renders. Give a new `key` to focus again. The seeded `value` places the
  caret at the end.
- `multiline = true` (API 21): wrapping text area with vertical scrolling; Enter
  inserts a newline and `onSubmit` fires on Ctrl+Enter. `multiline` and `password`
  are mutually exclusive.
- `submitOnEnter = true` (API 21) flips the multiline bindings for chat composers:
  Enter submits, Shift+Enter inserts a newline, Ctrl+Enter still submits.
- `frameVisible = false` (API 27) hides the native background and border while
  preserving editing, selection, cursor, scrolling, and focus.
- `password = true` masks the text.

### `ui.toggle`, `ui.slider`, `ui.select`

These are **value-driven**: pass the current value on every render and update it
from the callback. A slider's `value` is applied only when the prop changes between
renders, never while the user is dragging; passing the `onChange` value straight
back is safe. Use `onDragEnd` for persistence. `ui.select` opens a dropdown;
persistent panels cannot use it.

### `ui.scroll`

- `stickToBottom = true` (API 21) stays pinned to the bottom while content grows,
  until the user scrolls away.
- `onScroll(offset, maxOffset)` delivers both as strings.
- `scrollToBottomRev` jumps to the bottom on the first render that sees it and again
  whenever the number changes. The jump lands after the next layout pass, so it
  reaches content added in the same render.
- `revealKey = "hit-12"` (API 33) scrolls the descendant with that `key` into view
  by the smallest distance that shows it whole, and leaves the offset alone when it
  is already fully visible. It re-applies when the value changes or the child
  reappears, never on an unchanged re-render.
- A control inside a `ui.scroll` that gains keyboard focus (Tab/Shift+Tab) is
  scrolled into view automatically.

```lua
ui.scroll({ flexGrow = 1, revealKey = "hit-" .. selected }, rows)
```

### `ui.markdown`

API 21. Renders headings, lists, code blocks, and tables as a read-only block. The
host re-parses only when `text` or the surface scale changes, so streaming updates
with unchanged text are cheap.

### `ui.colorPicker`

API 41. Embeds the shell's picker: saturation/brightness plane, hue strip, and text
fields.

- `value` is `#RRGGBB`, or `#RRGGBBAA` with `alpha = true`; callbacks report the
  same form.
- `alpha` adds a transparency strip and percentage field.
- `inputs`: `"full"` (HEX/RGB/HSL switch and fields), `"hex"` (hex field only), or
  `"none"`. The format switch uses a dropdown, so only panels can show `"full"`;
  elsewhere use `"hex"` or `"none"`. Text fields need keyboard focus.
- `swatches`: up to 16 hex colors.
- `width` sets the picker width; height follows.
- `onChange` fires continuously and is coalesced; `onChangeEnd` fires once when a
  drag is released, a typed value is applied, or a swatch is clicked.

### `ui.graph`

Values are arrays of numbers from 0 to 1. `onPointerMove` receives normalized
positions within the graph box, `0,0` at top-left, so `normY` grows downward. Map x
onto your own samples; the graph does not know what they mean. `onPointerLeave`
fires with no arguments. Positions are coalesced, so a fast pointer cannot flood a
slow script. A graph with neither prop takes no pointer input.

## `ui.*` in each surface

### Bar widget

- The capsule clips to bar thickness. Keep the tree one control tall: a row on a
  horizontal bar, a column on a side bar. Branch on `barWidget.isVertical()`.
- No keyboard focus: `ui.input`, `ui.select`, and `ui.scroll` are skipped with a
  warning.
- Pointer controls work. An inline control consumes its own clicks; the widget-level
  `onClick` / `onRightClick` still fire for the rest of the capsule and its padding.
- A slider consumes vertical wheel events over itself; the widget's own `onScroll`
  does not see those.
- Drag/drop works (API 38) with the ghost confined to the widget's extent.
- There is no frame-tick API in the bar; use `noctalia.setUpdateInterval`.

### Panel

- Takes keyboard focus while open (depending on `keyboard_focus`), so all
  interactive controls are available.
- Panel size is host-owned. Render in `onOpen`; `height = "content"` follows the
  tree up to `max_height`.
- `panel.setWantsSecondTicks(true)` runs `update()` on second boundaries;
  `panel.setNeedsFrameTick(true)` adds per-frame `onFrameTick(deltaMs)` while open.
- `panel.openContextMenu` is available from `ui.button`'s `onRightClick`.

### Desktop widget

- No keyboard focus: use pointer controls.
- Position/size/rotation are host-owned; the script only renders content.
- `desktopWidget.setWantsSecondTicks(true)` runs `update()` on second boundaries;
  `setNeedsFrameTick(true)` adds `onFrameTick(deltaMs)`.
- Tooltips are not shown.

### Layer

- Same tree vocabulary as panels.
- Keys only reach controls while the layer holds keyboard focus.
- One runtime per shown output; `layer.outputName()` identifies it.
- `layer.setNeedsFrameTick(true)` adds `onFrameTick(deltaMs)` while shown.

## Drag and drop

API 5 for panels; API 38 for bar widgets. The host owns pointer capture, hit
testing, the drag ghost, target highlighting, and cursor changes. The plugin gets
one callback after a completed drop and must mutate its own model then re-render.

| Constructor | Required | Optional |
| --- | --- | --- |
| `ui.dragSource` | `dragType` (matched against `accepts`), `payload` (first callback arg) | `enabled`, `tooltip`, `previewAncestor` (0–8 parent levels), `liftFromLayout`, `grabCursor` (default true), `onClick` (fires on a press released before the drag threshold) |
| `ui.dropZone` | `accepts` (array of drag types; `{}` accepts nothing), `value` (second callback arg), `onDrop` | `direction` (`column`/`row`), `enabled`, `expandOnDrag`, `hitSlop` |

A press becomes a drag only after a small movement threshold, so clicks on controls
inside a dragged row still work. While dragging, the source dims (or lifts out of
layout), a ghost follows the pointer, and accepted targets highlight. Releasing over
an accepted zone calls `onDrop(payload, value)`; releasing elsewhere cancels
silently. Nested zones resolve to the deepest accepting zone; zones with `hitSlop`
are considered first, closest wins.

```lua
local function row(id)
  return ui.row({ key = "row-" .. id, gap = 8, align = "center" }, {
    ui.dragSource({
      key = "grip-" .. id,
      dragType = "item",
      payload = id,
      previewAncestor = 1,
      liftFromLayout = true,
      width = 24,
      height = 24,
    }, { ui.glyph({ name = "menu-2", size = 14 }) }),
    ui.label({ text = id, flexGrow = 1 }),
  })
end

local function gap(anchor, place)
  return ui.dropZone({
    key = "gap-" .. place .. "-" .. anchor,
    accepts = { "item" },
    value = place .. "|" .. anchor,
    onDrop = "onReorder",
    height = 3,
    expandOnDrag = true,
    hitSlop = 48,
  })
end

function onReorder(id, target)
  local place, anchor = string.match(target, "^([^|]+)|(.+)$")
  moveItem(id, anchor, place)
  render()                 -- re-render after mutating the model
end
```

Patterns:

- **Sortable lists:** a thin `expandOnDrag` + `hitSlop` insertion zone before every
  row and one after the last. With `liftFromLayout` on the source, the list shows
  exactly one open gap that follows the pointer. Encode the insertion point in
  `value`; the callback never receives coordinates.
- **Cross-container moves:** use the same `dragType` in every compatible container
  and a different `value` per container. Keep a container-level `ui.dropZone` around
  each list so an empty list stays a valid target.
- **Update the model before slow persistence:** mutate and `render()` first, keep a
  snapshot to roll back, and use `enabled = false` while a save is in flight.
- **Limits:** `payload` 16 KiB; `dragType`, `value`, `onDrop`, and each `accepts`
  entry 256 bytes; at most 16 `accepts` entries.
- **Scope:** panels and bar widgets only; rejected with a log on desktop widgets and
  layers. Drags stay inside one panel or one bar widget (the ghost is clipped to the
  surface). Only the left button drags; no OS/Wayland drag, no keyboard drag, and
  the wheel cannot scroll while a drag is active. Provide a non-drag alternative.

## Pixel streams

API 40. `ui.pixelStream` shows live frames from a companion process, e.g. a phone
screen mirror. The companion owns capture, decoding, audio, and device input;
Noctalia only displays pixels and reports pointer/keyboard actions. Frame data never
passes through the Lua script.

```lua
ui.pixelStream({
  key = "screen",
  path = noctalia.pluginDataDir() .. "/screen.sock",
  width = 320,
  height = 640,
  radius = 12,
  onPointerDown = function(x, y) sendTouch("down", x, y) end,
  onPointerMove = function(x, y) lastX, lastY = x, y end,
  onPointerUp = function(x, y) sendTouch("up", x, y) end,
  onPointerCancel = function() sendTouch("cancel") end,
  onScroll = function(dx, dy) sendScroll(lastX, lastY, tonumber(dx), tonumber(dy)) end,
  onTextInput = function(text) sendText(text) end,
  onKeyEvent = function(chord, pressed) sendKey(chord, pressed == "true") end,
})
```

- The frame is fitted inside `width` × `height` preserving aspect ratio; supply both.
- Until the first frame, and after `path` changes, the control is empty.
- When the companion disconnects, the last frame stays and Noctalia reconnects
  every second.
- Pointer positions are strings from `"0.0000"` to `"1.0000"`, relative to the
  displayed frame (letterboxing excluded), `0,0` at top-left.
- `onPointerMove` also fires outside the frame during a left drag, pinned to the
  nearest edge. Moves are coalesced; never one from after a later press/release.
- `onPointerDown`/`onPointerUp` bracket a left-button drag; `onPointerCancel` ends it
  without a release (disconnect, size change, callbacks changed, or left the tree).
- `onRightClick`/`onMiddleClick` fire on press-release over the control, with the
  press position.
- `onScroll(dx, dy)` reports whole wheel steps, positive right/down; pair with the
  last `onPointerMove` position.
- Declaring `onTextInput` or `onKeyEvent` lets the user focus the control by
  clicking it. Keys arrive only while focused, so this works in panels/layers with
  keyboard focus, not bar widgets. `onKeyEvent` chords use `"Ctrl+c"`, `"Return"`,
  `"BackSpace"` style; Super chords are never delivered. Host keys keep priority.

### Companion protocol

The companion listens on a filesystem Unix socket of type `SOCK_SEQPACKET` at
`path`, ideally in a user-only directory. Noctalia connects while the control
exists, accepts only a peer running as the same user, and closes when the control is
removed. Noctalia does not start or stop the companion.

Every message is little-endian unsigned 32-bit fields:

| Direction | Message | Fields | Meaning |
| --- | --- | --- | --- |
| Noctalia → companion | `HELLO` | `1`, version `1` | first message on every connection; close if unsupported |
| Noctalia → companion | `REQUEST` | `2`, `0` | ready for the next frame and done reading the previous buffer |
| companion → Noctalia | `BUFFER` | `1`, id, width, height | attaches shared buffer id 0–3 with one `SCM_RIGHTS` fd |
| companion → Noctalia | `FRAME` | `2`, id | buffer id holds the frame; only valid as an answer to `REQUEST` |

A buffer is a `memfd` of `width × height` RGBA pixels, 4 bytes each, rows top to
bottom, no padding. It must be at least that large and sealed against shrinking
(`MFD_ALLOW_SEALING`, then `F_ADD_SEALS` with `F_SEAL_SHRINK`). Dimensions are 1–4096
and at most 4,194,304 pixels. Pixels should be opaque (alpha 255). Send `BUFFER`
again with the same id to replace it or change size. There is at most one
outstanding `REQUEST`: answer immediately on a new connection, and only when a newer
frame exists. Do not write to or replace a buffer between `FRAME` and the next
`REQUEST`; use two buffers. Noctalia sends `REQUEST` after uploading a frame, so the
stream is paced by the shell and pauses while the control is not drawn. A malformed
or out-of-order message closes the connection; reconnect after one second.
