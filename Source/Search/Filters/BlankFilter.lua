Auctionator.Search.Filters.BlankFilterMixin = {}

function Auctionator.Search.Filters.BlankFilterMixin:Init(filterTracker, browseResult)
  filterTracker:ReportFilterComplete(true)
end
