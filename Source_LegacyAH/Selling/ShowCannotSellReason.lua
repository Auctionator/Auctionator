function Auctionator.Selling.ShowCannotSellReason(location)
  local currentDurability, maxDurability
  if location:IsBagAndSlot() then
    if C_Container then
      currentDurability, maxDurability = C_Container.GetContainerItemDurability(location:GetBagAndSlot())
    else
      currentDurability, maxDurability = GetContainerItemDurability(location:GetBagAndSlot())
    end
  elseif location:IsEquipmentSlot() then
    currentDurability, maxDurability = GetInventoryItemDurability(location:GetBagAndSlot())
  end

  if currentDurability ~= maxDurability then
    UIErrorsFrame:AddMessage(ERR_AUCTION_REPAIR_ITEM, 1.0, 0.1, 0.1, 1.0)
  elseif not Auctionator.Utilities.IsAtMaxCharges(location) then
    UIErrorsFrame:AddMessage(ERR_AUCTION_USED_CHARGES, 1.0, 0.1, 0.1, 1.0)
  elseif C_Item.IsBound(location) then
    UIErrorsFrame:AddMessage(ERR_AUCTION_BOUND_ITEM, 1.0, 0.1, 0.1, 1.0)
  end
end
