function Auctionator.Utilities.StringJoin(array, delimiter)
  local result = ""

  for index, item in ipairs(array) do
    if index == #array then
      result = result .. item
    else
      result = result .. item .. delimiter
    end
  end

  return result
end
