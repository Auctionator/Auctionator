AuctionatorBagViewSectionMixin = {}

function AuctionatorBagViewSectionMixin:Reset()
  self.col = 0
  self.row = 0
  self.collapsed = false
  self.buttons = {}
  self.rowWidth = math.floor(self:GetParent():GetWidth() / Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
  self.iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)
  self.SectionTitle:SetPoint("TOPLEFT", self.insetLeft, 0)
end

function AuctionatorBagViewSectionMixin:AddButton(button)
  table.insert(self.buttons, button)
  button:SetPoint("TOPLEFT", self, self.insetLeft + self.col * self.iconSize, -self.sectionTitleHeight - (self.row * self.iconSize))
  button:SetShown(not self.collapsed)
  self.col = self.col + 1

  if self.col == self.rowWidth then
    self.col = 0
    self.row = self.row + 1
  end
end

function AuctionatorBagViewSectionMixin:AnyButtons()
  return self.col ~= 0 or self.row ~= 0
end

function AuctionatorBagViewSectionMixin:ToggleOpen(doNotNotify)
  if not self.collapsable then
    return
  end

  self.collapsed = not self.collapsed

  for _, button in ipairs(self.buttons) do
    button:SetShown(not self.collapsed)
  end

  if not doNotNotify then
    -- Need to update heights
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagViewSectionToggled")
  end
end

function AuctionatorBagViewSectionMixin:UpdateHeight()
  local newHeight
  if self.collapsed then
    newHeight = self.sectionTitleHeight
  else
    if self.col == 0 then
      newHeight = self.row * self.iconSize + self.sectionTitleHeight
    else
      newHeight = (self.row + 1) * self.iconSize + self.sectionTitleHeight
    end
  end
  self:SetHeight(newHeight + self.paddingBottom)
end

function AuctionatorBagViewSectionMixin:SetName(name, isCustom)
  if self.SectionTitle then
    self.SectionTitle:SetText(_G["AUCTIONATOR_L_" .. name] or name)
  end
  self.name = name
  self.isCustom = isCustom
end
