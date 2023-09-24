Auctionator.BagGroups.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
Auctionator.BagGroups.CallbackRegistry:OnLoad()
Auctionator.BagGroups.CallbackRegistry:GenerateCallbackEvents(Auctionator.BagGroups.Constants.Events)

function Auctionator.BagGroups.Initialize()
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
end
local function AutoCreateCache()
  if not AuctionatorBagCacheFrame then
    CreateFrame("Frame", "AuctionatorBagCacheFrame", UIParent, "AuctionatorBagCacheTemplate")
  end
end

function Auctionator.BagGroups.OnAHOpen()
  AutoCreateCache()
end

function Auctionator.BagGroups.OpenCustomiseView()
  AutoCreateCache()
  if not AuctionatorBagCustomiseFrame then
    CreateFrame("Frame", "AuctionatorBagCustomiseFrame", UIParent, "AuctionatorBagCustomiseTemplate")
  end
  AuctionatorBagCustomiseFrame:SetShown(not AuctionatorBagCustomiseFrame:IsShown())
end
