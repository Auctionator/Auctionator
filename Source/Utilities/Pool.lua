Auctionator.Utilities.PoolMixin = {}

function Auctionator.Utilities.PoolMixin:Init()
  self.pool = {}
end

function Auctionator.Utilities.PoolMixin:SetCreator(func)
  self.creatorFunc = func
end

function Auctionator.Utilities.PoolMixin:Get()
  for item, state in pairs(self.pool) do
    if state then
      self.pool[item] = nil
      return item
    end
  end

  return self.creatorFunc()
end

function Auctionator.Utilities.PoolMixin:Return(item)
  self.pool[item] = true
end
