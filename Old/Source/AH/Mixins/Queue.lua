Auctionator.AH.QueueMixin = {}

function Auctionator.AH.QueueMixin:Init()
  self.queue = {}
  Auctionator.EventBus:Register(self, {
    Auctionator.AH.Events.Ready
  })
end

local function Dequeue(self)
  if #self.queue > 0 then
    Auctionator.AH.Internals.throttling:SearchQueried()
    self.queue[1]()
    table.remove(self.queue, 1)
  end
end

function Auctionator.AH.QueueMixin:Enqueue(func)
  table.insert(self.queue, func)

  if Auctionator.AH.Internals.throttling:IsReady() then
    Dequeue(self)
  end
end

function Auctionator.AH.QueueMixin:Remove(func)
  local index = tIndexOf(self.queue, func)
  if index ~= nil then
    table.remove(self.queue, index)
  end
end

function Auctionator.AH.QueueMixin:ReceiveEvent(event)
  Dequeue(self)
end
