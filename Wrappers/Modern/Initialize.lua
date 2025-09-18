---@class addonTableAuctionator
local addonTable = select(2, ...)

function addonTable.Wrappers.Modern.Initialize()
  addonTable.Wrappers.Internals = {}

  addonTable.Wrappers.Internals.throttling = addonTable.Utilities.InitFrameWithMixin(AuctionHouseFrame, addonTable.Wrappers.Modern.ThrottlingMixin)

  addonTable.Wrappers.Internals.itemKeyLoader = addonTable.Utilities.InitFrameWithMixin(AuctionHouseFrame, addonTable.Wrappers.Modern.ItemKeyLoaderMixin)

  addonTable.Wrappers.Internals.searchScan = addonTable.Utilities.InitFrameWithMixin(AuctionHouseFrame, addonTable.Wrappers.Modern.SearchScanMixin)

  addonTable.Wrappers.Queue = CreateAndInitFromMixin(addonTable.Wrappers.QueueMixin)
end
