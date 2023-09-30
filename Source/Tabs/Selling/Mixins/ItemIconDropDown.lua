AuctionatorItemIconDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

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

  --[[local hideInfo = LibDD:UIDropDownMenu_CreateInfo()
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
    StaticPopup_Show(Auctionator.Constants.DialogNames.SellingConfirmUnhideAll)
  end

  LibDD:UIDropDownMenu_AddButton(unhideAllAllInfo)
  ]]

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
