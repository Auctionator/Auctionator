AuctionatorBagListResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorBagListResultsRowMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorBagListResultsRowMixin:OnClick()")
  Auctionator.Utilities.TablePrint(self.rowData)

end
