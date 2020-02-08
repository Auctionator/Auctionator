function Auctionator.Utilities.ItemKeyFromLink(itemLink)
  local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
  local linkType, itemId, _, _, _, _, _, _, _ = strsplit(":", itemString)
  if linkType == "battlepet" then
    return "p:"..itemId;
  else
    return itemId;
  end
end
