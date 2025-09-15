---@class addonTableChattynator
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
    logo:SetTexture("Interface\\AddOns\\Chattynator\\Assets\\Logo.png")
    logo:SetSize(52, 52)
    logo:SetPoint("LEFT", 8, 0)

    local name = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    name:SetText(addonTable.Locales.CHATTYNATOR)
    name:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 0)

    local credit = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    credit:SetText(addonTable.Locales.BY_PLUSMOUSE)
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
      if profileName ~= "" and CHATTYNATOR_CONFIG.Profiles[profileName] == nil then
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
          return CHATTYNATOR_CURRENT_PROFILE == name
        end, function()
          local oldSkin = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
          addonTable.Config.ChangeProfile(name)
          if addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) ~= oldSkin then
            addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
          end
        end)
        if name ~= "DEFAULT" and name ~= CHATTYNATOR_CURRENT_PROFILE then
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

  local storeMessages = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.STORE_MESSAGES, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.STORE_MESSAGES, state)
  end)
  storeMessages.option = addonTable.Config.Options.STORE_MESSAGES
  storeMessages:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, storeMessages)

  local customTabsDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.SPECIAL_TABS)
  do
    customTabsDropdown.SetValue = nil
    customTabsDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    customTabsDropdown.DropDown:SetDefaultText(GRAY_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.TOGGLE_COMBAT_LOG_ETC))
    local function IsActive(customType)
      local windows = addonTable.Config.Get(addonTable.Config.Options.WINDOWS)
      for _, w in ipairs(windows) do
        for _, t in ipairs(w.tabs) do
          if t.custom == customType then
            return true
          end
        end
      end
      return false
    end

    customTabsDropdown.DropDown:SetupMenu(function(menu, rootDescription)
      local details = {}
      for key, val in pairs(addonTable.API.CustomTabs) do
        table.insert(details, {
          custom = key,
          label = addonTable.Display.GetTabNameFromName(val.label),
        })
      end
      table.sort(details, function(a, b)
        return a.label:lower() < b.label:lower()
      end)

      for _, d in ipairs(details) do
        rootDescription:CreateCheckbox(d.label, function()
          return IsActive(d.custom)
        end, function()
          local windows = addonTable.Config.Get(addonTable.Config.Options.WINDOWS)
          if IsActive(d.custom) then
            local found = false
            for windowIndex, w in ipairs(windows) do
              for tabIndex, t in ipairs(w.tabs) do
                if t.custom == d.custom then
                  table.remove(w.tabs, tabIndex)
                  if #w.tabs == 0 then
                    table.insert(w.tabs, addonTable.Config.GetEmptyTabConfig(addonTable.Locales.EMPTY_WINDOW))
                  end
                  found = true
                  break
                end
              end
              if found then
                break
              end
            end
          else
            local blank = addonTable.Config.GetEmptyTabConfig(d.label)
            blank.backgroundColor = "262626"
            blank.tabColor = "c97c48"
            blank.custom = d.custom
            table.insert(windows[1].tabs, blank)
          end
          addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Tabs] = true})
        end)
      end
    end)
  end
  table.insert(allFrames, customTabsDropdown)

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        f:SetValue(addonTable.Config.Get(f.option))
      end
    end
  end)

  return container
end

local function SetupLayout(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local messageSpacing
  messageSpacing = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.MESSAGE_SPACING, 0, 60, "%spx", function()
    addonTable.Config.Set(addonTable.Config.Options.MESSAGE_SPACING, messageSpacing:GetValue())
  end)
  messageSpacing.option = addonTable.Config.Options.MESSAGE_SPACING
  messageSpacing:SetPoint("TOP")
  table.insert(allFrames, messageSpacing)

  local showSeparator = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_VERTICAL_SEPARATOR, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_TIMESTAMP_SEPARATOR, state)
  end)
  showSeparator.option = addonTable.Config.Options.SHOW_TIMESTAMP_SEPARATOR
  showSeparator:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, showSeparator)

  local showTabs = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.SHOW_TABS, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.SHOW_TABS) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_TABS, value)
  end)
  showTabs:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  do
    local entries = {
      addonTable.Locales.ALWAYS,
      addonTable.Locales.MOUSEOVER,
      addonTable.Locales.NEVER,
    }
    local values = {
      "always",
      "hover",
      "never",
    }
    showTabs:Init(entries, values)
  end
  table.insert(allFrames, showTabs)

  local showButtons = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.SHOW_BUTTONS, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.SHOW_BUTTONS) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_BUTTONS, value)
  end)
  showButtons:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, 0)
  do
    local entries = {
      addonTable.Locales.ALWAYS,
      addonTable.Locales.MOUSEOVER,
      addonTable.Locales.NEVER,
    }
    local values = {
      "always",
      "hover",
      "never",
    }
    showButtons:Init(entries, values)
  end
  table.insert(allFrames, showButtons)

  local buttonPositionDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.BUTTONS_POSITION, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.BUTTON_POSITION) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.BUTTON_POSITION, value)
  end)
  buttonPositionDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  do
    local entries = {
      addonTable.Locales.LEFT_OUTSIDE,
      addonTable.Locales.LEFT_INSIDE,
      addonTable.Locales.TABS_ABOVE,
      addonTable.Locales.TABS_BELOW,
    }
    local values = {
      "outside_left",
      "inside_left",
      "outside_tabs",
      "inside_tabs",
    }
    buttonPositionDropdown:Init(entries, values)
  end
  table.insert(allFrames, buttonPositionDropdown)

  local editBoxPositionDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.EDIT_BOX_POSITION, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.EDIT_BOX_POSITION) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.EDIT_BOX_POSITION, value)
  end)
  editBoxPositionDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  do
    local entries = {
      addonTable.Locales.BOTTOM,
      addonTable.Locales.TOP,
    }
    local values = {
      "bottom",
      "top"
    }
    editBoxPositionDropdown:Init(entries, values)
  end
  table.insert(allFrames, editBoxPositionDropdown)

  local newWhispersNewTab = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.NEW_WHISPERS_TO_NEW_TAB, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.NEW_WHISPER_NEW_TAB, state and 1 or 0)
  end)
  newWhispersNewTab.option = addonTable.Config.Options.NEW_WHISPER_NEW_TAB
  newWhispersNewTab:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, newWhispersNewTab)

  local locked = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.LOCK_CHAT, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.LOCKED, state)
  end)
  locked.option = addonTable.Config.Options.LOCKED
  locked:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, locked)

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        if f.option == addonTable.Config.Options.NEW_WHISPER_NEW_TAB then
          f:SetValue(addonTable.Config.Get(f.option) ~= 0)
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

local function SetupDisplay(parent)
  local LibSharedMedia = LibStub("LibSharedMedia-3.0")

  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local fontDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MESSAGE_FONT)
  fontDropdown:SetPoint("TOP")
  table.insert(allFrames, fontDropdown)

  local fontSize
  fontSize = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.MESSAGE_FONT_SIZE, 2, 40, "%spx", function()
    addonTable.Config.Set(addonTable.Config.Options.MESSAGE_FONT_SIZE, fontSize:GetValue())
  end)
  fontSize.option = addonTable.Config.Options.MESSAGE_FONT_SIZE
  fontSize:SetPoint("TOP", fontDropdown, "BOTTOM")
  table.insert(allFrames, fontSize)

  local messageOutline = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MESSAGE_FONT_OUTLINE, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.MESSAGE_FONT_OUTLINE) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.MESSAGE_FONT_OUTLINE, value)
  end)
  messageOutline:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  do
    local entries = {
      NONE,
      addonTable.Locales.THIN,
      addonTable.Locales.THICK,
    }
    local values = {
      "none",
      "thin",
      "thick"
    }
    messageOutline:Init(entries, values)
  end
  table.insert(allFrames, messageOutline)

  local showTextShadow = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.MESSAGE_FONT_SHADOW, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_FONT_SHADOW, state)
  end)
  showTextShadow.option = addonTable.Config.Options.SHOW_FONT_SHADOW
  showTextShadow:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, 0)
  table.insert(allFrames, showTextShadow)

  local enableMessageFade = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.ENABLE_MESSAGE_FADE, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.ENABLE_MESSAGE_FADE, state)
  end)
  enableMessageFade.option = addonTable.Config.Options.ENABLE_MESSAGE_FADE
  enableMessageFade:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, enableMessageFade)

  local messageFadeTimer
  messageFadeTimer = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.MESSAGE_FADE_TIME, 5, 240, "%ss", function()
    addonTable.Config.Set(addonTable.Config.Options.MESSAGE_FADE_TIME, messageFadeTimer:GetValue())
  end)
  messageFadeTimer.option = addonTable.Config.Options.MESSAGE_FADE_TIME
  messageFadeTimer:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, messageFadeTimer)

  local flashOnDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.FLASH_TABS_ON, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.TAB_FLASH_ON) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.TAB_FLASH_ON, value)
  end)
  flashOnDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  do
    local entries = {
      addonTable.Locales.NEVER,
      addonTable.Locales.ALL_MESSAGES,
      addonTable.Locales.WHISPERS_ONLY,
    }
    local values = {
      "never",
      "all",
      "whispers"
    }
    flashOnDropdown:Init(entries, values)
  end
  table.insert(allFrames, flashOnDropdown)

  container:SetScript("OnShow", function()
    local fontValues = CopyTable(LibSharedMedia:List("font"))
    local fontLabels = CopyTable(LibSharedMedia:List("font"))
    table.insert(fontValues, 1, "default")
    table.insert(fontLabels, 1, DEFAULT)

    fontDropdown.DropDown:SetupMenu(function(_, rootDescription)
      for index, label in ipairs(fontLabels) do
        local radio = rootDescription:CreateRadio(label,
          function()
            return addonTable.Config.Get(addonTable.Config.Options.MESSAGE_FONT) == fontValues[index]
          end,
          function()
            addonTable.Config.Set(addonTable.Config.Options.MESSAGE_FONT, fontValues[index])
          end
        )
        radio:AddInitializer(function(button, elementDescription, menu)
          button.fontString:SetFontObject(addonTable.Core.GetFontByID(fontValues[index]))
        end)
      end
      rootDescription:SetScrollMode(20 * 20)
    end)

    for _, f in ipairs(allFrames) do
      if f.SetValue then
        if f.option then
          f:SetValue(addonTable.Config.Get(f.option))
        end
      end
    end
  end)

  return container
end

local function SetupFormatting(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local timestampDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.TIMESTAMP, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.TIMESTAMP_FORMAT) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.TIMESTAMP_FORMAT, value)
  end)
  timestampDropdown:SetPoint("TOP")
  do
    local entries = {
      NONE,
      "HH:MM",
      "HH:MM:SS",
      "HH:MM AM/PM",
      "HH:MM:SS AM/PM",
    }
    local values = {
      " ",
      "%H:%M",
      "%X",
      "%I:%M %p",
      "%I:%M:%S %p",
    }
    timestampDropdown:Init(entries, values)
  end
  table.insert(allFrames, timestampDropdown)

  local useClassColors = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.USE_CLASS_COLORS, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.CLASS_COLORS, state)
  end)
  useClassColors.option = addonTable.Config.Options.CLASS_COLORS
  useClassColors:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, useClassColors)

  local shorteningDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.SHORTEN_CHANNELS, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.SHORTEN_FORMAT) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.SHORTEN_FORMAT, value)
  end)
  shorteningDropdown:SetPoint("TOP", useClassColors, "BOTTOM")
  do
    local entries = {
      addonTable.Locales.NONE,
      addonTable.Locales.SHORTEN_STYLE_1,
      addonTable.Locales.SHORTEN_STYLE_2,
    }
    local values = {
      "none",
      "number",
      "letter",
    }
    shorteningDropdown:Init(entries, values)
  end
  table.insert(allFrames, shorteningDropdown)

  local reduceRedundantText = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.REDUCE_REDUNDANT_TEXT, 28, function(state)
    addonTable.Config.Set(addonTable.Config.Options.REDUCE_REDUNDANT_TEXT, state)
  end)
  reduceRedundantText.option = addonTable.Config.Options.REDUCE_REDUNDANT_TEXT
  reduceRedundantText:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, reduceRedundantText)

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        if f.option then
          f:SetValue(addonTable.Config.Get(f.option))
        else
          f:SetValue()
        end
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

local function SetupChatColors(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  for _, entry in ipairs(addonTable.CustomiseDialog.TYPE_LAYOUT_ORDER) do
    local dropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, entry[1])
    if #allFrames > 0 then
      dropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    else
      dropdown:SetPoint("TOP")
    end
    dropdown.DropDown:SetDefaultText(addonTable.Locales.SELECT_TYPE_TO_CHANGE)
    table.insert(allFrames, dropdown)
    local fields = addonTable.CustomiseDialog.TYPE_LAYOUT[entry[2]]
    if not fields then
      dropdown.DropDown:SetupMenu(function(_, rootDescription)
        local colors = addonTable.Config.Get(addonTable.Config.Options.CHAT_COLORS)
        local channelMap, count = addonTable.Messages:GetChannels()
        for i = 1, count do
          if channelMap[i] then
            local color = colors["CHANNEL_" .. channelMap[i]]
            local oldColor = CopyTable(color)
            local colorInfo = {
              r = oldColor.r, g = oldColor.g, b = oldColor.b,
              swatchFunc = function()
                color.r, color.g, color.b =  ColorPickerFrame:GetColorRGB()
                addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.MessageColor] = true})
              end,
              cancelFunc = function()
                color.r, color.g, color.b =  oldColor.r, oldColor.g, oldColor.b
                addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.MessageColor] = true})
              end,
            }
            rootDescription:CreateColorSwatch(addonTable.CustomiseDialog.GetChatColor("CHANNEL_" .. channelMap[i]):WrapTextInColorCode(channelMap[i]),
              function()
                ColorPickerFrame:SetupColorPickerAndShow(colorInfo)
              end,
              colorInfo
            )
          end
        end
      end)
    else
      dropdown.DropDown:SetupMenu(function(_, rootDescription)
        local colors = addonTable.Config.Get(addonTable.Config.Options.CHAT_COLORS)
        local fields = addonTable.CustomiseDialog.TYPE_LAYOUT[entry[2]]
        for _, f in ipairs(fields) do
          if ChatTypeGroup[f[1]] then
            local color = {}
            for _, a in ipairs(ChatTypeGroup[f[1]]) do
              table.insert(color, colors[(a:gsub("CHAT_MSG_", ""))])
            end
            local oldColor = CopyTable(color[1] or {1, 1, 1})
            local colorInfo = {
              r = oldColor.r, g = oldColor.g, b = oldColor.b,
              swatchFunc = function()
                for _, c in ipairs(color) do
                  c.r, c.g, c.b = ColorPickerFrame:GetColorRGB()
                end
                addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.MessageColor] = true})
              end,
              cancelFunc = function()
                for _, c in ipairs(color) do
                  c.r, c.g, c.b = oldColor.r, oldColor.g, oldColor.b
                end
                addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.MessageColor] = true})
              end,
            }
            rootDescription:CreateColorSwatch(addonTable.CustomiseDialog.GetChatColor(f[1]):WrapTextInColorCode(f[2] or _G[f[1]]),
              function()
                ColorPickerFrame:SetupColorPickerAndShow(colorInfo)
              end,
              colorInfo
            )
          end
        end
      end)
    end
  end

  return container
end

local TabSetups = {
  {name = GENERAL, callback = SetupGeneral},
  {name = addonTable.Locales.THEME, callback = SetupThemes},
  {name = addonTable.Locales.LAYOUT, callback = SetupLayout},
  {name = addonTable.Locales.DISPLAY, callback = SetupDisplay},
  {name = addonTable.Locales.MESSAGE_COLORS, callback = SetupChatColors},
  {name = addonTable.Locales.FORMATTING, callback = SetupFormatting},
}

function addonTable.CustomiseDialog.Toggle()
  if customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] then
    local frame = customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)]
    frame:SetShown(not frame:IsVisible())
    return
  end

  local frame = CreateFrame("Frame", "ChattynatorCustomiseDialog" .. addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN), UIParent, "ButtonFrameTemplate")
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
