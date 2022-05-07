function Auctionator.Utilities.DelimitThousands(num)
  local separator = ","

  local formatted, k = num, 0
  while true do  
    formatted, k = string.gsub(
      formatted,
      "([^%d]*%d+)(%d%d%d)",
      "%1"..AUCTIONATOR_L_NUMBER_SEPARATOR.."%2"
    )
    if k == 0 then
      break
    end
  end

  return formatted
end
