AuctionatorShoppingListDropdownMixin = {}

function AuctionatorShoppingListDropdownMixin:OnLoad()
  UIDropDownMenu_Initialize(self, self.Initialize, "taint prevention")
  UIDropDownMenu_SetWidth(self, 190)

  self:SetUpEvents()
end

function AuctionatorShoppingListDropdownMixin:OnShow()
  local listIndex = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_LIST)

  if Auctionator.ShoppingLists.Lists[listIndex] ~= nil then
    self:SelectList(Auctionator.ShoppingLists.Lists[listIndex])
  end
end

function AuctionatorShoppingListDropdownMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Dropdown")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListCreated,
    Auctionator.ShoppingLists.Events.ListDeleted,
    Auctionator.ShoppingLists.Events.ListRenamed
  })
end

function AuctionatorShoppingListDropdownMixin:Initialize()
  local listEntry

  for index, list in ipairs(Auctionator.ShoppingLists.Lists) do
    listEntry = UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.text = list.name
    listEntry.value = index
    listEntry.func = function(entry)
      self:SelectList(Auctionator.ShoppingLists.Lists[tonumber(entry.value)])
    end

    UIDropDownMenu_AddButton(listEntry)
  end
end

function AuctionatorShoppingListDropdownMixin:SelectList(selectedList)
  UIDropDownMenu_SetText(self, selectedList.name)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSelected, selectedList)
end

function AuctionatorShoppingListDropdownMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListDeleted or eventName == Auctionator.ShoppingLists.Events.ListCreated then
    UIDropDownMenu_Initialize(self, self.Initialize)
  end

  if eventName == Auctionator.ShoppingLists.Events.ListCreated then
    self:SelectList(eventData)
  end

  if eventName == Auctionator.ShoppingLists.Events.ListRenamed then
    self:SelectList(eventData)
  end

  if eventName == Auctionator.ShoppingLists.Events.ListDeleted then
    if #Auctionator.ShoppingLists.Lists == 0 then
      UIDropDownMenu_SetText(self, "")
    else
      self:SelectList(Auctionator.ShoppingLists.Lists[1])
    end
  end
end
