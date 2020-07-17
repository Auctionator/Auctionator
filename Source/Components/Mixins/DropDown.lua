AuctionatorDropDownMixin = {}

function AuctionatorDropDownMixin:Initialize(text, values)
  self.text = text
  self.values = values
  self.value = self.values[1]

  UIDropDownMenu_Initialize(self, self.BlizzInitialize, "taint prevention")
  UIDropDownMenu_SetWidth(self, self:GetWidth())
end

function AuctionatorDropDownMixin:BlizzInitialize()
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

function AuctionatorDropDownMixin:GetValue()
  return self.value
end

function AuctionatorDropDownMixin:SetValue(newValue)
  for index, value in ipairs(self.values) do
    if newValue == value then
      UIDropDownMenu_SetText(self, self.text[index])
      break
    end
  end

  self.value = newValue
end
