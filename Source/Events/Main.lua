Auctionator.Events.Handlers = {}

function Auctionator.Events.Register(event, callback)
  if Auctionator.Events.Handlers[event]==nil then
    Auctionator.Events.Handlers[event] = {}
  end
  table.insert(Auctionator.Events.Handlers[event], callback)
end

function Auctionator.Events.Handler(self, event, ...)
  local handlers = Auctionator.Events.Handlers[event] or {}
  for i=1, #handlers do
    handlers[i](...)
  end
  Auctionator.Events.LegacyHandler(self, event, ...)
end
