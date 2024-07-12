Auctionator.Search.Filters.ExpansionMixin = {}

function Auctionator.Search.Filters.ExpansionMixin:Init(filterTracker, browseResult, expansion)
  self.expansion = expansion
  self.completed = false

  if not C_Item.DoesItemExistByID(browseResult.itemKey.itemID) then
    filterTracker:ReportFilterComplete(false)
  else
    local item = Item:CreateFromItemID(browseResult.itemKey.itemID)
    item:ContinueOnItemLoad(function()
      filterTracker:ReportFilterComplete(self:FilterCheck(browseResult.itemKey))
    end)
  end
end

function Auctionator.Search.Filters.ExpansionMixin:FilterCheck(itemKey)
  return self:ExpansionCheck(itemKey)
end

function Auctionator.Search.Filters.ExpansionMixin:ExpansionCheck(itemKey)
  return (select(Auctionator.Constants.ITEM_INFO.XPAC, C_Item.GetItemInfo(itemKey.itemID))) == self.expansion
end
