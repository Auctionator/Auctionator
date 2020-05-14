Auctionator.AH.Queue = {}

function Auctionator.AH.Queue:Init()
  self.queue = {}
  Auctionator.EventBus:Register(self, {
    Auctionator.AH.Events.Ready
  })
end

local function Dequeue(self)
  if #self.queue > 0 then
    Auctionator.AH.Internals.throttling:Call(self.queue[1])
    table.remove(self.queue, 1)
  end
end

function Auctionator.AH.Queue:Enqueue(func)
  table.insert(self.queue, func)

  if Auctionator.AH.Internals.throttling:IsReady() then
    Dequeue(self)
  end
end

function Auctionator.AH.Queue:ReceiveEvent(event)
  Dequeue(self)
end
