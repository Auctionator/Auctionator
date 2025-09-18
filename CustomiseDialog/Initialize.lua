---@class addonTableAuctionator
local addonTable = select(2, ...)


function addonTable.CustomiseDialog.Initialize()
  -- Create shortcut to open Baganator options from the Bliizzard addon options
  -- panel
  local optionsFrame = CreateFrame("Frame")

  local instructions = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge3")
  instructions:SetPoint("CENTER", optionsFrame)
  instructions:SetText(WHITE_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.TO_OPEN_OPTIONS_X))

  local version = C_AddOns.GetAddOnMetadata("Auctionator", "Version")
  local versionText = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  versionText:SetPoint("CENTER", optionsFrame, 0, 28)
  versionText:SetText(WHITE_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.VERSION_COLON_X:format(version)))

  local header = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge3")
  header:SetScale(3)
  header:SetPoint("CENTER", optionsFrame, 0, 30)
  header:SetText(LINK_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.AUCTIONATOR))

  local template = "SharedButtonLargeTemplate"
  if not C_XMLUtil.GetTemplateInfo(template) then
    template = "UIPanelDynamicResizeButtonTemplate"
  end
  local button = CreateFrame("Button", nil, optionsFrame, template)
  button:SetText(addonTable.Locales.OPEN_OPTIONS)
  DynamicResizeButton_Resize(button)
  button:SetPoint("CENTER", optionsFrame, 0, -30)
  button:SetScale(2)
  button:SetScript("OnClick", function()
    addonTable.CustomiseDialog:Toggle()
  end)


  optionsFrame.OnCommit = function() end
  optionsFrame.OnDefault = function() end
  optionsFrame.OnRefresh = function() end

  local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, addonTable.Locales.AUCTIONATOR)
  category.ID = addonTable.Locales.AUCTIONATOR
  Settings.RegisterAddOnCategory(category)
end
