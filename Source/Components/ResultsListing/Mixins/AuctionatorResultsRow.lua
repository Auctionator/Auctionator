AuctionatorResultsRowTemplateMixin = {}

function AuctionatorResultsRowTemplateMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorResultsRowTemplateMixin:OnClick()", ...)
end

function AuctionatorResultsRowTemplateMixin:OnEnter(...)
  self.HighlightTexture:Show()
end

function AuctionatorResultsRowTemplateMixin:OnLeave(...)
  self.HighlightTexture:Hide()
end

function AuctionatorResultsRowTemplateMixin:Populate(rowData, dataIndex)
  self.rowData = rowData
  self.dataIndex = dataIndex
end