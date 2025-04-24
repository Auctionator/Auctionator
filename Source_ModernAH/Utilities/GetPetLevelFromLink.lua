function Auctionator.Utilities.GetPetLevelFromLink(itemLink)
  local _, _, level = strsplit(":", (itemLink:match("battlepet:.*")))

  return tonumber(level)
end
