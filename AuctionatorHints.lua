
local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local zz = zc.md;
local _

local ItemUpgradeInfo = LibStub( 'LibItemUpgradeInfo-1.0' )

-----------------------------------------

local auctionator_orig_GameTooltip_OnTooltipAddMoney;

-----------------------------------------

function auctionator_GameTooltip_OnTooltipAddMoney (self, cost, maxcost)

  if (AUCTIONATOR_V_TIPS == 1) then
    return;
  end

  auctionator_orig_GameTooltip_OnTooltipAddMoney (self, cost, maxcost);
end

-----------------------------------------

function Atr_Hook_OnTooltipAddMoney()
  auctionator_orig_GameTooltip_OnTooltipAddMoney = GameTooltip_OnTooltipAddMoney;
  GameTooltip_OnTooltipAddMoney = auctionator_GameTooltip_OnTooltipAddMoney;
end

------------------------------------------------

local function Atr_AppendHint (results, price, text, volume)

  if (price and price > 0) then
    local e = {};
    e.price   = price;
    e.text    = text;
    e.volume  = volume;

    table.insert (results, e);
  end

end

------------------------------------------------

function Atr_BuildHints (itemName, itemLink)

  local results = {};

  if (itemLink == nil and itemName == nil) then
    return results;
  end

  -- The Undermine Journal

  if (TUJMarketInfo) then
    local id = zc.RawItemIDfromLink (itemLink);

    local tujData = {}
    TUJMarketInfo (tonumber(id), tujData)

    local rawStdDevServer = tujData['stddev']
    local rawStdDevGlobal = tujData['globalStdDev']

    local stdDevServer = "???"
    if (rawStdDevServer) then
        stdDevServer = zc.priceToString (rawStdDevServer)
    end

    local stdDevGlobal = "???"
    if (rawStdDevGlobal) then
        stdDevGlobal = zc.priceToString (rawStdDevGlobal)
    end

    Atr_AppendHint (results, tujData['globalMean'], ZT("Undermine global avg (deviation: "..stdDevGlobal.." )"));
    Atr_AppendHint (results, tujData['recent'], ZT("Undermine 3-day server avg"));
    Atr_AppendHint (results, tujData['market'], ZT("Undermine 14-day server avg (deviation: "..stdDevServer.." )"));
    Atr_AppendHint (results, tujData['globalMedian'], ZT("Undermine global median"));
  end

  -- Wowecon

  if (Wowecon and Wowecon.API) then

    local priceG, volG, priceS, volS;

    if (itemLink) then
      priceG, volG = Wowecon.API.GetAuctionPrice_ByLink (itemLink, Wowecon.API.GLOBAL_PRICE)
      priceS, volS = Wowecon.API.GetAuctionPrice_ByLink (itemLink, Wowecon.API.SERVER_PRICE)
    else
      priceG, volG = Wowecon.API.GetAuctionPrice_ByName (itemName, Wowecon.API.GLOBAL_PRICE)
      priceS, volS = Wowecon.API.GetAuctionPrice_ByName (itemName, Wowecon.API.SERVER_PRICE)
    end

    Atr_AppendHint (results, priceG, ZT("Wowecon global price"), volG);
    Atr_AppendHint (results, priceS, ZT("Wowecon server price"), volS);

  end

  if (itemLink) then

    -- GoingPrice Wowhead

    local id = zc.RawItemIDfromLink (itemLink);

    id = tonumber(id);

    if (GoingPrice_Wowhead_Data and GoingPrice_Wowhead_Data[id] and GoingPrice_Wowhead_SV._index) then
      local index = GoingPrice_Wowhead_SV._index["Buyout price"];

      if (index ~= nil) then
        local price = GoingPrice_Wowhead_Data[id][index];

        Atr_AppendHint (results, price, "GoingPrice - Wowhead");
      end
    end

    -- GoingPrice Allakhazam

    if (GoingPrice_Allakhazam_Data and GoingPrice_Allakhazam_Data[id] and GoingPrice_Allakhazam_SV._index) then
      local index = GoingPrice_Allakhazam_SV._index["Median"];

      if (index ~= nil) then
        local price = GoingPrice_Allakhazam_Data[id][index];

        Atr_AppendHint (results, price, "GoingPrice - Allakhazam");
      end
    end
  end

  return results;

end

-----------------------------------------

function Atr_SetMFcolor (frameName, blue)

  local goldButton   = _G[frameName.."GoldButton"];
  local silverButton = _G[frameName.."SilverButton"];
  local copperButton = _G[frameName.."CopperButton"];

  if (blue) then
    goldButton:SetNormalFontObject(NumberFontNormalRightATRblue);
    silverButton:SetNormalFontObject(NumberFontNormalRightATRblue);
    copperButton:SetNormalFontObject(NumberFontNormalRightATRblue);
  else
    goldButton:SetNormalFontObject(NumberFontNormalRight);
    silverButton:SetNormalFontObject(NumberFontNormalRight);
    copperButton:SetNormalFontObject(NumberFontNormalRight);
  end

end


-----------------------------------------

function Atr_GetAuctionPrice (item)  -- itemName or itemID
  local itemName;

  if (type (item) == "number") then
    itemName = GetItemInfo (item);
  else
    itemName = item;
  end

  if (itemName == nil) then
    return nil;
  end

  if (gAtr_ScanDB and type (gAtr_ScanDB) ~= "table") then
    zc.msg_badErr ("Scanning history database appears to be corrupt")
    zc.msg_badErr ("gAtr_ScanDB:", gAtr_ScanDB)
    return nil
  end

  if ((type(gAtr_ScanDB) == "table") and gAtr_ScanDB[itemName] and gAtr_ScanDB[itemName].mr) then
    return gAtr_ScanDB[itemName].mr;
  end

  return nil;
end

-----------------------------------------

local function Atr_CalcTextWid (price)

  local wid = 15;

  if (price > 9)      then wid = wid + 12;  end;
  if (price > 99)     then wid = wid + 44;  end;
  if (price > 999)    then wid = wid + 12;  end;
  if (price > 9999)   then wid = wid + 44;  end;
  if (price > 99999)    then wid = wid + 12;  end;
  if (price > 999999)   then wid = wid + 12;  end;
  if (price > 9999999)  then wid = wid + 12;  end;
  if (price > 99999999) then wid = wid + 12;  end;

  return wid;
end

-----------------------------------------

local function Atr_GetDEitemName( itemID )
  local itemName = GetItemInfo( itemID )

  return itemName or Auctionator.Constants.DisenchantingItemName[ itemID ]
end

-----------------------------------------

-- same as Atr_GetAuctionPrice but understands that some "lesser" essences are
-- convertible with "greater"
function Atr_GetAuctionPriceDE( itemID )
  local mapping = Auctionator.Constants.DisenchantingMatMapping[ itemID ]

  if mapping then
    local lesserPrice = Atr_GetAuctionPrice( Atr_GetDEitemName( itemID ))
    local greaterPrice = Atr_GetAuctionPrice( Atr_GetDEitemName( mapping ))

    if lesserPrice and greaterPrice and lesserPrice * 3 > greaterPrice then
      return math.floor( greaterPrice / 3 )
    else
      return lesserPrice
    end
  else
    return Atr_GetAuctionPrice( Atr_GetDEitemName( itemID ))
  end
end

-----------------------------------------

function Auctionator.ItemLevelMatches( entry, itemLevel )
  return itemLevel >= entry[ Auctionator.Constants.DisenchantingProbabilityKeys.LOW ] and
    itemLevel <= entry[ Auctionator.Constants.DisenchantingProbabilityKeys.HIGH ]
end

local function Atr_FindDEentry (classID, itemRarity, itemLevel)
  local itemClassTable = Auctionator.Constants.DisenchantingProbability[ classID ]
  local entries = ( itemClassTable and itemClassTable[ itemRarity ] ) or {}

  for index, entry in pairs( entries ) do
    if Auctionator.ItemLevelMatches( entry, itemLevel ) then
      return entry
    end
  end
end

-----------------------------------------

function Atr_AddDEDetailsToTip( tip, classID, itemRarity, itemLevel )
  local entry = Atr_FindDEentry( classID, itemRarity, itemLevel )

  if entry then
    for x = 3, #entry, 3 do
      local percent = math.floor( entry[ x ] * 100 ) / 100
      local deitem = Atr_GetDEitemName( entry[ x + 2 ] )

      if (percent > 0) then
        tip:AddLine ("  |cFFFFFFFF" .. percent .. "%|r   " .. entry[ x + 1 ] .. " " .. ( deitem or '???' ))
      end
    end
  end
end


-----------------------------------------
function Auctionator.IsNotCommon( itemRarity )
  return itemRarity == Auctionator.Constants.Rarity.UNCOMMON or
    itemRarity == Auctionator.Constants.Rarity.RARE or
    itemRarity == Auctionator.Constants.Rarity.EPIC
end

function Auctionator.IsDisenchantable( classID )
  return Atr_IsWeaponType( classID ) or Atr_IsArmorType( classID )
end

function Atr_CalcDisenchantPrice( classID, itemRarity, itemLevel)
  if Auctionator.IsDisenchantable( classID ) and Auctionator.IsNotCommon( itemRarity ) then

    local dePrice = 0

    local ta = Atr_FindDEentry( classID, itemRarity, itemLevel )
    if ta then
      for x = 3, #ta, 3 do
        local price = Atr_GetAuctionPriceDE( ta[ x + 2 ] )

        if price then
          dePrice = dePrice + ( ta[ x ] * ta[ x + 1 ] * price )
        end
      end
    end

    return math.floor( dePrice / 100 )
  end

  return nil
end

-----------------------------------------

function Atr_STWP_AddVendorInfo (tip, xstring, vendorPrice, auctionPrice)
  if (AUCTIONATOR_V_TIPS == 1 and vendorPrice > 0) then
    tip:AddDoubleLine (ZT("Vendor")..xstring, "|cFFFFFFFF"..zc.priceToMoneyString (vendorPrice))
  end
end

-----------------------------------------

function Atr_STWP_AddAuctionInfo (tip, xstring, link, auctionPrice)
  if AUCTIONATOR_A_TIPS == 1 then

    local itemID = zc.RawItemIDfromLink (link);
    itemID = tonumber(itemID);

    local bondtype = Atr_GetBondType (itemID);

    if (bondtype == ATR_BIND_ON_PICKUP) then
      tip:AddDoubleLine (ZT("Auction")..xstring, "|cFFFFFFFF"..ZT("BOP").."  ");
    elseif (bondtype == ATR_BINDS_TO_ACCOUNT) then
      tip:AddDoubleLine (ZT("Auction")..xstring, "|cFFFFFFFF"..ZT("BOA").."  ");
    elseif (bondtype == ATR_QUEST_ITEM) then
      tip:AddDoubleLine (ZT("Auction")..xstring, "|cFFFFFFFF"..ZT("Quest Item").."  ");
    elseif (auctionPrice ~= nil) then
      tip:AddDoubleLine (ZT("Auction")..xstring, "|cFFFFFFFF"..zc.priceToMoneyString (auctionPrice));
    else
      tip:AddDoubleLine (ZT("Auction")..xstring, "|cFFFFFFFF"..ZT("unknown").."  ");
    end
  end
end

-----------------------------------------

function Atr_STWP_AddBasicDEInfo (tip, xstring, dePrice)

  if (AUCTIONATOR_D_TIPS == 1 and dePrice ~= nil) then
    if (dePrice > 0) then
      tip:AddDoubleLine (ZT("Disenchant")..xstring, "|cFFFFFFFF"..zc.priceToMoneyString(dePrice));
    else
      tip:AddDoubleLine (ZT("Disenchant")..xstring, "|cFFFFFFFF"..ZT("unknown").."  ");
    end
  end

end

-----------------------------------------

function Atr_STWP_GetPrices (link, num, showStackPrices, itemVendorPrice, itemName, classID, itemRarity, itemLevel)

  local vendorPrice = 0;
  local auctionPrice  = 0;
  local dePrice   = nil;

  if (AUCTIONATOR_V_TIPS == 1) then vendorPrice = itemVendorPrice; end;
  if (AUCTIONATOR_A_TIPS == 1) then auctionPrice  = Atr_GetAuctionPrice (itemName); end;
  if (AUCTIONATOR_D_TIPS == 1) then dePrice   = Atr_CalcDisenchantPrice (classID, itemRarity, itemLevel); end;

  if (num and showStackPrices) then
    if (auctionPrice) then  auctionPrice = auctionPrice * num;  end;
    if (vendorPrice)  then  vendorPrice  = vendorPrice  * num;  end;
    if (dePrice)      then  dePrice    = dePrice  * num;  end;
  end;

  if (vendorPrice == nil) then
    vendorPrice = 0;
  end

  return vendorPrice, auctionPrice, dePrice;

end

-----------------------------------------
local item_links = {}
local pet_links = {}

function Atr_ShowTipWithPricing (tip, link, num)
  if link == nil or zc.IsBattlePetLink( link ) then
    if link and not pet_links[ link ] then
      pet_links[ link ] = Auctionator.ItemLink:new({ item_link = link })
    end

    -- TODO: Once search functionality is updated to include battle pet levels,
    -- add tooltip here
    return
  end

  if Auctionator.Debug.IsOn() then
    if not item_links[ link ] then
      item_links[ link ] = Auctionator.ItemLink:new({ item_link = link })
    end

    tip:AddDoubleLine( "Auctionator ID", item_links[ link ]:IdString() )
    tip:AddDoubleLine( '-', item_links[ link ].item_string )
    tip:AddDoubleLine( 'ID', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.ID ))
    tip:AddDoubleLine( 'ENCHANT', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.ENCHANT ))
    tip:AddDoubleLine( 'GEM_1', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.GEM_1 ))
    tip:AddDoubleLine( 'GEM_2', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.GEM_2 ))
    tip:AddDoubleLine( 'GEM_3', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.GEM_3 ))
    tip:AddDoubleLine( 'GEM_4', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.GEM_4 ))
    tip:AddDoubleLine( 'SUFFIX_ID', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.SUFFIX_ID ))
    tip:AddDoubleLine( 'UNIQUE_ID', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.UNIQUE_ID ))
    tip:AddDoubleLine( 'LEVEL', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.LEVEL ))
    tip:AddDoubleLine( 'UPGRADE_ID', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.UPGRADE_ID ))
    tip:AddDoubleLine( 'INSTANCE_DIFFICULTY_ID', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.INSTANCE_DIFFICULTY_ID ))
    tip:AddDoubleLine( 'BONUS_ID_COUNT', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.BONUS_ID_COUNT ))
    tip:AddDoubleLine( 'BONUS_ID_1', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.BONUS_ID_1 ))
    tip:AddDoubleLine( 'BONUS_ID_2', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.BONUS_ID_2 ))
    tip:AddDoubleLine( 'BONUS_ID_3', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.BONUS_ID_3 ))
    tip:AddDoubleLine( 'BONUS_ID_4', item_links[ link ]:GetField( Auctionator.Constants.ItemLink.BONUS_ID_4 ))
  end
      -- TODO: Capture this knowledge somewhere
      -- 1: name
      -- 2: itemLink
      -- 3: quality
      -- 4: iLevel
      -- 5: required Level
      -- 6: itemClass String
      -- 7: subClass String
      -- 8: ? (int)
      -- 9: WTF String
      -- 10: big int
      -- 11: itemVendorPrice? (big int)
      -- 12: itemClass int
      -- 13: subClass int
  local itemName, itemLink, itemRarity, _, itemMinLevel, itemType, _, _, _, _, itemVendorPrice, classID = GetItemInfo (link);
  local itemLevel = ItemUpgradeInfo:GetUpgradedItemLevel( itemLink )

  local showStackPrices = IsShiftKeyDown();
  if (AUCTIONATOR_SHIFT_TIPS == 2) then
    showStackPrices = not IsShiftKeyDown();
  end

  local xstring = "";
  if (num and showStackPrices) then
    xstring = "|cFFAAAAFF x"..num.."|r";
  end

  local vendorPrice, auctionPrice, dePrice = Atr_STWP_GetPrices (link, num, showStackPrices, itemVendorPrice, itemName, classID, itemRarity, itemLevel);

  -- vendor info

  Atr_STWP_AddVendorInfo (tip, xstring, vendorPrice, auctionPrice)

  -- auction info

  Atr_STWP_AddAuctionInfo (tip, xstring, link, auctionPrice)

  -- disenchanting info

  Atr_STWP_AddBasicDEInfo (tip, xstring, dePrice)

  local showDetails = true;

  if (AUCTIONATOR_DE_DETAILS_TIPS == 1) then showDetails = IsShiftKeyDown(); end;
  if (AUCTIONATOR_DE_DETAILS_TIPS == 2) then showDetails = IsControlKeyDown(); end;
  if (AUCTIONATOR_DE_DETAILS_TIPS == 3) then showDetails = IsAltKeyDown(); end;
  if (AUCTIONATOR_DE_DETAILS_TIPS == 4) then showDetails = false; end;
  if (AUCTIONATOR_DE_DETAILS_TIPS == 5) then showDetails = true; end;

  if (showDetails and dePrice ~= nil) then
    Atr_AddDEDetailsToTip (tip, classID, itemRarity, itemLevel)
  end


  tip:Show()

end

-----------------------------------------

function Atr_InitToolTips ()

end


-----------------------------------------


hooksecurefunc (GameTooltip, "SetMerchantItem",
  function(tip, index)
    Atr_ShowTipWithPricing (tip, GetMerchantItemLink(index));
  end
);

hooksecurefunc (GameTooltip, "SetBuybackItem",
  function(tip, index)
    Atr_ShowTipWithPricing (tip, GetBuybackItemLink(index));
  end
);


hooksecurefunc (GameTooltip, "SetBagItem",
  function(tip, bag, slot)
    local _, num = GetContainerItemInfo(bag, slot);
    Atr_ShowTipWithPricing (tip, GetContainerItemLink(bag, slot), num);
  end
);

hooksecurefunc (GameTooltip, "SetAuctionItem",
  function (tip, type, index)
    local _, _, num = GetAuctionItemInfo(type, index);
    Atr_ShowTipWithPricing (tip, GetAuctionItemLink(type, index), num);
  end
);

hooksecurefunc (GameTooltip, "SetAuctionSellItem",
  function (tip)
    local name, _, count = GetAuctionSellItemInfo();
    local __, link = GetItemInfo(name);
    Atr_ShowTipWithPricing (tip, link, num);
  end
);


hooksecurefunc (GameTooltip, "SetLootItem",
  function (tip, slot)
    if LootSlotHasItem(slot) then
      local link, _, num = GetLootSlotLink(slot);
      Atr_ShowTipWithPricing (tip, link, num);
    end
  end
);

hooksecurefunc (GameTooltip, "SetLootRollItem",
  function (tip, slot)
    local _, _, num = GetLootRollItemInfo(slot);
    Atr_ShowTipWithPricing (tip, GetLootRollItemLink(slot), num);
  end
);


hooksecurefunc (GameTooltip, "SetInventoryItem",
  function (tip, unit, slot)
    Atr_ShowTipWithPricing (tip, GetInventoryItemLink(unit, slot), GetInventoryItemCount(unit, slot));
  end
);


hooksecurefunc (GameTooltip, "SetGuildBankItem",
  function (tip, tab, slot)
    local _, num = GetGuildBankItemInfo(tab, slot);
    Atr_ShowTipWithPricing (tip, GetGuildBankItemLink(tab, slot), num);
  end
);

-- TODO http://www.wowinterface.com/forums/showthread.php?p=315431
-- hooksecurefunc (GameTooltip, "SetTradeSkillItem",
--   function (tip, skill, id)
--     local link = GetTradeSkillItemLink(skill);
--     local num  = GetTradeSkillNumMade(skill);
--     if id then
--       link = GetTradeSkillReagentItemLink(skill, id);
--       num = select (3, GetTradeSkillReagentInfo(skill, id));
--     end

--     Atr_ShowTipWithPricing (tip, link, num);
--   end
-- );

hooksecurefunc (GameTooltip, "SetTradePlayerItem",
  function (tip, id)
    local _, _, num = GetTradePlayerItemInfo(id);
    Atr_ShowTipWithPricing (tip, GetTradePlayerItemLink(id), num);
  end
);

hooksecurefunc (GameTooltip, "SetTradeTargetItem",
  function (tip, id)
    local _, _, num = GetTradeTargetItemInfo(id);
    Atr_ShowTipWithPricing (tip, GetTradeTargetItemLink(id), num);
  end
);

hooksecurefunc (GameTooltip, "SetQuestItem",
  function (tip, type, index)
    local _, _, num = GetQuestItemInfo(type, index);
    Atr_ShowTipWithPricing (tip, GetQuestItemLink(type, index), num);
  end
);

hooksecurefunc (GameTooltip, "SetQuestLogItem",
  function (tip, type, index)
    local num, _;
    if type == "choice" then
      _, _, num = GetQuestLogChoiceInfo(index);
    else
      _, _, num = GetQuestLogRewardInfo(index)
    end

    Atr_ShowTipWithPricing (tip, GetQuestLogItemLink(type, index), num);
  end
);

hooksecurefunc (GameTooltip, "SetInboxItem",
  function (tip, index, attachIndex)
    -- TODO https://github.com/jrob8577/Auctionator/issues/75
    local attachmentIndex = attachIndex or 1
    local _, _, _, num = GetInboxItem(index, attachmentIndex);
    Atr_ShowTipWithPricing (tip, GetInboxItemLink(index, attachmentIndex), num);
  end
);

hooksecurefunc (GameTooltip, "SetSendMailItem",
  function (tip, id)
    local name, _, _, num = GetSendMailItem(id)
    local name, link = GetItemInfo(name);
    Atr_ShowTipWithPricing (tip, link, num);
  end
);

hooksecurefunc (GameTooltip, "SetHyperlink",
  function (tip, itemstring, num)
    local name, link = GetItemInfo (itemstring);
    Atr_ShowTipWithPricing (tip, link, num);
  end
);

hooksecurefunc (ItemRefTooltip, "SetHyperlink",
  function (tip, itemstring)
    local name, link = GetItemInfo (itemstring);
    Atr_ShowTipWithPricing (tip, link);
  end
);













