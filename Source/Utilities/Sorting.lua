local compareAscending = function(left, right, leftIndex, rightIndex)
  if left < right then
    return true
  elseif left > right then
    return false
  else
    return leftIndex < rightIndex
  end
end

local compareDescending = function(left, right, leftIndex, rightIndex)
  if left > right then
    return true
  elseif left < right then
    return false
  else
    return leftIndex < rightIndex
  end
end

function Auctionator.Utilities.NumberComparator(order, fieldName)
  return function(left, right)
    if left == nil then left = {sortingIndex = 0} end
    if right == nil then right = {sortingIndex = 0} end

    if order == Auctionator.Constants.SORT.ASCENDING then
      return compareAscending((left[fieldName] or 0), (right[fieldName] or 0), left.sortingIndex, right.sortingIndex)
    else
      return compareDescending((left[fieldName] or 0), (right[fieldName] or 0), left.sortingIndex, right.sortingIndex)
    end
  end
end

function Auctionator.Utilities.StringComparator(order, fieldName)
  return function(left, right)
    if left == nil then left = {sortingIndex = 0} end
    if right == nil then right = {sortingIndex = 0} end

    if order == Auctionator.Constants.SORT.ASCENDING then
      return compareAscending((left[fieldName] or ""), (right[fieldName] or ""), left.sortingIndex, right.sortingIndex)
    else
      return compareDescending((left[fieldName] or ""), (right[fieldName] or ""), left.sortingIndex, right.sortingIndex)
    end
  end
end
