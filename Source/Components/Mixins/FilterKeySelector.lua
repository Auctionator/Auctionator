AuctionatorFilterKeySelectorMixin = {}

function AuctionatorFilterKeySelectorMixin:OnLoad()
  self.displayText = ""
  self.onEntrySelected = function() end
  self.ResetButton:SetClickCallback(function()
    self:Reset()
  end)

  UIDropDownMenu_SetWidth(self, 180)

  UIDropDownMenu_Initialize(self, function(_, level, menuList)
    if level == 1 then
      self:InitializePrimaryClasses()
    elseif level == 2 then
      self:InitializeSecondaryClasses(menuList)
    elseif level == 3 then
      self:InitializeArmorSlots(menuList)
    end
  end, "taint prevention")
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
  UIDropDownMenu_SetText(self, value)
end

function AuctionatorFilterKeySelectorMixin:Reset()
  self.displayText = ""
  self.selectedCategory = {}
  UIDropDownMenu_SetText(self, "")
end

function AuctionatorFilterKeySelectorMixin:SetOnEntrySelected(callback)
  self.onEntrySelected = callback
end

function AuctionatorFilterKeySelectorMixin:EntrySelected(displayText)
  self:SetValue(displayText)
  CloseDropDownMenus()
end

function AuctionatorFilterKeySelectorMixin:InitializePrimaryClasses()
  local name
  local info = UIDropDownMenu_CreateInfo()

  info.hasArrow = true
  info.func = function(_, displayText)
    self:EntrySelected(displayText)
  end

  for _, classId in ipairs(Auctionator.Constants.ValidItemClassIDs) do
    name = GetItemClassInfo(classId)
    if name ~= nil then
      info.text = name
      info.arg1 = name
      info.menuList = {
        name = name,
        classId = classId,
        subClasses = Auctionator.AH.GetAuctionItemSubClasses(classId)
      }
      if self.selectedCategory[1] ~= nil then
        info.checked = info.arg1 == self.selectedCategory[1]
      else
        info.checked = false
      end

      UIDropDownMenu_AddButton(info)
    end
  end
end

function AuctionatorFilterKeySelectorMixin:InitializeSecondaryClasses(menuList)
  local name
  local info = UIDropDownMenu_CreateInfo()

  info.func = function(_, displayText)
    self:EntrySelected(displayText)
  end

  for _, subClassId in ipairs(menuList.subClasses) do
    name = GetItemSubClassInfo(menuList.classId, subClassId)

    info.text = name
    info.arg1 = menuList.name .. "/" .. name

    if menuList.classId == Enum.ItemClass.Armor then
      info.hasArrow = true
      info.menuList = {
        name = menuList.name .. "/" .. name,
        classId = menuList.classId,
        subClassId = subClassId,
        slots = Auctionator.Constants.INVENTORY_TYPE_IDS
      }
    end

    if self.selectedCategory[2] ~= nil then
      info.checked = info.arg1 == (self.selectedCategory[1] .. "/" .. self.selectedCategory[2])
    else
      info.checked = false
    end

    UIDropDownMenu_AddButton(info, 2)
  end
end

function AuctionatorFilterKeySelectorMixin:InitializeArmorSlots(menuList)
  local name
  local info = UIDropDownMenu_CreateInfo()

  info.func = function(_, displayText)
    self:EntrySelected(displayText)
  end

  for _, armorSlotId in ipairs(Auctionator.Constants.INVENTORY_TYPE_IDS) do
    name = GetItemInventorySlotInfo(armorSlotId)

    info.text = name
    info.arg1 = menuList.name .. "/" .. name

    info.value = {
      classId = menuList.classId,
      subClassId = menuList.subClassId,
      armorSlotId = armorSlotId
    }

    if self.selectedCategory[3] ~= nil then
      info.checked = info.arg1 == (self.selectedCategory[1] .. "/" .. self.selectedCategory[2] .. "/" .. self.selectedCategory[3])
    else
      info.checked = false
    end

    UIDropDownMenu_AddButton(info, 3)
  end
end
