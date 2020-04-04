local compareAscending = function(left, right)
  if left < right then
    return true
  elseif left >= right then
    return false
  end
end

local compareDescending = function(left, right)
  if left > right then
    return true
  elseif left <= right then
    return false
  end
end

function Auctionator.Utilities.NumberComparator(order, fieldName)
  return function(left, right)
    if order == Auctionator.Constants.SORT.ASCENDING then
      return compareAscending((left and left[fieldName] or 0), (right and right[fieldName] or 0))
    else
      return compareDescending((left and left[fieldName] or 0), (right and right[fieldName] or 0))
    end
  end
end

function Auctionator.Utilities.StringComparator(order, fieldName)
  return function(left, right)
    if left == nil then left = {} end
    if right == nil then right = {} end

    if order == Auctionator.Constants.SORT.ASCENDING then
      return compareAscending((left[fieldName] or ""), (right[fieldName] or ""))
    else
      return compareDescending((left[fieldName] or ""), (right[fieldName] or ""))
    end
  end
end