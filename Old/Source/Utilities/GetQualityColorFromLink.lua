function Auctionator.Utilities.GetQualityColorFromLink(itemLink)
  return string.match(itemLink, "|c(nIQ%d+:)|") or string.match(itemLink, "|c(........)|")
end
