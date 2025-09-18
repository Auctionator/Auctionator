---@class addonTableAuctionator
local addonTable = select(2, ...)

addonTable.CustomiseDialog.Components = {}

function addonTable.CustomiseDialog.Components.GetCheckbox(parent, label, spacing, callback)
  spacing = spacing or 0
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetHeight(40)
  holder:SetPoint("LEFT", parent, "LEFT", 30, 0)
  holder:SetPoint("RIGHT", parent, "RIGHT", -15, 0)
  local checkBox = CreateFrame("CheckButton", nil, holder, "SettingsCheckboxTemplate")

  checkBox:SetPoint("LEFT", holder, "CENTER", -15 - spacing, 0)
  checkBox:SetText(label)
  checkBox:SetNormalFontObject(GameFontHighlight)
  checkBox:GetFontString():SetPoint("RIGHT", holder, "CENTER", -30 - spacing, 0)

  addonTable.Skins.AddFrame("CheckBox", checkBox)

  function holder:SetValue(value)
    checkBox:SetChecked(value)
  end

  holder:SetScript("OnEnter", function()
    checkBox:OnEnter()
  end)

  holder:SetScript("OnLeave", function()
    checkBox:OnLeave()
  end)

  holder:SetScript("OnMouseUp", function()
    checkBox:Click()
  end)

  checkBox:SetScript("OnClick", function()
    callback(checkBox:GetChecked())
  end)

  return holder
end

function addonTable.CustomiseDialog.Components.GetHeader(parent, text)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetPoint("LEFT", 30, 0)
  holder:SetPoint("RIGHT", -30, 0)
  holder.text = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  holder.text:SetText(text)
  holder.text:SetPoint("LEFT", 20, -1)
  holder.text:SetPoint("RIGHT", 20, -1)
  holder:SetHeight(40)
  return holder
end

function addonTable.CustomiseDialog.Components.GetTab(parent, text)
  local tab
  if addonTable.Constants.IsRetail then
    tab = CreateFrame("Button", nil, parent, "PanelTopTabButtonTemplate")
    tab:SetScript("OnShow", function(self)
      PanelTemplates_TabResize(self, 15, nil, 10)
      PanelTemplates_DeselectTab(self)
    end)
  else
    tab = CreateFrame("Button", nil, parent, "TabButtonTemplate")
    tab:SetScript("OnShow", function(self)
      PanelTemplates_TabResize(self, 0, nil, 0)
      PanelTemplates_DeselectTab(self)
    end)
  end
  tab:SetText(text)
  tab:GetScript("OnShow")(tab)
  addonTable.Skins.AddFrame("TopTabButton", tab)
  return tab
end

function addonTable.CustomiseDialog.Components.GetBasicDropdown(parent, labelText, isSelectedCallback, onSelectionCallback)
  local frame = CreateFrame("Frame", nil, parent)
  local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
  dropdown:SetWidth(250)
  dropdown:SetPoint("LEFT", frame, "CENTER", -32, 0)
  local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  label:SetPoint("LEFT", 20, 0)
  label:SetPoint("RIGHT", frame, "CENTER", -50, 0)
  label:SetJustifyH("RIGHT")
  label:SetText(labelText)
  frame:SetPoint("LEFT", 30, 0)
  frame:SetPoint("RIGHT", -30, 0)
  frame.Init = function(_, entryLabels, values)
    local entries = {}
    for index = 1, #entryLabels do
      table.insert(entries, {entryLabels[index], values[index]})
    end
    MenuUtil.CreateRadioMenu(dropdown, isSelectedCallback, onSelectionCallback, unpack(entries))
  end
  frame.SetValue = function(_, _)
    dropdown:GenerateMenu()
    -- don't need to do anything as dropdown's onshow handles this
  end
  frame.Label = label
  frame.DropDown = dropdown
  frame:SetHeight(40)
  addonTable.Skins.AddFrame("Dropdown", frame.DropDown)

  return frame
end

function addonTable.CustomiseDialog.Components.GetSlider(parent, label, min, max, valuePattern, callback)
  local holder = CreateFrame("Frame", nil, parent)
  holder:SetHeight(40)
  holder:SetPoint("LEFT", parent, "LEFT", 30, 0)
  holder:SetPoint("RIGHT", parent, "RIGHT", -30, 0)

  holder.Label = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  holder.Label:SetJustifyH("RIGHT")
  holder.Label:SetPoint("LEFT", 20, 0)
  holder.Label:SetPoint("RIGHT", holder, "CENTER", -50, 0)
  holder.Label:SetText(label)

  holder.ValueText = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  holder.ValueText:SetJustifyH("LEFT")
  holder.ValueText:SetPoint("LEFT", holder, "RIGHT", -35, 0)

  holder.Slider = CreateFrame("Slider", nil, holder, "UISliderTemplate")
  holder.Slider:SetPoint("LEFT", holder, "CENTER", -32, 0)
  holder.Slider:SetPoint("RIGHT", -45, 0)
  holder.Slider:SetHeight(20)
  holder.Slider:SetMinMaxValues(min, max)
  holder.Slider:SetValueStep(1)
  holder.Slider:SetObeyStepOnDrag(true)

  holder.Slider:SetScript("OnValueChanged", function(_, _, userInput)
    local value = holder.Slider:GetValue()
    --[[if scale then
      value = value / scale
    end]]
    holder.ValueText:SetText(valuePattern:format(math.floor(holder.Slider:GetValue())))
    callback(value)
  end)

  function holder:GetValue()
    return holder.Slider:GetValue()
  end

  function holder:SetValue(value)
    return holder.Slider:SetValue(value)
  end

  addonTable.Skins.AddFrame("Slider", holder.Slider)

  holder:SetScript("OnMouseWheel", function(_, delta)
    if holder.Slider:IsEnabled() then
      holder.Slider:SetValue(holder.Slider:GetValue() + delta)
      callback(holder.Slider:GetValue())
    end
  end)

  return holder
end
