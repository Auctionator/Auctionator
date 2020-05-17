AuctionatorConfigHorizontalRadioButtonGroupMixin = CreateFromMixins(AuctionatorConfigRadioButtonGroupMixin)

function AuctionatorConfigHorizontalRadioButtonGroupMixin:SetupRadioButtons()
  local children = { self:GetChildren() }
  local size = 0

  for _, child in ipairs(children) do
    if child.isAuctionatorRadio then
      table.insert(self.radioButtons, child)

      child:SetPoint("TOPLEFT", 0, size * -1)
      child.RadioButton.Label:SetPoint("TOPLEFT", 20, -2)

      child.onSelectedCallback = function()
        self:RadioSelected(child)
      end
    end

    size = size + (child:GetHeight() or 20)
  end

  -- 8 is for bottom padding
  self:SetHeight(size + 8)
end