Auctionator.Shopping.Recents = {}

function Auctionator.Shopping.Recents.Save(searchText)
  local prevIndex = tIndexOf(AUCTIONATOR_RECENT_SEARCHES, searchText)
  if prevIndex ~= nil then
    table.remove(AUCTIONATOR_RECENT_SEARCHES, prevIndex)
  end

  table.insert(AUCTIONATOR_RECENT_SEARCHES, 1, searchText)

  while #AUCTIONATOR_RECENT_SEARCHES > Auctionator.Constants.RecentsListLimit do
    table.remove(AUCTIONATOR_RECENT_SEARCHES)
  end

  Auctionator.EventBus
    :RegisterSource(Auctionator.Shopping.Recents.Save, "save recents entry")
    :Fire(Auctionator.Shopping.Recents.Save, Auctionator.Shopping.Events.RecentSearchesUpdate)
    :UnregisterSource(Auctionator.Shopping.Recents.Save)
end

function Auctionator.Shopping.Recents.DeleteEntry(searchTerm)
  local index = tIndexOf(AUCTIONATOR_RECENT_SEARCHES, searchTerm)

  if index ~= nil then
    table.remove(AUCTIONATOR_RECENT_SEARCHES, index)
    Auctionator.EventBus
      :RegisterSource(Auctionator.Shopping.Recents.DeleteEntry, "delete recents entry")
      :Fire(Auctionator.Shopping.Recents.DeleteEntry, Auctionator.Shopping.Events.RecentSearchesUpdate)
      :UnregisterSource(Auctionator.Shopping.Recents.DeleteEntry)
  end
end

function Auctionator.Shopping.Recents.GetAll()
  return AUCTIONATOR_RECENT_SEARCHES
end
