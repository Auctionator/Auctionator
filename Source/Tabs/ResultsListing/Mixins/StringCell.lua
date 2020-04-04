AuctionatorStringCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, TableBuilderCellMixin)

function AuctionatorStringCellTemplateMixin:Init(columnName)
  self.columnName = columnName

  self.text:SetJustifyH("LEFT")
end

function AuctionatorStringCellTemplateMixin:Populate(rowData, index)
  AuctionatorCellMixin.Populate(self, rowData, index)

  self.text:SetText(rowData[self.columnName])
end