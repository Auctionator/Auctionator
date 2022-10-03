local function SearchItem(text)
  if text == nil or AuctionatorShoppingFrame == nil or not AuctionatorShoppingFrame:IsVisible() then
    return false
  end

  C_Timer.After(0, function()
    StackSplitFrame:Hide()
  end)

  local name = Auctionator.Utilities.GetNameFromLink(text)

  if name == nil then
    name = text
  end

  AuctionatorShoppingFrame.OneItemSearchBox:SetText("\"" .. name .. "\"")
  AuctionatorShoppingFrame.OneItemSearchButton:Click()

  return true
end

-- We would replace ChatEdit_InsertLink so that the return value is used, but
-- that causes a taint error when attempting to buy vendor items with the stack
-- selection dialog (to replicate, when ChatEdit_InsertLink is manually
-- replaced, hold down "c" while pressing [Enter] with the stack dialog open)
hooksecurefunc(_G, "ChatEdit_InsertLink", function(text)
  SearchItem(text)
end)
