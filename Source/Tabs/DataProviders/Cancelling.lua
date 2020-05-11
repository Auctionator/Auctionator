local CANCELLING_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = "Name",
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Quantity",
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Unit Price",
    headerParameters = { "price" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" }
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Time Left",
    headerParameters = { "timeLeft" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "timeLeft" }
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Cancel",
    cellTemplate = "AuctionatorDeleteButtonCellTemplate",
    width = 80,
  }
}

AuctionatorCancellingDataProviderMixin = CreateFromMixins(DataProviderMixin, AuctionatorItemKeyLoadingMixin)

function AuctionatorCancellingDataProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)
  AuctionatorItemKeyLoadingMixin.OnLoad(self)
  Auctionator.EventBus:Register(self, {Auctionator.Cancelling.Events.RequestCancel})

  self.beenCancelled = {}

  self:RegisterEvent("OWNED_AUCTIONS_UPDATED")
  self:RegisterEvent("AUCTION_CANCELED")
end

function AuctionatorCancellingDataProviderMixin:OnShow()
  self.beenCancelled = {}

  C_AuctionHouse.QueryOwnedAuctions({})
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator
}

function AuctionatorCancellingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function AuctionatorCancellingDataProviderMixin:OnEvent(eventName, ...)
  AuctionatorItemKeyLoadingMixin.OnEvent(self, event, ...)
  if eventName == "AUCTION_CANCELED" then
    C_AuctionHouse.QueryOwnedAuctions({})

  elseif eventName == "OWNED_AUCTIONS_UPDATED" then
    self:Reset()
    self:PopulateAuctions()
  end
end

function AuctionatorCancellingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Cancelling.Events.RequestCancel then
    table.insert(self.beenCancelled, eventData)
  end
end

function AuctionatorCancellingDataProviderMixin:PopulateAuctions()
  local results = {}
  for index = 1, C_AuctionHouse.GetNumOwnedAuctions() do
    local info = C_AuctionHouse.GetOwnedAuctionInfo(index)

    --Only look at unsold auctions
    if info.status == 0 then
      table.insert(results, {
        id = info.auctionID,
        quantity = info.quantity,
        price = info.buyoutAmount or info.bidAmount,
        itemKey = info.itemKey,
        timeLeft = math.ceil(info.timeLeftSeconds/60/60),
        cancelled = (Auctionator.Utilities.ArrayIndex(self.beenCancelled, info.auctionID) ~= nil)
      })
    end
  end
  self:AppendEntries(results, true)
end

function AuctionatorCancellingDataProviderMixin:UniqueKey(entry)
  return tostring(entry.id)
end

function AuctionatorCancellingDataProviderMixin:GetTableLayout()
  return CANCELLING_TABLE_LAYOUT
end

function AuctionatorCancellingDataProviderMixin:GetRowTemplate()
  return "AuctionatorCancellingListResultsRowTemplate"
end
