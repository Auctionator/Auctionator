---@class addonTableAuctionator
local addonTable = select(2, ...)

addonTable.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
addonTable.CallbackRegistry:OnLoad()
addonTable.CallbackRegistry:GenerateCallbackEvents(addonTable.Constants.Events)

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()
  addonTable.Data.Initialize()

  addonTable.Groups.Initialize()
end

addonTable.OnAddonLoaded("Auctionator", function()
  addonTable.Core.Initialize()
end)
