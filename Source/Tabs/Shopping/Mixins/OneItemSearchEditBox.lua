AuctionatorShoppingOneItemSearchEditBoxMixin = {}

function AuctionatorShoppingOneItemSearchEditBoxMixin:OnTextChanged(isUserInput)
  if isUserInput and not self:IsInIMECompositionMode() then
    local current = self:GetText():lower()
    if current == "" or (self.prevCurrent ~= nil and #self.prevCurrent >= #current) then
      self.prevCurrent = current
      return
    end
    self.prevCurrent = current

    local function CompareSearch(toCompare)
      if toCompare:lower():sub(1, #current) == current then
        local split = Auctionator.Search.SplitAdvancedSearch(toCompare)
        local searchString = split.searchString
        if split.isExact then
          searchString = "\"" .. searchString .. "\""
        end
        self:SetText(searchString)
        self:SetCursorPosition(#current)
        self:HighlightText(#current, #searchString)
        return true
      else
        return false
      end
    end

    for _, recent in ipairs(Auctionator.Shopping.Recents.GetAll()) do
      if CompareSearch(recent) then
        return
      end
    end

    for i = 1, Auctionator.Shopping.ListManager:GetCount() do
      local list = Auctionator.Shopping.ListManager:GetByIndex(i)
      for j = 1, list:GetItemCount() do
        local search = list:GetItemByIndex(j)
        if CompareSearch(search) then
          return
        end
      end
    end
  end
end
