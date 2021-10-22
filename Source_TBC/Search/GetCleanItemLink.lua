function Auctionator.Search.GetCleanItemLink(itemLink)
  local _, pre, hyperlink, post = ExtractHyperlinkString(itemLink)

  local parts = { strsplit(":", hyperlink) }

  for index = 3, 7 do
    parts[index] = ""
  end

  local wantedBits = Auctionator.Utilities.Slice(parts, 1, 8)

  return Auctionator.Utilities.StringJoin(wantedBits, ":")
end
