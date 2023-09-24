Auctionator.BagGroups.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
Auctionator.BagGroups.CallbackRegistry:OnLoad()
Auctionator.BagGroups.CallbackRegistry:GenerateCallbackEvents(Auctionator.BagGroups.Constants.Events)

EventUtil.ContinueOnAddOnLoaded("Auctionator", function()
  if AUCTIONATOR_SELLING_GROUPS == nil then
    AUCTIONATOR_SELLING_GROUPS = {
      Version = 1,
      CustomSections = {},
      HiddenItems = {},
    }

    Auctionator.BagGroups.AddSection("FAVOURITES")
    local list = Auctionator.BagGroups.GetSectionList("FAVOURITES")

    for _, data in pairs(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)) do
      table.insert(list, data.itemLink)
    end
  end

  CreateFrame("Frame", "AuctionatorBagCacheFrame", UIParent, "AuctionatorBagCacheTemplate")
  --CreateFrame("Frame", "AuctionatorBagUseFrame", UIParent, "AuctionatorBagUseTemplate")
  CreateFrame("Frame", "AuctionatorBagCustomiseFrame", UIParent, "AuctionatorBagCustomiseTemplate")
  --AuctionatorBagUseFrame:Show()

  --AuctionatorBagUseFrame.View:Update(AuctionatorBagCacheFrame)
end)
