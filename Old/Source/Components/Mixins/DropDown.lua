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

function AuctionatorDropDownMixin:OnLoad()
  if self.textString ~= nil and self.valuesString ~= nil then
    self:InitAgain(
      localizeArray(splitStrArray(self.textString)),
      splitStrArray(self.valuesString)
    )
  end
  self.DropDown:SetWidth(180)

  if self.labelText ~= nil then
    self.Label:SetText(self.labelText)
  end
end

function AuctionatorDropDownMixin:InitAgain(labels, values)
  local entries = {}
  for index = 1, #labels do
    table.insert(entries, {labels[index], values[index]})
  end
  self.value = values[1]
  MenuUtil.CreateRadioMenu(self.DropDown, function(value)
    return value == self.value
  end, function(value)
    self.value = value
  end, unpack(entries))
end

function AuctionatorDropDownMixin:SetValue(...)
  self.value = ...
  self.DropDown:GenerateMenu()
end

function AuctionatorDropDownMixin:GetValue(...)
  return self.value
end
