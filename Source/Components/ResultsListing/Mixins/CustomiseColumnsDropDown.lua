AuctionatorCustomiseColumnsDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function AuctionatorCustomiseColumnsDropDownMixin:OnLoad()
  LibDD:Create_UIDropDownMenu(self)
  LibDD:UIDropDownMenu_SetInitializeFunction(self, AuctionatorCustomiseColumnsDropDownMixin.Initialize)
  LibDD:UIDropDownMenu_SetDisplayMode(self, "MENU")
end

function AuctionatorCustomiseColumnsDropDownMixin:Callback(columns, hideStates, applyChanges)
  self.columns = columns
  self.hideStates = hideStates
  self.applyChanges = applyChanges

  self:Toggle()
end

function AuctionatorCustomiseColumnsDropDownMixin:MoreThanOneVisible()
  local count = 0
  for _, column in ipairs(self.columns) do
    if not self.hideStates[column.headerText] then
      count = count + 1
    end
  end

  return count >= 2
end

function AuctionatorCustomiseColumnsDropDownMixin:Initialize()
  if not self.columns then
    LibDD:HideDropDownMenu(1)
    return
  end

  for _, column in ipairs(self.columns) do
    local info = LibDD:UIDropDownMenu_CreateInfo()
    info.text = column.headerText
    info.isNotRadio = true
    info.checked = not self.hideStates[column.headerText]
    info.disabled = false
    info.func = (function(column)
      return function()
        self.hideStates[column.headerText] = self:MoreThanOneVisible() and not self.hideStates[column.headerText]
        self.applyChanges()
      end
      end)(column)
    LibDD:UIDropDownMenu_AddButton(info)
  end
end

function AuctionatorCustomiseColumnsDropDownMixin:Toggle()
  LibDD:ToggleDropDownMenu(1, nil, self, "cursor", 0, 0)
end
