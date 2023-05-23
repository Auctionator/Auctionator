function Auctionator.Shopping.Tab.CreateOptionButton(button, xOffset, width, height)
  local option = CreateFrame("Button", nil, button)
  option:SetPoint("TOPRIGHT", xOffset, 0)
  option:SetSize(width, height)
  option.Icon = option:CreateTexture()
  option.Icon:SetSize(height - 5, height - 5)
  option.Icon:SetPoint("CENTER")
  option:SetScript("OnEnter", function()
    option.Icon:SetAlpha(0.5)
    if option.TooltipText then
      GameTooltip:SetOwner(option, "ANCHOR_RIGHT")
      GameTooltip:SetText(option.TooltipText, 1, 1, 1)
      GameTooltip:Show()
    end
  end)
  option:SetScript("OnLeave", function()
    option.Icon:SetAlpha(1)
    if option.TooltipText then
      GameTooltip:Hide()
    end
  end)
  option:SetScript("OnHide", function()
    option.Icon:SetAlpha(1)
  end)
  return option
end

function Auctionator.Shopping.Tab.SetupContainerRow(button, buttonHeight, buttonSpacing)
  local fontString = button:CreateFontString(nil, nil, "GameFontHighlightSmall")
  fontString:SetJustifyH("LEFT")
  fontString:SetPoint("RIGHT", button, "RIGHT", -buttonSpacing, 0)
  fontString:SetWordWrap(false)
  button.Text = fontString
  button.Bg = button:CreateTexture()
  button.Bg:SetAtlas("auctionhouse-rowstripe-1")
  button.Bg:SetBlendMode("ADD")
  button.Bg:SetAllPoints()
  button.Highlight = button:CreateTexture()
  button.Highlight:SetAtlas("auctionhouse-ui-row-highlight")
  button.Highlight:SetBlendMode("ADD")
  button.Highlight:SetAllPoints()
  button.Highlight:Hide()
  button.Selected = button:CreateTexture()
  button.Selected:SetAtlas("auctionhouse-ui-row-select")
  button.Selected:SetBlendMode("ADD")
  button.Selected:SetAllPoints()
  button.Selected:Hide()
end
