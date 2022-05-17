function Auctionator.Selling.UniqueBagKey(entry)
  local result = Auctionator.Search.GetCleanItemLink(entry.itemLink)

  if not entry.auctionable then
    result = result .. " x"
  end

  return result
end
