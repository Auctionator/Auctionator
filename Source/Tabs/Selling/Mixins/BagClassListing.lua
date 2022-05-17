AuctionatorBagClassListingMixin = {}

function AuctionatorBagClassListingMixin:Init(classID)
  if self.title == nil and classID ~= nil then
    self.title = GetItemClassInfo(classID)
  end

  self:UpdateTitle()
  self:SetHeight(self.SectionTitle:GetHeight())

  self.SectionTitle:SetWidth(self:GetRowWidth())

  if Auctionator.Constants.IsClassic then
    self.SectionTitle:GetNormalTexture():SetWidth(self:GetRowWidth() + 8)
    self.SectionTitle:GetFontString():SetPoint("LEFT", 12, 0)
    self.SectionTitle:GetHighlightTexture():SetSize(self:GetRowWidth() + 9, self.SectionTitle:GetHeight())
  else
    self.SectionTitle.NormalTexture:SetWidth(self:GetRowWidth() + 8)
    self.SectionTitle.Text:SetPoint("LEFT", 12, 0)
    self.SectionTitle.HighlightTexture:SetSize(self:GetRowWidth() + 9, self.SectionTitle:GetHeight())
  end

  self.collapsed = false

  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED) then
    self.collapsed = true
    self.ItemContainer:Hide()
  end
end

function AuctionatorBagClassListingMixin:GetRowWidth()
  return self.ItemContainer:GetRowWidth()
end

function AuctionatorBagClassListingMixin:GetTitleHeight()
  return self.SectionTitle:GetHeight()
end

function AuctionatorBagClassListingMixin:Reset()
  self.ItemContainer:Reset()
end

function AuctionatorBagClassListingMixin:UpdateTitle()
  self.SectionTitle:SetText(self.title .. " (" .. self.ItemContainer:GetNumItems() .. ")")
end

function AuctionatorBagClassListingMixin:AddItems(itemList)
  self.ItemContainer:AddItems(itemList)

  self:UpdateTitle()
  self:UpdateForCollapsing()
  self:UpdateForEmpty()
end

function AuctionatorBagClassListingMixin:UpdateForCollapsing()
  if self.collapsed then
    self.ItemContainer:Hide()
    self:SetHeight(self.SectionTitle:GetHeight())
  else
    self.ItemContainer:Show()
    self:SetHeight(self.ItemContainer:GetHeight() + self.SectionTitle:GetHeight())
  end
end

-- Hide the frame if there are no buttons in it.
-- Anchors are updated to ensure a blank space isn't left behind
function AuctionatorBagClassListingMixin:UpdateForEmpty()
  -- Get the TOPLEFT anchor and its relative frame
  local relativeTo, relativePoint
  for i = 1, self:GetNumPoints() do
    local point = {self:GetPoint(1)}
    if point[1] == "TOPLEFT" then
      relativeTo = point[2]
      relativePoint = point[3]
      break
    end
  end

  -- Shift the title up slightly
  if self.ItemContainer:GetNumItems() == 0 then
    self:SetPoint("TOPLEFT", relativeTo, relativePoint, 0, self:GetTitleHeight())
    self:SetPoint("RIGHT", self:GetParent(), "RIGHT")
    self:Hide()
  else
    self:SetPoint("TOPLEFT", relativeTo, relativePoint, 0, 0)
    self:SetPoint("RIGHT", self:GetParent(), "RIGHT")
    self:Show()
  end
end

function AuctionatorBagClassListingMixin:OnClick()
  self.collapsed = not self.collapsed

  self:UpdateForCollapsing()
end
