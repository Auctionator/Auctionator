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
    Auctionator.ShoppingLists.Events.ListRenamed
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
    listEntry.text = GREEN_FONT_COLOR:WrapTextInColorCode("New Shopping List")
    listEntry.func = function(entry)
      StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
    end
    listEntry.noPopup = true
    UIDropDownMenu_AddButton(listEntry)

    for index, list in ipairs(Auctionator.ShoppingLists.Lists) do
      listEntry = UIDropDownMenu_CreateInfo()
      listEntry.notCheckable = true
      listEntry.text = list.name
      listEntry.value = index
      listEntry.menuList = {index = index}
      listEntry.func = function(entry)
        self:SelectList(Auctionator.ShoppingLists.Lists[tonumber(entry.value)])
      end
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
      StaticPopup_Show(Auctionator.Constants.DialogNames.DeleteShoppingList)
    end
    UIDropDownMenu_AddButton(listEntry, 2)

    listEntry.text = AUCTIONATOR_L_RENAME
    listEntry.func = function(entry)
      StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList)
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
    UIDropDownMenu_Initialize(self, self.Initialize)
    self:SetNoList()
  end

  if eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:SelectList(eventData)
  end

  if eventName == Auctionator.ShoppingLists.Events.ListRenamed then
    self:SelectList(eventData)
  end

  if eventName == Auctionator.ShoppingLists.Events.ListDeleted then
    UIDropDownMenu_SetText(self, "")
  end
end
