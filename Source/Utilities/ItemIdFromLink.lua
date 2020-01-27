function Auctionator.Utilities.ItemIdFromLink(itemLink)
  if itemLink == nil then
    -- Just returning an invalid itemId (should be reported as unknown by Auctionator)
    return 0
  else
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    local _, itemId = strsplit(":", itemString)

    return tonumber(itemId)
  end
end
