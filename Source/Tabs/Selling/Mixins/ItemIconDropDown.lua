AuctionatorItemIconDropDownMixin = {}

local function IgnoreItemKey(itemKey)
  table.insert(
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS),
    Auctionator.Utilities.ItemKeyString(itemKey)
  )

  Auctionator.EventBus
    :RegisterSource(IgnoreItemKey, "IgnoreItemKey")
    :Fire(IgnoreItemKey, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(IgnoreItemKey)
end

local function FavouriteIndex(data)
  return tIndexOf(
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS),
    Auctionator.Selling.UniqueBagKey(data)
  )
end

function Auctionator.Selling.IsFavourite(data)
  return FavouriteIndex(data) ~= nil
end

local function ToggleFavouriteItem(data)
  if Auctionator.Selling.IsFavourite(data) then
    table.remove(
      Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS),
      FavouriteIndex(data)
    )
  else
    table.insert(
      Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS),
      Auctionator.Selling.UniqueBagKey(data)
    )
  end

  Auctionator.EventBus
    :RegisterSource(ToggleFavouriteItem, "ToggleFavouriteItem")
    :Fire(ToggleFavouriteItem, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(ToggleFavouriteItem)
end

local function RestoreAllItemKeys()
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, {})

  Auctionator.EventBus
    :RegisterSource(RestoreAllItemKeys, "RestoreAllItemKeys")
    :Fire(RestoreAllItemKeys, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(RestoreAllItemKeys)
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
  hideInfo.text = AUCTIONATOR_L_HIDE

  hideInfo.disabled = false
  hideInfo.func = function()
    IgnoreItemKey(itemKey)
  end

  local restoreAllInfo = UIDropDownMenu_CreateInfo()
  restoreAllInfo.notCheckable = 1
  restoreAllInfo.text = AUCTIONATOR_L_RESTORE_ALL

  restoreAllInfo.disabled = NoItemKeysHidden()
  restoreAllInfo.func = function()
    RestoreAllItemKeys()
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
  UIDropDownMenu_AddButton(restoreAllInfo)
  UIDropDownMenu_AddButton(favouriteItemInfo)
end

function AuctionatorItemIconDropDownMixin:Callback(itemInfo)
  -- If the dropdown is already open close it so that Toggle reopens it at the
  -- new cursor position
  if self.data and self.data.itemKey ~= itemInfo.itemKey then
    HideDropDownMenu(1)
  end

  self.data = itemInfo
  self:Toggle()
end

function AuctionatorItemIconDropDownMixin:Toggle()
  ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
