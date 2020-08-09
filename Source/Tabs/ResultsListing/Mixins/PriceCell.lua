AuctionatorPriceCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, TableBuilderCellMixin)

function AuctionatorPriceCellTemplateMixin:Init(columnName)
  self.columnName = columnName

  self.MoneyDisplay:ClearAllPoints();
  self.MoneyDisplay:SetPoint("LEFT");
end

function AuctionatorPriceCellTemplateMixin:Populate(rowData, index)
  AuctionatorCellMixin.Populate(self, rowData, index)

  if rowData[self.columnName] ~= nil then
    self.MoneyDisplay:SetAmount(rowData[self.columnName])
    self.MoneyDisplay:Show()
  else
    self.MoneyDisplay:Hide()
  end
end
