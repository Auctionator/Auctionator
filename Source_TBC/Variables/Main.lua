--No connected realms, so just the realm with mixed with the faction (like in
--the 8.2.0 edition of Auctionator)
function Auctionator.Variables.GetConnectedRealmRoot()
  return GetRealmName() .. " " .. (UnitFactionGroup("player"))
end
