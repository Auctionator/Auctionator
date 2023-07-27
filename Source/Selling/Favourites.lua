function Auctionator.Selling.GetAllFavourites()
  local favourites = {}
  for _, fav in pairs(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)) do
    table.insert(favourites, fav)
  end

  return favourites
end

function Auctionator.Selling.IsFavourite(data)
  return Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)[Auctionator.Selling.UniqueBagKey(data)] ~= nil
end

function Auctionator.Selling.ToggleFavouriteItem(data)
  if Auctionator.Selling.IsFavourite(data) then
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)[Auctionator.Selling.UniqueBagKey(data)] = nil
  else
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITE_KEYS)[Auctionator.Selling.UniqueBagKey(data)] = {
      itemKey = data.itemKey,
      itemLink = data.itemLink,
      count = 0,
      iconTexture = data.iconTexture,
      itemType = data.itemType,
      location = nil,
      quality = data.quality,
      classId = data.classId,
      auctionable = data.auctionable,
    }
  end

  Auctionator.EventBus
    :RegisterSource(Auctionator.Selling.ToggleFavouriteItem, "Auctionator.Selling.ToggleFavouriteItem")
    :Fire(Auctionator.Selling.ToggleFavouriteItem, Auctionator.Selling.Events.BagRefresh)
    :UnregisterSource(Auctionator.Selling.ToggleFavouriteItem)
end
