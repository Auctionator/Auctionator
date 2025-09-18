function Auctionator.Utilities.ReverseArray(array)
  local result = {}

  for index = #array, 1, -1 do
    table.insert(result, array[index])
  end

  return result
end

