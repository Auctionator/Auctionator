function Auctionator.Utilities.ItemIdFromLink(itemLink)
  local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
  local _, itemId = strsplit(":", itemString)

  return tonumber(itemId)
end