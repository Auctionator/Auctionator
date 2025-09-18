AuctionatorCellMixin = {}

function AuctionatorCellMixin:Populate(rowData, index)
  self.rowData = rowData
  self.index = index
end

function AuctionatorCellMixin:OnEnter()
  if self:GetParent().OnEnter ~= nil then
    self:GetParent():OnEnter()
  end
end

function AuctionatorCellMixin:OnLeave()
  if self:GetParent().OnLeave ~= nil then
    self:GetParent():OnLeave()
  end
end

function AuctionatorCellMixin:OnClick(...)
  if self:GetParent().OnClick ~= nil then
    self:GetParent():OnClick(...)

    Auctionator.Debug.Message("index", self.index)

  end
end
