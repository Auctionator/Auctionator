
local function IsClassicWow()
  local gameVersion = GetBuildInfo()

  return gameVersion:match("%d") == "1"
end

function Auctionator.Utilities.ClassicWoWCheck()
  if IsClassicWow() then
    Auctionator.Utilities.Message(AUCTIONATOR_L_CLASSIC_SUPPORT_ERROR)
  end
end
