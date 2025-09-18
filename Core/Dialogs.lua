---@class addonTableAuctionator
local addonTable = select(2, ...)

local counter = 0
local function GenerateDialog()
  counter = counter + 1
  local dialog = CreateFrame("Frame", "AuctionatorDialog" .. counter, UIParent)
  dialog:SetToplevel(true)
  table.insert(UISpecialFrames, "AuctionatorDialog" .. counter)
  dialog:SetPoint("TOP", 0, -135)
  dialog:EnableMouse(true)
  dialog:SetFrameStrata("DIALOG")

  dialog.NineSlice = CreateFrame("Frame", nil, dialog, "NineSlicePanelTemplate")
  NineSliceUtil.ApplyLayoutByName(dialog.NineSlice, "Dialog", dialog.NineSlice:GetFrameLayoutTextureKit())

  local bg = dialog:CreateTexture(nil, "BACKGROUND", nil, -1)
  bg:SetColorTexture(0, 0, 0, 0.8)
  bg:SetPoint("TOPLEFT", 11, -11)
  bg:SetPoint("BOTTOMRIGHT", -11, 11)

  dialog:SetSize(500, 110)

  dialog.text = dialog:CreateFontString(nil, nil, "GameFontHighlight")
  dialog.text:SetPoint("TOP", 0, -20)
  dialog.text:SetPoint("LEFT", 20, 0)
  dialog.text:SetPoint("RIGHT", -20, 0)
  dialog.text:SetJustifyH("CENTER")

  addonTable.Skins.AddFrame("Dialog", dialog)

  return dialog
end

local copyDialogsBySkin = {}
function addonTable.Dialogs.ShowCopy(text)
  local currentSkinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  if not copyDialogsBySkin[currentSkinKey] then
    local dialog = GenerateDialog()
    dialog:SetWidth(350)
    dialog.text:SetText(addonTable.Locales.CTRL_C_TO_COPY)
    dialog.editBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    dialog.editBox:SetAutoFocus(false)
    dialog.editBox:SetSize(200, 30)
    dialog.editBox:SetPoint("CENTER")
    dialog.editBox:SetScript("OnEnterPressed", function()
      dialog:Hide()
    end)

    local okButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
    okButton:SetText(DONE)
    DynamicResizeButton_Resize(okButton)
    okButton:SetPoint("TOP", dialog, "CENTER", 0, -18)
    okButton:SetScript("OnClick", function()
      dialog:Hide()
    end)

    addonTable.Skins.AddFrame("EditBox", dialog.editBox)
    addonTable.Skins.AddFrame("Button", okButton)

    copyDialogsBySkin[currentSkinKey] = dialog
  end

  local dialog = copyDialogsBySkin[currentSkinKey]
  dialog:Hide()
  dialog:Show()
  dialog.editBox:SetText(text)
  dialog.editBox:SetFocus()
  dialog.editBox:HighlightText()
end

local editBoxDialogsBySkin = {}
function addonTable.Dialogs.ShowEditBox(text, acceptText, cancelText, confirmCallback)
  local currentSkinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  if not editBoxDialogsBySkin[currentSkinKey] then
    local dialog = GenerateDialog()
    dialog:SetWidth(350)
    dialog.editBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    dialog.editBox:SetAutoFocus(false)
    dialog.editBox:SetSize(200, 30)
    dialog.editBox:SetPoint("CENTER")

    dialog.acceptButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
    dialog.cancelButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")

    dialog.acceptButton:SetPoint("TOPRIGHT", dialog, "CENTER", -5, -18)
    dialog.cancelButton:SetPoint("TOPLEFT", dialog, "CENTER", 5, -18)
    dialog.cancelButton:SetScript("OnClick", function()
      dialog:Hide()
    end)

    addonTable.Skins.AddFrame("EditBox", dialog.editBox)
    addonTable.Skins.AddFrame("Button", dialog.acceptButton)
    addonTable.Skins.AddFrame("Button", dialog.cancelButton)

    editBoxDialogsBySkin[currentSkinKey] = dialog
  end

  local dialog = editBoxDialogsBySkin[currentSkinKey]
  dialog:Hide()

  dialog.text:SetText(text)
  dialog.acceptButton:SetText(acceptText)
  DynamicResizeButton_Resize(dialog.acceptButton)
  dialog.cancelButton:SetText(cancelText)
  DynamicResizeButton_Resize(dialog.cancelButton)
  dialog.acceptButton:SetScript("OnClick", function() confirmCallback(dialog.editBox:GetText()); dialog:Hide() end)
  dialog.editBox:SetScript("OnEnterPressed", function() confirmCallback(dialog.editBox:GetText()); dialog:Hide() end)
  dialog.editBox:SetText("")

  dialog:Show()
  dialog.editBox:SetFocus()
end

local confirmDialogsBySkin = {}
function addonTable.Dialogs.ShowConfirm(text, yesText, noText, confirmCallback)
  local currentSkinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  if not confirmDialogsBySkin[currentSkinKey] then
    local dialog = GenerateDialog()
    dialog:SetSize(450, 100)
    dialog.text:SetPoint("TOP", 0, -30)

    dialog.acceptButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
    dialog.cancelButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")

    dialog.acceptButton:SetPoint("TOPRIGHT", dialog, "CENTER", -5, -10)
    dialog.cancelButton:SetPoint("TOPLEFT", dialog, "CENTER", 5, -10)
    dialog.cancelButton:SetScript("OnClick", function()
      dialog:Hide()
    end)

    confirmDialogsBySkin[currentSkinKey] = dialog
  end

  local dialog = confirmDialogsBySkin[currentSkinKey]
  dialog:Hide()

  dialog.text:SetText(text)
  dialog.acceptButton:SetText(yesText)
  DynamicResizeButton_Resize(dialog.acceptButton)
  dialog.cancelButton:SetText(noText)
  DynamicResizeButton_Resize(dialog.cancelButton)
  dialog.acceptButton:SetScript("OnClick", function() confirmCallback(); dialog:Hide() end)

  dialog:Show()
end

local acknowledgeDialogsBySkin = {}
function addonTable.Dialogs.ShowAcknowledge(text)
  local currentSkinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  if not acknowledgeDialogsBySkin[currentSkinKey] then
    local dialog = GenerateDialog()
    dialog:SetSize(450, 90)

    local okButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
    okButton:SetText(OKAY)
    DynamicResizeButton_Resize(okButton)
    okButton:SetPoint("TOP", dialog, "CENTER", 0, -8)
    okButton:SetScript("OnClick", function()
      dialog:Hide()
    end)

    acknowledgeDialogsBySkin[currentSkinKey] = dialog
  end

  local dialog = acknowledgeDialogsBySkin[currentSkinKey]
  dialog:Hide()
  dialog.text:SetText(text)
  dialog:Show()
end

local moneyBoxDialogsBySkin = {}
function addonTable.Dialogs.ShowMoneyBox(text, acceptText, cancelText, confirmCallback)
  local currentSkinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  if not moneyBoxDialogsBySkin[currentSkinKey] then
    local dialog = GenerateDialog()
    dialog:SetWidth(350)
    dialog.moneyBox = CreateFrame("Frame", dialog:GetName() .. "MoneyBox", dialog, "MoneyInputFrameTemplate")
    dialog.moneyBox:SetPoint("CENTER")

    dialog.acceptButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
    dialog.cancelButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")

    dialog.acceptButton:SetPoint("TOPRIGHT", dialog, "CENTER", -5, -18)
    dialog.cancelButton:SetPoint("TOPLEFT", dialog, "CENTER", 5, -18)
    dialog.cancelButton:SetScript("OnClick", function()
      dialog:Hide()
    end)

    addonTable.Skins.AddFrame("EditBox", dialog.moneyBox.copper)
    addonTable.Skins.AddFrame("EditBox", dialog.moneyBox.silver)
    addonTable.Skins.AddFrame("EditBox", dialog.moneyBox.gold)
    addonTable.Skins.AddFrame("Button", dialog.acceptButton)
    addonTable.Skins.AddFrame("Button", dialog.cancelButton)

    moneyBoxDialogsBySkin[currentSkinKey] = dialog
  end

  local dialog = moneyBoxDialogsBySkin[currentSkinKey]
  dialog:Hide()
  MoneyInputFrame_ResetMoney(dialog.moneyBox)

  dialog.text:SetText(text)
  dialog.acceptButton:SetText(acceptText)
  DynamicResizeButton_Resize(dialog.acceptButton)
  dialog.cancelButton:SetText(cancelText)
  DynamicResizeButton_Resize(dialog.cancelButton)

  local callback = function() confirmCallback(MoneyInputFrame_GetCopper(dialog.moneyBox)); dialog:Hide() end
  dialog.acceptButton:SetScript("OnClick", callback)
  dialog.moneyBox.copper:SetScript("OnEnterPressed", callback)
  dialog.moneyBox.silver:SetScript("OnEnterPressed", callback)
  dialog.moneyBox.gold:SetScript("OnEnterPressed", callback)

  dialog:Show()
  dialog.moneyBox.gold:SetFocus()
end

local moneyShowDialogsBySkin = {}
function addonTable.Dialogs.ShowMoney(text, value, acceptText, cancelText, confirmCallback)
  local currentSkinKey = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
  if not moneyShowDialogsBySkin[currentSkinKey] then
    local dialog = GenerateDialog()
    dialog:SetWidth(400)

    dialog.acceptButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
    dialog.cancelButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")

    dialog.acceptButton:SetPoint("TOPRIGHT", dialog, "CENTER", -5, -18)
    dialog.cancelButton:SetPoint("TOPLEFT", dialog, "CENTER", 5, -18)
    dialog.cancelButton:SetScript("OnClick", function()
      dialog:Hide()
    end)

    addonTable.Skins.AddFrame("Button", dialog.acceptButton)
    addonTable.Skins.AddFrame("Button", dialog.cancelButton)

    moneyShowDialogsBySkin[currentSkinKey] = dialog
  end

  local dialog = moneyShowDialogsBySkin[currentSkinKey]
  dialog:Hide()

  dialog.text:SetText(text .. "\n\n" .. GetMoneyString(value, true))
  dialog.acceptButton:SetText(acceptText)
  DynamicResizeButton_Resize(dialog.acceptButton)
  dialog.cancelButton:SetText(cancelText)
  DynamicResizeButton_Resize(dialog.cancelButton)

  local callback = function() confirmCallback(); dialog:Hide() end
  dialog.acceptButton:SetScript("OnClick", callback)

  dialog:Show()
end
