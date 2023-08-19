AuctionatorBagItemContainerMixin = {}

function AuctionatorBagItemContainerMixin:OnLoad()
  self.iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)

  self.buttons = {}
  self.buttonPool = CreateFramePool("Button", self, "AuctionatorBagItem", FramePool_HideAndClearAnchors, false)
end

function AuctionatorBagItemContainerMixin:Reset()
  self.buttons = {}

  self.buttonPool:ReleaseAll()
end

function AuctionatorBagItemContainerMixin:GetRowLength()
  return math.floor(250/self.iconSize)
end

function AuctionatorBagItemContainerMixin:GetRowWidth()
  return self:GetRowLength() * self.iconSize
end

function AuctionatorBagItemContainerMixin:GetSelectedButton()
  return self.selectedButton
end

function AuctionatorBagItemContainerMixin:AddItems(itemList)
  self.selectedButton = nil
  for _, item in ipairs(itemList) do
    self:AddItem(item)
  end

  self:DrawButtons()
end

function AuctionatorBagItemContainerMixin:AddItem(item)
  local button = self.buttonPool:Acquire()

  button:Show()

  button:SetItemInfo(item)

  -- Note: We set the size here rather than in a frame pool initialization
  -- function because the initialization function doesn't work on classic era
  button:SetSize(self.iconSize, self.iconSize)

  table.insert(self.buttons, button)

  if item.selected then
    self.selectedButton = button
  end
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
  return #self.buttons
end
