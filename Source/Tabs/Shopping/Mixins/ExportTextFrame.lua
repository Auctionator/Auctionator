AuctionatorExportTextFrameMixin = {}

function AuctionatorExportTextFrameMixin:OnLoad()
  self.ScrollFrame:SetHeight(self.Inset:GetHeight())
  self.ScrollFrame.ExportString:SetWidth(300)
end

function AuctionatorExportTextFrameMixin:SetOpeningEvents(open, close)
  self.openEvent = open
  self.closeEvent = close
end

function AuctionatorExportTextFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorExportTextFrameMixin:OnShow()")

  self.ScrollFrame.ExportString:SetFocus()
  self.ScrollFrame.ExportString:HighlightText()

  if self.openEvent then
    Auctionator.EventBus
      :RegisterSource(self, "lists export text dialog 2")
      :Fire(self, self.openEvent)
      :UnregisterSource(self)
  end
end

function AuctionatorExportTextFrameMixin:OnHide()
  self:Hide()

  if self.closeEvent then
    Auctionator.EventBus
      :RegisterSource(self, "lists export text dialog 2")
      :Fire(self, self.closeEvent)
      :UnregisterSource(self)
  end
end

function AuctionatorExportTextFrameMixin:SetExportString(exportString)
  self.ScrollFrame.ExportString:SetText(exportString)
  self.ScrollFrame.ExportString:HighlightText()
end

function AuctionatorExportTextFrameMixin:OnCloseClicked()
  self.ScrollFrame.ExportString:SetText("")
  self:Hide()
end
