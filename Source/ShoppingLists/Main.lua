function Auctionator.ShoppingLists.Initialize()
  Auctionator.Debug.Message("Auctionator.ShoppingLists.Initialize")

  UIDropDownMenu_SetWidth(AuctionatorAHFrame_ListDropDown, 220)
  AuctionatorAHFrame_DeleteList:Disable()
  AuctionatorAHFrame_AddItem:Disable()
end

function Auctionator.ShoppingLists.GetCurrentList()
  local currentListName = UIDropDownMenu_GetText(AuctionatorAHFrame_ListDropDown)

  if currentListName == nil then
    -- TODO Should probably use NullObject
    return nil
  else
    for _, list in pairs(Auctionator.ShoppingLists.Lists) do
      if list.name == currentListName then
        return list
      end
    end

    -- Shouldn't be able to get here, but just in case
    return nil
  end
end

function Auctionator.ShoppingLists.InitializeListDropdown(self)
  -- This could get called before everything is loaded, so check for lists
  if Auctionator.ShoppingLists.Lists == nil then
    return
  end

  local listEntry
  for index, list in ipairs(Auctionator.ShoppingLists.Lists) do
    listEntry = UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.text = list.name
    listEntry.value = index
    listEntry.func = Auctionator.ShoppingLists.ListSelected

    UIDropDownMenu_AddButton(listEntry)
  end
end

local function CloseShoppingListDropdown()
  -- We need to close AuctionatorAHFrame_ListDropDown to ensure we can refresh it after
  -- adding a list entry
  if UIDROPDOWNMENU_OPEN_MENU == AuctionatorAHFrame_ListDropDown then
    ToggleDropDownMenu(1, nil, AuctionatorAHFrame_ListDropDown, nil)
  end
end

local function OpenShoppingListDropdown()
  -- We need to refresh AuctionatorAHFrame_ListDropDown if not open
  if UIDROPDOWNMENU_OPEN_MENU ~= AuctionatorAHFrame_ListDropDown then
    ToggleDropDownMenu(1, nil, AuctionatorAHFrame_ListDropDown, nil)
  end
end

function Auctionator.ShoppingLists.CreateButtonClicked(...)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.CreateButtonClicked")
  StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
end

function Auctionator.ShoppingLists.DeleteButtonClicked(...)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.DeleteButtonClicked")

  -- Probably not needed since I disable, but just to be safe...
  local message = "You must select a list to delete."
  local currentList = Auctionator.ShoppingLists.GetCurrentList()

  if currentList ~= nil then
    message = "Are you SURE you want to delete " .. currentList.name .. "?"
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList].text = message
  StaticPopup_Show(Auctionator.Constants.DialogNames.DeleteShoppingList)
end

function Auctionator.ShoppingLists.Create(listName)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.Create")

  CloseShoppingListDropdown()

  table.insert(Auctionator.ShoppingLists.Lists, {
    name = listName,
    index = #Auctionator.ShoppingLists.Lists + 1,
    items = {}
  })

  -- Set selected entry to new list
  UIDropDownMenu_SetText(AuctionatorAHFrame_ListDropDown, listName)

  Auctionator.ShoppingLists.LoadList(listName)
end

function Auctionator.ShoppingLists.Delete()
  local currentList = Auctionator.ShoppingLists.GetCurrentList()

  if currentList == nil then
    Auctionator.Utilities.Message("An error occurred attempting to delete a list.")
    return
  end

  CloseShoppingListDropdown()

  local listIndex = 0
  for index, list in ipairs(Auctionator.ShoppingLists.Lists) do
    if list.name == currentList.name then
      listIndex = index
      break
    end
  end

  table.remove(Auctionator.ShoppingLists.Lists, listIndex)

  if #Auctionator.ShoppingLists.Lists > 0 then
    UIDropDownMenu_SetText(AuctionatorAHFrame_ListDropDown, Auctionator.ShoppingLists.Lists[1].name)
    Auctionator.ShoppingLists.LoadList(Auctionator.ShoppingLists.Lists[1].name)
  else
    -- No lists, so disable everything
    AuctionatorAHFrame_DeleteList:Disable()
    AuctionatorAHFrame_AddItem:Disable()
  end
end

function Auctionator.ShoppingLists.ListSelected(info)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.ListSelected", info:GetText(), info.value)

  UIDropDownMenu_SetText(AuctionatorAHFrame_ListDropDown, info:GetText())
  Auctionator.ShoppingLists.LoadList(info:GetText())
end

function Auctionator.ShoppingLists.AddItemButtonClicked()
  Auctionator.Debug.Message("Auctionator.ShoppingLists.AddItemButtonClicked")
  StaticPopup_Show(Auctionator.Constants.DialogNames.AddItemToShoppingList)
end

function Auctionator.ShoppingLists.AddItem(itemName)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.AddItem", itemName)

  local currentList = Auctionator.ShoppingLists.GetCurrentList()
  if currentList == nil then
    Auctionator.Utilities.Message("An error occurred attempting to add an item to the current list.")
    return
  end

  table.insert(currentList.items, itemName)
  AuctionatorAHFrame_ShoppingListItems:Reset()
  AuctionatorAHFrame_ShoppingListItems:RefreshScrollFrame()
end

function Auctionator.ShoppingLists.RemoveItem(itemName)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.RemoveItem", itemName)

  local currentList = Auctionator.ShoppingLists.GetCurrentList()
  if currentList == nil then
    Auctionator.Utilities.Message("An error occurred attempting to remove an item from the current list.")
    return
  end

  local itemIndex = 0
  for index, name in ipairs(currentList.items) do
    if itemName == name then
      itemIndex = index
      break
    end
  end

  table.remove(currentList.items, itemIndex)

  AuctionatorAHFrame_ShoppingListItems:Reset()
  AuctionatorAHFrame_ShoppingListItems:RefreshScrollFrame()
end

function Auctionator.ShoppingLists.LoadList(listName)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.LoadList", listName)

  -- If we're loading a list, one is selected, so we can enable Delete
  -- and list editing
  AuctionatorAHFrame_DeleteList:Enable()
  AuctionatorAHFrame_AddItem:Enable()

  -- Find the list to load
  local currentList = nil
  for _, list in pairs(Auctionator.ShoppingLists.Lists) do
    if list.name == listName then
      currentList = list
    end
  end

  if currentList == nil then
    Auctionator.Utilities.Message("An error occurred attempting to load list " .. listName)
    return
  end

  AuctionatorAHFrame_ShoppingListItems:Reset()
  AuctionatorAHFrame_ShoppingListItems:RefreshScrollFrame()
end