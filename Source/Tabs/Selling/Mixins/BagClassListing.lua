AuctionatorBagClassListingMixin = {}

local ROW_LENGTH = 5

function AuctionatorBagClassListingMixin:OnLoad()
  self.items = {}
  self.buttons = {}

  self.title = GetItemClassInfo(self.classId)
  self:UpdateTitle()
  self:SetHeight(self.SectionTitle:GetHeight())
  self.SectionTitle:SetWidth(self:GetRowWidth())

  self.buttonNamePrefix = self.title .. "Item"
  self:CreateEmptyButtons()
end

function AuctionatorBagClassListingMixin:CreateEmptyButtons()
  self.emptyButtons = {}
  local frame

  for count = 1, ROW_LENGTH - 1 do
    frame = CreateFrame("Frame", self.buttonNamePrefix .. "Empty" .. count, self.ItemContainer, "AuctionatorBagItem")
    frame:Hide()

    table.insert(self.emptyButtons, frame)
  end
end

function AuctionatorBagClassListingMixin:Reset()
  self.items = {}
  self.buttons = {}
end

function AuctionatorBagClassListingMixin:GetRowWidth()
  return ROW_LENGTH * 42
end

function AuctionatorBagClassListingMixin:UpdateTitle()
  self.SectionTitle:SetText(self.title .. " (" .. #self.items .. ")")
end

function AuctionatorBagClassListingMixin:AddItem(item)
  local button = CreateFrame("Frame", self.buttonNamePrefix .. #self.items, self.ItemContainer, "AuctionatorBagItem")
  button:SetItemInfo(item)

  table.insert(self.buttons, button)
  table.insert(self.items, item)

  self:UpdateTitle()
  self:DrawButtons()
end

function AuctionatorBagClassListingMixin:DrawButtons()
  local rows = 1
  local lastButton

  for _, button in ipairs(self.emptyButtons) do
    button:ClearAllPoints()
    button:Hide()
  end

  for index, button in ipairs(self.buttons) do
    lastButton = button

    if index == 1 then
      button:SetPoint("TOPLEFT", self.ItemContainer, "TOPLEFT", 0, -2)
    elseif (index % (ROW_LENGTH + 1)) == 0 then
      rows = rows + 1
      button:SetPoint("TOPLEFT", self.buttons[index - ROW_LENGTH], "BOTTOMLEFT")
    else
      button:SetPoint("TOPLEFT", self.buttons[index - 1], "TOPRIGHT")
    end
  end

  if (#self.buttons % ROW_LENGTH) ~= 0 then
    local emptyCount = ROW_LENGTH - (#self.buttons % ROW_LENGTH)

    for count = 1, emptyCount do
      self.emptyButtons[count]:SetPoint("TOPLEFT", lastButton, "TOPRIGHT")
      self.emptyButtons[count]:Show()

      lastButton = self.emptyButtons[count]
    end
  end

  self.ItemContainer:SetSize( self.buttons[1]:GetWidth() * 3, rows * 42 + 2)

  self:SetSize(42 * ROW_LENGTH, self.ItemContainer:GetHeight() + self.SectionTitle:GetHeight())
end

function AuctionatorBagClassListingMixin:OnEnter()
  -- Something wrong with texture on enter (is not contained by button), leaving for now
end

function AuctionatorBagClassListingMixin:OnLeave()
  -- Something wrong with texture on enter (is not contained by button), leaving for now
end

function AuctionatorBagClassListingMixin:OnClick()
  if self.ItemContainer:IsVisible() then
    self:SetHeight(self.SectionTitle:GetHeight())
    self.ItemContainer:Hide()
  else
    self:SetHeight(self.ItemContainer:GetHeight() + self.SectionTitle:GetHeight())
    self.ItemContainer:Show()
  end
end
