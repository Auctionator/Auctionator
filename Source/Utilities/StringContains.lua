function Auctionator.Utilities.StringContains (s, sub, ...)
  if (s == nil or sub == nil or sub == "") then
    return false;
  end

  local start, stop = string.find (string.lower(s), string.lower(sub), 1, true);

  local found = (start ~= nil);

  if (found or select("#", ...) == 0) then
    return found;
  end

  return Auctionator.Utilities.StringContains (s, ...);
end
