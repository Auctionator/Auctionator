AuctionatorListImportFrameMixin = {}

function AuctionatorListImportFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListImportFrameMixin:OnLoad()")

  self.onClose = function() end

  self.ScrollFrame:SetHeight(self.Inset:GetHeight())
  self.ScrollFrame.ImportString:SetWidth(300)
end

function AuctionatorListImportFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorListImportFrameMixin:OnShow()")

  self.ScrollFrame.ImportString:SetFocus()
end

function AuctionatorListImportFrameMixin:SetOnClose(callback)
  self.onClose = callback
end

function AuctionatorListImportFrameMixin:OnCloseDialogClicked()
  self.ScrollFrame.ImportString:SetText("")

  self:Hide()
  self.onClose()
end

function AuctionatorListImportFrameMixin:OnImportClicked()
  local importString = self.ScrollFrame.ImportString:GetText()

  Auctionator.ShoppingLists.BatchImportFromString(importString)

  self:Hide()
  self.onClose()
end
