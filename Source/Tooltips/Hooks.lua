-- This is called when mousing over an item in your bags
hooksecurefunc (GameTooltip, "SetBagItem",
  function(tip, bag, slot)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)

    if itemLocation:IsValid() then
      local itemLink = C_Item.GetItemLink(itemLocation);
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)
      local itemCount = C_Item.GetStackCount(itemLocation)

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
    end
  end
);

-- This is called when mousing over an item in a merchant window (Buyback Pane)
hooksecurefunc (GameTooltip, "SetBuybackItem",
  function(tip, slotIndex)
    local itemLink = GetBuybackItemLink(slotIndex)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)
    local _, _, _, itemCount = GetBuybackItemInfo(slotIndex);

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over an item in a merchant window (Merchant Pane)
hooksecurefunc (GameTooltip, "SetMerchantItem",
  function(tip, index)
    local itemLink = GetMerchantItemLink(index)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)
    local _, _, _, itemCount = GetMerchantItemInfo(index);

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over an item in your bank, or a bag in your bag list
hooksecurefunc (GameTooltip, "SetInventoryItem",
  function(tip, unit, slot)
    local itemLink = GetInventoryItemLink(unit, slot)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)
    local itemCount = GetInventoryItemCount(unit, slot)

    if itemKey ~= nil then
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount ~= 0 and itemCount or 1)
    end
  end
);

-- This is called when mousing over an item in your guild bank
-- Guild banks don't keep track of pets inside them correctly, so showing the AH
-- price is difficult.
hooksecurefunc (GameTooltip, "SetGuildBankItem",
  function(tip, tab, slot)
    local itemLink = GetGuildBankItemLink(tab, slot)
    local _, itemCount = GetGuildBankItemInfo(tab, slot)

    if itemLink ~= nil then
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)
      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
    end
  end
);

-- This is called when mousing over the result item on a recipe page in the tradeskill window
hooksecurefunc( GameTooltip, 'SetRecipeResultItem',
  function(tip, recipeResultItemId)
    local itemLink = C_TradeSkillUI.GetRecipeItemLink(recipeResultItemId)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    local itemCount  = C_TradeSkillUI.GetRecipeNumItemsProduced(recipeResultItemId)

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over a reagant item on a recipe page in the tradeskill window
hooksecurefunc( GameTooltip, 'SetRecipeReagentItem',
  function( tip, reagentId, index )
    local itemLink = C_TradeSkillUI.GetRecipeReagentItemLink(reagentId, index)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    local itemCount = select(3, C_TradeSkillUI.GetRecipeReagentInfo(reagentId, index))

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over an item in the loot window
hooksecurefunc (GameTooltip, "SetLootItem",
  function (tip, slot)
    if LootSlotHasItem(slot) then
      local itemLink, _, itemCount = GetLootSlotLink(slot);
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
    end
  end
);

-- TODO Haven't tested this so making an educated guess:
-- This is called when mousing over an item in the loot roll window
hooksecurefunc (GameTooltip, "SetLootRollItem",
  function (tip, slot)
    local itemLink = GetLootRollItemLink(slot)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    local _, _, itemCount = GetLootRollItemInfo(slot)

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over an item in a quest window
hooksecurefunc (GameTooltip, "SetQuestItem",
  function (tip, type, index)
    local itemLink = GetQuestItemLink(type, index)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    local _, _, itemCount = GetQuestItemInfo(type, index);

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over an item in a quest description in your quest log
hooksecurefunc (GameTooltip, "SetQuestLogItem",
  function (tip, type, index)
    local itemLink = GetQuestLogItemLink(type, index)
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    local itemCount;
    if type == "choice" then
      _, _, itemCount = GetQuestLogChoiceInfo(index);
    else
      _, _, itemCount = GetQuestLogRewardInfo(index)
    end

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
  end
);

-- This is called when mousing over an item in the send mail window
hooksecurefunc (GameTooltip, "SetSendMailItem",
  function (tip, id)
    local _, _, _, itemCount = GetSendMailItem(id)
    local itemLink = GetSendMailItemLink(id);
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
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
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

      local _, _, _, itemCount = GetInboxItem(index, attachmentIndex);

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
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
      local itemKeys = {}
      local name, itemCount, itemLink, itemKey

      for attachmentIndex = 1, ATTACHMENTS_MAX_RECEIVE do
        name, _, _, itemCount = GetInboxItem(self.index, attachmentIndex)

        if name then
          itemLink = GetInboxItemLink(self.index, attachmentIndex)
          itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

          table.insert(itemKeys, {
            key = itemKey,
            link = itemLink,
            count = itemCount,
            name = name
          })
        end
      end

      Auctionator.Tooltip.ShowTipWithMultiplePricing(GameTooltip, itemKeys)
    end
  end
);

-- This occurs when clicking on an item link (i.e. in chat)
hooksecurefunc(ItemRefTooltip, "SetHyperlink",
  function(tip, itemstring)
    local _, itemLink = GetItemInfo(itemstring);
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, 1)
  end
);

-- Occurs when mousing over  items I'm trading
hooksecurefunc (GameTooltip, "SetTradePlayerItem",
  function (tip, id)
    local itemLink = GetTradePlayerItemLink(id)
    if itemLink ~= nil then
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

      local _, _, itemCount = GetTradePlayerItemInfo(id);

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
    end
  end
);

-- Occurs when mousing over items other player are trading
hooksecurefunc (GameTooltip, "SetTradeTargetItem",
  function (tip, id)
    local itemLink = GetTradeTargetItemLink(id)
    if itemLink ~= nil then
      local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

      local _, _, itemCount = GetTradeTargetItemInfo(id)

      Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, itemCount)
    end
  end
);

-- No idea when this thing is fired :shrug:
hooksecurefunc (GameTooltip, "SetHyperlink",
  function (tip, itemstring, num)
    local _, itemLink = GetItemInfo(itemstring);
    local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

    Auctionator.Tooltip.ShowTipWithPricing(tip, itemKey, 1)
  end
);
