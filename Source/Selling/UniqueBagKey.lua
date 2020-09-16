function Auctionator.Selling.UniqueBagKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey) .. entry.quality
end
