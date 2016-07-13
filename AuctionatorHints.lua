
local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local zz = zc.md;
local _
local ItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0")

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

local function Atr_CalcTTpadding (price1, price2)

  local padding = "";

  if (price1 and price2) then
    local vpwidth = Atr_CalcTextWid (price1);
    local apwidth = Atr_CalcTextWid (price2);

    local padlen = math.floor ((apwidth - vpwidth)/6);
    local k;

    for k = 1,padlen do
      padding = padding.." ";
    end
  end

  return padding;

end

-----------------------------------------

local UNCOMMON  = 2;
local RARE    = 3;
local EPIC    = 4;

local WEAPON = LE_ITEM_CLASS_WEAPON;
local ARMOR  = LE_ITEM_CLASS_ARMOR;

local DEMATS = {
	LESSER_MAGIC = 10938,
	GREATER_MAGIC = 10939,
	STRANGE_DUST = 10940,
	SMALL_GLIMMERING = 10978,
	LESSER_ASTRAL = 10998,
	GREATER_ASTRAL = 11082,
	SOUL_DUST = 11083,
	LARGE_GLIMMERING = 11084,
	LESSER_MYSTIC = 11134,
	GREATER_MYSTIC = 11135,
	VISION_DUST = 11137,
	SMALL_GLOWING = 11138,
	LARGE_GLOWING = 11139,
	LESSER_NETHER = 11174,
	GREATER_NETHER = 11175,
	DREAM_DUST = 11176,
	SMALL_RADIANT = 11177,
	LARGE_RADIANT = 11178,
	SMALL_BRILLIANT = 14343,
	LARGE_BRILLIANT = 14344,
	LESSER_ETERNAL = 16202,
	GREATER_ETERNAL = 16203,
	ILLUSION_DUST = 16204,
	NEXUS_CRYSTAL = 20725,
	ARCANE_DUST = 22445,
	GREATER_PLANAR = 22446,
	LESSER_PLANAR = 22447,
	SMALL_PRISMATIC = 22448,
	LARGE_PRISMATIC = 22449,
	VOID_CRYSTAL = 22450,
	DREAM_SHARD = 34052,
	SMALL_DREAM = 34053,
	INFINITE_DUST = 34054,
	GREATER_COSMIC = 34055,
	LESSER_COSMIC = 34056,
	ABYSS_CRYSTAL = 34057,
	HEAVENLY_SHARD = 52721,
	SMALL_HEAVENLY = 52720,
	HYPN_DUST = 52555,
	GREATER_CEL = 52719,
	LESSER_CEL = 52718,
	MAELSTROM_CRYSTAL = 52722,
	ETHEREAL_SHARD = 74247,
	SMALL_ETHEREAL = 74252,
	SPIRIT_DUST = 74249,
	MYSTERIOUS_ESS = 74250,
	GREATER_MYST_ESS = 74251,
	SHA_CRYSTAL = 74248,
	TEMPORAL_CRYSTAL = 113588,
	LUMINOUS_SHARD = 111245,
	SMALL_LUM_SHARD = 115502,
	DRAENIC_DUST = 109693,
	ARKHANA = 124440,
	LEYLIGHT_SHARD = 124441,
	CHAOS_CRYSTAL = 124442
};

local engDEnames = {};

engDEnames [DEMATS.LESSER_MAGIC] = "Lesser Magic Essence";
engDEnames [DEMATS.GREATER_MAGIC] = "Greater Magic Essence";
engDEnames [DEMATS.STRANGE_DUST] = "Strange Dust";
engDEnames [DEMATS.SMALL_GLIMMERING] = "Small Glimmering Shard";
engDEnames [DEMATS.LESSER_ASTRAL] = "Lesser Astral Essence";
engDEnames [DEMATS.GREATER_ASTRAL] = "Greater Astral Essence";
engDEnames [DEMATS.SOUL_DUST] = "Soul Dust";
engDEnames [DEMATS.LARGE_GLIMMERING] = "Large Glimmering Essence";
engDEnames [DEMATS.LESSER_MYSTIC] = "Lesser Mystic Essence";
engDEnames [DEMATS.GREATER_MYSTIC] = "Greater Mystic Essence";
engDEnames [DEMATS.VISION_DUST] = "Vision Dust";
engDEnames [DEMATS.SMALL_GLOWING] = "Small Glowing Shard";
engDEnames [DEMATS.LARGE_GLOWING] = "Large Glowing Shard";
engDEnames [DEMATS.LESSER_NETHER] = "Lesser Nether Essence";
engDEnames [DEMATS.GREATER_NETHER] = "Greater Nether Essence";
engDEnames [DEMATS.DREAM_DUST] = "Dream Dust";
engDEnames [DEMATS.SMALL_RADIANT] = "Small Radiant";
engDEnames [DEMATS.LARGE_RADIANT] = "Large Radiant";
engDEnames [DEMATS.SMALL_BRILLIANT] = "Small Brilliant Shard";
engDEnames [DEMATS.LARGE_BRILLIANT] = "Large Brilliant Shard";
engDEnames [DEMATS.LESSER_ETERNAL] = "Lesser Eternal Essence";
engDEnames [DEMATS.GREATER_ETERNAL] = "Greater Eternal Essence";
engDEnames [DEMATS.ILLUSION_DUST] = "Illusion Dust";
engDEnames [DEMATS.NEXUS_CRYSTAL] = "Nexus Crystal";
engDEnames [DEMATS.ARCANE_DUST] = "Arcane Dust";
engDEnames [DEMATS.GREATER_PLANAR] = "Greater Planar Essence";
engDEnames [DEMATS.LESSER_PLANAR] = "Lesser Planar Essence";
engDEnames [DEMATS.SMALL_PRISMATIC] = "Small Prismatic Shard";
engDEnames [DEMATS.LARGE_PRISMATIC] = "Large Prismatic Shard";
engDEnames [DEMATS.VOID_CRYSTAL] = "Void Crystal";
engDEnames [DEMATS.DREAM_SHARD] = "Dream Shard";
engDEnames [DEMATS.SMALL_DREAM] = "Small Dream Shard";
engDEnames [DEMATS.INFINITE_DUST] = "Infinite Dust";
engDEnames [DEMATS.GREATER_COSMIC] = "Greater Cosmic Essence";
engDEnames [DEMATS.LESSER_COSMIC] = "Lesser Cosmic Essence";
engDEnames [DEMATS.ABYSS_CRYSTAL] = "Abyss Crystal";
engDEnames [DEMATS.HEAVENLY_SHARD] = "Heavenly Shard";
engDEnames [DEMATS.SMALL_HEAVENLY] = "Small Heavenly Shard";
engDEnames [DEMATS.HYPN_DUST] = "Hypnotic Dust";
engDEnames [DEMATS.GREATER_CEL] = "Greater Celestial Essence";
engDEnames [DEMATS.LESSER_CEL] = "Lesser Celestial Essence";
engDEnames [DEMATS.MAELSTROM_CRYSTAL] = "Maelstrom Crystal";
engDEnames[DEMATS.SMALL_ETHEREAL]  = 'Small Ethereal Shard';
engDEnames[DEMATS.ETHEREAL_SHARD] = 'Ethereal Shard';
engDEnames[DEMATS.SPIRIT_DUST] = 'Spirit Dust';
engDEnames[DEMATS.MYSTERIOUS_ESS] = 'Mysterious Essence';
engDEnames[DEMATS.GREATER_MYST_ESS] = 'Greater Mysterious Essence';
engDEnames[DEMATS.SHA_CRYSTAL] = 'Sha Crystal';
engDEnames[DEMATS.TEMPORAL_CRYSTAL] = 'Temporal Crystal';
engDEnames[DEMATS.LUMINOUS_SHARD] = 'Luminous Shard';
engDEnames[DEMATS.SMALL_LUM_SHARD] = 'Small Luminous Shard';
engDEnames[DEMATS.DRAENIC_DUST] = 'Draenic Dust';
engDEnames[DEMATS.ARKHANA] = 'DEMATS.ARKHANA';
engDEnames[DEMATS.LEYLIGHT_SHARD] = 'Leylight Shard';
engDEnames[DEMATS.CHAOS_CRYSTAL] = 'Chaos Crystal';


local dustsAndEssences = {};
	tinsert (dustsAndEssences, DEMATS.LESSER_MAGIC)
	tinsert (dustsAndEssences, DEMATS.GREATER_MAGIC)
	tinsert (dustsAndEssences, DEMATS.STRANGE_DUST)
	tinsert (dustsAndEssences, DEMATS.SMALL_GLIMMERING)
	tinsert (dustsAndEssences, DEMATS.LESSER_ASTRAL)
	tinsert (dustsAndEssences, DEMATS.GREATER_ASTRAL)
	tinsert (dustsAndEssences, DEMATS.SOUL_DUST)
	tinsert (dustsAndEssences, DEMATS.LARGE_GLIMMERING)
	tinsert (dustsAndEssences, DEMATS.LESSER_MYSTIC)
	tinsert (dustsAndEssences, DEMATS.GREATER_MYSTIC)
	tinsert (dustsAndEssences, DEMATS.VISION_DUST)
	tinsert (dustsAndEssences, DEMATS.SMALL_GLOWING)
	tinsert (dustsAndEssences, DEMATS.LARGE_GLOWING)
	tinsert (dustsAndEssences, DEMATS.LESSER_NETHER)
	tinsert (dustsAndEssences, DEMATS.GREATER_NETHER)
	tinsert (dustsAndEssences, DEMATS.DREAM_DUST)
	tinsert (dustsAndEssences, DEMATS.SMALL_RADIANT)
	tinsert (dustsAndEssences, DEMATS.LARGE_RADIANT)
	tinsert (dustsAndEssences, DEMATS.SMALL_BRILLIANT)
	tinsert (dustsAndEssences, DEMATS.LARGE_BRILLIANT)
	tinsert (dustsAndEssences, DEMATS.LESSER_ETERNAL)
	tinsert (dustsAndEssences, DEMATS.GREATER_ETERNAL)
	tinsert (dustsAndEssences, DEMATS.ILLUSION_DUST)
	tinsert (dustsAndEssences, DEMATS.NEXUS_CRYSTAL)
	tinsert (dustsAndEssences, DEMATS.ARCANE_DUST)
	tinsert (dustsAndEssences, DEMATS.GREATER_PLANAR)
	tinsert (dustsAndEssences, DEMATS.LESSER_PLANAR)
	tinsert (dustsAndEssences, DEMATS.SMALL_PRISMATIC)
	tinsert (dustsAndEssences, DEMATS.LARGE_PRISMATIC)
	tinsert (dustsAndEssences, DEMATS.VOID_CRYSTAL)
	tinsert (dustsAndEssences, DEMATS.DREAM_SHARD)
	tinsert (dustsAndEssences, DEMATS.SMALL_DREAM)
	tinsert (dustsAndEssences, DEMATS.INFINITE_DUST)
	tinsert (dustsAndEssences, DEMATS.GREATER_COSMIC)
	tinsert (dustsAndEssences, DEMATS.LESSER_COSMIC)
	tinsert (dustsAndEssences, DEMATS.ABYSS_CRYSTAL)
	tinsert (dustsAndEssences, DEMATS.HEAVENLY_SHARD)
	tinsert (dustsAndEssences, DEMATS.SMALL_HEAVENLY)
	tinsert (dustsAndEssences, DEMATS.HYPN_DUST)
	tinsert (dustsAndEssences, DEMATS.GREATER_CEL)
	tinsert (dustsAndEssences, DEMATS.LESSER_CEL)
	tinsert (dustsAndEssences, DEMATS.MAELSTROM_CRYSTAL)
	tinsert (dustsAndEssences, DEMATS.SMALL_ETHEREAL)
	tinsert (dustsAndEssences, DEMATS.ETHEREAL_SHARD)	
	tinsert (dustsAndEssences, DEMATS.SPIRIT_DUST)
	tinsert (dustsAndEssences, DEMATS.MYSTERIOUS_ESS)
	tinsert (dustsAndEssences, DEMATS.GREATER_MYST_ESS)
	tinsert (dustsAndEssences, DEMATS.SHA_CRYSTAL)
	tinsert (dustsAndEssences, DEMATS.TEMPORAL_CRYSTAL)
	tinsert (dustsAndEssences, DEMATS.LUMINOUS_SHARD)
	tinsert (dustsAndEssences, DEMATS.SMALL_LUM_SHARD)
	tinsert (dustsAndEssences, DEMATS.DRAENIC_DUST)
	tinsert (dustsAndEssences, DEMATS.ARKHANA)
	tinsert (dustsAndEssences, DEMATS.LEYLIGHT_SHARD)
	tinsert (dustsAndEssences, DEMATS.CHAOS_CRYSTAL)

gAtr_dustCacheIndex = 1;

local DUST_CACHE_READY_FOR_NEXT  = 0;
local DUST_CACHE_WAITING_ON_PREV = 1;

local dustCacheState = DUST_CACHE_READY_FOR_NEXT;

local dustCacheNotFound = 0;
local dustCacheFound = 0;
-----------------------------------------

function Atr_GetNextDustIntoCache()   -- make sure all the dusts and essences are in the RAM cache

  if (gAtr_dustCacheIndex == 0 or AtrScanningTooltip == nil) then
    return;
  end

  local itemID    = dustsAndEssences[gAtr_dustCacheIndex];
  local itemString  = "item:"..itemID..":0:0:0:0:0:0:0";

  local itemName, itemLink = GetItemInfo(itemString);

  if (itemLink == nil and dustCacheState == DUST_CACHE_READY_FOR_NEXT) then
    dustCacheState = DUST_CACHE_WAITING_ON_PREV;
    AtrScanningTooltip:SetHyperlink(itemString);
    local _, link = GetItemInfo(itemString);
--    zc.md ("pulling "..itemString.." into the local cache   ", dustCacheState);
    dustCacheNotFound = dustCacheNotFound + 1;
  end

  if (itemLink) then
--    zc.md (itemLink.." is in RAM cache");
    dustCacheFound = dustCacheFound + 1;
    dustCacheState = DUST_CACHE_READY_FOR_NEXT;
    gAtr_dustCacheIndex = gAtr_dustCacheIndex + 1;

    if (gAtr_dustCacheIndex > #dustsAndEssences) then
      gAtr_dustCacheIndex = 0;    -- finished
--      zc.md ("num items pulled into memory: ", dustCacheNotFound, "out of", dustCacheFound);
    end
  end
end

-----------------------------------------

local deItemNames = {};

local function Atr_GetDEitemName (itemID)

  if (deItemNames[itemID] == nil) then
    local itemName = GetItemInfo (itemID);
    if (itemName == nil) then
      zc.md ("defaulting to english DE mat name: "..engDEnames [itemID]);
      return engDEnames [itemID];
    end

    deItemNames[itemID] = itemName;
  end

  return deItemNames[itemID];

end

-----------------------------------------

function Atr_GetAuctionPriceDE (itemID)  -- same as Atr_GetAuctionPrice but understands that some "lesser" essences are convertible with "greater"

  local lesserPrice;
  local greaterPrice;

  if (itemID == DEMATS.LESSER_CEL) then
    lesserPrice = Atr_GetAuctionPrice (Atr_GetDEitemName (DEMATS.LESSER_CEL));
    greaterPrice = Atr_GetAuctionPrice (Atr_GetDEitemName (DEMATS.GREATER_CEL));
  end

  if (itemID == DEMATS.LESSER_COSMIC) then
    lesserPrice = Atr_GetAuctionPrice (Atr_GetDEitemName (DEMATS.LESSER_COSMIC));
    greaterPrice = Atr_GetAuctionPrice (Atr_GetDEitemName (DEMATS.GREATER_COSMIC));
  end

  if (itemID == DEMATS.LESSER_PLANAR) then
    lesserPrice = Atr_GetAuctionPrice (Atr_GetDEitemName (DEMATS.LESSER_PLANAR));
    greaterPrice = Atr_GetAuctionPrice (Atr_GetDEitemName (DEMATS.GREATER_PLANAR));
  end

  if (lesserPrice ~= nil and greaterPrice ~= nil and lesserPrice * 3 > greaterPrice) then
    return math.floor (greaterPrice / 3);
  end

  return Atr_GetAuctionPrice (Atr_GetDEitemName (itemID));
end

-----------------------------------------

local deTable = {};

-----------------------------------------

local function deKey (itemType, itemRarity)
  local s = tostring(itemType).."_"..itemRarity
  return s;
end

-----------------------------------------

local function DEtableInsert(t, info)

  local entry = {};

  local x, i, n;

  entry[1]  = info[1];
  entry[2]  = info[2];

  n = 3;

  for x = 3,#info,3 do
    local nums = info[x+1];
    if (type(nums) == "number") then
      entry[n]   = info[x];
      entry[n+1] = info[x+1];
      entry[n+2] = info[x+2];
      n = n + 3;
    else
      for i = nums[1],nums[2] do
        entry[n]   = info[x]/(nums[2]-nums[1]+1);
        entry[n+1] = i;
        entry[n+2] = info[x+2];
        n = n + 3;
      end
    end
  end

  table.insert (t, entry);

end


-----------------------------------------

function Atr_InitDETable()

-- Table Structure
-- DEtableInsert(t, {minimum item level, maximum item level, percent of [first mats], {1, 2} <- this is the number total you can get such as 1 to 2 of a mat can also be express as numerical value into tenths such as 2.5, table entry of mat name, 20});
-- if written as say 80 {1, 2} this actually means 40% 1 mat, 40% 2 mats and so on

-- UNCOMMON (GREEN) ARMOR
	deTable[deKey(ARMOR, UNCOMMON)] = {};
	t = deTable[deKey(ARMOR, UNCOMMON)];

        DEtableInsert(t, {5, 15, 80, {1, 2}, DEMATS.STRANGE_DUST, 20, {1, 2}, DEMATS.LESSER_MAGIC});
        DEtableInsert(t, {16, 20, 75, {2, 3}, DEMATS.STRANGE_DUST, 20, {1, 2}, DEMATS.GREATER_MAGIC, 5, 1, DEMATS.SMALL_GLIMMERING});
        DEtableInsert(t, {21, 25, 75, {4, 6}, DEMATS.STRANGE_DUST, 15, {1, 2}, DEMATS.LESSER_ASTRAL, 10, 1, DEMATS.SMALL_GLIMMERING});
        DEtableInsert(t, {26, 30, 75, {1, 2}, DEMATS.SOUL_DUST, 20, {1, 2}, DEMATS.GREATER_ASTRAL, 5, 1, DEMATS.LARGE_GLIMMERING});
        DEtableInsert(t, {31, 35, 75, {2, 5}, DEMATS.SOUL_DUST, 20, {1, 2}, DEMATS.LESSER_MYSTIC, 5, 1, DEMATS.SMALL_GLOWING});
        DEtableInsert(t, {36, 40, 75, {1, 2}, DEMATS.VISION_DUST, 20, {1, 2}, DEMATS.GREATER_MYSTIC, 5, 1, DEMATS.LARGE_GLOWING});
        DEtableInsert(t, {41, 45, 75, {2, 5}, DEMATS.VISION_DUST, 20, {1, 2}, DEMATS.LESSER_NETHER, 5, 1, DEMATS.SMALL_RADIANT});
        DEtableInsert(t, {46, 50, 75, {1, 2}, DEMATS.DREAM_DUST, 20, {1, 2}, DEMATS.GREATER_NETHER, 5, 1, DEMATS.LARGE_RADIANT});
        DEtableInsert(t, {51, 55, 75, {2, 5}, DEMATS.DREAM_DUST, 20, {1, 2}, DEMATS.LESSER_ETERNAL, 5, 1, DEMATS.SMALL_BRILLIANT});
        DEtableInsert(t, {56, 60, 75, {1, 2}, DEMATS.ILLUSION_DUST, 20, {1, 2}, DEMATS.GREATER_ETERNAL, 5, 1, DEMATS.LARGE_BRILLIANT});
        DEtableInsert(t, {61, 65, 75, {2, 5}, DEMATS.ILLUSION_DUST, 20, {2, 3}, DEMATS.GREATER_ETERNAL, 5, 1, DEMATS.LARGE_BRILLIANT});
        DEtableInsert(t, {66, 80, 75, {1, 3}, DEMATS.ARCANE_DUST, 22, {1, 3}, DEMATS.LESSER_PLANAR, 3, 1, DEMATS.SMALL_PRISMATIC});
        DEtableInsert(t, {81, 99, 75, {2, 3}, DEMATS.ARCANE_DUST, 22, {2, 3}, DEMATS.LESSER_PLANAR, 3, 1, DEMATS.SMALL_PRISMATIC});
        DEtableInsert(t, {100, 120, 75, {2, 5}, DEMATS.ARCANE_DUST, 22, {1, 2}, DEMATS.GREATER_PLANAR, 3, 1, DEMATS.LARGE_PRISMATIC});
        DEtableInsert(t, {121, 151, 75, {1, 3}, DEMATS.INFINITE_DUST, 22, {1, 2}, DEMATS.LESSER_COSMIC, 3, 1, DEMATS.SMALL_DREAM});
        DEtableInsert(t, {152, 200, 75, {4, 7}, DEMATS.INFINITE_DUST, 22, {1, 2}, DEMATS.GREATER_COSMIC, 3, 1, DEMATS.DREAM_SHARD});
        DEtableInsert(t, {272, 272, 34, 1, DEMATS.HYPN_DUST, 41, 2, DEMATS.HYPN_DUST, 13, 1, DEMATS.LESSER_CEL, 12, 2, DEMATS.LESSER_CEL});
        DEtableInsert(t, {278, 278, 31, 1, DEMATS.HYPN_DUST, 20, 2, DEMATS.HYPN_DUST, 22, 3, DEMATS.HYPN_DUST, 9, 1, DEMATS.LESSER_CEL, 11, 2, DEMATS.LESSER_CEL, 6, 3, DEMATS.LESSER_CEL});
        DEtableInsert(t, {283, 283, 28, 1, DEMATS.HYPN_DUST, 21, 2, DEMATS.HYPN_DUST, 24, 3, DEMATS.HYPN_DUST, 1, 4, DEMATS.HYPN_DUST, 8, 1, DEMATS.LESSER_CEL, 9, 2, DEMATS.LESSER_CEL, 9, 3, DEMATS.LESSER_CEL});
        DEtableInsert(t, {285, 285, 28, 1, DEMATS.HYPN_DUST, 25, 2, DEMATS.HYPN_DUST, 20, 3, DEMATS.HYPN_DUST, 0, 4, DEMATS.HYPN_DUST, 7, 1, DEMATS.LESSER_CEL, 9, 2, DEMATS.LESSER_CEL, 10, 3, DEMATS.LESSER_CEL, 0, 6, DEMATS.LESSER_CEL});
        DEtableInsert(t, {289, 289, 25, 1, DEMATS.HYPN_DUST, 25, 2, DEMATS.HYPN_DUST, 25, 3, DEMATS.HYPN_DUST, 0, 4, DEMATS.HYPN_DUST, 0, 5, DEMATS.HYPN_DUST, 7, 1, DEMATS.LESSER_CEL, 9, 2, DEMATS.LESSER_CEL, 8, 3, DEMATS.LESSER_CEL, 0, 5, DEMATS.LESSER_CEL});
        DEtableInsert(t, {295, 295, 21, 1, DEMATS.HYPN_DUST, 19, 2, DEMATS.HYPN_DUST, 22, 3, DEMATS.HYPN_DUST, 17, 4, DEMATS.HYPN_DUST, 7, 2, DEMATS.LESSER_CEL, 8, 3, DEMATS.LESSER_CEL, 6, 4, DEMATS.LESSER_CEL});
        DEtableInsert(t, {300, 300, 18, 1, DEMATS.HYPN_DUST, 20, 2, DEMATS.HYPN_DUST, 19, 3, DEMATS.HYPN_DUST, 19, 4, DEMATS.HYPN_DUST, 0, 6, DEMATS.HYPN_DUST, 8, 2, DEMATS.LESSER_CEL, 10, 3, DEMATS.LESSER_CEL, 7, 4, DEMATS.LESSER_CEL});
        DEtableInsert(t, {305, 305, 15, 1, DEMATS.HYPN_DUST, 12, 2, DEMATS.HYPN_DUST, 26, 3, DEMATS.HYPN_DUST, 20, 4, DEMATS.HYPN_DUST, 9, 2, DEMATS.LESSER_CEL, 10, 3, DEMATS.LESSER_CEL, 9, 4, DEMATS.LESSER_CEL});
        DEtableInsert(t, {306, 306, 24, 2, DEMATS.HYPN_DUST, 26, 3, DEMATS.HYPN_DUST, 26, 4, DEMATS.HYPN_DUST, 12, 1, DEMATS.GREATER_CEL, 12, 2, DEMATS.GREATER_CEL});
        DEtableInsert(t, {312, 312, 29, 2, DEMATS.HYPN_DUST, 30, 3, DEMATS.HYPN_DUST, 20, 4, DEMATS.HYPN_DUST, 11, 1, DEMATS.GREATER_CEL, 11, 2, DEMATS.GREATER_CEL});
        DEtableInsert(t, {316, 316, 18, 2, DEMATS.HYPN_DUST, 18, 3, DEMATS.HYPN_DUST, 22, 4, DEMATS.HYPN_DUST, 16, 5, DEMATS.HYPN_DUST, 14, 2, DEMATS.GREATER_CEL, 12, 3, DEMATS.GREATER_CEL});
        DEtableInsert(t, {318, 318, 14, 2, DEMATS.HYPN_DUST, 21, 3, DEMATS.HYPN_DUST, 22, 4, DEMATS.HYPN_DUST, 18, 5, DEMATS.HYPN_DUST, 12, 2, DEMATS.GREATER_CEL, 13, 3, DEMATS.GREATER_CEL});
        DEtableInsert(t, {325, 325, 17, 3, DEMATS.HYPN_DUST, 17, 4, DEMATS.HYPN_DUST, 17, 5, DEMATS.HYPN_DUST, 50, 2, DEMATS.GREATER_CEL});
        DEtableInsert(t, {333, 333, 12, 2, DEMATS.HYPN_DUST, 24, 3, DEMATS.HYPN_DUST, 12, 4, DEMATS.HYPN_DUST, 29, 5, DEMATS.HYPN_DUST, 18, 2, DEMATS.GREATER_CEL, 6, 3, DEMATS.GREATER_CEL});
        DEtableInsert(t, {364, 380, 85, 2, DEMATS.SPIRIT_DUST, 15, 1, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {381, 390, 85, 2.5, DEMATS.SPIRIT_DUST, 15, 1, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {391, 410, 85, 3, DEMATS.SPIRIT_DUST, 15, 1.5, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {411, 483, 85, 3.5, DEMATS.SPIRIT_DUST, 15, 2, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {484, 700, 100, 2.5, DEMATS.DRAENIC_DUST});
        DEtableInsert(t, {701, 900, 100, 2.5, DEMATS.ARKHANA});


--UNCOMMON(GREEN)WEAPONS
	deTable[deKey(WEAPON, UNCOMMON)]={};
	t = deTable[deKey(WEAPON, UNCOMMON)];

        DEtableInsert(t, {6, 15, 20, {1, 2}, DEMATS.STRANGE_DUST, 80, {1, 2}, DEMATS.LESSER_MAGIC});
        DEtableInsert(t, {16, 20, 20, {2, 3}, DEMATS.STRANGE_DUST, 75, {1, 2}, DEMATS.GREATER_MAGIC, 5, 1, DEMATS.SMALL_GLIMMERING});
        DEtableInsert(t, {21, 25, 15, {4, 6}, DEMATS.STRANGE_DUST, 75, {1, 2}, DEMATS.LESSER_ASTRAL, 10, 1, DEMATS.SMALL_GLIMMERING});
        DEtableInsert(t, {26, 30, 20, {1, 2}, DEMATS.SOUL_DUST, 75, {1, 2}, DEMATS.GREATER_ASTRAL, 5, 1, DEMATS.LARGE_GLIMMERING});
        DEtableInsert(t, {31, 35, 20, {2, 5}, DEMATS.SOUL_DUST, 75, {1, 2}, DEMATS.LESSER_MYSTIC, 5, 1, DEMATS.SMALL_GLOWING});
        DEtableInsert(t, {36, 40, 20, {1, 2}, DEMATS.VISION_DUST, 75, {1, 2}, DEMATS.GREATER_MYSTIC, 5, 1, DEMATS.LARGE_GLOWING});
        DEtableInsert(t, {41, 45, 20, {2, 5}, DEMATS.VISION_DUST, 75, {1, 2}, DEMATS.LESSER_NETHER, 5, 1, DEMATS.SMALL_RADIANT});
        DEtableInsert(t, {46, 50, 20, {1, 2}, DEMATS.DREAM_DUST, 75, {1, 2}, DEMATS.GREATER_NETHER, 5, 1, DEMATS.LARGE_RADIANT});
        DEtableInsert(t, {51, 55, 22, {2, 5}, DEMATS.DREAM_DUST, 75, {1, 2}, DEMATS.LESSER_ETERNAL, 5, 1, DEMATS.SMALL_BRILLIANT});
        DEtableInsert(t, {56, 60, 22, {1, 2}, DEMATS.ILLUSION_DUST, 75, {1, 2}, DEMATS.GREATER_ETERNAL, 5, 1, DEMATS.LARGE_BRILLIANT});
        DEtableInsert(t, {61, 65, 22, {2, 5}, DEMATS.ILLUSION_DUST, 75, {2, 3}, DEMATS.GREATER_ETERNAL, 5, 1, DEMATS.LARGE_BRILLIANT});
        DEtableInsert(t, {66, 99, 22, {2, 3}, DEMATS.ARCANE_DUST, 75, {2, 3}, DEMATS.LESSER_PLANAR, 3, 1, DEMATS.SMALL_PRISMATIC});
        DEtableInsert(t, {100, 120, 22, {2, 5}, DEMATS.ARCANE_DUST, 75, {1, 2}, DEMATS.GREATER_PLANAR, 3, 1, DEMATS.LARGE_PRISMATIC});
        DEtableInsert(t, {121, 151, 22, {1, 3}, DEMATS.INFINITE_DUST, 75, {1, 2}, DEMATS.LESSER_COSMIC, 3, 1, DEMATS.SMALL_DREAM});
        DEtableInsert(t, {152, 200, 22, {4, 7}, DEMATS.INFINITE_DUST, 75, {1, 2}, DEMATS.GREATER_COSMIC, 3, 1, DEMATS.DREAM_SHARD});
        DEtableInsert(t, {272, 272, 12, 1, DEMATS.HYPN_DUST, 11, 2, DEMATS.HYPN_DUST, 33, 1, DEMATS.LESSER_CEL, 45, 2, DEMATS.LESSER_CEL});
        DEtableInsert(t, {278, 278, 16, 1, DEMATS.HYPN_DUST, 8, 2, DEMATS.HYPN_DUST, 4, 3, DEMATS.HYPN_DUST, 16, 1, DEMATS.LESSER_CEL, 28, 2, DEMATS.LESSER_CEL, 28, 3, DEMATS.LESSER_CEL});
        DEtableInsert(t, {283, 283, 7, 1, DEMATS.HYPN_DUST, 5, 2, DEMATS.HYPN_DUST, 17, 3, DEMATS.HYPN_DUST, 22, 1, DEMATS.LESSER_CEL, 22, 2, DEMATS.LESSER_CEL, 25, 3, DEMATS.LESSER_CEL});
        DEtableInsert(t, {289, 289, 8, 1, DEMATS.HYPN_DUST, 8, 2, DEMATS.HYPN_DUST, 25, 1, DEMATS.LESSER_CEL, 33, 2, DEMATS.LESSER_CEL, 27, 3, DEMATS.LESSER_CEL})
        DEtableInsert(t, {295, 295, 2, 1, DEMATS.HYPN_DUST, 16, 2, DEMATS.HYPN_DUST, 5, 3, DEMATS.HYPN_DUST, 3, 4, DEMATS.HYPN_DUST, 17, 2, DEMATS.LESSER_CEL, 30, 3, DEMATS.LESSER_CEL, 28, 4, DEMATS.LESSER_CEL});
        DEtableInsert(t, {300, 300, 4, 1, DEMATS.HYPN_DUST, 10, 2, DEMATS.HYPN_DUST, 10, 3, DEMATS.HYPN_DUST, 8, 4, DEMATS.HYPN_DUST, 25, 2, DEMATS.LESSER_CEL, 16, 3, DEMATS.LESSER_CEL, 27, 4, DEMATS.LESSER_CEL});
        DEtableInsert(t, {305, 305, 25, 2, DEMATS.HYPN_DUST, 25, 3, DEMATS.HYPN_DUST, 37, 3, DEMATS.LESSER_CEL, 12, 4, DEMATS.LESSER_CEL});
        DEtableInsert(t, {306, 306, 11, 2, DEMATS.HYPN_DUST, 8, 3, DEMATS.HYPN_DUST, 11, 4, DEMATS.HYPN_DUST, 36, 1, DEMATS.GREATER_CEL, 35, 2, DEMATS.GREATER_CEL});
        DEtableInsert(t, {312, 312, 11, 2, DEMATS.HYPN_DUST, 7, 3, DEMATS.HYPN_DUST, 8, 4, DEMATS.HYPN_DUST, 42, 1, DEMATS.GREATER_CEL, 31, 2, DEMATS.GREATER_CEL});
        DEtableInsert(t, {317, 317, 6, 2, DEMATS.HYPN_DUST, 7, 3, DEMATS.HYPN_DUST, 7, 4, DEMATS.HYPN_DUST, 6, 5, DEMATS.HYPN_DUST, 37, 2, DEMATS.GREATER_CEL, 36, 3, DEMATS.GREATER_CEL, 1, 5, DEMATS.GREATER_CEL});
        DEtableInsert(t, {318, 318, 21, 3, DEMATS.HYPN_DUST, 5, 5, DEMATS.HYPN_DUST, 42, 2, DEMATS.GREATER_CEL, 32, 3, DEMATS.GREATER_CEL});
        DEtableInsert(t, {351, 380, 85, 2.5, DEMATS.SPIRIT_DUST, 15, 1, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {381, 390, 85, 3, DEMATS.SPIRIT_DUST, 15, 1, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {391, 410, 85, 3.5, DEMATS.SPIRIT_DUST, 15, 1.5, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {411, 483, 85, 4, DEMATS.SPIRIT_DUST, 15, 2, DEMATS.MYSTERIOUS_ESS});
        DEtableInsert(t, {484, 700, 100, 2.5, DEMATS.DRAENIC_DUST});


--RARE(BLUE)ARMOR
	deTable[deKey(ARMOR, RARE)]={};
	t = deTable[deKey(ARMOR, RARE)];

        DEtableInsert(t, {11, 25, 100, 1, DEMATS.SMALL_GLIMMERING});
        DEtableInsert(t, {26, 30, 100, 1, DEMATS.LARGE_GLIMMERING});
        DEtableInsert(t, {31, 35, 100, 1, DEMATS.SMALL_GLOWING});
        DEtableInsert(t, {36, 40, 100, 1, DEMATS.LARGE_GLOWING});
        DEtableInsert(t, {41, 45, 100, 1, DEMATS.SMALL_RADIANT});
        DEtableInsert(t, {46, 50, 100, 1, DEMATS.LARGE_RADIANT});
        DEtableInsert(t, {51, 55, 100, 1, DEMATS.SMALL_BRILLIANT});
        DEtableInsert(t, {56, 65, 99.5, 1, DEMATS.LARGE_BRILLIANT, 0.5, 1, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {66, 99, 99.5, 1, DEMATS.SMALL_PRISMATIC, 0.5, 1, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {100, 120, 99.5, 1, DEMATS.LARGE_PRISMATIC, 0.5, 1, DEMATS.VOID_CRYSTAL});
        DEtableInsert(t, {121, 164, 99.5, 1, DEMATS.SMALL_DREAM, 0.5, 1, DEMATS.ABYSS_CRYSTAL});
        DEtableInsert(t, {165, 280, 99.5, 1, DEMATS.DREAM_SHARD, 0.5, 1, DEMATS.ABYSS_CRYSTAL});
        DEtableInsert(t, {288, 288, 100, 1, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {292, 292, 100, 1, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {300, 300, 95, 1, DEMATS.SMALL_HEAVENLY, 5, 2, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {308, 308, 100, 1, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {316, 316, 100, 1, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {318, 318, 100, 1, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {325, 325, 100, 1, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {333, 333, 97, 1, DEMATS.HEAVENLY_SHARD, 3, 2, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {339, 339, 98, 1, DEMATS.HEAVENLY_SHARD, 2, 2, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {346, 346, 99, 1, DEMATS.HEAVENLY_SHARD, 1, 2, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {352, 380, 100, 1, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {381, 424, 100, 1, DEMATS.SMALL_ETHEREAL});
        DEtableInsert(t, {425, 449, 100, 1, DEMATS.ETHEREAL_SHARD});
        DEtableInsert(t, {450, 450, 20, 1, DEMATS.ETHEREAL_SHARD, 80, 1, DEMATS.SMALL_ETHEREAL});
        DEtableInsert(t, {451, 476, 100, 1, DEMATS.ETHEREAL_SHARD});
        DEtableInsert(t, {477, 714, 90, 9, DEMATS.DRAENIC_DUST, 10, 1, DEMATS.LUMINOUS_SHARD});
        DEtableInsert(t, {715, 850, 30, 3, DEMATS.ARKHANA, 70, 1, DEMATS.LEYLIGHT_SHARD});


--RARE(BLUE)WEAPON
	deTable[deKey(WEAPON, RARE)]={};
	t = deTable[deKey(WEAPON, RARE)];

        DEtableInsert(t, {11, 25, 100, 1, DEMATS.SMALL_GLIMMERING});
        DEtableInsert(t, {26, 30, 100, 1, DEMATS.LARGE_GLIMMERING});
        DEtableInsert(t, {31, 35, 100, 1, DEMATS.SMALL_GLOWING});
        DEtableInsert(t, {36, 40, 100, 1, DEMATS.LARGE_GLOWING});
        DEtableInsert(t, {41, 45, 100, 1, DEMATS.SMALL_RADIANT});
        DEtableInsert(t, {46, 50, 100, 1, DEMATS.LARGE_RADIANT});
        DEtableInsert(t, {51, 55, 100, 1, DEMATS.SMALL_BRILLIANT});
        DEtableInsert(t, {56, 65, 99.5, 1, DEMATS.LARGE_BRILLIANT, 0.5, 1, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {66, 99, 99.5, 1, DEMATS.SMALL_PRISMATIC, 0.5, 1, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {100, 120, 99.5, 1, DEMATS.LARGE_PRISMATIC, 0.5, 1, DEMATS.VOID_CRYSTAL});
        DEtableInsert(t, {121, 164, 99.5, 1, DEMATS.SMALL_DREAM, 0.5, 1, DEMATS.ABYSS_CRYSTAL});
        DEtableInsert(t, {165, 280, 99.5, 1, DEMATS.DREAM_SHARD, 0.5, 1, DEMATS.ABYSS_CRYSTAL});
        DEtableInsert(t, {308, 308, 100, 1, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {316, 316, 100, 1, DEMATS.SMALL_HEAVENLY});
        DEtableInsert(t, {318, 318, 100, 1, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {333, 333, 100, 1, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {346, 346, 93, 1, DEMATS.HEAVENLY_SHARD, 7, 2, DEMATS.HEAVENLY_SHARD});
        DEtableInsert(t, {381, 424, 100, 1, DEMATS.SMALL_ETHEREAL});
        DEtableInsert(t, {425, 449, 100, 1, DEMATS.ETHEREAL_SHARD});
        DEtableInsert(t, {450, 450, 20, 1, DEMATS.ETHEREAL_SHARD, 80, 1, DEMATS.SMALL_ETHEREAL});
        DEtableInsert(t, {451, 476, 100, 1, DEMATS.ETHEREAL_SHARD});
        DEtableInsert(t, {477, 800, 90, 9, DEMATS.DRAENIC_DUST, 10, 1, DEMATS.LUMINOUS_SHARD});


--EPIC(PURPLE)ARMOR
	deTable[deKey(ARMOR, EPIC)]={};
	t = deTable[deKey(ARMOR, EPIC)];

        DEtableInsert(t, {40, 45, 100, {2, 4}, DEMATS.SMALL_RADIANT});
        DEtableInsert(t, {46, 50, 100, {2, 4}, DEMATS.LARGE_RADIANT});
        DEtableInsert(t, {51, 55, 100, {2, 4}, DEMATS.SMALL_BRILLIANT});
        DEtableInsert(t, {56, 60, 100, 1, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {61, 80, 50, 1, DEMATS.NEXUS_CRYSTAL, 50, 2, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {95, 100, 100, {1, 2}, DEMATS.VOID_CRYSTAL});
        DEtableInsert(t, {105, 164, 33.3, 1, DEMATS.VOID_CRYSTAL, 66.6, 2, DEMATS.VOID_CRYSTAL});
        DEtableInsert(t, {165, 280, 100, 1, DEMATS.ABYSS_CRYSTAL});
        DEtableInsert(t, {281, 450, 100, 1, DEMATS.MAELSTROM_CRYSTAL});
        DEtableInsert(t, {420, 600, 100, 1, DEMATS.SHA_CRYSTAL});
        DEtableInsert(t, {601, 714, 100, 1, DEMATS.TEMPORAL_CRYSTAL});
        DEtableInsert(t, {715, 950, 100, 1, DEMATS.CHAOS_CRYSTAL});


--EPIC(PURPLE)WEAPON
	deTable[deKey(WEAPON, EPIC)]={};
	t = deTable[deKey(WEAPON, EPIC)];

        DEtableInsert(t, {40, 45, 100, {2, 4}, DEMATS.SMALL_RADIANT});
        DEtableInsert(t, {46, 50, 100, {2, 4}, DEMATS.LARGE_RADIANT});
        DEtableInsert(t, {51, 55, 100, {2, 4}, DEMATS.SMALL_BRILLIANT});
        DEtableInsert(t, {56, 60, 100, 1, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {61, 80, 33.3, 1, DEMATS.NEXUS_CRYSTAL, 66.6, 2, DEMATS.NEXUS_CRYSTAL});
        DEtableInsert(t, {95, 100, 100, {1, 2}, DEMATS.VOID_CRYSTAL});
        DEtableInsert(t, {105, 164, 33.3, 1, DEMATS.VOID_CRYSTAL, 66.6, 2, DEMATS.VOID_CRYSTAL});
        DEtableInsert(t, {165, 280, 100, 1, DEMATS.ABYSS_CRYSTAL});
        DEtableInsert(t, {281, 450, 100, 1, DEMATS.MAELSTROM_CRYSTAL});
        DEtableInsert(t, {420, 600, 100, 1, DEMATS.SHA_CRYSTAL});
        DEtableInsert(t, {601, 714, 100, 1, DEMATS.TEMPORAL_CRYSTAL});
 
end

-----------------------------------------


local function Atr_FindDEentry (classID, itemRarity, itemLevel)

  local itemTypeNum = classID

 local t = deTable[deKey(itemTypeNum, itemRarity)];

  if (t) then
    local n;
    for n = 1, #t do

      local ta = t[n];

      if (itemLevel >= ta[1] and itemLevel <= ta[2]) then
        return ta;
      end
    end
  end


end

-----------------------------------------

function Atr_AddDEDetailsToTip (tip, classID, itemRarity, itemLevel)

  local ta = Atr_FindDEentry (classID, itemRarity, itemLevel);

  if (ta) then
    local x;
    for x = 3,#ta,3 do
      local percent = math.floor (ta[x]*100) / 100;

      local deitem = Atr_GetDEitemName(ta[x+2]);
      if (deitem == nil) then
        deitem = "???";
      end

      if (percent > 0) then
        tip:AddLine ("  |cFFFFFFFF"..percent.."%|r   "..ta[x+1].." "..deitem)
      end
    end
  end

end

-----------------------------------------

function Atr_DumpDETable (itemType, itemRarity)

  local t = deTable[deKey(itemType, itemRarity)];

  if (t) then
    local n, x;
    for n = 1, #t do
      local ta = t[n];

      zc.msg_pink ("iLvl: "..ta[1].."-"..ta[2]);

      for x = 3,#ta,3 do
        zc.msg_pink ("   "..ta[x].."%  "..ta[x+1].."  "..Atr_GetDEitemName(ta[x+2]).."  ("..Atr_GetAuctionPrice (Atr_GetDEitemName(ta[x+2]))..")");
      end
    end
  end

end

-----------------------------------------

function Atr_CalcDisenchantPrice( classID, itemRarity, itemLevel)

  if (Atr_IsWeaponType (classID) or Atr_IsArmorType (classID)) then
    if (itemRarity == UNCOMMON or itemRarity == RARE or itemRarity == EPIC) then

      local dePrice = 0;

      local ta = Atr_FindDEentry (classID, itemRarity, itemLevel);
      if (ta) then
        local x;
        for x = 3,#ta,3 do
          local price = Atr_GetAuctionPriceDE (ta[x+2]);
          if (price) then
            dePrice = dePrice + (ta[x] * ta[x+1] * price);
          end
        end
      end

      return math.floor (dePrice/100);
    end
  end

  return nil;   -- can't be disenchanted
end

-----------------------------------------

function Atr_STWP_AddVendorInfo (tip, xstring, vendorPrice, auctionPrice)

  if (AUCTIONATOR_V_TIPS == 1 and vendorPrice > 0) then
    local vpadding = Atr_CalcTTpadding (vendorPrice, auctionPrice);
    tip:AddDoubleLine (ZT("Vendor")..xstring, "|cFFFFFFFF"..zc.priceToMoneyString (vendorPrice))
  end

end

-----------------------------------------

function Atr_STWP_AddAuctionInfo (tip, xstring, link, auctionPrice)
  if (AUCTIONATOR_A_TIPS == 1) then

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

  if (link == nil or zc.IsBattlePetLink(link)) then
    if link and not pet_links[ link ] then
      pet_links[ link ] = Auctionator.ItemLink:new({ item_link = link })
      Auctionator.Debug.Message( pet_links[ link ]:GetField( Auctionator.Constants.ItemLink.TYPE ),
        pet_links[ link ]:IdString() )
    end

    return;
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

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, _, _, _, _, itemVendorPrice, classID = GetItemInfo (link);
  itemLevel = ItemUpgradeInfo:GetUpgradedItemLevel(itemLink)

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


--[[

-- TODO http://www.wowinterface.com/forums/showthread.php?p=315431
 hooksecurefunc (GameTooltip, "SetTradeSkillItem",
   function (tip, skill, id)
     local link = GetTradeSkillItemLink(skill);
     local num  = GetTradeSkillNumMade(skill);
     if id then
       link = GetTradeSkillReagentItemLink(skill, id);
       num = select (3, GetTradeSkillReagentInfo(skill, id));
     end

     Atr_ShowTipWithPricing (tip, link, num);
   end
 );

]]--

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