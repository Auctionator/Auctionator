AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnLoad()
  Auctionator.EventBus:Register( self, { Auctionator.Selling.Events.BagItemClicked })
end

function AuctionatorSaleItemMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.Selling.Events.BagItemClicked then
    self.TitleArea.Text:SetText(itemInfo.name .. " - " .. Auctionator.Constants.ITEM_TYPES[itemInfo.itemType])
    self.TitleArea.Text:SetTextColor(
      ITEM_QUALITY_COLORS[itemInfo.quality].r,
      ITEM_QUALITY_COLORS[itemInfo.quality].g,
      ITEM_QUALITY_COLORS[itemInfo.quality].b
    )

    self.Icon:SetItemInfo(itemInfo)
    self.Quantity:SetNumber(itemInfo.count)
  end
end