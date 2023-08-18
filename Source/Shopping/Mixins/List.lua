AuctionatorShoppingListMixin = {}

function AuctionatorShoppingListMixin:Init(data, manager)
  assert(data)
  self.data = data
  self.manager = manager
end

function AuctionatorShoppingListMixin:GetName()
  return self.data.name
end

function AuctionatorShoppingListMixin:Rename(newName)
  assert(type(newName) == "string")
  assert(self.manager:GetIndexForName(newName) == nil, "New name already in use")

  self.data.name = newName

  self.manager:FireMetaChangeEvent(self:GetName())
end

function AuctionatorShoppingListMixin:IsTemporary()
  return self.data.isTemporary
end

function AuctionatorShoppingListMixin:MakePermanent()
  self.data.isTemporary = false

  self.manager:FireMetaChangeEvent(self:GetName())
end

function AuctionatorShoppingListMixin:GetItemCount()
  return #self.data.items
end

function AuctionatorShoppingListMixin:GetItemByIndex(index)
  return self.data.items[index]
end

function AuctionatorShoppingListMixin:GetIndexForItem(item)
  return tIndexOf(self.data.items, item)
end

function AuctionatorShoppingListMixin:GetAllItems()
  return CopyTable(self.data.items)
end

function AuctionatorShoppingListMixin:DeleteItem(index)
  assert(self.data.items[index], "Nonexistent item")
  table.remove(self.data.items, index)

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionatorShoppingListMixin:AlterItem(index, newItem)
  assert(self.data.items[index], "Nonexistent item")
  assert(type(newItem) == "string")

  self.data.items[index] = newItem

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionatorShoppingListMixin:InsertItem(newItem, index)
  assert(type(newItem) == "string")
  if index ~= nil then
    table.insert(self.data.items, index, newItem)
  else
    table.insert(self.data.items, newItem)
  end

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionatorShoppingListMixin:AppendItems(newItems)
  for _, i in ipairs(newItems) do
    assert(type(i) == "string")
    table.insert(self.data.items, i)
  end

  self.manager:FireItemChangeEvent(self:GetName())
end

function AuctionatorShoppingListMixin:Sort()
  table.sort(self.data.items, function(a, b)
    return a:lower():gsub("\"", "") < b:lower():gsub("\"", "")
  end)
  self.manager:FireItemChangeEvent(self:GetName())
end
