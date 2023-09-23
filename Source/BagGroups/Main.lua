SB2.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
SB2.CallbackRegistry:OnLoad()
SB2.CallbackRegistry:GenerateCallbackEvents(SB2.Constants.Events)

EventUtil.ContinueOnAddOnLoaded("SellingBag2", function()
  if SB2_BAG_SETUP == nil then
    SB2_BAG_SETUP = {
      Version = 1,
      CustomSections = {},
    }

    SB2.AddSection("FAVOURITES")
    local list = SB2.GetSectionList("FAVOURITES")

    for _, data in pairs(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)) do
      table.insert(list, data.itemLink)
    end
  end

  CreateFrame("Frame", "SB2BagCacheFrame", UIParent, "SB2BagCacheTemplate")
  --CreateFrame("Frame", "SB2BagUseFrame", UIParent, "SB2BagUseTemplate")
  CreateFrame("Frame", "SB2BagCustomiseFrame", UIParent, "SB2BagCustomiseTemplate")
  --SB2BagUseFrame:Show()

  --SB2BagUseFrame.View:Update(SB2BagCacheFrame)
end)
