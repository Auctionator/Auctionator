---@class addonTableaddonTable.
local addonTable = select(2, ...)

addonTable.Storage.ShoppingListMixin = {}

function addonTable.Storage.ShoppingListMixin:Init(data, manager)
  assert(data)
  self.data = data
  self.manager = manager
end

function addonTable.Storage.ShoppingListMixin:GetName()
  return self.data.name
end

function addonTable.Storage.ShoppingListMixin:Rename(newName)
  assert(type(newName) == "string")
  assert(self.manager:GetIndexForName(newName) == nil, "New name already in use")

  self.data.name = newName

  self.manager:FireMetaChangeEvent(self:GetName())
end

function addonTable.Storage.ShoppingListMixin:IsTemporary()
  return self.data.isTemporary
end

function addonTable.Storage.ShoppingListMixin:MakePermanent()
  self.data.isTemporary = false

  self.manager:FireMetaChangeEvent(self:GetName())
end

function addonTable.Storage.ShoppingListMixin:GetItemCount()
  return #self.data.items
end

function addonTable.Storage.ShoppingListMixin:GetItemByIndex(index)
  return self.data.items[index]
end

function addonTable.Storage.ShoppingListMixin:GetIndexForItem(item)
  return tIndexOf(self.data.items, item)
end

function addonTable.Storage.ShoppingListMixin:GetAllItems()
  return CopyTable(self.data.items)
end

function addonTable.Storage.ShoppingListMixin:DeleteItem(index)
  assert(self.data.items[index], "Nonexistent item")
  table.remove(self.data.items, index)

  self.manager:FireItemChangeEvent(self:GetName())
end

function addonTable.Storage.ShoppingListMixin:AlterItem(index, newItem)
  assert(self.data.items[index], "Nonexistent item")
  assert(type(newItem) == "string")

  self.data.items[index] = newItem

  self.manager:FireItemChangeEvent(self:GetName())
end

function addonTable.Storage.ShoppingListMixin:InsertItem(newItem, index)
  assert(type(newItem) == "string")
  if index ~= nil then
    table.insert(self.data.items, index, newItem)
  else
    table.insert(self.data.items, newItem)
  end

  self.manager:FireItemChangeEvent(self:GetName())
end

function addonTable.Storage.ShoppingListMixin:ClearItems()
  self.data.items = {}
end

function addonTable.Storage.ShoppingListMixin:AppendItems(newItems)
  for _, i in ipairs(newItems) do
    assert(type(i) == "string")
    table.insert(self.data.items, i)
  end

  self.manager:FireItemChangeEvent(self:GetName())
end

function addonTable.Storage.ShoppingListMixin:Sort()
  table.sort(self.data.items, function(a, b)
    return a:lower():gsub("\"", "") < b:lower():gsub("\"", "")
  end)
  self.manager:FireItemChangeEvent(self:GetName())
end
