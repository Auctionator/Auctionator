---@class addonTableAuctionator
local addonTable = select(2, ...)

addonTable.Wrappers.QueueMixin = {}

function addonTable.Wrappers.QueueMixin:Init()
  self.queue = {}
  addonTable.CallbackRegistry:RegisterCallback("ThrottleReady", self.ProcessNext, self)
end

local function Dequeue(self)
  if #self.queue > 0 then
    addonTable.Wrappers.Internals.throttling:SearchQueried()
    self.queue[1]()
    table.remove(self.queue, 1)
  end
end

function addonTable.Wrappers.QueueMixin:Enqueue(func)
  table.insert(self.queue, func)

  if addonTable.Wrappers.Internals.throttling:IsReady() then
    Dequeue(self)
  end
end

function addonTable.Wrappers.QueueMixin:Remove(func)
  local index = tIndexOf(self.queue, func)
  if index ~= nil then
    table.remove(self.queue, index)
  end
end

function addonTable.Wrappers.QueueMixin:ProcessNext()
  Dequeue(self)
end
