local function SearchItem(text)
  if text == nil or AuctionatorShoppingListFrame == nil or not AuctionatorShoppingListFrame:IsVisible() then
    return false
  end

  local name = Auctionator.Utilities.GetNameFromLink(text)

  if name == nil then
    name = text
  end

  AuctionatorShoppingListFrame.OneItemSearchBox:SetText(name)
  AuctionatorShoppingListFrame.OneItemSearchButton:Click()

  return true
end

local prevChatEdit_InsertLink = ChatEdit_InsertLink

ChatEdit_InsertLink = function(text)
  return prevChatEdit_InsertLink(text) or SearchItem(text)
end
