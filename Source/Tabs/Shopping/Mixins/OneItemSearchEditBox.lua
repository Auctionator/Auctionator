AuctionatorShoppingOneItemSearchEditBoxMixin = {}

function AuctionatorShoppingOneItemSearchEditBoxMixin:OnTextChanged(isUserInput)
  if isUserInput then
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

    for _, list in ipairs(Auctionator.Shopping.Lists.Data) do
      for _, search in ipairs(list.items) do
        if CompareSearch(search) then
          return
        end
      end
    end
  end
end
