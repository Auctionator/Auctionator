Auctionator.AH.Queue = {}

function Auctionator.AH.Queue:Init()
  self.queue = {}
  Auctionator.EventBus:Register(self, {
    --Auctionator.AH.Events.Ready
    Auctionator.AH.Events.SearchReady
  })
end

function Auctionator.AH.Queue:Push(func)
  table.insert(self.queue, func)

  if Auctionator.AH.internals.throttling.searchReady then
    self:_Pop()
  end
end

function Auctionator.AH.Queue:ReceiveEvent(event)
  print(event)
  self:_Pop()
end

function Auctionator.AH.Queue:_Pop()
  if #self.queue > 0 then
    print("calling")
    Auctionator.AH.internals.throttling:Call(self.queue[1])
    table.remove(self.queue, 1)
  end
end
