function Auctionator.ShoppingLists.Create(listName)
  table.insert(Auctionator.ShoppingLists.Lists, {
    name = listName,
    items = {},
    isTemporary = false,
  })
end
function Auctionator.ShoppingLists.CreateTemporary(listName)
  table.insert(Auctionator.ShoppingLists.Lists, {
    name = listName,
    items = {},
    isTemporary = true,
  })
end

function Auctionator.ShoppingLists.MakePermanent(listName)
  local list = Auctionator.ShoppingLists.GetListByName(listName)
  list.isTemporary = false
end

function Auctionator.ShoppingLists.ListIndex(listName)
  for index, list in ipairs(Auctionator.ShoppingLists.Lists) do
    if list.name == listName then
      return index
    end
  end

  return nil
end

function Auctionator.ShoppingLists.Delete(listName)
  local listIndex = Auctionator.ShoppingLists.ListIndex(listName)

  if listIndex == nil then
    error("List doesn't exist: '" .. listName .. "'")
  end

  table.remove(Auctionator.ShoppingLists.Lists, listIndex)
end

function Auctionator.ShoppingLists.Rename(listIndex, newListName)
  Auctionator.ShoppingLists.Lists[listIndex].name = newListName
end

function Auctionator.ShoppingLists.GetListByName(listName)
  local listIndex = Auctionator.ShoppingLists.ListIndex(listName)

  if listIndex == nil then
    error("List doesn't exist: '" .. listName .. "'")
  end

  return Auctionator.ShoppingLists.Lists[listIndex]
end

function Auctionator.ShoppingLists.Prune()
  local lists = {}

  for _, list in ipairs(Auctionator.ShoppingLists.Lists) do
    if not list.isTemporary then
      table.insert(lists, list)
    end
  end

  Auctionator.ShoppingLists.Lists = lists
end
