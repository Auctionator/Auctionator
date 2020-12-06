AuctionatorStringCellTemplateMixin = CreateFromMixins(AuctionatorCellMixin, TableBuilderCellMixin)

function AuctionatorStringCellTemplateMixin:Init(columnName)
  self.columnName = columnName

  self.text:SetJustifyH("LEFT")
end

function AuctionatorStringCellTemplateMixin:Populate(rowData, index)
  AuctionatorCellMixin.Populate(self, rowData, index)

  self.text:SetText(rowData[self.columnName])
  if not self:IsVisible() then
    self.text:Hide()
  else
    self.text:Show()
  end
end
