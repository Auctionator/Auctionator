AuctionatorEventBusMixin = {}

function AuctionatorEventBusMixin:Init()
  self.registeredListeners = {}
  self.sources = {}
  self.queue = {}
end

function AuctionatorEventBusMixin:Register(listener, eventNames)
  if listener.ReceiveEvent == nil then
    error("Attempted to register an invalid listener! ReceiveEvent method must be defined.")
    return self
  end

  for _, eventName in ipairs(eventNames) do
    if self.registeredListeners[eventName] == nil then
      self.registeredListeners[eventName] = {}
    end

    table.insert(self.registeredListeners[eventName], listener)
    Auctionator.Debug.Message("AuctionatorEventBusMixin:Register", eventName)
  end

  return self
end

-- Assumes events have been registered exactly once
function AuctionatorEventBusMixin:Unregister(listener, eventNames)
  for _, eventName in ipairs(eventNames) do
    table.remove(
      self.registeredListeners[eventName],
      tIndexOf(self.registeredListeners[eventName], listener)
    )
    Auctionator.Debug.Message("AuctionatorEventBusMixin:Unregister", eventName)
  end

  return self
end

function AuctionatorEventBusMixin:RegisterSource(source, name)
  self.sources[source] = name

  return self
end

function AuctionatorEventBusMixin:UnregisterSource(source)
  self.sources[source] = nil

  return self
end

function AuctionatorEventBusMixin:Fire(source, eventName, ...)
  if self.sources[source] == nil then
    error("All sources must be registered (" .. eventName .. ")")
  end

  table.insert(self.queue, {sourceName = self.sources[source], eventName = eventName, params = {...}})

  Auctionator.Debug.Message(
    "AuctionatorEventBus:Fire()",
    self.sources[source],
    eventName,
    ...
  )

  --Already processing an event
  if #self.queue > 1 then
    return self
  end

  local current
  while #self.queue > 0 do
    Auctionator.Debug.Message("queued events", #self.queue)

    current = self.queue[1]

    if self.registeredListeners[current.eventName] ~= nil then
      Auctionator.Debug.Message("ReceiveEvent", #self.registeredListeners[current.eventName], current.eventName)

      local allListeners = Auctionator.Utilities.Slice(
        self.registeredListeners[current.eventName],
        1,
        #self.registeredListeners[current.eventName]
      )
      for _, listener in ipairs(allListeners) do
        listener:ReceiveEvent(current.eventName, unpack(current.params))
      end
    end

    table.remove(self.queue, 1)
  end

  return self
end
