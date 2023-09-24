SB2BagViewSectionMixin = {}

function SB2BagViewSectionMixin:Reset()
  self.col = 0
  self.row = 0
  self.collapsed = false
  self.buttons = {}
  if not self.rowWidth then
    self.rowWidth = math.ceil(6 * Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_ICON_SIZE] / Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
  end
  self.iconSize = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE)
end

function SB2BagViewSectionMixin:AddButton(button)
  table.insert(self.buttons, button)
  button:SetPoint("TOPLEFT", self, self.insetLeft + self.col * self.iconSize, -self.sectionTitleHeight - (self.row * self.iconSize))
  button:SetShown(not self.collapsed)
  self.col = self.col + 1

  if self.col == self.rowWidth then
    self.col = 0
    self.row = self.row + 1
  end
end

function SB2BagViewSectionMixin:AnyButtons()
  return self.col ~= 0 or self.row ~= 0
end

function SB2BagViewSectionMixin:ToggleOpen()
  if not self.collapsable then
    return
  end

  self.collapsed = not self.collapsed
  for _, button in ipairs(self.buttons) do
    button:SetShown(not self.collapsed)
  end
  SB2.CallbackRegistry:TriggerEvent("BagViewSectionToggled")
end

function SB2BagViewSectionMixin:UpdateHeight()
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

function SB2BagViewSectionMixin:SetName(name, isCustom)
  self.SectionTitle:SetText(_G["AUCTIONATOR_L_" .. name] or name)
  self.name = name
  self.isCustom = isCustom
end
