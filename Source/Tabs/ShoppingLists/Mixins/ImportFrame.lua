AuctionatorListImportFrameMixin = {}

function AuctionatorListImportFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListImportFrameMixin:OnLoad()")

  self.ScrollFrame:SetHeight(self.Inset:GetHeight())
  self.ScrollFrame.ImportString:SetWidth(300)
end

function AuctionatorListImportFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorListImportFrameMixin:OnShow()")

  self.ScrollFrame.ImportString:SetFocus()

  Auctionator.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorListImportFrameMixin:OnHide()
  self:Hide()
  Auctionator.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorListImportFrameMixin:OnCloseDialogClicked()
  self.ScrollFrame.ImportString:SetText("")

  self:Hide()
end

function AuctionatorListImportFrameMixin:OnImportClicked()
  local importString = self.ScrollFrame.ImportString:GetText()

  if string.match(importString, "[\\^]") then
    Auctionator.Debug.Message("Import shopping list with 8.3+ format")
    Auctionator.ShoppingLists.BatchImportFromString(importString)
  elseif string.match(importString, "[*]") then
    Auctionator.Debug.Message("Import shopping list from old format")
    Auctionator.ShoppingLists.OldBatchImportFromString(importString)
  elseif string.match(importString, "[,]") then
    Auctionator.Debug.Message("Import shopping list from TSM group")
    Auctionator.ShoppingLists.TSMImportFromString(importString)
  end

  self:Hide()
end
