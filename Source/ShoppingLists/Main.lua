local function ErrorIfExists(name)
  assert(Auctionator.ShoppingLists.ListIndex(name) == nil, "Shopping list already exists")
end

function Auctionator.ShoppingLists.Create(listName)
  ErrorIfExists(listName)

  table.insert(Auctionator.ShoppingLists.Lists, {
    name = listName,
    items = {},
    isTemporary = false,
  })

  Auctionator.ShoppingLists.Sort()
end
function Auctionator.ShoppingLists.CreateTemporary(listName)
  ErrorIfExists(listName)

  table.insert(Auctionator.ShoppingLists.Lists, {
    name = listName,
    items = {},
    isTemporary = true,
  })

  Auctionator.ShoppingLists.Sort()
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
  ErrorIfExists(newListName)

  Auctionator.ShoppingLists.Lists[listIndex].name = newListName
  Auctionator.ShoppingLists.Sort()
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

function Auctionator.ShoppingLists.GetUnusedListName(prefix)
  local currentIndex = 1
  local newName = prefix

  while Auctionator.ShoppingLists.ListIndex(newName) ~= nil do
    currentIndex = currentIndex + 1
    newName = prefix .. " " .. currentIndex
  end

  return newName
end

function Auctionator.ShoppingLists.Sort()
  table.sort(Auctionator.ShoppingLists.Lists, function(left, right)
    local lowerLeft = string.lower(left.name)
    local lowerRight = string.lower(right.name)

    -- Handle case where names are the same, when ignoring lettercase
    if lowerLeft == lowerRight then
      return left.name < right.name
    else
      return lowerLeft < lowerRight
    end
  end)
end
