AuctionatorExportTextFrameMixin = {}

function AuctionatorExportTextFrameMixin:OnLoad()
  self.ScrollFrame:SetHeight(self.Inset:GetHeight())
  self.ScrollFrame.ExportString:SetWidth(300)
end

function AuctionatorExportTextFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorExportTextFrameMixin:OnShow()")

  self.ScrollFrame.ExportString:SetFocus()
  self.ScrollFrame.ExportString:HighlightText()

  Auctionator.EventBus
    :RegisterSource(self, "lists export text dialog 2")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorExportTextFrameMixin:OnHide()
  Auctionator.EventBus
    :RegisterSource(self, "lists export text dialog 2")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorExportTextFrameMixin:SetExportString(exportString)
  self.ScrollFrame.ExportString:SetText(exportString)
  self.ScrollFrame.ExportString:HighlightText()
end

function AuctionatorExportTextFrameMixin:OnCloseClicked()
  self.ScrollFrame.ExportString:SetText("")
  self:Hide()
end
