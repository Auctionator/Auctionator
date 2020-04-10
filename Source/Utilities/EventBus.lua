AuctionatorEventBus = {}

function AuctionatorEventBus:Register(frame, eventNames)
  if frame.EventUpdate == nil then
    error("Attempted to register an invalid frame! EventUpdate function must be defined.")
    return
  end

  if self.registeredFrames == nil then
    self.registeredFrames = {}
  end

  for _, eventName in ipairs(eventNames) do
    if self.registeredFrames[eventName] == nil then
      self.registeredFrames[eventName] = {}
    end

    table.insert(self.registeredFrames[eventName], frame)
  end
end

function AuctionatorEventBus:Fire(eventName, eventData)
  Auctionator.Debug.Message("AuctionatorEventBus:Fire()", eventName, eventData)

  if self.registeredFrames == nil or self.registeredFrames[eventName] == nil then
    return
  end

  for _, frame in ipairs(self.registeredFrames[eventName]) do
    frame:EventUpdate(eventName, eventData)
  end
end