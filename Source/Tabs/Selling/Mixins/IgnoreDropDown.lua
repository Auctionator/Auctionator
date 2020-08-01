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

  local info = UIDropDownMenu_CreateInfo()
  info.notCheckable = 1
  info.text = AUCTIONATOR_L_HIDE

  info.disabled = false
  info.func = function()
    IgnoreItemKey(itemKey)
  end
  UIDropDownMenu_AddButton(info)
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
