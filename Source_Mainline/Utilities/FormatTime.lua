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
