AuctionatorShoppingListDropdownMixin = {}

function AuctionatorShoppingListDropdownMixin:OnLoad()
  UIDropDownMenu_Initialize(self, self.Initialize, "taint prevention")
  UIDropDownMenu_SetWidth(self, 190)

  self.searchNextTime = true
  self:SetUpEvents()
  self:SetNoList()
end

function AuctionatorShoppingListDropdownMixin:SetNoList()
  UIDropDownMenu_SetText(self, AUCTIONATOR_L_SELECT_SHOPPING_LIST)
  self.currentList = nil
end

function AuctionatorShoppingListDropdownMixin:OnShow()
  if not self.searchNextTime then
    return
  end
  self.searchNextTime = false

  local listName = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_LIST)

  if listName == Auctionator.Constants.NO_LIST then
    return
  end

  local listIndex = Auctionator.ShoppingLists.ListIndex(listName)

  if listIndex ~= nil then
    self:SelectList(Auctionator.ShoppingLists.Lists[listIndex])
  end
end

function AuctionatorShoppingListDropdownMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_CLOSED" then
    self.searchNextTime = true
  end
end

function AuctionatorShoppingListDropdownMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Dropdown")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListCreated,
    Auctionator.ShoppingLists.Events.ListDeleted,
    Auctionator.ShoppingLists.Events.ListRenamed,
    Auctionator.ShoppingLists.Events.ListSelected,
  })
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_CLOSED"
  })
end

function AuctionatorShoppingListDropdownMixin:Initialize(level, rootEntry)
  if level == 1 then
    local listEntry

    listEntry = UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.text = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_NEW_SHOPPING_LIST)
    listEntry.func = function(entry)
      StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
    end
    listEntry.noPopup = true
    UIDropDownMenu_AddButton(listEntry)

    if self.currentList ~= nil then
      local isTemp = self.currentList.isTemporary
      if isTemp then
        listEntry = UIDropDownMenu_CreateInfo()
        listEntry.notCheckable = true
        listEntry.text = BLUE_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_SAVE_THIS_LIST_AS)
        listEntry.func = function(entry)
          StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList, nil, nil, self.currentList.name)
        end
        listEntry.noPopup = true
        UIDropDownMenu_AddButton(listEntry)
      end
    end

    for index, list in ipairs(Auctionator.ShoppingLists.Lists) do
      listEntry = UIDropDownMenu_CreateInfo()
      listEntry.text = list.name
      listEntry.value = index
      listEntry.menuList = {index = index}
      listEntry.func = function(entry)
        self:SelectList(list)
      end
      listEntry.checked = self.currentList == list
      listEntry.hasArrow = true

      UIDropDownMenu_AddButton(listEntry)
    end
  elseif level == 2 and not rootEntry.noPopup then
    listEntry = UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.value = index

    local listName = Auctionator.ShoppingLists.Lists[tonumber(rootEntry.index)].name
    listEntry.text = AUCTIONATOR_L_DELETE
    listEntry.func = function(entry)
      local message = AUCTIONATOR_L_DELETE_LIST_CONFIRM:format(listName)
      StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList].text = message
      StaticPopup_Show(Auctionator.Constants.DialogNames.DeleteShoppingList, nil, nil, listName)
      HideDropDownMenu(1)
    end
    UIDropDownMenu_AddButton(listEntry, 2)

    listEntry.text = AUCTIONATOR_L_RENAME
    listEntry.func = function(entry)
      StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList, nil, nil, listName)
      HideDropDownMenu(1)
    end
    UIDropDownMenu_AddButton(listEntry, 2)
  end
end

function AuctionatorShoppingListDropdownMixin:SelectList(selectedList)
  UIDropDownMenu_SetText(self, selectedList.name)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSelected, selectedList)
end

function AuctionatorShoppingListDropdownMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListDeleted or eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:SetNoList()
  end

  if eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:SelectList(eventData)
  end

  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
  end

  if eventName == Auctionator.ShoppingLists.Events.ListRenamed then
    if self.currentList == eventData then
      self:SelectList(eventData)
    end
  end
end
