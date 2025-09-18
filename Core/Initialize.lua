---@class addonTableAuctionator
local addonTable = select(2, ...)

addonTable.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
addonTable.CallbackRegistry:OnLoad()
addonTable.CallbackRegistry:GenerateCallbackEvents(addonTable.Constants.Events)

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()
  addonTable.CustomiseDialog.Initialize()
  addonTable.SlashCmd.Initialize()

  addonTable.Storage.Initialize()
  --addonTable.Scanning.Initialize()

  --addonTable.Groups.Initialize()

  addonTable.Skins.Initialize()
end

addonTable.Utilities.OnAddonLoaded("Auctionator", function()
  addonTable.Core.Initialize()
end)
