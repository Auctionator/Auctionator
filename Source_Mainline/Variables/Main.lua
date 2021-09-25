-- All "realms" that are connected together use the same AH database, this
-- determines which database is in use.
function Auctionator.Variables.GetConnectedRealmRoot()
  local currentRealm = GetRealmName()
  local connections = GetAutoCompleteRealms()

  -- We sort so that we always get the same first realm to use for the database
  table.sort(connections)

  if connections[1] ~= nil then
    -- Case where we are on a connected realm
    return connections[1]
  else
    -- We are not on a connected realm
    return currentRealm
  end
end
