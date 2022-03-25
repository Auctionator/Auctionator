AuctionatorPriceCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, AuctionatorRetailImportTableBuilderCellMixin)

function AuctionatorPriceCellTemplateMixin:Init(columnName)
  self.columnName = columnName
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
