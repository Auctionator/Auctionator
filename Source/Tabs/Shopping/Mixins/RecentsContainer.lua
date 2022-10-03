AuctionatorShoppingTabRecentsContainerMixin = {}
function AuctionatorShoppingTabRecentsContainerMixin:OnLoad()
  self.Tabs = {self.ListTab, self.RecentsTab}
  self.numTabs = #self.Tabs

  Auctionator.EventBus:RegisterSource(self, "List Search Button")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSelected,
  })
end

function AuctionatorShoppingTabRecentsContainerMixin:ReceiveEvent(eventName)
  if eventName == Auctionator.Shopping.Events.ListSelected then
    self:SetView(Auctionator.Constants.ShoppingListViews.Lists)
  end
end

function AuctionatorShoppingTabRecentsContainerMixin:SetView(viewIndex)
  PanelTemplates_SetTab(self, viewIndex)

  self:GetParent().ManualSearch:Hide()
  self:GetParent().AddItem:Hide()
  self:GetParent().SortItems:Hide()

  if viewIndex == Auctionator.Constants.ShoppingListViews.Recents then
    self:GetParent().ScrollListShoppingList:Hide()
    self:GetParent().ScrollListRecents:Show()

  elseif viewIndex == Auctionator.Constants.ShoppingListViews.Lists then
    self:GetParent().ScrollListRecents:Hide()
    self:GetParent().ScrollListShoppingList:Show()
    self:GetParent().ManualSearch:Show()
    self:GetParent().AddItem:Show()
    self:GetParent().SortItems:Show()
  end
end
