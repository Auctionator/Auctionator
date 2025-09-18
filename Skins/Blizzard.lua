---@class addonTableAuctionator
local addonTable = select(2, ...)

local skinners = {
}

local function ConvertTags(tags)
  local res = {}
  for _, tag in ipairs(tags) do
    res[tag] = true
  end
  return res
end

local function SkinFrame(details)
  local func = skinners[details.regionType]
  if func then
    func(details.region, details.tags and ConvertTags(details.tags) or {})
  end
end

local function SetConstants()
  if addonTable.Constants.IsRetail then
    addonTable.Constants.ButtonFrameOffset = 6
  end
  if addonTable.Constants.IsClassic then
    addonTable.Constants.ButtonFrameOffset = 0
  end
end

local function LoadSkin()
end

addonTable.Skins.RegisterSkin(addonTable.Locales.BLIZZARD, "blizzard", LoadSkin, SkinFrame, SetConstants, {})
