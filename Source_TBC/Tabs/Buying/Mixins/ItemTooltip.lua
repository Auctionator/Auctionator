AuctionatorBuyingItemTooltipMixin = {}

function AuctionatorBuyingItemTooltipMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.Show
  })
end

function AuctionatorBuyingItemTooltipMixin:OnEnter()
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:SetHyperlink(self.itemLink)
  GameTooltip:Show()
end

function AuctionatorBuyingItemTooltipMixin:OnLeave()
  GameTooltip:Hide()
end

function AuctionatorBuyingItemTooltipMixin:OnMouseUp()
  if IsModifiedClick("CHATLINK") then
    if self.itemLink ~= nil then
      ChatEdit_InsertLink(self.itemLink)
    end
  end
end

function AuctionatorBuyingItemTooltipMixin:ReceiveEvent(eventName, eventData)
  self.itemLink = eventData.itemLink
  self.Icon:SetTexture(eventData.iconTexture)
  self.Text:SetText(eventData.itemName)
end
