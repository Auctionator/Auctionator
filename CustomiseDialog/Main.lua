---@class addonTableAuctionator
local addonTable = select(2, ...)

local customisers = {}

local function SetupGeneral(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}
  local infoInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  do
    table.insert(allFrames, infoInset)
    infoInset:SetPoint("TOP")
    infoInset:SetPoint("LEFT", 20, 0)
    infoInset:SetPoint("RIGHT", -20, 0)
    infoInset:SetHeight(75)
    addonTable.Skins.AddFrame("InsetFrame", infoInset)

    local logo = infoInset:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\Auctionator\\Assets\\logo")
    logo:SetSize(52, 52)
    logo:SetPoint("LEFT", 8, 0)

    local name = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    name:SetText(addonTable.Locales.AUCTIONATOR)
    name:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 0)

    local credit = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    credit:SetText(addonTable.Locales.BY_PLUSMOUSE_PAST_AUTHOR_BORJAMACARE)
    credit:SetPoint("BOTTOMLEFT", name, "BOTTOMRIGHT", 5, 0)

    local discordButton = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate")
    discordButton:SetText(addonTable.Locales.JOIN_THE_DISCORD)
    DynamicResizeButton_Resize(discordButton)
    discordButton:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 8, 0)
    discordButton:SetScript("OnClick", function()
      addonTable.Dialogs.ShowCopy("https://discord.gg/gPS62RjKSZ")
    end)
    addonTable.Skins.AddFrame("Button", discordButton)
    local discordText = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    discordText:SetPoint("LEFT", discordButton, "RIGHT", 10, 0)
    discordText:SetText(addonTable.Locales.DISCORD_DESCRIPTION)
  end

  do
    local header = addonTable.CustomiseDialog.Components.GetHeader(container, addonTable.Locales.DEVELOPMENT_IS_TIME_CONSUMING)
    header:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    table.insert(allFrames, header)

    local donateFrame = CreateFrame("Frame", nil, container)
    donateFrame:SetPoint("LEFT")
    donateFrame:SetPoint("RIGHT")
    donateFrame:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    donateFrame:SetHeight(40)
    local text = donateFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("RIGHT", donateFrame, "CENTER", -50, 0)
    text:SetText(addonTable.Locales.DONATE)
    text:SetJustifyH("RIGHT")

    local button = CreateFrame("Button", nil, donateFrame, "UIPanelDynamicResizeButtonTemplate")
    button:SetText(addonTable.Locales.LINK)
    DynamicResizeButton_Resize(button)
    button:SetPoint("LEFT", donateFrame, "CENTER", -35, 0)
    button:SetScript("OnClick", function()
      addonTable.Dialogs.ShowCopy("https://linktr.ee/plusmouse")
    end)
    addonTable.Skins.AddFrame("Button", button)
    table.insert(allFrames, donateFrame)
  end

  local profileDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.PROFILES)
  do
    profileDropdown.SetValue = nil

    local clone = false
    local function ValidateAndCreate(profileName)
      if profileName ~= "" and AUCTIONATOR_CONFIG.Profiles[profileName] == nil then
        local oldSkin = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
        addonTable.Config.MakeProfile(profileName, clone)
        profileDropdown.DropDown:GenerateMenu()
        if addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) ~= oldSkin then
          addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
        end
      end
    end
    profileDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    profileDropdown.DropDown:SetupMenu(function(menu, rootDescription)
      local profiles = addonTable.Config.GetProfileNames()
      table.sort(profiles, function(a, b) return a:lower() < b:lower() end)
      for _, name in ipairs(profiles) do
        local button = rootDescription:CreateRadio(name ~= "DEFAULT" and name or LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(DEFAULT), function()
          return AUCTIONATOR_CURRENT_PROFILE == name
        end, function()
          local oldSkin = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
          addonTable.Config.ChangeProfile(name)
          if addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) ~= oldSkin then
            addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
          end
        end)
        if name ~= "DEFAULT" and name ~= AUCTIONATOR_CURRENT_PROFILE then
          button:AddInitializer(function(button, description, menu)
            local delete = MenuTemplates.AttachAutoHideButton(button, "transmog-icon-remove")
            delete:SetPoint("RIGHT")
            delete:SetSize(18, 18)
            delete.Texture:SetAtlas("transmog-icon-remove")
            delete:SetScript("OnClick", function()
              menu:Close()
              addonTable.Dialogs.ShowConfirm(addonTable.Locales.CONFIRM_DELETE_PROFILE_X:format(name), YES, NO, function()
                addonTable.Config.DeleteProfile(name)
              end)
            end)
            MenuUtil.HookTooltipScripts(delete, function(tooltip)
              GameTooltip_SetTitle(tooltip, DELETE);
            end);
          end)
        end
      end
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_PROFILE_CLONE), function()
        clone = true
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PROFILE_NAME, ACCEPT, CANCEL, ValidateAndCreate)
      end)
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_PROFILE_BLANK), function()
        clone = false
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PROFILE_NAME, ACCEPT, CANCEL, ValidateAndCreate)
      end)
    end)
  end
  table.insert(allFrames, profileDropdown)

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        f:SetValue(addonTable.Config.Get(f.option))
      end
    end
  end)

  return container
end

local function SetupThemes(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local themeDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.THEME, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.CURRENT_SKIN, value)
    addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
  end)
  themeDropdown:SetPoint("TOP")
  do
    local skins = {}
    for _, skin in pairs(addonTable.Skins.availableSkins) do
      table.insert(skins, {name = skin.label, value = skin.key})
    end
    table.sort(skins, function(a, b) return a.name < b.name end)
    local entries, values = {}, {}
    for _, skinDetails in ipairs(skins) do
      table.insert(entries, skinDetails.name)
      table.insert(values, skinDetails.value)
    end
    themeDropdown:Init(entries, values)
  end
  table.insert(allFrames, themeDropdown)

  local skinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  local currentSkin = addonTable.Skins.availableSkins[skinKey]
  for index, option in ipairs(currentSkin.options) do
    local optionKey = "skins." .. skinKey .. "." .. option.option
    if option.type == "slider" then
      local slider
      slider = addonTable.CustomiseDialog.Components.GetSlider(container, option.text, option.min, option.max, option.valuePattern, function()
        addonTable.Config.Set(optionKey, slider:GetValue() / (option.scale or 1))
      end)
      slider.option = optionKey
      slider.scale = option.scale
      slider:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, index == 1 and -30 or 0)
      table.insert(allFrames, slider)
    elseif option.type == "checkbox" then
      local checkbox = addonTable.CustomiseDialog.Components.GetCheckbox(container, option.text, 28, function(state)
        addonTable.Config.Set(optionKey, state)
      end)
      checkbox.option = optionKey
      checkbox:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
      table.insert(allFrames, checkbox)
    end
  end

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        if f.option and f.scale then
          f:SetValue(addonTable.Config.Get(f.option) * f.scale)
        elseif f.option then
          f:SetValue(addonTable.Config.Get(f.option))
        else
          f:SetValue()
        end
      end
    end
  end)

  return container
end

local TabSetups = {
  {name = GENERAL, callback = SetupGeneral},
  {name = addonTable.Locales.THEME, callback = SetupThemes},
}

function addonTable.CustomiseDialog.Toggle()
  if customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] then
    local frame = customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)]
    frame:SetShown(not frame:IsVisible())
    return
  end

  local frame = CreateFrame("Frame", "AuctionatorCustomiseDialog" .. addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN), UIParent, "ButtonFrameTemplate")
  frame:SetToplevel(true)
  customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] = frame
  table.insert(UISpecialFrames, frame:GetName())
  frame:SetSize(600, 700)
  frame:SetPoint("CENTER")
  frame:Raise()

  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    frame:StartMoving()
    frame:SetUserPlaced(false)
  end)
  frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    frame:SetUserPlaced(false)
  end)

  ButtonFrameTemplate_HidePortrait(frame)
  ButtonFrameTemplate_HideButtonBar(frame)
  frame.Inset:Hide()
  frame:EnableMouse(true)
  frame:SetScript("OnMouseWheel", function() end)

  frame:SetTitle(addonTable.Locales.CUSTOMISE_CHATTYNATOR)

  local containers = {}
  local lastTab
  local Tabs = {}
  for _, setup in ipairs(TabSetups) do
    local tabContainer = setup.callback(frame)
    tabContainer:SetPoint("TOPLEFT", 0 + addonTable.Constants.ButtonFrameOffset, -65)
    tabContainer:SetPoint("BOTTOMRIGHT")

    local tabButton = addonTable.CustomiseDialog.Components.GetTab(frame, setup.name)
    if lastTab then
      tabButton:SetPoint("LEFT", lastTab, "RIGHT", 5, 0)
    else
      tabButton:SetPoint("TOPLEFT", 0 + addonTable.Constants.ButtonFrameOffset + 5, -25)
    end
    lastTab = tabButton
    tabContainer.button = tabButton
    tabButton:SetScript("OnClick", function()
      for _, c in ipairs(containers) do
        PanelTemplates_DeselectTab(c.button)
        c:Hide()
      end
      PanelTemplates_SelectTab(tabButton)
      tabContainer:Show()
    end)
    tabContainer:Hide()

    table.insert(Tabs, tabButton)
    table.insert(containers, tabContainer)
  end
  frame.Tabs = Tabs
  PanelTemplates_SetNumTabs(frame, #frame.Tabs)
  containers[1].button:Click()

  frame:SetScript("OnShow", function()
    local shownContainer = FindValueInTableIf(containers, function(c) return c:IsShown() end)
    if shownContainer then
      PanelTemplates_SetTab(frame, tIndexOf(containers, shownContainer))
    end
  end)

  addonTable.Skins.AddFrame("ButtonFrame", frame, {"customise"})
end
