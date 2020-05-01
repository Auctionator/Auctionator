function Auctionator.ShoppingLists.Create(listName)
  table.insert(Auctionator.ShoppingLists.Lists, {
    name = listName,
    items = {}
  })
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

function Auctionator.ShoppingLists.GetExportString(listName)
  local list = Auctionator.ShoppingLists.GetListByName(listName)

  local result = ""
  for _, item in ipairs(list.items) do
    result = result .. item .. "\n"
  end

  result = gsub(result, "\n$", "")

  return result
end

function Auctionator.ShoppingLists.ImportFromString(listName, importString)
  local list = Auctionator.ShoppingLists.GetListByName(listName)

  list.items = {strsplit("\n", importString)}
end
