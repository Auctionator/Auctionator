Auctionator.PostingHistoryMixin = {}

function Auctionator.PostingHistoryMixin:Init(db)
  self.db = db
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.AuctionCreated
  })
end

function Auctionator.PostingHistoryMixin:AddEntry(key, price, quantity)
  Auctionator.Debug.Message("Auctionator.PostingHistoryMixin:AddEntry", key, price, quantity)
  if not self.db[key] then
    self.db[key] = {}
  end

  local itemInfo = self.db[key]

  table.insert(itemInfo, {
    price = price, quantity = quantity, time = time()
  })

  local currentTime = date("*t", itemInfo[#itemInfo].time)

  local index = #itemInfo - 1
  --Combine any items of the same price and same day
  while index > 0 do
    local time = date("*t", itemInfo[index].time)
    if itemInfo[index].price == price and
        time.day == currentTime.day and time.month == currentTime.month and time.year == currentTime.year then
      itemInfo[#itemInfo].quantity = itemInfo[#itemInfo].quantity + itemInfo[index].quantity
      table.remove(itemInfo, index)
      index = index - 1
    end
  end

  if #itemInfo > Auctionator.Config.Get(Auctionator.Config.Options.POSTING_HISTORY_LENGTH) then
    table.remove(itemInfo, 1)
  end
end

function Auctionator.PostingHistoryMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Selling.Events.AuctionCreated then
    self:AddEntry(
      Auctionator.Utilities.ItemKeyFromLink(eventData.itemLink),
      eventData.buyoutAmount,
      eventData.quantity
    )
  end
end

function Auctionator.PostingHistoryMixin:GetPriceHistory(itemKey)
  if self.db[itemKey] == nil then
    return {}
  end

  local results = {}

  for _, entry in ipairs(self.db[itemKey]) do
    table.insert(results, {
     date = Auctionator.Utilities.PrettyDate(
        entry.time
     ),
     rawDay = entry.time,
     price = entry.price,
     quantity = entry.quantity
   })
 end

 return results
end
