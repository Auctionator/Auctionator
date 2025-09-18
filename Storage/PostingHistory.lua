---@class addonTableAuctionator
local addonTable = select(2, ...)

addonTable.Storage.PostingHistoryMixin = {}

function addonTable.Storage.PostingHistoryMixin:Init(db)
  self.db = db

  addonTable.CallbackRegistry:RegisterCallback("AuctionCreated", function()
    addonTable.Storage.DBKeyFromLink(eventData.itemLink, function(keys)
      for _, key in ipairs(keys) do
        self:AddEntry(key, eventData.buyoutAmount, eventData.quantity, eventData.bidAmount)
      end
    end)
  end)
end

function addonTable.Storage.PostingHistoryMixin:AddEntry(key, price, quantity, bidPrice)
  addonTable.Storage.Debug.Message("Auctionator.PostingHistoryMixin:AddEntry", key, price, quantity)
  if not self.db[key] then
    self.db[key] = {}
  end

  -- Remove bid price because the wrong value is reported for multiple stacks
  -- posted
  if addonTable.Storage.Constants.IsLegacyAH then
    bidPrice = nil
  end

  table.insert(self.db[key], {
    price = price, quantity = quantity, bidPrice = bidPrice, time = time()
  })

  self:PruneKey(key)
end

local function IsSameDay(time1, time2)
  return time1.day == time2.day and time1.month == time2.month and time1.year == time2.year
end

function addonTable.Storage.PostingHistoryMixin:PruneKey(key)
  local itemInfo = self.db[key]

  local currentTime = date("*t", itemInfo[#itemInfo].time)
  local price = itemInfo[#itemInfo].price

  local index = #itemInfo - 1
  --Combine any items of the same price and same day
  while index > 0 do
    local otherTime = date("*t", itemInfo[index].time)
    if itemInfo[index].price == price and
        IsSameDay(currentTime, otherTime) then
      -- Combine quantities
      itemInfo[#itemInfo].quantity = itemInfo[#itemInfo].quantity + itemInfo[index].quantity
      table.remove(itemInfo, index)
    end
    index = index - 1
  end

  while #itemInfo > addonTable.Storage.Config.Get(Auctionator.Config.Options.POSTING_HISTORY_LENGTH) do
    table.remove(itemInfo, 1)
  end
end

function addonTable.Storage.PostingHistoryMixin:GetPriceHistory(dbKey)
  if self.db[dbKey] == nil then
    return {}
  end

  local results = {}

  for _, entry in ipairs(self.db[dbKey]) do
    table.insert(results, {
     date = addonTable.Utilities.PrettyDate(entry.time),
     rawDay = entry.time,
     price = entry.price,
     bidPrice = entry.bidPrice,
     quantity = entry.quantity
   })
 end

 return results
end
