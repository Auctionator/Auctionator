local LISTS_VIEW = 1
local RECENTS_VIEW = 2

local DEFAULT_VIEW = RECENTS_VIEW

AuctionatorShoppingTabRecentsContainerMixin = {}
function AuctionatorShoppingTabRecentsContainerMixin:OnLoad()
  self.Tabs = {self.ListTab, self.RecentsTab}
  self.numTabs = #self.Tabs

  Auctionator.EventBus:RegisterSource(self, "List Search Button")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
  })
end

function AuctionatorShoppingTabRecentsContainerMixin:ReceiveEvent(eventName)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self:SetView(LISTS_VIEW)
  end
end

function AuctionatorShoppingTabRecentsContainerMixin:SetView(viewIndex)
  PanelTemplates_SetTab(self, viewIndex)

  self:GetParent().ManualSearch:Hide()
  self:GetParent().AddItem:Hide()
  self:GetParent().SortItems:Hide()
  self:GetParent().ScrollListRecents:Hide()
  self:GetParent().ScrollListShoppingList:Hide()

  if viewIndex == RECENTS_VIEW then
    self:GetParent().ScrollListRecents:Show()

  elseif viewIndex == LISTS_VIEW then
    self:GetParent().ScrollListShoppingList:Show()
    self:GetParent().ManualSearch:Show()
    self:GetParent().AddItem:Show()
    self:GetParent().SortItems:Show()
  end
end
