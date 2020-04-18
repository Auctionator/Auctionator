function Auctionator.Utilities.ArrayIndex(list, item)
  for index, cmp in ipairs(list) do
    if cmp == item then
      return index
    end
  end

  return nil
end
