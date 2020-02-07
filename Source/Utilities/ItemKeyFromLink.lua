function Auctionator.Utilities.ItemKeyFromLink(itemLink)
  local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
  local linkType, itemId, _, _, _, _, _, _, displayId = strsplit(":", itemString)
  if linkType == "battlepet" then
    return "p:"..displayId;
  else
    return itemId;
  end
end
