local function SearchItem(text)
  if text == nil or AuctionatorShoppingFrame == nil or not AuctionatorShoppingFrame:IsVisible() then
    return false
  end

  C_Timer.After(0, function()
    StackSplitFrame:Hide()
  end)

  -- Borrowed from Blizzard ChatEdit_InsertLink to avoid inserting textures with
  -- DF reagent links
  local name;
  if ( strfind(text, "battlepet:") ) then
    local petName = strmatch(text, "%[(.+)%]");
    name = petName;
  elseif ( strfind(text, "item:", 1, true) ) then
    name = GetItemInfo(text);
  end
  if not name then
    name = text
  end

  if name == nil then
    name = text
  end

  -- Non-exact with enchants as the name doesn't match exactly
  if text:match("enchant:") then
    AuctionatorShoppingFrame.OneItemSearchBox:SetText(name)
  else
    AuctionatorShoppingFrame.OneItemSearchBox:SetText("\"" .. name .. "\"")
  end
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
