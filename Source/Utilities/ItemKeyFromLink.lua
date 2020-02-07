function Auctionator.Utilities.ItemKeyFromLink(itemLink)
  if itemLink ~= nil then
    local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    local linkType, itemId, _, _, _, _, _, _, _ = strsplit(":", itemString)
    if linkType == "battlepet" then
      return "p:"..itemId;
    elseif linkType == "item" then
      return itemId;
    else
      return nil
    end
  else
    return nil
  end
end
