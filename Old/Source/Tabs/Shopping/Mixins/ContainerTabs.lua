AuctionatorShoppingTabContainerTabsMixin = {}

function AuctionatorShoppingTabContainerTabsMixin:OnLoad()
  self.Tabs = {self.ListsTab, self.RecentsTab}
  self.numTabs = #self.Tabs
end

function AuctionatorShoppingTabContainerTabsMixin:SetView(viewIndex)
  PanelTemplates_SetTab(self, viewIndex)
  Auctionator.Config.Set(Auctionator.Config.Options.SHOPPING_LAST_CONTAINER_VIEW, viewIndex)

  self:GetParent().NewListButton:Hide()
  self:GetParent().ImportButton:Hide()
  self:GetParent().ExportButton:Hide()

  if viewIndex == Auctionator.Constants.ShoppingListViews.Recents then
    self:GetParent().ListsContainer:Hide()
    self:GetParent().RecentsContainer:Show()

  elseif viewIndex == Auctionator.Constants.ShoppingListViews.Lists then
    self:GetParent().RecentsContainer:Hide()
    self:GetParent().ListsContainer:Show()
    self:GetParent().NewListButton:Show()
    self:GetParent().ImportButton:Show()
    self:GetParent().ExportButton:Show()
  end
end
