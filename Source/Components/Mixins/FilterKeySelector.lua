AuctionatorFilterKeySelectorMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function AuctionatorFilterKeySelectorMixin:OnLoad()
  self.displayText = ""
  self.onEntrySelected = function() end
  self.ResetButton:SetClickCallback(function()
    self:Reset()
  end)

  LibDD:Create_UIDropDownMenu(self)
  LibDD:UIDropDownMenu_SetWidth(self, 180)

  LibDD:UIDropDownMenu_SetInitializeFunction(self, function(_, level, menuList)
    if level == 1 then
      self:InitializeLevels(level, AuctionCategories, true)
    elseif menuList ~= nil then
      self:InitializeLevels(level, menuList.subCategories, menuList.rootChecked, menuList.prefix)
    end
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
  LibDD:UIDropDownMenu_SetText(self, value)
end

function AuctionatorFilterKeySelectorMixin:Reset()
  self.displayText = ""
  self.selectedCategory = {}
  LibDD:UIDropDownMenu_SetText(self, "")
end

function AuctionatorFilterKeySelectorMixin:SetOnEntrySelected(callback)
  self.onEntrySelected = callback
end

function AuctionatorFilterKeySelectorMixin:EntrySelected(displayText)
  self:SetValue(displayText)
  LibDD:CloseDropDownMenus()
end

function AuctionatorFilterKeySelectorMixin:InitializeLevels(level, allCategories, rootChecked, prefix)
  if allCategories == nil then
    return
  end

  local name
  local info = LibDD:UIDropDownMenu_CreateInfo()
  prefix = prefix or ""

  info.hasArrow = true
  info.func = function(_, displayText)
    self:EntrySelected(displayText)
  end

  for _, category in ipairs(allCategories) do 
    if not category:HasFlag("WOW_TOKEN_FLAG") and not category.implicitFilter then
      info.hasArrow = category.subCategories ~= nil

      info.text = category.name
      info.arg1 = prefix .. category.name
      info.checked = rootChecked and info.text == self.selectedCategory[level]

      info.menuList = {
        prefix = info.arg1 .. "/",
        subCategories = category.subCategories,
        rootChecked = info.checked
      }
      LibDD:UIDropDownMenu_AddButton(info, level)
    end
  end
end
