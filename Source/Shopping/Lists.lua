local function ErrorIfExists(name)
  assert(Auctionator.Shopping.Lists.ListIndex(name) == nil, "Shopping list already exists")
end
Auctionator.Shopping.Lists = {}

function Auctionator.Shopping.Lists.Create(listName)
  ErrorIfExists(listName)

  table.insert(Auctionator.Shopping.Lists.Data, {
    name = listName,
    items = {},
    isTemporary = false,
  })

  Auctionator.Shopping.Lists.Sort()
end
function Auctionator.Shopping.Lists.CreateTemporary(listName)
  ErrorIfExists(listName)

  table.insert(Auctionator.Shopping.Lists.Data, {
    name = listName,
    items = {},
    isTemporary = true,
  })

  Auctionator.Shopping.Lists.Sort()
end

function Auctionator.Shopping.Lists.MakePermanent(listName)
  local list = Auctionator.Shopping.Lists.GetListByName(listName)
  list.isTemporary = false
end

function Auctionator.Shopping.Lists.ListIndex(listName)
  for index, list in ipairs(Auctionator.Shopping.Lists.Data) do
    if list.name == listName then
      return index
    end
  end

  return nil
end

function Auctionator.Shopping.Lists.Delete(listName)
  local listIndex = Auctionator.Shopping.Lists.ListIndex(listName)

  if listIndex == nil then
    error("List doesn't exist: '" .. listName .. "'")
  end

  table.remove(Auctionator.Shopping.Lists.Data, listIndex)
end

function Auctionator.Shopping.Lists.Rename(listIndex, newListName)
  ErrorIfExists(newListName)

  Auctionator.Shopping.Lists.Data[listIndex].name = newListName
  Auctionator.Shopping.Lists.Sort()
end

function Auctionator.Shopping.Lists.GetListByName(listName)
  local listIndex = Auctionator.Shopping.Lists.ListIndex(listName)

  if listIndex == nil then
    error("List doesn't exist: '" .. listName .. "'")
  end

  return Auctionator.Shopping.Lists.Data[listIndex]
end

function Auctionator.Shopping.Lists.Prune()
  local lists = {}

  for _, list in ipairs(Auctionator.Shopping.Lists.Data) do
    if not list.isTemporary then
      table.insert(lists, list)
    end
  end

  Auctionator.Shopping.Lists.Data = lists
end

function Auctionator.Shopping.Lists.GetUnusedListName(prefix)
  local currentIndex = 1
  local newName = prefix

  while Auctionator.Shopping.Lists.ListIndex(newName) ~= nil do
    currentIndex = currentIndex + 1
    newName = prefix .. " " .. currentIndex
  end

  return newName
end

function Auctionator.Shopping.Lists.Sort()
  table.sort(Auctionator.Shopping.Lists.Data, function(left, right)
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
