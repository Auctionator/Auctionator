function Auctionator.Utilities.Slice(array, start, count)
  local result = {}

  for index = start, math.min(#array, start + count - 1) do
    table.insert(result, array[index])
  end

  return result
end
