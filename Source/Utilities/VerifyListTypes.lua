-- array: List of objects
-- typeStr: Type to ensure every item is
--
-- Returns a new array with only valid entries
function Auctionator.Utilities.VerifyListTypes(array, typeStr)
  if array and type(array) == "table" then
    local result = {}
    for _, item in ipairs(array) do
      if type(item) == typeStr then
        table.insert(result, item)
      else
        return nil
      end
    end
    return result
  end
  return nil
end
