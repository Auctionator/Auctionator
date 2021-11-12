AuctionatorScrollListLineMixin = CreateFromMixins(
  AuctionatorRetailImportScrollListLineMixin,
  AuctionatorRetailImportTableBuilderRowMixin
)

function AuctionatorScrollListLineMixin:DeleteItem()
end

function AuctionatorScrollListLineMixin:UpdateDisplay()
  self.Text:SetText(Auctionator.Search.PrettifySearchString(self.searchTerm))
end

function AuctionatorScrollListLineMixin:Populate(searchTerm, dataIndex)
  self.LastSearchedHighlight:Hide()
  self.searchTerm = searchTerm
  self.dataIndex = dataIndex
end

local function ComposeTooltip(searchTerm)
  local tooltipDetails = Auctionator.Search.ComposeTooltip(searchTerm)

  GameTooltip:SetText(tooltipDetails.title, 1, 1, 1, 1)

  for _, line in ipairs(tooltipDetails.lines) do
    if line[2] == AUCTIONATOR_L_ANY_LOWER then
      -- Faded line when no filter set
      GameTooltip:AddDoubleLine(line[1], line[2], 0.4, 0.4, 0.4, 0.4, 0.4, 0.4)

    else
      GameTooltip:AddDoubleLine(
        line[1],
        WHITE_FONT_COLOR:WrapTextInColorCode(line[2])
      )
    end
  end
end

function AuctionatorScrollListLineMixin:ShowTooltip()
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  ComposeTooltip(self.searchTerm)
  GameTooltip:Show()
end

function AuctionatorScrollListLineMixin:HideTooltip()
  GameTooltip:Hide()
end

function AuctionatorScrollListLineMixin:OnEnter()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  self:ShowTooltip()
end

function AuctionatorScrollListLineMixin:OnLeave()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  self:HideTooltip()
end

function AuctionatorScrollListLineMixin:OnSelected()
  error("Need to override")
end
