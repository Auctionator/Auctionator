AuctionatorDeleteButtonCellTemplateMixin = {}

function AuctionatorDeleteButtonCellTemplateMixin:DeleteItem()
  Auctionator.Debug.Message(self.rowData.itemName .. " delete clicked.")

end