function Auctionator.Utilities.TableKeys(original)
  local keys = {}
  for key, _ in pairs(original) do
    table.insert(keys, key)
  end
  return keys
end
