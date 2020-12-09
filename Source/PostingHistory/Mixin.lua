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

  local prettyDate = Auctionator.Utilities.PrettyDate(itemInfo[#itemInfo].time)

  local index = #itemInfo - 1
  --Combine any items on the same day and same date visually
  while index > 0 do
    if itemInfo[index].price == price and Auctionator.Utilities.PrettyDate(itemInfo[index].time) == prettyDate then
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
