AuctionatorItemIconDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local function HideItem(info)
  table.insert(
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS),
    Auctionator.Selling.UniqueBagKey(info)
  )

  Auctionator.EventBus
    :RegisterSource(HideItem, "HideItem")
    :Fire(HideItem, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(HideItem)
end

local function UnhideItem(info)
  local ignored = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS)
  local index = tIndexOf(ignored, Auctionator.Selling.UniqueBagKey(info))

  if index ~= nil then
    table.remove(ignored, index)
  end

  Auctionator.EventBus
    :RegisterSource(UnhideItem, "UnhideItem")
    :Fire(UnhideItem, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(UnhideItem)
end

local function IsHidden(info)
  return tIndexOf(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS), Auctionator.Selling.UniqueBagKey(info)) ~= nil
end
local function ToggleHidden(info)
  if IsHidden(info) then
    UnhideItem(info)
  else
    HideItem(info)
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
  LibDD:Create_UIDropDownMenu(self)

  LibDD:UIDropDownMenu_SetInitializeFunction(self, AuctionatorItemIconDropDownMixin.Initialize)
  LibDD:UIDropDownMenu_SetDisplayMode(self, "MENU")
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
    LibDD:HideDropDownMenu(1)
    return
  end

  local hideInfo = LibDD:UIDropDownMenu_CreateInfo()
  hideInfo.notCheckable = 1
  if IsHidden(self.data) then
    hideInfo.text = AUCTIONATOR_L_UNHIDE
  else
    hideInfo.text = AUCTIONATOR_L_HIDE
  end

  hideInfo.disabled = false
  hideInfo.func = function()
    ToggleHidden(self.data)
  end

  LibDD:UIDropDownMenu_AddButton(hideInfo)

  local unhideAllAllInfo = LibDD:UIDropDownMenu_CreateInfo()
  unhideAllAllInfo.notCheckable = 1
  unhideAllAllInfo.text = AUCTIONATOR_L_UNHIDE_ALL

  unhideAllAllInfo.disabled = NoItemKeysHidden()
  unhideAllAllInfo.func = function()
    UnhideAllItemKeys()
  end

  LibDD:UIDropDownMenu_AddButton(unhideAllAllInfo)

  local favouriteItemInfo = LibDD:UIDropDownMenu_CreateInfo()
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

  LibDD:UIDropDownMenu_AddButton(favouriteItemInfo)
end

function AuctionatorItemIconDropDownMixin:Callback(itemInfo)
  self.data = itemInfo
  self:Toggle()
end

function AuctionatorItemIconDropDownMixin:Toggle()
  LibDD:ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
