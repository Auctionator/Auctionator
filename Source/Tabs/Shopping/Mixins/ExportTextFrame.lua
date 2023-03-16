AuctionatorExportTextFrameMixin = {}

function AuctionatorExportTextFrameMixin:OnLoad()
  ScrollUtil.RegisterScrollBoxWithScrollBar(self.EditBoxContainer:GetScrollBox(), self.ScrollBar)
  self.EditBoxContainer:GetScrollBox():GetView():SetPanExtent(50)
end

function AuctionatorExportTextFrameMixin:SetOpeningEvents(open, close)
  self.openEvent = open
  self.closeEvent = close
end

function AuctionatorExportTextFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorExportTextFrameMixin:OnShow()")

  self.EditBoxContainer:GetEditBox():SetFocus()
  self.EditBoxContainer:GetEditBox():HighlightText()

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
  self.EditBoxContainer:GetEditBox():SetText(exportString)
  self.EditBoxContainer:GetEditBox():HighlightText()
end

function AuctionatorExportTextFrameMixin:OnCloseClicked()
  self.EditBoxContainer:GetEditBox():SetText("")
  self:Hide()
end
