AuctionatorBagItemContainerMixin = {}

function AuctionatorBagItemContainerMixin:OnLoad()
  self.iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)

  self.items = {}
  self.buttons = {}
  self.buttonPool = CreateAndInitFromMixin(Auctionator.Utilities.PoolMixin)
  self.buttonPool:SetCreator(function()
    local button = CreateFrame("Button", nil, self, "AuctionatorBagItem")
    button:SetSize(self.iconSize, self.iconSize)

    return button
  end)
end

function AuctionatorBagItemContainerMixin:Reset()
  self.items = {}

  for _, item in ipairs(self.buttons) do
    item:Hide()
    self.buttonPool:Return(item)
  end

  self.buttons = {}
end

function AuctionatorBagItemContainerMixin:GetRowLength()
  return math.floor(250/self.iconSize)
end

function AuctionatorBagItemContainerMixin:GetRowWidth()
  return self:GetRowLength() * self.iconSize
end

function AuctionatorBagItemContainerMixin:AddItems(itemList)
  for _, item in ipairs(itemList) do
    self:AddItem(item)
  end

  self:DrawButtons()
end

function AuctionatorBagItemContainerMixin:AddItem(item)
  local button = self.buttonPool:Get()

  button:Show()

  button:SetItemInfo(item)

  table.insert(self.buttons, button)
  table.insert(self.items, item)
end

function AuctionatorBagItemContainerMixin:DrawButtons()
  local rows = 1

  for index, button in ipairs(self.buttons) do
    if index == 1 then
      button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -2)
    elseif ((index - 1) % self:GetRowLength()) == 0 then
      rows = rows + 1
      button:SetPoint("TOPLEFT", self.buttons[index - self:GetRowLength()], "BOTTOMLEFT")
    else
      button:SetPoint("TOPLEFT", self.buttons[index - 1], "TOPRIGHT")
    end
  end

  if #self.buttons > 0 then
    self:SetSize(self.buttons[1]:GetWidth() * 3, rows * self.iconSize + 2)
  else
    self:SetSize(0, 0)
  end

  self:SetSize(self.iconSize * self:GetRowLength(), self:GetHeight())
end

function AuctionatorBagItemContainerMixin:GetNumItems()
  return #self.items
end
