AuctionatorDropDownMixin = {}

local ARRAY_DELIMITER = ";"
local function splitStrArray(arrayString)
  return {strsplit(ARRAY_DELIMITER, arrayString)}
end

local function localizeArray(array)
  for index, itm in ipairs(array) do
    array[index] = Auctionator.Locales.Apply(itm)
  end

  return array
end

function AuctionatorDropDownMixin:OnShow()
  self:SetScript("OnShow", nil)
  if self.textString ~= nil and self.valuesString ~= nil then
    self:InitAgain(
      localizeArray(splitStrArray(self.textString)),
      splitStrArray(self.valuesString)
    )
  end

  if self.labelText ~= nil then
    self.Label:SetText(self.labelText)
  end
end

function AuctionatorDropDownMixin:InitAgain(lables, values)
  self.DropDown:Initialize(lables, values)
end

function AuctionatorDropDownMixin:SetValue(...)
  self.DropDown:SetValue(...)
end

function AuctionatorDropDownMixin:GetValue(...)
  return self.DropDown:GetValue(...)
end

AuctionatorDropDownInternalMixin = {}

function AuctionatorDropDownInternalMixin:Initialize(text, values)
  self.text = text
  self.values = values
  self.value = self.values[1]

  UIDropDownMenu_Initialize(self, self.BlizzInitialize)

  UIDropDownMenu_SetWidth(self, 150)
end

function AuctionatorDropDownInternalMixin:BlizzInitialize()
  local listEntry

  for index = 1, #self.text do
    listEntry = UIDropDownMenu_CreateInfo()
    listEntry.notCheckable = true
    listEntry.text = self.text[index]
    listEntry.value = self.values[index]
    listEntry.func = function(entry)
      self:SetValue(entry.value)
    end

    UIDropDownMenu_AddButton(listEntry)
  end

  self:SetValue(self.value)
end

function AuctionatorDropDownInternalMixin:GetValue()
  return self.value
end

function AuctionatorDropDownInternalMixin:SetValue(newValue)
  for index, value in ipairs(self.values) do
    if newValue == value then
      UIDropDownMenu_SetText(self, self.text[index])
      break
    end
  end

  self.value = newValue
end
