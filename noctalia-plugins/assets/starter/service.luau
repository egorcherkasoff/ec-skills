--!nonstrict
-- Starter service: publishes an incrementing tick once per refresh interval.

local count = 0

local function applyInterval()
  noctalia.setUpdateInterval(noctalia.getConfig("refresh_ms") or 1000)
end

applyInterval()

function update()
  count += 1
  noctalia.state.set("tick", count)
end

function onConfigChanged()
  applyInterval()
end
