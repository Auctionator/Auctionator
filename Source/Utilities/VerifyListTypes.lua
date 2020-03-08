-- array: List of objects
-- typeStr: Type to ensure every item is
--
-- Returns a new array with only valid entries


function Auctionator.Utilities.VerifyListTypes(list, requiredTypeString)
  if list == nil or type(list) ~= "table" then
    return nil
  end

  local result = {}
  for _, item in ipairs(list) do
    if type(item) == requiredTypeString then
      table.insert(result, item)
    else
      return nil
    end
  end

  return result
end
