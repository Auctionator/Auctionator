local tooltip = CreateFrame("GameTooltip", "AuctionatorUtilitiesScanTooltipTooltip", UIParent, "GameTooltipTemplate")
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

--Identifies if any text on a tooltip matches a given predicate
--  tooltipSet: Function to set the item on a tooltip ready for scanning
--  tooltipCheck: Function to test each string of text on the tooltip with
function Auctionator.Utilities.ScanTooltip(tooltipSet, tooltipCheck)
  tooltipSet(tooltip)
  for _, region in ipairs({tooltip:GetRegions()}) do
    if region and region:GetObjectType() == "FontString" then
      if region:GetText() ~= nil and tooltipCheck(region:GetText()) then
        return region:GetText()
      end
    end
  end
  return nil
end
