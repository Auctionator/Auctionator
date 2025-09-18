---@class addonTableAuctionator
local addonTable = select(2, ...)

function addonTable.Wrappers.Initialize()
  addonTable.Utilities.OnAuctionHouseLoaded(function()
    Auctionator.AH = {}
    if addonTable.Constants.IsModernAH then
      addonTable.Wrappers.Modern.Initialize()
      for key, val in pairs(addonTable.Wrappers.Modern) do
        if type(val) == "function" then
          Auctionator.AH[key] = val
        end
      end
    else
      addonTable.Wrappers.Legacy.Initialize()
      for key, val in pairs(addonTable.Wrappers.Legacy) do
        if type(val) == "function" then
          Auctionator.AH[key] = val
        end
      end
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("ScanProgress", function(_, ...)
    print(...)
  end)
end
