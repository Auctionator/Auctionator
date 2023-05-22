-- Add search term information to a tooltip
function Auctionator.Shopping.Tab.ComposeSearchTermTooltip(searchTerm)
  local tooltipDetails = Auctionator.Search.ComposeTooltip(searchTerm)

  GameTooltip:SetText(tooltipDetails.title, 1, 1, 1, 1)

  for _, line in ipairs(tooltipDetails.lines) do
    if line[2] == AUCTIONATOR_L_ANY_LOWER then
      -- Faded line when no filter set
      GameTooltip:AddDoubleLine(line[1], line[2], 0.4, 0.4, 0.4, 0.4, 0.4, 0.4)

    else
      GameTooltip:AddDoubleLine(
        line[1],
        WHITE_FONT_COLOR:WrapTextInColorCode(line[2])
      )
    end
  end
end
