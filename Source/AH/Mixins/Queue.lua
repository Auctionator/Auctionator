Auctionator.AH.Queue = (function()
  local Mixin = {}

  function Mixin:Init()
    self.queue = {}
    Auctionator.EventBus:Register(self, {
      --Auctionator.AH.Events.Ready
      Auctionator.AH.Events.SearchReady
    })
  end

  function Pop(self)
    if #self.queue > 0 then
      print("calling")
      Auctionator.AH.internals.throttling:Call(self.queue[1])
      table.remove(self.queue, 1)
    end
  end

  function Mixin:Push(func)
    table.insert(self.queue, func)

    if Auctionator.AH.internals.throttling.searchReady then
      Pop(self)
    end
  end

  function Mixin:ReceiveEvent(event)
    print(event)
    Pop(self)
  end

  return Mixin
end)()
