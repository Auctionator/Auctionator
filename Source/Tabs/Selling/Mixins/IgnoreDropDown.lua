AuctionatorIgnoreDropDownMixin = {}

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

function AuctionatorIgnoreDropDownMixin:OnLoad()
  UIDropDownMenu_Initialize(self, AuctionatorIgnoreDropDownMixin.Initialize, "MENU")
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.IgnoreCallback,
  })
end

function AuctionatorIgnoreDropDownMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.IgnoreCallback then
    self:Callback(...)
  end
end

function AuctionatorIgnoreDropDownMixin:Initialize()
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

  UIDropDownMenu_AddButton(hideInfo)
  UIDropDownMenu_AddButton(restoreAllInfo)
end

function AuctionatorIgnoreDropDownMixin:Callback(itemKey)
  -- If the dropdown is already open close it so that Toggle reopens it at the
  -- new cursor position
  if self.data and self.data.itemKey ~= itemKey then
    HideDropDownMenu(1)
  end

  self.data = { itemKey = itemKey }
  self:Toggle()
end

function AuctionatorIgnoreDropDownMixin:Toggle()
  ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
