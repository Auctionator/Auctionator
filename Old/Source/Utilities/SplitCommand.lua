function Auctionator.Utilities.SplitCommand(input)
  local result = {}
  for match in string.gmatch(input:lower(), "%S+") do
    table.insert(result, match)
  end

  return result
end
