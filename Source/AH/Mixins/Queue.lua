Auctionator.AH.Queue = {}

function Auctionator.AH.Queue:Init()
  self.queue = {}
  Auctionator.EventBus:Register(self, {
    Auctionator.AH.Events.Ready
  })
end

local function Pop(self)
  if #self.queue > 0 then
    Auctionator.AH.internals.throttling:Call(self.queue[1])
    table.remove(self.queue, 1)
  end
end

function Auctionator.AH.Queue:Push(func)
  table.insert(self.queue, func)

  if Auctionator.AH.internals.throttling.ready then
    Pop(self)
  end
end

function Auctionator.AH.Queue:ReceiveEvent(event)
  Pop(self)
end
