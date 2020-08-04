AuctionatorConfigHorizontalRadioButtonGroupMixin = CreateFromMixins(AuctionatorConfigRadioButtonGroupMixin)

function AuctionatorConfigHorizontalRadioButtonGroupMixin:SetupRadioButtons()
  local children = { self:GetChildren() }
  local size = 65

  self.GroupHeading:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -5)

  for _, child in ipairs(children) do
    if child.isAuctionatorRadio then
      table.insert(self.radioButtons, child)

      child:SetPoint("LEFT", size, 0)
      child.RadioButton.Label:SetPoint("TOPLEFT", 20, -2)

      child.onSelectedCallback = function()
        self:RadioSelected(child)
      end

      -- Hacky; only works for strings < 50 in width
      size = size + 50
    end
  end

  -- 8 is for bottom padding
  self:SetSize(size, 28)
end