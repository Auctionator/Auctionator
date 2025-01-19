AuctionatorFilterKeySelectorMixin = {}

function AuctionatorFilterKeySelectorMixin:OnLoad()
  self.displayText = ""
  self.selectedCategory = {}
  self.onEntrySelected = function() end
  self.ResetButton:SetClickCallback(function()
    self:Reset()
  end)

  self.DropDown = CreateFrame("DropdownButton", nil, self, "WowStyle1DropdownTemplate")
  self.DropDown:SetPoint("TOPLEFT", 20, 0)
  self.DropDown:SetWidth(280)

  self.DropDown:SetupMenu(function(dropdown, rootDescription)
    self:InitializeLevels(rootDescription, 1, AuctionCategories)
  end)
end

function AuctionatorFilterKeySelectorMixin:GetValue()
  return self.displayText
end

function AuctionatorFilterKeySelectorMixin:SetValue(value)
  if value == nil then
    value = ""
  end

  self.displayText = value
  self.onEntrySelected(value)
  self.selectedCategory = {strsplit("/", value)}
  self.DropDown:GenerateMenu()
end

function AuctionatorFilterKeySelectorMixin:Reset()
  self.displayText = ""
  self.selectedCategory = {}
  self.DropDown:GenerateMenu()
end

function AuctionatorFilterKeySelectorMixin:SetOnEntrySelected(callback)
  self.onEntrySelected = callback
end

function AuctionatorFilterKeySelectorMixin:EntrySelected(displayText)
  self:SetValue(displayText)
  self.DropDown:CloseMenu()
end

function AuctionatorFilterKeySelectorMixin:InitializeLevels(rootDescription, level, allCategories, prefix)
  if allCategories == nil then
    return
  end

  prefix = prefix or ""

  for _, category in ipairs(allCategories) do 
    if not category:HasFlag("WOW_TOKEN_FLAG") and not category.implicitFilter then
      local key = prefix .. category.name
      local desc = rootDescription:CreateRadio(category.name, function()
        local terms = {strsplit("/", key)}
        for i = 1, level do
          if terms[i] ~= self.selectedCategory[i] then
            return false
          end
        end
        return true
      end, function()
        self:EntrySelected(key)
      end)

      if category.subCategories ~= nil then
        local newPrefix = key .. "/"
        self:InitializeLevels(desc, level + 1, category.subCategories, newPrefix)
      end
    end
  end
end
