Auctionator.Groups.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
Auctionator.Groups.CallbackRegistry:OnLoad()
Auctionator.Groups.CallbackRegistry:GenerateCallbackEvents(Auctionator.Groups.Constants.Events)

function Auctionator.Groups.Initialize()
  if AUCTIONATOR_SELLING_GROUPS == nil then
    AUCTIONATOR_SELLING_GROUPS = {
      Version = 1,
      CustomGroups = {},
      HiddenItems = {},
    }

    Auctionator.Groups.AddGroup("FAVOURITES_GROUP")
    local list = Auctionator.Groups.GetGroupList("FAVOURITES_GROUP")

    for _, data in pairs(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)) do
      table.insert(list, data.itemLink)
    end
  end
  if AUCTIONATOR_SELLING_GROUPS.CustomSections then
    AUCTIONATOR_SELLING_GROUPS.CustomGroups = AUCTIONATOR_SELLING_GROUPS.CustomSections
    AUCTIONATOR_SELLING_GROUPS.CustomSections = nil
  end
end
local function AutoCreateCache()
  if not AuctionatorBagCacheFrame then
    CreateFrame("Frame", "AuctionatorBagCacheFrame", UIParent, "AuctionatorBagCacheTemplate")
  end
end

function Auctionator.Groups.OnAHOpen()
  AutoCreateCache()
end

function Auctionator.Groups.OpenCustomiseView()
  AutoCreateCache()
  if not AuctionatorGroupsCustomiseFrame then
    CreateFrame("Frame", "AuctionatorGroupsCustomiseFrame", UIParent, "AuctionatorGroupsCustomiseTemplate")
  end
  AuctionatorGroupsCustomiseFrame:SetShown(not AuctionatorGroupsCustomiseFrame:IsShown())
end
