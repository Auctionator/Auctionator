AuctionatorItemIconDropDownMixin = {}

local function HideItemKey(itemKey)
  table.insert(
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS),
    Auctionator.Utilities.ItemKeyString(itemKey)
  )

  Auctionator.EventBus
    :RegisterSource(HideItemKey, "HideItemKey")
    :Fire(HideItemKey, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(HideItemKey)
end

local function UnhideItemKey(itemKey)
  local ignored = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS)
  local index = tIndexOf(ignored, Auctionator.Utilities.ItemKeyString(itemKey))

  if index ~= nil then
    table.remove(ignored, index)
  end

  Auctionator.EventBus
    :RegisterSource(UnhideItemKey, "UnhideItemKey")
    :Fire(UnhideItemKey, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(UnhideItemKey)
end

local function IsHidden(itemKey)
  return tIndexOf(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS), Auctionator.Utilities.ItemKeyString(itemKey)) ~= nil
end
local function ToggleHidden(itemKey)
  if IsHidden(itemKey) then
    UnhideItemKey(itemKey)
  else
    HideItemKey(itemKey)
  end
end

function Auctionator.Selling.GetAllFavourites()
  local favourites = {}
  for _, fav in pairs(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)) do
    table.insert(favourites, fav)
  end

  return favourites
end

function Auctionator.Selling.IsFavourite(data)
  return Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)[Auctionator.Selling.UniqueBagKey(data)] ~= nil
end

local function ToggleFavouriteItem(data)
  if Auctionator.Selling.IsFavourite(data) then
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)[Auctionator.Selling.UniqueBagKey(data)] = nil
  else
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)[Auctionator.Selling.UniqueBagKey(data)] = {
      itemKey = data.itemKey,
      itemLink = data.itemLink,
      count = 0,
      iconTexture = data.iconTexture,
      itemType = data.itemType,
      location = nil,
      quality = data.quality,
      classId = data.classId,
      auctionable = data.auctionable,
    }
  end

  Auctionator.EventBus
    :RegisterSource(ToggleFavouriteItem, "ToggleFavouriteItem")
    :Fire(ToggleFavouriteItem, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(ToggleFavouriteItem)
end

local function UnhideAllItemKeys()
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, {})

  Auctionator.EventBus
    :RegisterSource(UnhideAllItemKeys, "UnhideAllItemKeys")
    :Fire(UnhideAllItemKeys, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(UnhideAllItemKeys)
end

local function NoItemKeysHidden()
  return #Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS) == 0
end

function AuctionatorItemIconDropDownMixin:OnLoad()
  UIDropDownMenu_Initialize(self, AuctionatorItemIconDropDownMixin.Initialize, "MENU")
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.ItemIconCallback,
  })
end

function AuctionatorItemIconDropDownMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.ItemIconCallback then
    self:Callback(...)
  end
end

function AuctionatorItemIconDropDownMixin:Initialize()
  if not self.data then
    HideDropDownMenu(1)
    return
  end

  local itemKey = self.data.itemKey

  local hideInfo = UIDropDownMenu_CreateInfo()
  hideInfo.notCheckable = 1
  if IsHidden(itemKey) then
    hideInfo.text = AUCTIONATOR_L_UNHIDE
  else
    hideInfo.text = AUCTIONATOR_L_HIDE
  end

  hideInfo.disabled = false
  hideInfo.func = function()
    ToggleHidden(itemKey)
  end

  local unhideAllAllInfo = UIDropDownMenu_CreateInfo()
  unhideAllAllInfo.notCheckable = 1
  unhideAllAllInfo.text = AUCTIONATOR_L_UNHIDE_ALL

  unhideAllAllInfo.disabled = NoItemKeysHidden()
  unhideAllAllInfo.func = function()
    UnhideAllItemKeys()
  end

  local favouriteItemInfo = UIDropDownMenu_CreateInfo()
  favouriteItemInfo.notCheckable = 1
  if Auctionator.Selling.IsFavourite(self.data) then
    favouriteItemInfo.text = AUCTIONATOR_L_REMOVE_FAVOURITE
  else
    favouriteItemInfo.text = AUCTIONATOR_L_ADD_FAVOURITE
  end

  favouriteItemInfo.disabled = false
  favouriteItemInfo.func = function()
    ToggleFavouriteItem(self.data)
  end

  UIDropDownMenu_AddButton(hideInfo)
  UIDropDownMenu_AddButton(unhideAllAllInfo)
  UIDropDownMenu_AddButton(favouriteItemInfo)
end

function AuctionatorItemIconDropDownMixin:Callback(itemInfo)
  self.data = itemInfo
  self:Toggle()
end

function AuctionatorItemIconDropDownMixin:Toggle()
  ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
