Auctionator.BagGroups.Utilities = {}
function Auctionator.BagGroups.Utilities.IsContainedPredicate(list, pred)
  for _, item in ipairs(list) do
    if (pred(item)) then
      return true
    end
  end
  return false
end
