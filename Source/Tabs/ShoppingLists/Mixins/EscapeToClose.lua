AuctionatorEscapeToCloseMixin = {}

function AuctionatorEscapeToCloseMixin:OnKeyDown(key)
  self:SetPropagateKeyboardInput(key ~= "ESCAPE")
end

function AuctionatorEscapeToCloseMixin:OnKeyUp(key)
  Auctionator.Debug.Message("AuctionatorEscapeToCloseMixin:OnKeyUp()", key)

  if key == "ESCAPE" then
    self:Hide()
  end
end
