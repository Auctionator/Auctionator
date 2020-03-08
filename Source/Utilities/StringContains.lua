function Auctionator.Utilities.StringContains(s, sub, ...)
  if s == nil or sub == nil or sub == "" then
    return false
  end

  if string.find(string.lower(s), string.lower(sub), 1, true) ~= nil then
    return true
  end

  return Auctionator.Utilities.StringContains(s, ...);
end
