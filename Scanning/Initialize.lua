---@class addonTableAuctionator
local addonTable = select(2, ...)

function addonTable.Scanning.Initialize()
  addonTable.Utilities.OnAuctionHouseLoaded(function()
    if addonTable.Constants.IsModernAH then
      addonTable.Scanning.FullScan = addonTable.Utilities.InitFrameWithMixin(nil, addonTable.Scanning.Modern.BrowseMixin)
    else
      addonTable.Scanning.FullScan = addonTable.Utilities.InitFrameWithMixin(nil, addonTable.Scanning.Legacy.QueryAllMixin)
    end

    addonTable.CallbackRegistry:RegisterCallback("RequestScan", function()
      addonTable.Scanning.FullScan:InitiateScan()
    end)
  end)
end
