SB2.Utilities = {}
function SB2.Utilities.IsContainedPredicate(list, pred)
  for _, item in ipairs(list) do
    if (pred(item)) then
      return true
    end
  end
  return false
end
