function Auctionator.Utilities.GetNameFromLink(itemLink)
  return string.match(itemLink, "h%[(.*)%]|h")
end
