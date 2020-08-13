AuctionatorExportTextFrameMixin = {}

function AuctionatorExportTextFrameMixin:OnLoad()
  self.ScrollFrame:SetHeight(self.Inset:GetHeight())
  self.ScrollFrame.ExportString:SetWidth(300)
end

function AuctionatorExportTextFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorExportTextFrameMixin:OnShow()")

  self.ScrollFrame.ExportString:SetFocus()
  self.ScrollFrame.ExportString:HighlightText()
end

function AuctionatorExportTextFrameMixin:SetExportString(exportString)
  self.ScrollFrame.ExportString:SetText(exportString)
  self.ScrollFrame.ExportString:HighlightText()
end

function AuctionatorExportTextFrameMixin:OnCloseClicked()
  self.ScrollFrame.ExportString:SetText("")
  self:Hide()
end