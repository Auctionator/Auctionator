-- This is called when mousing over an item in your bags
hooksecurefunc (GameTooltip, "SetBagItem",
  function(tip, bag, slot)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)

    if itemLocation:IsValid() then
      local itemId = C_Item.GetItemID(itemLocation)
      local itemCount = C_Item.GetStackCount(itemLocation)

      if itemId ~= nil then
        Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
      end
    end
  end
);

-- This is called when mousing over an item in a merchant window (Buyback Pane)
hooksecurefunc (GameTooltip, "SetBuybackItem",
  function(tip, slotIndex)
    local itemId = C_MerchantFrame.GetBuybackItemID(slotIndex)
    local _, _, _, itemCount = GetBuybackItemInfo(slotIndex);

    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over an item in a merchant window (Merchant Pane)
hooksecurefunc (GameTooltip, "SetMerchantItem",
  function(tip, index)
    local itemId = GetMerchantItemID(index)
    local _, _, _, itemCount = GetMerchantItemInfo(index);

    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over an item in your bank, or a bag in your bag list
hooksecurefunc (GameTooltip, "SetInventoryItem",
  function(tip, unit, slot)
    local itemId = GetInventoryItemID(unit, slot)
    local itemCount = GetInventoryItemCount(unit, slot)

    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount ~= 0 and itemCount or 1)
    end
  end
);

-- This is called when mousing over an item in your guild bank
hooksecurefunc (GameTooltip, "SetGuildBankItem",
  function(tip, tab, slot)
    local itemLink = GetGuildBankItemLink(tab, slot)
    local _, itemCount = GetGuildBankItemInfo(tab, slot)

    if itemLink ~= nil then
      local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

      if itemId ~= nil then
        Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
      end
    end
  end
);

-- This is called when mousing over the result item on a recipe page in the tradeskill window
hooksecurefunc( GameTooltip, 'SetRecipeResultItem',
  function(tip, recipeResultItemId)
    local itemLink = C_TradeSkillUI.GetRecipeItemLink(recipeResultItemId)
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

    local itemCount  = C_TradeSkillUI.GetRecipeNumItemsProduced(recipeResultItemId)

    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over a reagant item on a recipe page in the tradeskill window
hooksecurefunc( GameTooltip, 'SetRecipeReagentItem',
  function( tip, reagentId, index )
    local itemLink = C_TradeSkillUI.GetRecipeReagentItemLink(reagentId, index)
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

    if itemId ~= nil then
      local itemCount = select(3, C_TradeSkillUI.GetRecipeReagentInfo(reagentId, index))

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over an item in the loot window
hooksecurefunc (GameTooltip, "SetLootItem",
  function (tip, slot)
    if LootSlotHasItem(slot) then
      local itemLink, _, itemCount = GetLootSlotLink(slot);
      local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

      if itemId ~= nil then
        Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
      end
    end
  end
);

-- TODO Haven't tested this so making an educated guess:
-- This is called when mousing over an item in the loot roll window
hooksecurefunc (GameTooltip, "SetLootRollItem",
  function (tip, slot)
    local itemLink = GetLootRollItemLink(slot)
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

    if itemId ~= nil then
      local _, _, itemCount = GetLootRollItemInfo(slot)

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over an item in a quest window
hooksecurefunc (GameTooltip, "SetQuestItem",
  function (tip, type, index)
    local itemLink = GetQuestItemLink(type, index)
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

    if itemId ~= nil then
      local _, _, itemCount = GetQuestItemInfo(type, index);

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over an item in a quest description in your quest log
hooksecurefunc (GameTooltip, "SetQuestLogItem",
  function (tip, type, index)
    local itemLink = GetQuestLogItemLink(type, index)
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)
    if itemId ~= nil then
      local itemCount;
      if type == "choice" then
        _, _, itemCount = GetQuestLogChoiceInfo(index);
      else
        _, _, itemCount = GetQuestLogRewardInfo(index)
      end

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This is called when mousing over an item in the send mail window
hooksecurefunc (GameTooltip, "SetSendMailItem",
  function (tip, id)
    local _, itemId, _, itemCount = GetSendMailItem(id)
    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- This occurs when:
-- 1. mousing over an item in the Open Mail frame
-- 2. mousing over an item in the Inbox frame
hooksecurefunc (GameTooltip, "SetInboxItem",
  function(tip, index, attachIndex)
    if AUCTIONATOR_SHOW_MAILBOX_TIPS == 1 then
      local attachmentIndex = attachIndex or 1

      local itemLink = GetInboxItemLink(index, attachmentIndex)
      local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)
      if itemId ~= nil then
        local _, _, _, itemCount = GetInboxItem(index, attachmentIndex);

        Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
      end
    end
  end
);

-- This occurs when mousing over an item in the Inbox frame
hooksecurefunc("InboxFrameItem_OnEnter",
  function(self)
    local itemCount = select(8, GetInboxHeaderInfo(self.index))
    local tooltipEnabled = AUCTIONATOR_SHOW_MAILBOX_TIPS == 1 and  (
      AUCTIONATOR_V_TIPS == 1 or AUCTIONATOR_A_TIPS == 1 or AUCTIONATOR_D_TIPS == 1
    )

    if tooltipEnabled and itemCount and itemCount > 1 then
      local itemIds = {}
      local name, itemCount, itemLink, itemId

      for attachmentIndex = 1, ATTACHMENTS_MAX_RECEIVE do
        name, _, _, itemCount = GetInboxItem(self.index, attachmentIndex)

        if name then
          itemLink = GetInboxItemLink(self.index, attachmentIndex)
          itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)
          if itemId ~= nil then
            table.insert(itemIds, {
              id = itemId,
              link = itemLink,
              count = itemCount,
              name = name
            })
          end
        end
      end

      Auctionator.Tooltip.ShowTipWithMultiplePricing(GameTooltip, itemIds)
    end
  end
);

-- This occurs when clicking on an item link (i.e. in chat)
hooksecurefunc(ItemRefTooltip, "SetHyperlink",
  function(tip, itemstring)
    local _, itemLink = GetItemInfo(itemstring);
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)
    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, 1)
    end
  end
);

-- Occurs when mousing over  items I'm trading
hooksecurefunc (GameTooltip, "SetTradePlayerItem",
  function (tip, id)
    local itemLink = GetTradePlayerItemLink(id)
    if itemLink ~= nil then
      local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

      local _, _, itemCount = GetTradePlayerItemInfo(id);

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- Occurs when mousing over items other player are trading
hooksecurefunc (GameTooltip, "SetTradeTargetItem",
  function (tip, id)
    local itemLink = GetTradeTargetItemLink(id)
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

    if itemId ~= nil then
      local _, _, itemCount = GetTradeTargetItemInfo(id)

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, itemCount)
    end
  end
);

-- No idea when this thing is fired :shrug:
hooksecurefunc (GameTooltip, "SetHyperlink",
  function (tip, itemstring, num)
    local _, itemLink = GetItemInfo(itemstring);
    local itemId = Auctionator.Utilities.ItemIdFromLink(itemLink)

    if itemId ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemId, 1)
    end
  end
);
