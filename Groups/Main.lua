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

    Auctionator.Groups.AddGroup("FAVOURITES")
    local list = Auctionator.Groups.GetGroupList("FAVOURITES")

    for _, data in pairs(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)) do
      table.insert(list, data.itemLink)
    end
  end
  if AUCTIONATOR_SELLING_GROUPS.CustomSections then
    AUCTIONATOR_SELLING_GROUPS.CustomGroups = AUCTIONATOR_SELLING_GROUPS.CustomSections
    AUCTIONATOR_SELLING_GROUPS.CustomSections = nil
  end

  local group1 = AUCTIONATOR_SELLING_GROUPS.CustomGroups[1]
  if group1.name ~= "FAVOURITES_GROUP" and group1.name ~= "FAVOURITES" then
    for index, group in ipairs(AUCTIONATOR_SELLING_GROUPS.CustomGroups) do
      if group.name == "FAVOURITES_GROUP" or group.name == "FAVOURITES" then
        AUCTIONATOR_SELLING_GROUPS.CustomGroups[index] = group1
        AUCTIONATOR_SELLING_GROUPS.CustomGroups[1] = group
        group1 = group
      end
    end
  end

  if group1.name == "FAVOURITES_GROUP" then
    AUCTIONATOR_SELLING_GROUPS.CustomGroups[1].name = "FAVOURITES"
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
