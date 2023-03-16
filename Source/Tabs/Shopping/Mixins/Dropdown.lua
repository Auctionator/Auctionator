AuctionatorShoppingListDropdownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function AuctionatorShoppingListDropdownMixin:OnLoad()
  LibDD:Create_UIDropDownMenu(self)

  LibDD:UIDropDownMenu_SetInitializeFunction(self, self.Initialize)
  LibDD:UIDropDownMenu_SetWidth(self, 190)

  self.searchNextTime = true
  self:SetUpEvents()
  self:SetNoList()
end

function AuctionatorShoppingListDropdownMixin:SetNoList()
  LibDD:UIDropDownMenu_SetText(self, AUCTIONATOR_L_SELECT_SHOPPING_LIST)
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

  local listIndex = Auctionator.Shopping.ListManager:GetIndexForName(listName)

  if listIndex ~= nil then
    self:SelectList(Auctionator.Shopping.ListManager:GetByIndex(listIndex))
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
    Auctionator.Shopping.Events.ListMetaChange,
    Auctionator.Shopping.Tab.Events.ListCreated,
    Auctionator.Shopping.Tab.Events.ListRenamed,
    Auctionator.Shopping.Tab.Events.ListSelected,
  })
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_CLOSED"
  })
end

function AuctionatorShoppingListDropdownMixin:Initialize(level, rootEntry)
  local listEntry
  if level == 1 then

    -- Add entry to create a new shopping list
    listEntry = LibDD:UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.text = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_NEW_SHOPPING_LIST)
    listEntry.func = function(entry)
      StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
    end
    LibDD:UIDropDownMenu_AddButton(listEntry)

    -- Add promiment "Save As" entry for temporary shopping lists
    if self.currentList ~= nil then
      local isTemp = self.currentList:IsTemporary()
      if isTemp then
        listEntry = LibDD:UIDropDownMenu_CreateInfo()
        listEntry.notCheckable = true
        listEntry.text = BLUE_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_SAVE_THIS_LIST_AS)
        listEntry.func = function(entry)
          local message = AUCTIONATOR_L_RENAME_LIST_CONFIRM:format(self.currentList:GetName())
          StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList].text = message
          StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList, nil, nil, self.currentList:GetName())
        end
        LibDD:UIDropDownMenu_AddButton(listEntry)
      end
    end

    -- Add an entry for each shopping list
    for index = 1, Auctionator.Shopping.ListManager:GetCount() do
      local list = Auctionator.Shopping.ListManager:GetByIndex(index)
      listEntry = LibDD:UIDropDownMenu_CreateInfo()
      listEntry.text = list:GetName()
      listEntry.value = index
      listEntry.menuList = {index = index}
      listEntry.func = function(entry)
        self:SelectList(list)
      end
      listEntry.checked = self.currentList and self.currentList:GetName() == list:GetName()
      listEntry.hasArrow = true

      LibDD:UIDropDownMenu_AddButton(listEntry)
    end
  --Add Rename and Delete submenu entries for the given shopping list
  elseif level == 2 then
    listEntry = LibDD:UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.value = index

    local list = Auctionator.Shopping.ListManager:GetByIndex(tonumber(rootEntry.index))
    listEntry.text = AUCTIONATOR_L_DELETE
    listEntry.func = function(entry)
      local message = AUCTIONATOR_L_DELETE_LIST_CONFIRM:format(list:GetName()):gsub("%%", "%%%%")
      StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList].text = message
      StaticPopup_Show(Auctionator.Constants.DialogNames.DeleteShoppingList, nil, nil, list:GetName())
      LibDD:HideDropDownMenu(1)
    end
    LibDD:UIDropDownMenu_AddButton(listEntry, 2)

    if list.isTemporary then
      listEntry.text = AUCTIONATOR_L_SAVE_AS
    else
      listEntry.text = AUCTIONATOR_L_RENAME
    end
    listEntry.func = function(entry)
      local message = AUCTIONATOR_L_RENAME_LIST_CONFIRM:format(list:GetName()):gsub("%%", "%%%%")
      StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList].text = message
      StaticPopup_Show(Auctionator.Constants.DialogNames.RenameShoppingList, nil, nil, list:GetName())
      LibDD:HideDropDownMenu(1)
    end
    LibDD:UIDropDownMenu_AddButton(listEntry, 2)
  end
end

function AuctionatorShoppingListDropdownMixin:SelectList(selectedList)
  LibDD:UIDropDownMenu_SetText(self, selectedList:GetName())
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.ListSelected, selectedList)
end

function AuctionatorShoppingListDropdownMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Events.ListMetaChange then
    if self.currentList ~= nil and self.currentList:GetName() == eventData and Auctionator.Shopping.ListManager:GetIndexForName(eventData) == nil then
      self:SetNoList()
    end
  elseif eventName == Auctionator.Shopping.Tab.Events.ListCreated then
    self:SelectList(eventData)
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSelected then
    self.currentList = eventData
  elseif eventName == Auctionator.Shopping.Tab.Events.ListRenamed then
    if self.currentList ~= nil and self.currentList:GetName() == eventData:GetName() then
      self:SelectList(eventData)
    end
  end
end
