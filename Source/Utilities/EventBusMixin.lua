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
    local index = tIndexOf(self.registeredListeners[eventName], listener)
    if index ~= nil then
      table.remove(self.registeredListeners[eventName], index, listener)
    end
    Auctionator.Debug.Message("AuctionatorEventBusMixin:Unregister", eventName)
  end

  return self
end

function AuctionatorEventBusMixin:IsSourceRegistered(source)
  return self.sources[source] ~= nil
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

  Auctionator.Debug.Message(
    "AuctionatorEventBus:Fire()",
    self.sources[source],
    eventName,
    ...
  )

  if self.registeredListeners[eventName] ~= nil then
    Auctionator.Debug.Message("ReceiveEvent", #self.registeredListeners[eventName], eventName)

    local allListeners = Auctionator.Utilities.Slice(
      self.registeredListeners[eventName],
      1,
      #self.registeredListeners[eventName]
    )
    for index, listener in ipairs(allListeners) do
      listener:ReceiveEvent(eventName, ...)
    end
  end

  return self
end

Auctionator.EventBus = CreateAndInitFromMixin(AuctionatorEventBusMixin)
