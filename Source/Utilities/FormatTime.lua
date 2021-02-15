-- Formatter found in Blizzard_AuctionHouseUtil.lua
local formatter = CreateFromMixins(SecondsFormatterMixin);
formatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true);
formatter:SetStripIntervalWhitespace(true);

function formatter:GetDesiredUnitCount(seconds)
	return 1;
end

function formatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes
end

function formatter:GetMaxInterval()
  return SecondsFormatter.Interval.Hours
end

function Auctionator.Utilities.FormatTimeLeft(seconds)
	local timeLeftMinutes = math.ceil(seconds / 60);
	local color = WHITE_FONT_COLOR
  if timeLeftMinutes < 60 then
    color = RED_FONT_COLOR;
  end

  return color:WrapTextInColorCode(formatter:Format(seconds))
end

local hour = 60 * 60
local SHORT     = "<" .. formatter:Format(hour/2) -- <30m
local MEDIUM    = formatter:Format(hour/2) .. " - " .. formatter:Format(hour * 2)     -- 30m - 2h
local LONG      = formatter:Format(hour * 2) .. " - " .. formatter:Format(hour * 12)  -- 2h - 12h
local VERY_LONG = formatter:Format(hour * 12) .. " - " .. formatter:Format(hour * 48) -- 12h - 48h

function Auctionator.Utilities.FormatTimeLeftBand(timeLeftBand)
	if timeLeftBand == Enum.AuctionHouseTimeLeftBand.Short then
		return RED_FONT_COLOR:WrapTextInColorCode(SHORT)
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Medium then
		return MEDIUM
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.Long then
		return LONG
	elseif timeLeftBand == Enum.AuctionHouseTimeLeftBand.VeryLong then
		return VERY_LONG
	end

	return ""
end

