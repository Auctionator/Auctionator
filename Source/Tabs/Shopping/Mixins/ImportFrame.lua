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
    :Fire(self, Auctionator.Shopping.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorListImportFrameMixin:OnHide()
  self.ScrollFrame.ImportString:SetText("")
  self:Hide()
  Auctionator.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, Auctionator.Shopping.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorListImportFrameMixin:OnCloseDialogClicked()
  self:Hide()
end

function AuctionatorListImportFrameMixin:OnImportClicked()
  local importString = self.ScrollFrame.ImportString:GetText()

  if string.match(importString, "[\\^]") then
    Auctionator.Debug.Message("Import shopping list with 8.3+ format")
    Auctionator.Shopping.Lists.BatchImportFromString(importString)
  elseif string.match(importString, "[*]") then
    Auctionator.Debug.Message("Import shopping list from old format")
    Auctionator.Shopping.Lists.OldBatchImportFromString(importString)
  elseif string.match(importString, "[,]") then
    Auctionator.Debug.Message("Import shopping list from TSM group")
    Auctionator.Shopping.Lists.TSMImportFromString(importString)
  end

  self:Hide()
end
