function Auctionator.Utilities.ItemIdFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    local linkType, itemId = strsplit(":", itemString)

    --Only return an id if it is attached to an item
    if linkType == "item" then
      return tonumber(itemId)
    else
      return nil
    end
  else
    return nil
  end
end
