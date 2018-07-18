
AuctionatorVersion = "???";   -- set from toc upon loading
AuctionatorAuthor  = "Borjamacare";

AuctionatorLoaded = false;
AuctionatorInited = false;

local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local zz = zc.md;
local _
local ItemUpgradeInfo = LibStub( 'LibItemUpgradeInfo-1.0' )

gAtrZC = addonTable.zc;   -- share with AuctionatorDev

-----------------------------------------
local recommendElements     = {};

AUCTIONATOR_ENABLE_ALT    = 1;
AUCTIONATOR_SHOW_ST_PRICE = 0;
AUCTIONATOR_SHOW_TIPS   = 1;
AUCTIONATOR_DEF_DURATION  = "N";    -- none
AUCTIONATOR_V_TIPS      = 1;
AUCTIONATOR_A_TIPS      = 1;
AUCTIONATOR_D_TIPS      = 1;
AUCTIONATOR_SHIFT_TIPS    = 1;
AUCTIONATOR_DE_DETAILS_TIPS = 4;    -- off by default
AUCTIONATOR_DEFTAB      = 1;

AUCTIONATOR_DB_MAXITEM_AGE  = 180;
AUCTIONATOR_DB_MAXHIST_AGE  = 21;   -- obsolete - just needed for migration
AUCTIONATOR_DB_MAXHIST_DAYS = 5;

AUCTIONATOR_OPEN_FIRST    = 0;  -- obsolete - just needed for migration
AUCTIONATOR_OPEN_BUY    = 0;  -- obsolete - just needed for migration

local SELL_TAB    = 1;
local MORE_TAB    = 2;
local BUY_TAB     = 3;


-- saved variables - amounts to undercut

local auctionator_savedvars_defaults = {
  ["_5000000"]      = 10000;  -- amount to undercut buyouts over 500 gold
  ["_1000000"]      = 2500;
  ["_200000"]       = 1000;
  ["_50000"]        = 500;
  ["_10000"]        = 200;
  ["_2000"]       = 100;
  ["_500"]        = 5;
  ["STARTING_DISCOUNT"] = 5;  -- PERCENT
  ["LOG_DE_DATA_X"]   = true;
}


-----------------------------------------

local auctionator_orig_AuctionFrameTab_OnClick;
local auctionator_orig_ContainerFrameItemButton_OnModifiedClick;
local auctionator_orig_AuctionFrameAuctions_Update;
local auctionator_orig_CanShowRightUIPanel;
local auctionator_orig_ChatEdit_InsertLink;
local auctionator_orig_ChatFrame_OnEvent;

local gForceMsgAreaUpdate = true;
local gAtr_ClickAuctionSell = false;

local gTimeZero;
local gTimeTightZero;

local cslots = {};
local gEmptyBScached = nil;

local gAutoSingleton = 0;
local gTradeSkillFrameModded = false

-- set to the last item posted, even after the posting so that message and icon can be displayed
local gJustPosted = { ItemName=nil, ItemLink=nil, BuyoutPrice=0, StackSize=0, NumStacks=0 }

local auctionator_pending_message = nil;

local kBagIDs = {};

local Atr_Confirm_Proc_Yes = nil;

local gStartingTime     = time();
local gHentryTryAgain   = nil;
local gCondensedThisSession = {};

local gAtr_Owner_Item_Indices = {};

local ITEM_HIST_NUM_LINES = 20;

local gActiveAuctions = {};

local gHlistNeedsUpdate = false;
local gAtr_SellTriggeredByAuctionator = false;

local gSellPane;
local gMorePane;
local gActivePane;
local gShopPane;

local gCurrentPane;

local gHistoryItemList = {};

local ATR_CACT_NULL             = 0;
local ATR_CACT_READY            = 1;
local ATR_CACT_PROCESSING         = 2;
local ATR_CACT_WAITING_ON_CANCEL_CONFIRM  = 3;

gATR_BattlePetIconCache = {};

local gItemPostingInProgress = false;

gAtr_ptime = nil;   -- a more precise timer but may not be updated very frequently

gAtr_ScanDB     = nil;
gAtr_PriceHistDB  = nil;

-----------------------------------------

ATR_SK_GLYPHS   = "*_glyphs";
ATR_SK_GEMS_CUT   = "*_gemscut";
ATR_SK_GEMS_UNCUT = "*_gemsuncut";
ATR_SK_ITEM_ENH   = "*_itemenh";
ATR_SK_POT_ELIX   = "*_potelix";
ATR_SK_FLASKS   = "*_flasks";
ATR_SK_HERBS    = "*_herbs";

-----------------------------------------

local roundPriceDown, ToTightTime, FromTightTime, monthDay;

-----------------------------------------

function Atr_RegisterEvents(self)
  Auctionator.Debug.Message( 'Atr_RegisterEvents' )

  self:RegisterEvent("VARIABLES_LOADED");
  self:RegisterEvent("ADDON_LOADED");

  self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
  self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");

  self:RegisterEvent("AUCTION_MULTISELL_START");
  self:RegisterEvent("AUCTION_MULTISELL_UPDATE");
  self:RegisterEvent("AUCTION_MULTISELL_FAILURE");

  self:RegisterEvent("AUCTION_HOUSE_SHOW");
  self:RegisterEvent("AUCTION_HOUSE_CLOSED");

  self:RegisterEvent("NEW_AUCTION_UPDATE");
  self:RegisterEvent("CHAT_MSG_ADDON");
  self:RegisterEvent("PLAYER_ENTERING_WORLD");

end

-----------------------------------------

function Atr_EventHandler(self, event, ...)
  -- Auctionator.Debug.Message( 'Atr_EventHandler', event, ... )

  if (event == "VARIABLES_LOADED")      then  Atr_OnLoad();             end;
  if (event == "ADDON_LOADED")        then  Atr_OnAddonLoaded(...);       end;
  if (event == "AUCTION_ITEM_LIST_UPDATE")  then  Atr_OnAuctionUpdate(...);       end;
  if (event == "AUCTION_OWNED_LIST_UPDATE") then  Atr_OnAuctionOwnedUpdate();     end;

  if (event == "AUCTION_MULTISELL_START")   then  Atr_OnAuctionMultiSellStart();    end;
  if (event == "AUCTION_MULTISELL_UPDATE")  then  Atr_OnAuctionMultiSellUpdate(...); end;
  if (event == "AUCTION_MULTISELL_FAILURE") then  Atr_OnAuctionMultiSellFailure();   end;

  if (event == "AUCTION_HOUSE_SHOW")      then  Atr_OnAuctionHouseShow();       end;
  if (event == "AUCTION_HOUSE_CLOSED")    then  Atr_OnAuctionHouseClosed();     end;
  if (event == "NEW_AUCTION_UPDATE")      then  Atr_OnNewAuctionUpdate();       end;
  if (event == "CHAT_MSG_ADDON")        then  Atr_OnChatMsgAddon(...);      end;
  if (event == "PLAYER_ENTERING_WORLD")   then  Atr_OnPlayerEnteringWorld();    end;

  if (event == "UNIT_SPELLCAST_SENT")     then  Atr_OnSpellCastSent(...);     end;
  if (event == "UNIT_SPELLCAST_SUCCEEDED")  then  Atr_OnSpellCastSucess(...);     end;
  if (event == "BAG_UPDATE")          then  Atr_OnBagUpdate(...);     end;
end


-----------------------------------------

function Atr_SetupHookFunctionsEarly ()
  Auctionator.Debug.Message( 'Atr_SetupHookFunctionsEarly' )

  if (Atr_Dev_SetupEarlyHooks) then
    Atr_Dev_SetupEarlyHooks();
  end

  Atr_Hook_OnTooltipAddMoney ();

end


-----------------------------------------

local auctionator_orig_GetAuctionItemInfo;

function Atr_SetupHookFunctions ()
  Auctionator.Debug.Message( 'Atr_SetupHookFunctions' )

  auctionator_orig_AuctionFrameTab_OnClick = AuctionFrameTab_OnClick;
  AuctionFrameTab_OnClick = Atr_AuctionFrameTab_OnClick;

  auctionator_orig_ContainerFrameItemButton_OnModifiedClick = ContainerFrameItemButton_OnModifiedClick;
  ContainerFrameItemButton_OnModifiedClick = Atr_ContainerFrameItemButton_OnModifiedClick;

  auctionator_orig_AuctionFrameAuctions_Update = AuctionFrameAuctions_Update;
  AuctionFrameAuctions_Update = Atr_AuctionFrameAuctions_Update;

  auctionator_orig_CanShowRightUIPanel = CanShowRightUIPanel;
  CanShowRightUIPanel = auctionator_CanShowRightUIPanel;

  auctionator_orig_ChatEdit_InsertLink = ChatEdit_InsertLink;
  ChatEdit_InsertLink = auctionator_ChatEdit_InsertLink;

  auctionator_orig_ChatFrame_OnEvent = ChatFrame_OnEvent;
  ChatFrame_OnEvent = auctionator_ChatFrame_OnEvent;

end

-----------------------------------------

function GetRealmFacInfoString()
  Auctionator.Debug.Message( 'GetRealmFacInfoString' )

  local realm_fac, data
  local rf_string = ""
  if (AUCTIONATOR_PRICE_DATABASE) then
    for realm_fac, data in pairs (AUCTIONATOR_PRICE_DATABASE) do
      if (realm_fac and not zc.StringStartsWith (realm_fac, "__")) then
        rf_string = rf_string..", "..realm_fac
        local c = 0;
        if (data) then
          for n, v in pairs (data) do
            c = c + 1;
          end
        end
        rf_string = rf_string.." ("..c..")"
      end
    end
  end

  return rf_string
end

-----------------------------------------

local function IsCataEnchanting (prof)
  Auctionator.Debug.Message( 'IsCataEnchanting' )

  if (prof) then
    local profname, _, skillLevel = GetProfessionInfo (prof)

    if (zc.StringSame ("enchanting", profname) and skillLevel >= 450) then
      return true
    end
  end

  return false

end

-----------------------------------------

local function IsCataEnchanter()
  Auctionator.Debug.Message( 'IsCataEnchanter' )

  local prof1, prof2 = GetProfessions()

  if (IsCataEnchanting (prof1) or IsCataEnchanting (prof2)) then
    return true
  end

  return false
end


-----------------------------------------

local checkVerString    = nil;
local versionReminderCalled = false;  -- make sure we don't bug user more than once

-----------------------------------------

local function VersionStringToInt( versionString )
  Auctionator.Debug.Message( 'VersionStringToInt', versionString )
  local major, minor, patch = strsplit( '.', versionString )

  return ( tonumber( major ) or -1 ),
    ( tonumber( minor ) or -1 ),
    ( tonumber( patch ) or -1 )
end

local function CheckVersion( verString )
  if checkVerString == nil then
    checkVerString = AuctionatorVersion
  end

  Auctionator.Debug.Message( 'CheckVersion', verString, checkVerString )

  local userMajor, userMinor, userPatch = VersionStringToInt( checkVerString )
  local otherMajor, otherMinor, otherPatch = VersionStringToInt( verString )

  -- TODO is this needed? kept it in, not sure if it was here for backwards compatibility?
  if userMajor == nil or userMinor == nil or userPatch == nil then
    return false
  end

  return userMajor < otherMajor or
    ( userMajor == otherMajor and userMinor < otherMinor ) or
    ( userMajor == otherMajor and userMinor == otherMinor and userPatch < otherPatch )
end

-----------------------------------------

function Atr_VersionReminder ()
  Auctionator.Debug.Message( 'Atr_VersionReminder' )

  if (not versionReminderCalled) then
    versionReminderCalled = true;

    zc.msg_anm (ZT("There is a more recent version of Auctionator: VERSION").." "..checkVerString);
  end
end



-----------------------------------------

local VREQ_sent = 0;

-----------------------------------------

function Atr_SendAddon_VREQ (type, target)
  Auctionator.Debug.Message( 'Atr_SendAddon_VREQ', type, target )

  VREQ_sent = time()

  if (not zc.StringSame (type, "WHISPER")) then
    zz ("sending vreq to", type)
  end

  C_ChatInfo.SendAddonMessage( "ATR", "VREQ_"..AuctionatorVersion, type, target )
end

-----------------------------------------

function Atr_OnChatMsgAddon (...)
  local prefix, msg, distribution, sender = ...

  if prefix == "ATR" then
    Auctionator.Debug.Message( 'Atr_OnChatMsgAddon', ... )

    local s = string.format(
      "%s %s |cff88ffff %s |cffffffaa %s|r", prefix, distribution, sender, msg
    )

    if zc.StringStartsWith( msg, "VREQ_" ) then
      C_ChatInfo.SendAddonMessage( "ATR", "V_"..AuctionatorVersion, "WHISPER", sender )
    end

    if zc.StringStartsWith (msg, "IREQ_") then
      collectgarbage( "collect" )
      UpdateAddOnMemoryUsage()
      local mem  = math.floor( GetAddOnMemoryUsage("Auctionator") )
      C_ChatInfo.SendAddonMessage( "ATR", "I_" .. Atr_GetDBsize() .. "_" .. mem .. "_" .. #AUCTIONATOR_SHOPPING_LISTS.."_"..GetRealmFacInfoString(), "WHISPER", sender)
    end

    if zc.StringStartsWith( msg, "V_" ) and time() - VREQ_sent < 5 then

      local herVerString = string.sub( msg, 3 )
      local outOfDate = CheckVersion( herVerString )

      if outOfDate then
        zc.AddDeferredCall( 3, "Atr_VersionReminder", nil, nil, "VR" )
      end
    end
  end

  Atr_OnChatMsgAddon_ShoppingListCmds( prefix, msg, distribution, sender )
end


-----------------------------------------

function Atr_GetAuctionatorMemString(msg)
  Auctionator.Debug.Message( 'Atr_GetAuctionatorMemString', msg )

  collectgarbage  ("collect");

  UpdateAddOnMemoryUsage();

  local mem  = GetAddOnMemoryUsage("Auctionator");
  return string.format ("%6i KB", math.floor(mem));
end

-----------------------------------------

local function Atr_RestoreDElog()
  Auctionator.Debug.Message( 'Atr_RestoreDElog' )

  if (AUCTIONATOR_DE_DATA_BAK and #AUCTIONATOR_DE_DATA_BAK > 0) then

    AUCTIONATOR_DE_DATA = {}

    zc.CopyDeep (AUCTIONATOR_DE_DATA, AUCTIONATOR_DE_DATA_BAK)
    zc.msg_anm ("Disenchant data restored.  Number of entries:", #AUCTIONATOR_DE_DATA_BAK);
  else
    zc.msg_anm ("No data available to be restored");
  end

end

-----------------------------------------

local function Atr_DumpDElog()
  Auctionator.Debug.Message( 'Atr_DumpDElog' )

  if (AUCTIONATOR_DE_DATA == nil or #AUCTIONATOR_DE_DATA == 0) then
    zc.msg_anm ("no data has been collected");
    return
  end

  AUCTIONATOR_DE_DATA_BAK = {}

  zc.CopyDeep (AUCTIONATOR_DE_DATA_BAK, AUCTIONATOR_DE_DATA)

  AUCTIONATOR_DE_DATA = {}

  zc.msg_anm ("Disenchant data cleared.");

  Atr_LUA_explanation:SetText ("");


  local n
  local x = 0;
  for n = 1,#AUCTIONATOR_DE_DATA_BAK do
    local a, b = strsplit ("_", AUCTIONATOR_DE_DATA_BAK[n])
    x = x + tonumber (a) + tonumber (b)
  end


  local msg = "DISENCHANT "..time().." "..x.." "..UnitName("player").."\n"

  for n = 1,#AUCTIONATOR_DE_DATA_BAK do
    msg = msg..AUCTIONATOR_DE_DATA_BAK[n].."\n"
  end
end

-----------------------------------------

function Atr_ClearItemStackingPrefs ()
  Auctionator.Debug.Message( 'Atr_ClearItemStackingPrefs' )

  local text, spinfo;

  for text, spinfo in pairs (AUCTIONATOR_STACKING_PREFS) do
    if (not zc.StringContains (text, "_")) then
      AUCTIONATOR_STACKING_PREFS[text] = nil
    end
  end
end

-----------------------------------------

local function Atr_ClearPostHistory ()
  Auctionator.Debug.Message( 'Atr_ClearPostHistory' )

  AUCTIONATOR_PRICING_HISTORY = {};
  zc.msg_anm (ZT("posting history cleared"));
end

-----------------------------------------

local function Atr_ClearFullScanDB ()
  Auctionator.Debug.Message( 'Atr_ClearFullScanDB' )

  gAtr_ScanDB = nil;
  AUCTIONATOR_PRICE_DATABASE = nil;
  Atr_InitScanDB();
  zc.msg_anm (ZT("full scan database cleared"));
end

-----------------------------------------

local function Atr_SlashCmdFunction(msg)
  Auctionator.Debug.Message( 'Atr_SlashCmdFunction', msg )

  local cmd, param1u, param2u, param3u = zc.words (msg);

  if (cmd == nil or type (cmd) ~= "string") then
    return;
  end

      cmd    = cmd     and cmd:lower()    or nil;
  local param1 = param1u and param1u:lower() or nil;
  local param2 = param2u and param2u:lower() or nil;
  local param3 = param3u and param3u:lower() or nil;

  if (cmd == "mem") then

    UpdateAddOnMemoryUsage();

    for i = 1, GetNumAddOns() do
      local mem  = GetAddOnMemoryUsage(i);
      local name = GetAddOnInfo(i);
      if (mem > 0) then
        local s = string.format ("%6i KB   %s", math.floor(mem), name);
        zc.msg_yellow (s);
      end
    end

  elseif (cmd == "share" and param1 == "lists") then
    Atr_Send_ShareShoppingListRequest(param2)

  elseif (cmd == "locale") then
    Atr_PickLocalizationTable (param1u);

  elseif (cmd == "fsc") then

    if (param1) then
      AUCTIONATOR_FS_CHUNK = tonumber(param1);
    end

    if (AUCTIONATOR_FS_CHUNK == nil) then
      zc.msg_anm ("full scan chunk size: ", gDefaultFullScanChunkSize, " (default)");
    else
      zc.msg_anm ("full scan chunk size: ", AUCTIONATOR_FS_CHUNK);
    end


  elseif (cmd == "generr") then

    local y = 5 + nil;

  elseif (cmd == "vsl") then

    Atr_ShpList_Validate()

  elseif (cmd == "delog") then

    AUCTIONATOR_SAVEDVARS.LOG_DE_DATA_X = zc.Negate (AUCTIONATOR_SAVEDVARS.LOG_DE_DATA_X)

    EnableDisableDElogging ()

  elseif (cmd == "dedump") then

    Atr_DumpDElog()

  elseif (cmd == "derestore") then

    Atr_RestoreDElog()

    elseif (cmd == "declear") then

    AUCTIONATOR_DE_DATA   = nil
    AUCTIONATOR_DE_DATA_BAK = nil

    zc.msg_anm ("Disenchant data cleared");

  elseif (cmd == "clear") then

    zc.msg_anm ("memory usage: "..Atr_GetAuctionatorMemString());

    if    (param1 == "fullscandb") then   Atr_ClearFullScanDB()
    elseif  (param1 == "posthistory") then    Atr_ClearPostHistory()
    elseif  (param1 == "ssprefs") then
      Atr_ClearItemStackingPrefs()
      zc.msg_anm (ZT("selling preferences cleared"))
    end

    collectgarbage  ("collect");

    zc.msg_anm ("memory usage: "..Atr_GetAuctionatorMemString());
  elseif (Atr_HandleDevCommands and Atr_HandleDevCommands (cmd, param1, param2)) then
    -- do nothing
  else
    zc.msg_anm (ZT("unrecognized command"));
  end

end


-----------------------------------------

function EnableDisableDElogging ()
  Auctionator.Debug.Message( 'EnableDisableDElogging' )

  if (not IsCataEnchanter()) then
    return
  end

  if (AUCTIONATOR_SAVEDVARS and (AUCTIONATOR_SAVEDVARS.LOG_DE_DATA_X or AUCTIONATOR_SAVEDVARS.LOG_DE_DATA_X == nil)) then

    Atr_core:RegisterEvent("UNIT_SPELLCAST_START");
    Atr_core:RegisterEvent("UNIT_SPELLCAST_SENT");
    Atr_core:RegisterEvent("UNIT_SPELLCAST_STOP");
    Atr_core:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    Atr_core:RegisterEvent("BAG_UPDATE");

    local num = AUCTIONATOR_DE_DATA and #AUCTIONATOR_DE_DATA or 0

    zz ("Disenchanting info is being logged.  Current number of entries:", num)

  else

    Atr_core:UnregisterEvent("UNIT_SPELLCAST_START");
    Atr_core:UnregisterEvent("UNIT_SPELLCAST_SENT");
    Atr_core:UnregisterEvent("UNIT_SPELLCAST_STOP");
    Atr_core:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    Atr_core:UnregisterEvent("BAG_UPDATE");

    zz ("disenchanting info is NOT being logged")
  end
end

-----------------------------------------

local function Atr_OnClickTradeSkillBut()
  Auctionator.Debug.Message( 'Atr_OnClickTradeSkillBut' )

  if (not AuctionFrame or not AuctionFrame:IsShown()) then
    Atr_Error_Display (ZT("When the Auction House is open\nclicking this button tells Auctionator\nto scan for the item and all its reagents."))
    return
  end

  Atr_SelectPane (BUY_TAB);

  local index = TradeSkillFrame.RecipeList:GetSelectedRecipeID()


  local link = C_TradeSkillUI.GetRecipeItemLink(index)

  local _, _, _, _, _, itemType = GetItemInfo (link);

  local numReagents = C_TradeSkillUI.GetRecipeNumReagents(index)

  local reagentId

  local shoppingListName = GetItemInfo (link)
  if (shoppingListName == nil) then
    shoppingListName = C_TradeSkillUI.GetRecipeInfo(index).name
  end

  local items = {}

  if (shoppingListName) then
    table.insert (items, shoppingListName)
  end

  for reagentId = 1, numReagents do
    local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(index, reagentId)
    if (reagentName and not zc.StringSame(reagentName, "Crystal Vial")) then
      table.insert (items, reagentName)
    end
  end

  Atr_SearchAH (shoppingListName, items, itemType)
end

-----------------------------------------

local function Atr_ModTradeSkillFrame()
  Auctionator.Debug.Message( 'Atr_ModTradeSkillFrame' )

  if (gTradeSkillFrameModded) then
    return
  end

  if (TradeSkillFrame) then
    gTradeSkillFrameModded = true

    local button = CreateFrame("BUTTON", "Auctionator_Search", TradeSkillFrame, "UIPanelButtonTemplate");
    button:SetPoint("RIGHT", "TradeSkillFrame", "RIGHT", -35, 100);

    button:SetHeight (20)
    button:SetText("AH")
    button:SetNormalFontObject(_G["GameFontNormalSmall"])
    button:SetHighlightFontObject(_G["GameFontNormalSmall"])
    button:SetDisabledFontObject(_G["GameFontNormalSmall"])
    button:SetScript ("OnClick", Atr_OnClickTradeSkillBut)
    zz ("TradeSkillFrame modded")
  else
    zz ("TradeSkillFrame not loaded")
  end



end
-----------------------------------------

function Atr_InitScanDB()
  Auctionator.Debug.Message( 'Atr_InitScanDB' )

  local realm_Faction = GetRealmName().."_"..UnitFactionGroup ("player");

  if (AUCTIONATOR_PRICE_DATABASE and AUCTIONATOR_PRICE_DATABASE["__dbversion"] == nil) then -- migrate version 1 to version 2

    local temp = {};

    zc.CopyDeep (temp, AUCTIONATOR_PRICE_DATABASE);

    AUCTIONATOR_PRICE_DATABASE = {};
    AUCTIONATOR_PRICE_DATABASE["__dbversion"] = 2;

    AUCTIONATOR_PRICE_DATABASE[realm_Faction] = {};
    zc.CopyDeep (AUCTIONATOR_PRICE_DATABASE[realm_Faction], temp);

    temp = {};
  end

  if (AUCTIONATOR_PRICE_DATABASE and AUCTIONATOR_PRICE_DATABASE["__dbversion"] == 2) then   -- migrate version 2 to version 3

    local temp_price_db = {};

    for realm_fac, data in pairs (AUCTIONATOR_PRICE_DATABASE) do

      if (type(data) == "table") then

        temp_price_db[realm_fac] = {};

        zc.md ("migrating Auctionator db to version 3 for:", realm_fac);

        local name, price;
        local count = 0;

        for name, price in pairs (data) do

          if (type(price) == "table") then    -- this is to fix the bug where I didn't set the dbversion correctly for NEW dbs
            temp_price_db[realm_fac][name] = price;
          else
            Atr_UpdateScanDBprice (name, price, temp_price_db[realm_fac]);
          end
          count = count + 1;
        end

        zc.md (count, "entries migrated");
      end
    end

    AUCTIONATOR_PRICE_DATABASE = temp_price_db;
    AUCTIONATOR_PRICE_DATABASE["__dbversion"] = 3;
  end

  -- migrate version 3 to version 4

  if (AUCTIONATOR_PRICE_DATABASE and AUCTIONATOR_PRICE_DATABASE["__dbversion"] == 3) then
    for realm_fac, data in pairs (AUCTIONATOR_PRICE_DATABASE) do
      if (type(data) == "table") then
        zc.md ("migrating Auctionator db to version 4 for:", realm_fac);
        local name, itemInfo;
        for name, itemInfo in pairs (data) do
          if (type(itemInfo) == "table") then
            itemInfo["po"] = 1;   -- flag for deletion after the first full scan
          end
        end
      end
    end
    AUCTIONATOR_PRICE_DATABASE["__dbversion"] = 4;
  end

  if (AUCTIONATOR_PRICE_DATABASE == nil) then
    AUCTIONATOR_PRICE_DATABASE = {};
    AUCTIONATOR_PRICE_DATABASE["__dbversion"] = 4;
  end

  if (AUCTIONATOR_PRICE_DATABASE[realm_Faction] == nil) then
    AUCTIONATOR_PRICE_DATABASE[realm_Faction] = {};
  end

  gAtr_ScanDB = AUCTIONATOR_PRICE_DATABASE[realm_Faction];

  Atr_PruneScanDB ();
  Atr_PrunePostDB ();

  Atr_Broadcast_DBupdated (#gAtr_ScanDB, "dbinited");

end


-----------------------------------------

function Atr_OnLoad()
  Auctionator.Debug.Message( 'Atr_OnLoad' )

  AuctionatorVersion = GetAddOnMetadata("Auctionator", "Version");

  gTimeZero   = time({year=2000, month=1, day=1, hour=0});
  gTimeTightZero  = time({year=2008, month=8, day=1, hour=0});

  local x;
  for x = 0, NUM_BAG_SLOTS do
    kBagIDs[x+1] = x;
  end

  kBagIDs[NUM_BAG_SLOTS+2] = KEYRING_CONTAINER;

  AuctionatorLoaded = true;

  SlashCmdList["Auctionator"] = Atr_SlashCmdFunction;

  SLASH_Auctionator1 = "/auctionator";
  SLASH_Auctionator2 = "/atr";

  Atr_InitScanDB ();

  if (AUCTIONATOR_PRICING_HISTORY == nil) then  -- the old history of postings
    AUCTIONATOR_PRICING_HISTORY = {};
  end

  if (AUCTIONATOR_TOONS == nil) then
    AUCTIONATOR_TOONS = {};
  end

  if (AUCTIONATOR_STACKING_PREFS == nil) then
    Atr_StackingPrefs_Init();
  end

  if (AUCTIONATOR_SAVEDVARS == nil) then
    Atr_ResetSavedVars()
  end

  local playerName = UnitName("player");

  if (not AUCTIONATOR_TOONS[playerName]) then
    AUCTIONATOR_TOONS[playerName] = {};
    AUCTIONATOR_TOONS[playerName].firstSeen   = time();
    AUCTIONATOR_TOONS[playerName].firstVersion  = AuctionatorVersion;
  end

  AUCTIONATOR_TOONS[playerName].guid = UnitGUID ("player");

  if (AUCTIONATOR_SCAN_MINLEVEL == nil) then
    AUCTIONATOR_SCAN_MINLEVEL = 1;      -- poor (all) items
  end

  if (AUCTIONATOR_SHOW_TIPS == 0) then    -- migrate old option to new ones
    AUCTIONATOR_V_TIPS = 0;
    AUCTIONATOR_A_TIPS = 0;
    AUCTIONATOR_D_TIPS = 0;

    AUCTIONATOR_SHOW_TIPS = 2;
  end

  if (AUCTIONATOR_OPEN_FIRST < 2) then  -- set to 2 to indicate it's been migrated
    if    (AUCTIONATOR_OPEN_FIRST == 1) then AUCTIONATOR_DEFTAB = 1;
    elseif  (AUCTIONATOR_OPEN_BUY == 1)   then AUCTIONATOR_DEFTAB = 2;
    else                     AUCTIONATOR_DEFTAB = 0; end;

    AUCTIONATOR_OPEN_FIRST = 2;
  end


  -- Migrate old version of shopping lists to new adv
  if AUCTIONATOR_SHOPPING_LISTS and AUCTIONATOR_SHOPPING_LISTS_MIGRATED_V2 == nil then
    for index, list in ipairs( AUCTIONATOR_SHOPPING_LISTS ) do
      local fixedList = {}

      for itemIndex, itemName in ipairs( list.items ) do
        local replacement = itemName:gsub( "|", ";" )
        table.insert( fixedList, replacement )
      end

      AUCTIONATOR_SHOPPING_LISTS[ index ].items = fixedList
    end

    AUCTIONATOR_SHOPPING_LISTS_MIGRATED_V2 = true
  end

  Atr_SetupHookFunctionsEarly();

  ------------------

  local atrtt1 = CreateFrame( "GameTooltip", "AtrScanningTooltip", nil, "GameTooltipTemplate" ); -- Tooltip name cannot be nil
  if (atrtt1 == nil) then
    zc.msg_anm ("Unable to create AtrScanningTooltip");
  end
  AtrScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );

  local atrtt2 = CreateFrame( "GameTooltip", "AtrScanningTooltip2", nil, "GameTooltipTemplate" ); -- Tooltip name cannot be nil
  if (atrtt2 == nil) then
    zc.msg_anm ("Unable to create AtrScanningTooltip2");
  end
  AtrScanningTooltip2:SetOwner( WorldFrame, "ANCHOR_NONE" );

  ------------------

  Atr_ShoppingListsInit();

  EnableDisableDElogging ()

  if ( IsAddOnLoaded("Blizzard_AuctionUI") ) then   -- need this for AH_QuickSearch since that mod forces Blizzard_AuctionUI to load at a startup
    Atr_Init();
  end

  Atr_ModTradeSkillFrame()
end

-----------------------------------------

local gPrevTime = 0;

function Atr_OnAddonLoaded(...)
  Auctionator.Debug.Message( 'Atr_OnAddonLoaded', ... )

  local addonName = select (1, ...);

  if (zc.StringSame (addonName, "blizzard_auctionui")) then
    Atr_Init();
  end

  Atr_Check_For_Conflicts (addonName);

  local now = time();

  gPrevTime = now;

  if (zc.StringSame (addonName, "blizzard_tradeskillui")) then
    Atr_ModTradeSkillFrame();
  end

end

-----------------------------------------

auctionatorInited = false

-----------------------------------------
function Atr_OnPlayerEnteringWorld()
  Auctionator.Debug.Message( 'Atr_OnPlayerEnteringWorld' )

  zz ("auctionatorInited = ", auctionatorInited);

  if (auctionatorInited == false) then
    auctionatorInited = true;

    Atr_InitOptionsPanels()
    Atr_InitToolTips()

    if (RegisterAddonMessagePrefix) then
      RegisterAddonMessagePrefix ("ATR")
    end

  end
end

-----------------------------------------

local preDEmats;
local preDEgear;
local gDisenchantTime = 0;

-----------------------------------------

function Atr_ScanBags (mats, gear)
  Auctionator.Debug.Message( 'Atr_ScanBags', mats, gear )

  local bagID, slotID, numslots;

  for bagID = 0, NUM_BAG_SLOTS do

    local numslots = GetContainerNumSlots (bagID);

    for slotID = 1,numslots do

      local itemLink = GetContainerItemLink(bagID, slotID);

      if (itemLink) then
        local texture, itemCount, locked, quality = GetContainerItemInfo(bagID, slotID);

        local itemName, _, itemRarity, _, _, itemType, itemSubType, _, _, _, _, itemClassID, itemSubClassID = GetItemInfo( itemLink )
        local itemLevel = ItemUpgradeInfo:GetUpgradedItemLevel( itemLink )

        if ( Atr_IsWeaponType( itemClassID ) or Atr_IsArmorType( itemClassID ) ) and itemLevel > 271 then
          local key = itemType.."_"..itemSubType.."_"..itemRarity.."_"..itemLevel;
          if (gear[key]) then
            gear[key].count = gear[key].count + 1;
          else
            local q = "X";

            if (itemRarity == 2) then q = "G"; end
            if (itemRarity == 3) then q = "B"; end
            if (itemRarity == 4) then q = "P"; end

            gear[key] = { t=itemType, s=itemSubType, q=q, lev=itemLevel, count=itemCount };
          end
        end

        if (zc.StringContains (itemName, "Celestial Essence", "Heavenly Shard", "Hypnotic Dust", "Maelstrom Crystal")) then
          local key = itemName;
          if (mats[key]) then
            mats[key].count = mats[key].count + itemCount;
          else
            mats[key] = { count=itemCount };
          end
        end
      end

    end
  end

end

-----------------------------------------

function Atr_OnSpellCastSent (...)
  Auctionator.Debug.Message( 'Atr_OnSpellCastSent', ... )

  if (select (2,...) ~= "Disenchant") then
    return;
  end

  preDEmats = {};
  preDEgear = {};

  Atr_ScanBags (preDEmats, preDEgear);

end

-----------------------------------------

function Atr_OnSpellCastSucess (...)
  Auctionator.Debug.Message( 'Atr_OnSpellCastSucess', ... )

  if (select (2,...) ~= "Disenchant") then
    return;
  end

  gDisenchantTime = time();
end

-----------------------------------------

function Atr_OnBagUpdate (...)
  Auctionator.Debug.Message( 'Atr_OnBagUpdate', ... )

  if (time() - gDisenchantTime > 5) then
    return;
  end

  local postMats = {};
  local postGear = {};

  Atr_ScanBags (postMats, postGear);

  local k, m, g;

  local preMats = {}
  local preGear = {};

  zc.CopyDeep (preMats, preDEmats)
  zc.CopyDeep (preGear, preDEgear)

  for k, g in pairs (postGear) do
    if (preGear[k]) then
      preGear[k].count = preGear[k].count - g.count
    end
  end

  for k, m in pairs (postMats) do
    if (preMats[k]) then
      preMats[k].count = preMats[k].count - m.count
    else
      preMats[k] = {};
      zc.CopyDeep (preMats[k], m)
      preMats[k].count = 0 - m.count
    end
  end

  local result = {};
  local numG = 0;
  local numM = 0;

  for k, g in pairs (preGear) do
    if (g.count ~= 0) then
      numG = numG + 1;
      zc.CopyDeep (result, g)
    end
  end

  for k, m in pairs (preMats) do
    if (m.count ~= 0) then
      numM = numM + 1;
      result.matname = k;
      result.matcount = -m.count;
    end
  end

  if (numG == 1 and numM == 1) then
    local matname = result.matname;

    if     (zc.StringSame (result.matname, "Hypnotic Dust"))        then matname = "HDU";
    elseif (zc.StringSame (result.matname, "Greater Celestial Essence"))  then matname = "GCE";
    elseif (zc.StringSame (result.matname, "Lesser Celestial Essence"))   then matname = "LCE";
    elseif (zc.StringSame (result.matname, "Heavenly Shard"))       then matname = "NHV";
    elseif (zc.StringSame (result.matname, "Small Heavenly Shard"))     then matname = "SHV";
    elseif (zc.StringSame (result.matname, "Maelstrom Crystal"))      then matname = "MAC";  end

    local itemClass   = Atr_ItemType2AuctionClass   (result.t)
    local itemSubclass  = Atr_SubType2AuctionSubclass (itemClass, result.s)

    local itemClassAbbrev = "A"
    if (Atr_IsWeaponType (result.t)) then
      itemClassAbbrev = "W"
    end

    local reftime = time({year=2010, month=12, day=1, hour=0})
    local dec13   = time({year=2010, month=12, day=13, hour=0})

    local tm = time() - reftime;
    tm = math.floor (tm / 3600)

    local s = tm.."_"..result.matcount.."_"..matname.."_"..itemClassAbbrev.."_"..itemSubclass.."_"..result.q.."_"..result.lev;

    gDisenchantTime = 0;

    if (AUCTIONATOR_DE_DATA == nil) then
      AUCTIONATOR_DE_DATA = {}
    end

    table.insert (AUCTIONATOR_DE_DATA, s);

    AUCTIONATOR_DE_DATA_BAK = nil
  end
end

-----------------------------------------

function Atr_Init()
  Auctionator.Debug.Message( 'Atr_Init' )

  if (AuctionatorInited) then
    return;
  end

  AuctionatorInited = true;

  if (AUCTIONATOR_SAVEDVARS == nil) then
    Atr_ResetSavedVars()
  end

  gShopPane = Atr_AddSellTab (ZT("Buy"),      BUY_TAB);
  gSellPane = Atr_AddSellTab (ZT("Sell"),     SELL_TAB);
  gMorePane = Atr_AddSellTab (ZT("More").."...",  MORE_TAB);

  Atr_AddMainPanel ();

  Atr_SetupHookFunctions ();

  recommendElements[1] = _G["Atr_Recommend_Text"];
  recommendElements[2] = _G["Atr_RecommendPerItem_Text"];
  recommendElements[3] = _G["Atr_RecommendPerItem_Price"];
  recommendElements[4] = _G["Atr_RecommendPerStack_Text"];
  recommendElements[5] = _G["Atr_RecommendPerStack_Price"];
  recommendElements[6] = _G["Atr_Recommend_Basis_Text"];
  recommendElements[7] = _G["Atr_RecommendItem_Tex"];

  -- create the lines that appear in the item history scroll pane

  local line, n;

  for n = 1, ITEM_HIST_NUM_LINES do
    local y = -5 - ((n-1)*16);
    line = CreateFrame("BUTTON", "AuctionatorHEntry"..n, Atr_Hlist, "Atr_HEntryTemplate");
    line:SetPoint("TOPLEFT", 0, y);
  end

  Atr_ShowHide_StartingPrice();

  Atr_LocalizeFrames();

end

-----------------------------------------

function Atr_ShowHide_StartingPrice()
  Auctionator.Debug.Message( 'Atr_ShowHide_StartingPrice' )

  if (AUCTIONATOR_SHOW_ST_PRICE == 1) then
    Atr_StartingPriceText:Show();
    Atr_StartingPrice:Show();
    Atr_StartingPriceDiscountText:Hide();
    Atr_Duration_Text:SetPoint ("TOPLEFT", 10, -307);
  else
    Atr_StartingPriceText:Hide();
    Atr_StartingPrice:Hide();
    Atr_StartingPriceDiscountText:Show();
    Atr_Duration_Text:SetPoint ("TOPLEFT", 10, -304);
  end
end

-----------------------------------------

function Atr_GetSellItemInfo ()
  Auctionator.Debug.Message( 'Atr_GetSellItemInfo' )

  local auctionItemName, auctionTexture, auctionCount, auctionQuality = GetAuctionSellItemInfo();

  Auctionator.Debug.Message( "GetAuctionSellItemInfo()", auctionItemName, auctionTexture, auctionCount, auctionQuality )

  if (auctionItemName == nil) then
    auctionItemName = "";
    auctionCount  = 0;
  end

  local auctionItemLink = nil;

  -- only way to get sell itemlink that I can figure
  if (auctionItemName ~= "") then
    local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetAuctionSellItem();

    if (speciesID and speciesID > 0) then   -- if it's a battle pet, construct a fake battlepet link

      local battlePetID = 0   -- unfortunately we don't know it

      auctionItemLink = "|cffcccccc|Hbattlepet:"..speciesID..":"..level..":"..breedQuality..":"..maxHealth..":"..power..":"..speed..":"..battlePetID.."|h["..name.."]|h|r";

      ATR_AddToBattlePetIconCache (auctionItemLink, auctionTexture);
    else
      AtrScanningTooltip:SetAuctionSellItem();

      local name;
      name, auctionItemLink = AtrScanningTooltip:GetItem();

      if (auctionItemLink == nil) then
        return "",0,nil;
      end
    end

  end

  return auctionItemName, auctionCount, auctionItemLink;
end

-----------------------------------------

function Atr_ResetSavedVars ()
  Auctionator.Debug.Message( 'Atr_ResetSavedVars' )

  AUCTIONATOR_SAVEDVARS = {};
  zc.CopyDeep (AUCTIONATOR_SAVEDVARS, auctionator_savedvars_defaults);
end

--------------------------------------------------------------------------------

function Atr_FindTabIndex (whichTab)
  local i;
  for i = 4,20  do
    local tab = _G['AuctionFrameTab'..i];

    if (tab and tab.auctionatorTab and tab.auctionatorTab == whichTab) then
      return i
    end
  end

  return 0
end

-----------------------------------------

function Atr_AuctionFrameTab_OnClick (self, index, down)
  Auctionator.Debug.Message( 'Atr_AuctionFrameTab_OnClick', self, index, down )

  if ( index == nil or type(index) == "string") then
    index = self:GetID();
  end

  _G["Atr_Main_Panel"]:Hide();

  gBuyState = ATR_BUY_NULL;     -- just in case
  gItemPostingInProgress = false;   -- just in case

  auctionator_orig_AuctionFrameTab_OnClick (self, index, down);

  if (not Atr_IsAuctionatorTab(index)) then
    gForceMsgAreaUpdate = true;
    Atr_HideAllDialogs();

    if (index >= 1 and index <= 3) then   -- if it's one of Blizzard's tabs
      AuctionFrameMoneyFrame:Show();
    end

    if (AP_Bid_MoneyFrame) then   -- for the addon 'Auction Profit'
      if (AP_ShowBid) then  AP_ShowHide_Bid_Button(1);  end;
      if (AP_ShowBO)  then  AP_ShowHide_BO_Button(1); end;
    end

  elseif (Atr_IsAuctionatorTab(index)) then

    AuctionFrameAuctions:Hide();
    AuctionFrameBrowse:Hide();
    AuctionFrameBid:Hide();
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);

    PanelTemplates_SetTab(AuctionFrame, index);

    AuctionFrameTopLeft:SetTexture  ("Interface\\AddOns\\Auctionator\\Images\\Atr_topleft");
    AuctionFrameBotLeft:SetTexture  ("Interface\\AddOns\\Auctionator\\Images\\Atr_botleft");
    AuctionFrameTop:SetTexture    ("Interface\\AddOns\\Auctionator\\Images\\Atr_top");
    AuctionFrameTopRight:SetTexture ("Interface\\AddOns\\Auctionator\\Images\\Atr_topright");
    AuctionFrameBot:SetTexture    ("Interface\\AddOns\\Auctionator\\Images\\Atr_bot");
    AuctionFrameBotRight:SetTexture ("Interface\\AddOns\\Auctionator\\Images\\Atr_botright");

    if (index == Atr_FindTabIndex(SELL_TAB))  then gCurrentPane = gSellPane; end;
    if (index == Atr_FindTabIndex(BUY_TAB))   then gCurrentPane = gShopPane; end;
    if (index == Atr_FindTabIndex(MORE_TAB))  then gCurrentPane = gMorePane; end;

    if (index == Atr_FindTabIndex(SELL_TAB))  then AuctionatorTitle:SetText ("Auctionator - "..ZT("Sell"));     end;
    if (index == Atr_FindTabIndex(BUY_TAB))   then AuctionatorTitle:SetText ("Auctionator - "..ZT("Buy"));      end;
    if (index == Atr_FindTabIndex(MORE_TAB))  then AuctionatorTitle:SetText ("Auctionator - "..ZT("More").."...");  end;

    Atr_ClearHlist();
    Atr_SellControls:Hide();
    Atr_Hlist:Hide();
    Atr_Hlist_ScrollFrame:Hide();
    Atr_Search_Box:Hide();
    Atr_Search_Button:Hide();
    Atr_Adv_Search_Button:Hide();
    Atr_Exact_Search_Button:Hide();
    Atr_AddToSListButton:Hide();
    Atr_RemFromSListButton:Hide();
    Atr_NewSListButton:Hide();
    Atr_MngSListsButton:Hide();
    Atr_SrchSListButton:Hide()
    Atr_ActiveItems_Text:Hide();
    Atr_DropDownSL:Hide();
    Atr_CheckActiveButton:Hide();
    Atr_Back_Button:Hide()
    Atr_SaveThisList_Button:Hide()

    AuctionFrameMoneyFrame:Hide();

    if (index == Atr_FindTabIndex(SELL_TAB)) then
      Atr_SellControls:Show();
    else
      Atr_Hlist:Show();
      Atr_Hlist_ScrollFrame:Show();
      if (gJustPosted.ItemName) then
        gJustPosted.ItemName = nil;
        gSellPane:ClearSearch ();
      end
    end


    if (index == Atr_FindTabIndex(MORE_TAB)) then
      FauxScrollFrame_SetOffset (Atr_Hlist_ScrollFrame, gCurrentPane.hlistScrollOffset);
      Atr_DisplayHlist();
      Atr_ActiveItems_Text:Show();
      Atr_CheckActiveButton:Show();
    end


    if (index == Atr_FindTabIndex(BUY_TAB)) then
      Atr_Search_Box:Show();
      Atr_Search_Button:Show();
      Atr_Adv_Search_Button:Show();
      Atr_Exact_Search_Button:Show();
      AuctionFrameMoneyFrame:Show();
      Atr_AddToSListButton:Show();
      Atr_RemFromSListButton:Show();
      Atr_NewSListButton:Show();
      Atr_MngSListsButton:Show();
      Atr_SrchSListButton:Show()
      Atr_DropDownSL:Show();
      Atr_Hlist:SetHeight (252);
      Atr_Hlist_ScrollFrame:SetHeight (252);
    else
      Atr_Hlist:SetHeight (335);
      Atr_Hlist_ScrollFrame:SetHeight (335);
    end

    if (index == Atr_FindTabIndex(BUY_TAB) or index == Atr_FindTabIndex(SELL_TAB)) then
      Atr_Buy1_Button:Show();
      Atr_Buy1_Button:Disable();
    end

    Atr_HideElems (recommendElements);

    _G["Atr_Main_Panel"]:Show();

    gCurrentPane.UINeedsUpdate = true;
  end
end

-----------------------------------------

function Atr_StackSize ()
  Auctionator.Debug.Message( 'Atr_StackSize' )

  return math.max( Atr_Batch_Stacksize:GetNumber(), 1 )
end

-----------------------------------------

function Atr_SetStackSize (n)
  Auctionator.Debug.Message( 'Atr_SetStackSize', n )

  return Atr_Batch_Stacksize:SetText(n);
end

-----------------------------------------

function Atr_SelectPane (whichTab)
  Auctionator.Debug.Message( 'Atr_SelectPane', whichTab )

  local index = Atr_FindTabIndex(whichTab);
  local tab   = _G['AuctionFrameTab'..index];

  Atr_AuctionFrameTab_OnClick (tab, index);

end

-----------------------------------------

function Atr_IsModeCreateAuction ()
  -- Auctionator.Debug.Message( 'Atr_IsModeCreateAuction' )

  return (Atr_IsTabSelected(SELL_TAB));
end


-----------------------------------------

function Atr_IsModeBuy ()
  -- Auctionator.Debug.Message( 'Atr_IsModeBuy' )

  return (Atr_IsTabSelected(BUY_TAB));
end

-----------------------------------------

function Atr_IsModeActiveAuctions ()
  -- Auctionator.Debug.Message( 'Atr_IsModeActiveAuctions' )

  return (Atr_IsTabSelected(MORE_TAB));
end

-----------------------------------------

function Atr_ClickAuctionSellItemButton (self, button)
  Auctionator.Debug.Message( 'Atr_ClickAuctionSellItemButton', self, button )

  if (AuctionFrameAuctions.duration == nil) then    -- blizz attempts to calculate deposit below and in some cases, duration has yet to be set
    AuctionFrameAuctions.duration = 1;
  end

  gAtr_ClickAuctionSell = true;
  ClickAuctionSellItemButton(self, button);
end


-----------------------------------------

function Atr_OnDropItem (self, button)
  Auctionator.Debug.Message( 'Atr_OnDropItem', self, button )

  if (GetCursorInfo() ~= "item") then
    return;
  end

  if (not Atr_IsTabSelected(SELL_TAB)) then
    Atr_SelectPane (SELL_TAB);    -- then fall through
  end

  Atr_ClickAuctionSellItemButton (self, button);
  ClearCursor();
end

-----------------------------------------

function Atr_SellItemButton_OnClick (self, button, ...)
  Auctionator.Debug.Message( 'Atr_SellItemButton_OnClick', self, button, ... )

  Atr_ClickAuctionSellItemButton (self, button);
end

-----------------------------------------

function Atr_SellItemButton_OnEvent (self, event, ...)
  Auctionator.Debug.Message( 'Atr_SellItemButton_OnEvent', self, event, ... )

  if ( event == "NEW_AUCTION_UPDATE") then
    local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
    Atr_SellControls_Tex:SetNormalTexture(texture);
  end

end

-----------------------------------------

local function Atr_LoadContainerItemToSellPane(slot)
  Auctionator.Debug.Message( 'Atr_LoadContainerItemToSellPane', slot )

  local bagID  = slot:GetParent():GetID();
  local slotID = slot:GetID();

  if (not Atr_IsTabSelected(SELL_TAB)) then
    Atr_SelectPane (SELL_TAB);
  end

  if (IsControlKeyDown()) then
    gAutoSingleton = time();
  end

  PickupContainerItem(bagID, slotID);

  local infoType = GetCursorInfo()

  if (infoType == "item") then
    Atr_ClearAll();
    Atr_ClickAuctionSellItemButton ();
    ClearCursor();
  end

end

-----------------------------------------

function Atr_ContainerFrameItemButton_OnClick (self, button)
  Auctionator.Debug.Message( 'Atr_ContainerFrameItemButton_OnClick', self, button )

  if (AuctionFrame and AuctionFrame:IsShown() and zc.StringSame (button, "RightButton")) then

    local selectedTab = PanelTemplates_GetSelectedTab (AuctionFrame);

    if (selectedTab == 1 or selectedTab == 2 or Atr_IsAuctionatorTab(selectedTab)) then
      Atr_LoadContainerItemToSellPane (self);
    end
  end

end

-----------------------------------------

function Atr_ContainerFrameItemButton_OnModifiedClick (self, button)
  Auctionator.Debug.Message( 'Atr_ContainerFrameItemButton_OnModifiedClick', self, button )

  if (AUCTIONATOR_ENABLE_ALT ~= 0 and AuctionFrame:IsShown() and IsAltKeyDown()) then

    Atr_LoadContainerItemToSellPane(self);
    return;
  end

  return auctionator_orig_ContainerFrameItemButton_OnModifiedClick (self, button);
end




-----------------------------------------

function Atr_CreateAuction_OnClick ()
  Auctionator.Debug.Message( 'Atr_CreateAuction_OnClick' )

  gAtr_SellTriggeredByAuctionator = true;

  gJustPosted.ItemName      = gCurrentPane.activeScan.itemName;
  gJustPosted.ItemLink      = gCurrentPane.activeScan.itemLink;
  gJustPosted.BuyoutPrice     = MoneyInputFrame_GetCopper(Atr_StackPrice);

  if (zc.IsBattlePetLink (gJustPosted.ItemLink)) then
    gJustPosted.StackSize     = 1;
    gJustPosted.NumStacks     = 1;
  else
    gJustPosted.StackSize     = Atr_StackSize();
    gJustPosted.NumStacks     = Atr_Batch_NumAuctions:GetNumber();
  end

  local duration        = UIDropDownMenu_GetSelectedValue(Atr_Duration);
  local stackStartingPrice  = MoneyInputFrame_GetCopper(Atr_StartingPrice);
  local stackBuyoutPrice    = MoneyInputFrame_GetCopper(Atr_StackPrice);

  Atr_Memorize_Stacking_If();

  StartAuction (stackStartingPrice, stackBuyoutPrice, duration, gJustPosted.StackSize, gJustPosted.NumStacks);

  Atr_SetToShowCurrent();
end


-----------------------------------------

local gMS_stacksPrev;

-----------------------------------------

function Atr_OnAuctionMultiSellStart()
  Auctionator.Debug.Message( 'Atr_OnAuctionMultiSellStart' )

  gMS_stacksPrev = 0;
end

-----------------------------------------

function Atr_OnAuctionMultiSellUpdate(...)
  Auctionator.Debug.Message( 'Atr_OnAuctionMultiSellUpdate', ... )

  if (not gAtr_SellTriggeredByAuctionator) then
    zc.md ("skipping.  gAtr_SellTriggeredByAuctionator is false");
    return;
  end

  local stacksSoFar, stacksTotal = ...;

  --zc.md ("stacksSoFar: ", stacksSoFar, "stacksTotal: ", stacksTotal);

  local delta = stacksSoFar - gMS_stacksPrev;

  gMS_stacksPrev = stacksSoFar;

  Atr_AddToScan (gJustPosted.ItemLink, gJustPosted.ItemName, gJustPosted.StackSize, gJustPosted.BuyoutPrice, delta);

  if (stacksSoFar == stacksTotal) then
    Atr_LogMsg (gJustPosted.ItemLink, gJustPosted.StackSize, gJustPosted.BuyoutPrice, stacksTotal);
    Atr_AddHistoricalPrice (gJustPosted.ItemName, gJustPosted.BuyoutPrice / gJustPosted.StackSize, gJustPosted.StackSize, gJustPosted.ItemLink);
    gAtr_SellTriggeredByAuctionator = false;     -- reset
  end

end

-----------------------------------------

function Atr_OnAuctionMultiSellFailure()
  Auctionator.Debug.Message( 'Atr_OnAuctionMultiSellFailure' )

  if (not gAtr_SellTriggeredByAuctionator) then
    zc.md ("skipping.  gAtr_SellTriggeredByAuctionator is false");
    return;
  end

  -- add one more.  no good reason other than it just seems to work
  Atr_AddToScan (gJustPosted.ItemLink, gJustPosted.ItemName, gJustPosted.StackSize, gJustPosted.BuyoutPrice, 1);

  Atr_LogMsg (gJustPosted.ItemLink, gJustPosted.StackSize, gJustPosted.BuyoutPrice, gMS_stacksPrev + 1);
  Atr_AddHistoricalPrice (gJustPosted.ItemName, gJustPosted.BuyoutPrice / gJustPosted.StackSize, gJustPosted.StackSize, gJustPosted.ItemLink);

  gAtr_SellTriggeredByAuctionator = false;     -- reset

  if (gCurrentPane.activeScan) then
    gCurrentPane.activeScan.whenScanned = 0;
  end
end


-----------------------------------------

function Atr_AuctionFrameAuctions_Update()
  Auctionator.Debug.Message( 'Atr_AuctionFrameAuctions_Update' )

  auctionator_orig_AuctionFrameAuctions_Update();

end


-----------------------------------------

function Atr_LogMsg (itemlink, itemcount, price, numstacks)
  Auctionator.Debug.Message( 'Atr_LogMsg', itemlink, itemcount, price, numstacks )

  if (itemlink == nil) then
    itemlink = "<nil>";
  end

  local logmsg = string.format (ZT("Auction created for %s"), itemlink);

  if (numstacks > 1) then
    logmsg = string.format (ZT("%d auctions created for %s"), numstacks, itemlink);
  end


  if (itemcount > 1) then
    logmsg = logmsg.."|cff00ddddx"..itemcount.."|r";
  end

  logmsg = logmsg.."   "..zc.priceToString(price);

  if (numstacks > 1 and itemcount > 1) then
    logmsg = logmsg.."  per stack";
  end


  zc.msg_yellow (logmsg);

end

-----------------------------------------

function Atr_OnAuctionOwnedUpdate ()
  Auctionator.Debug.Message( 'Atr_OnAuctionOwnedUpdate' )

  gItemPostingInProgress = false;

  if (Atr_IsModeActiveAuctions()) then
    gHlistNeedsUpdate = true;
  end

  if (not Atr_IsTabSelected()) then
    Atr_ClearScanCache();   -- if not our tab, we have no idea what happened so must flush all caches
    return;
  end;

  gActiveAuctions = {};   -- always flush this cache

  if (gAtr_SellTriggeredByAuctionator) then

    if (gJustPosted.ItemName) then

      if (gJustPosted.NumStacks == 1) then
        Atr_LogMsg (gJustPosted.ItemLink, gJustPosted.StackSize, gJustPosted.BuyoutPrice, 1);
        Atr_AddHistoricalPrice (gJustPosted.ItemName, gJustPosted.BuyoutPrice / gJustPosted.StackSize, gJustPosted.StackSize, gJustPosted.ItemLink);
        Atr_AddToScan (gJustPosted.ItemLink, gJustPosted.ItemName, gJustPosted.StackSize, gJustPosted.BuyoutPrice, 1);

        gAtr_SellTriggeredByAuctionator = false;     -- reset
      end
    end
  end

end

-----------------------------------------

function Atr_ResetDuration()
  Auctionator.Debug.Message( 'Atr_ResetDuration' )

  local durMenu = _G["Atr_Duration"]

  UIDropDownMenu_Initialize (durMenu, Atr_Duration_Initialize);

  if (AUCTIONATOR_DEF_DURATION == "S") then UIDropDownMenu_SetSelectedValue(durMenu, 1); end;
  if (AUCTIONATOR_DEF_DURATION == "M") then UIDropDownMenu_SetSelectedValue(durMenu, 2); end;
  if (AUCTIONATOR_DEF_DURATION == "L") then UIDropDownMenu_SetSelectedValue(durMenu, 3); end;

end

-----------------------------------------

function Atr_AddToScan (itemLink, itemName, stackSize, buyoutPrice, numAuctions)
  Auctionator.Debug.Message( 'Atr_AddToScan', itemLink, itemName, stackSize, buyoutPrice, numAuctions )

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })
  local scan = Atr_FindScan( item_link:IdString(), itemName )

  if scan then
    scan:AddScanItem( stackSize, buyoutPrice, UnitName("player"), numAuctions )
    scan:CondenseAndSort()
  end

  gCurrentPane.UINeedsUpdate = true;
end

-----------------------------------------

function AuctionatorSubtractFromScan (itemLink, stackSize, buyoutPrice, howMany)
  Auctionator.Debug.Message( 'AuctionatorSubtractFromScan', itemLink, stackSize, buyoutPrice, howMany )

  if (howMany == nil) then
    howMany = 1;
  end

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })
  local scan = Atr_FindScan( item_link:IdString() )

  if scan then
    local x

    for x = 1, howMany do
      scan:SubtractScanItem( stackSize, buyoutPrice )
    end

    scan:CondenseAndSort()
  end

  gCurrentPane.UINeedsUpdate = true
end


-----------------------------------------

function auctionator_ChatEdit_InsertLink(text)
  Auctionator.Debug.Message( 'auctionator_ChatEdit_InsertLink', text )

  if text and AuctionFrame:IsShown() and Atr_IsTabSelected( BUY_TAB ) then
    local item

    if strfind( text, "item:", 1, true ) then
      item = GetItemInfo( text )
    end

    if item then
      if IsLeftShiftKeyDown() then
        Atr_SetSearchText( item )
      elseif IsRightShiftKeyDown() then
        Atr_SetSearchText( zc.QuoteString( item ) )
      end

      Atr_Search_Onclick()

      return true
    end
  end

  return auctionator_orig_ChatEdit_InsertLink( text )

end

-----------------------------------------

function auctionator_ChatFrame_OnEvent(self, event, ...)
  -- Auctionator.Debug.Message( 'auctionator_ChatFrame_OnEvent', self, event, ... )

  local msg = select (1, ...);

  if (event == "CHAT_MSG_SYSTEM") then
    if (msg == ERR_AUCTION_STARTED) then    -- absorb the Auction Created message
      return;
    end
    if (msg == ERR_AUCTION_REMOVED) then    -- absorb the Auction Cancelled message
      return;
    end
  end

  return auctionator_orig_ChatFrame_OnEvent (self, event, ...);

end




-----------------------------------------

function auctionator_CanShowRightUIPanel(frame)
  Auctionator.Debug.Message( 'auctionator_CanShowRightUIPanel', frame )

  if (zc.StringSame (frame:GetName(), "TradeSkillFrame")) then
    return 1;
  end;

  return auctionator_orig_CanShowRightUIPanel(frame);

end

-----------------------------------------

function Atr_AddMainPanel ()
  Auctionator.Debug.Message( 'Atr_AddMainPanel' )

  local frame = CreateFrame("FRAME", "Atr_Main_Panel", AuctionFrame, "Atr_Sell_Template");
  frame:Hide();

  UIDropDownMenu_SetWidth (Atr_Duration, 95);

end

-----------------------------------------

function Atr_AddSellTab (tabtext, whichTab)
  Auctionator.Debug.Message( 'Atr_AddSellTab', tabtext, whichTab )

  local n = AuctionFrame.numTabs+1;

  local framename = "AuctionFrameTab"..n;

  local frame = CreateFrame("Button", framename, AuctionFrame, "AuctionTabTemplate");

  frame:SetID(n);
  frame:SetText(tabtext);

  frame:SetNormalFontObject(_G["AtrFontOrange"]);

  frame.auctionatorTab = whichTab;

  frame:SetPoint("LEFT", _G["AuctionFrameTab"..n-1], "RIGHT", -8, 0);

  PanelTemplates_SetNumTabs (AuctionFrame, n);
  PanelTemplates_EnableTab  (AuctionFrame, n);

  return AtrPane.create (whichTab);
end

-----------------------------------------

function Atr_HideElems (tt)
  Auctionator.Debug.Message( 'Atr_HideElems', tt )

  if (not tt) then
    return;
  end

  for i,x in ipairs(tt) do
    x:Hide();
  end
end

-----------------------------------------

function Atr_ShowElems (tt)
  Auctionator.Debug.Message( 'Atr_ShowElems', tt )

  for i,x in ipairs(tt) do
    x:Show();
  end
end




-----------------------------------------

local aoa_count = 0

function Atr_OnAuctionUpdate (...)
  Auctionator.Debug.Message( 'Atr_OnAuctionUpdate' )

  local numBatchAuctions, totalAuctions = Atr_GetNumAuctionItems("list");

  aoa_count = aoa_count + 1

  if (gAtr_FullScanState == ATR_FS_STARTED) then
    Atr_FullScanBeginAnalyzePhase()   -- handle in idle loop to slow down
    return
  end

  if (gAtr_FullScanState == ATR_FS_SLOW_QUERY_SENT) then
    Atr_FullScanBeginAnalyzePhase()
    Atr_FullScanAnalyze()           -- handle here since it's just one page
    return
  end

  if (not Atr_IsTabSelected()) then
    Atr_ClearScanCache()    -- if not our tab, we have no idea what happened so must flush all caches
    return;
  end;

  if (Atr_Buy_OnAuctionUpdate()) then
    return
  end

  if (gCurrentPane.activeSearch and gCurrentPane.activeSearch.processing_state == Auctionator.Constants.SearchStates.POST_QUERY) then

    gCurrentPane.activeSearch:CapturePageInfo();

    local isDup = gCurrentPane.activeSearch:CheckForDuplicatePage ();

    if (not isDup) then

      local done = gCurrentPane.activeSearch:AnalyzeResultsPage();

      if (done) then
        gCurrentPane.activeSearch:Finish();
        Atr_OnSearchComplete ();
      end
    end
  end

end

-----------------------------------------

function Atr_OnSearchComplete()
  Auctionator.Debug.Message( 'Atr_OnSearchComplete' )

  gCurrentPane.sortedHist = nil;

  Atr_Clear_Owner_Item_Indices();

  local count = gCurrentPane.activeSearch:NumScans();
  if (count == 1) then
    gCurrentPane.activeScan = gCurrentPane.activeSearch:GetFirstScan();
  end

  if (Atr_IsModeCreateAuction()) then

    Atr_SetToShowCurrent();

    if (#gCurrentPane.activeScan.scanData == 0) then
      if (gAtr_ScanDB[gCurrentPane.activeScan.itemName]) then
        Atr_SetToShowHistory();
        Atr_BuildSortedScanHistoryList(gCurrentPane.activeScan.itemName);
        gCurrentPane.histIndex = 1;
      else
        local hints = Atr_BuildHints (gCurrentPane.activeScan.itemName, gCurrentPane.activeScan.itemLink);    -- just to get the count
        if (#hints > 0) then
          Atr_SetToShowHints();
          Atr_Build_PostingsList ();
          gCurrentPane.histIndex = 1;
        end
      end

    end

    if (Atr_IsSelectedTab_Current()) then
      Atr_FindBestCurrentAuction ();
    end

    Atr_UpdateRecommendation(true);
  else
    if (Atr_IsModeActiveAuctions()) then
      Atr_DisplayHlist();
    end

    Atr_FindBestCurrentAuction ();
  end

  if (Atr_IsModeBuy()) then
    Atr_Shop_OnFinishScan ();
  end

  Atr_CheckingActive_OnSearchComplete();

  gCurrentPane.UINeedsUpdate = true;

end

-----------------------------------------

function Atr_ClearTop ()
  Auctionator.Debug.Message( 'Atr_ClearTop' )

  Atr_HideElems (recommendElements);

  if (AuctionatorMessageFrame) then
    AuctionatorMessageFrame:Hide();
    AuctionatorMessage2Frame:Hide();
  end
end

-----------------------------------------

function Atr_ClearList ()
  Auctionator.Debug.Message( 'Atr_ClearList' )

  Atr_Col1_Heading:Hide();
  Atr_Col3_Heading:Hide();
  Atr_Col4_Heading:Hide();

  Atr_Col1_Heading_Button:Hide();
  Atr_Col3_Heading_Button:Hide();

  local line;             -- 1 through 12 of our window to scroll

  FauxScrollFrame_Update (AuctionatorScrollFrame, 0, 12, 16);

  for line = 1,12 do
    local lineEntry = _G["AuctionatorEntry"..line];
    lineEntry:Hide();
  end

end

-----------------------------------------

function Atr_ClearAll ()
  Auctionator.Debug.Message( 'Atr_ClearAll' )

  if (AuctionatorMessageFrame) then -- just to make sure xml has been loaded

    Atr_ClearTop();
    Atr_ClearList();
  end
end

-----------------------------------------

function Atr_SetMessage (msg)
  Auctionator.Debug.Message( 'Atr_SetMessage', msg )

  Atr_HideElems (recommendElements);

  if (gCurrentPane.activeSearch.searchText) then

    Atr_ShowItemNameAndTexture (gCurrentPane.activeSearch.searchText);

    AuctionatorMessage2Frame:SetText (msg);
    AuctionatorMessage2Frame:Show();

  else
    AuctionatorMessageFrame:SetText (msg);
    AuctionatorMessageFrame:Show();
    AuctionatorMessage2Frame:Hide();
  end
end

-----------------------------------------

function Atr_ShowItemNameAndTexture(itemName)
  Auctionator.Debug.Message( 'Atr_ShowItemNameAndTexture', itemName )

  AuctionatorMessageFrame:Hide();
  AuctionatorMessage2Frame:Hide();

  local scn = gCurrentPane.activeScan;

  local color = "";
  local level = "";

  if (scn and not scn:IsNil()) then
    color = "|cff"..zc.RGBtoHEX (scn.itemTextColor[1], scn.itemTextColor[2], scn.itemTextColor[3]);
    itemName = scn.itemName;

    if (zc.IsBattlePetLink(scn.itemLink)) then
      level = " (Level "..scn.itemLevel..")"
    end
  end

  Atr_Recommend_Text:Show ()
  Atr_Recommend_Text:SetText (color..itemName..level)

  if (scn and not scn:IsNil()) then
    Atr_SetTextureButton ("Atr_RecommendItem_Tex", 1, scn.itemLink)
  end
end



-----------------------------------------

function Atr_SortHistoryData (x, y)
  Auctionator.Debug.Message( 'Atr_SortHistoryData', x, y )

  return x.when > y.when;

end

-----------------------------------------

function BuildHtag (type, y, m, d)
  Auctionator.Debug.Message( 'BuildHtag', type, y, m, d )

  local t = time({year=y, month=m, day=d, hour=0});

  return tostring (ToTightTime(t))..":"..type;
end

-----------------------------------------

function ParseHtag (tag)
  Auctionator.Debug.Message( 'ParseHtag', tag )

  local when, type = strsplit(":", tag);

  if (type == nil) then
    type = "hx";
  end

  when = FromTightTime (tonumber (when));

  return when, type;
end

-----------------------------------------

function ParseHist (tag, hist)
  Auctionator.Debug.Message( 'ParseHist', tag, hist )

  local when, type = ParseHtag(tag);

  local price, count  = strsplit(":", hist);

  price = tonumber (price);

  local stacksize, numauctions;

  if (type == "hx") then
    stacksize = tonumber (count);
    numauctions = 1;
  else
    stacksize = 0;
    numauctions = tonumber (count);
  end

  return when, type, price, stacksize, numauctions;

end

-----------------------------------------

function CalcAbsTimes (when, whent)
  Auctionator.Debug.Message( 'CalcAbsTimes', when, whent )

  local absYear = whent.year - 2000;
  local absMonth  = (absYear * 12) + whent.month;
  local absDay  = floor ((when - gTimeZero) / (60*60*24));

  return absYear, absMonth, absDay;

end

-----------------------------------------

function Atr_Condense_History (itemname)
  Auctionator.Debug.Message( 'Atr_Condense_History', itemname )

  if (AUCTIONATOR_PRICING_HISTORY[itemname] == nil) then
    return;
  end

  local tempHistory = {};

  local now     = time();
  local nowt      = date("*t", now);

  local absNowYear, absNowMonth, absNowDay = CalcAbsTimes (now, nowt);

  local n = 1;
  local tag, hist, newtag, stacksize, numauctions;
  for tag, hist in pairs (AUCTIONATOR_PRICING_HISTORY[itemname]) do
    if (tag ~= "is") then

      local when, type, price, stacksize, numauctions = ParseHist (tag, hist);

      local whnt = date("*t", when);

      local absYear, absMonth, absDay = CalcAbsTimes (when, whnt);

      if (absNowYear - absYear >= 3) then
        newtag = BuildHtag ("hy", whnt.year, 1, 1);
      elseif (absNowMonth - absMonth >= 2) then
        newtag = BuildHtag ("hm", whnt.year, whnt.month, 1);
      elseif (absNowDay - absDay >= 2) then
        newtag = BuildHtag ("hd", whnt.year, whnt.month, whnt.day);
      else
        newtag = tag;
      end

      tempHistory[n] = {};
      tempHistory[n].price    = price;
      tempHistory[n].numauctions  = numauctions;
      tempHistory[n].stacksize  = stacksize;
      tempHistory[n].when     = when;
      tempHistory[n].newtag   = newtag;
      n = n + 1;
    end
  end

  -- clear all the existing history

  local is = AUCTIONATOR_PRICING_HISTORY[itemname]["is"];

  AUCTIONATOR_PRICING_HISTORY[itemname] = {};
  AUCTIONATOR_PRICING_HISTORY[itemname]["is"] = is;

  -- repopulate the history

  local x;

  for x = 1,#tempHistory do

    local thist   = tempHistory[x];
    local newtag  = thist.newtag;

    if (AUCTIONATOR_PRICING_HISTORY[itemname][newtag] == nil) then

      local when, type = ParseHtag (newtag);

      local count = thist.numauctions;
      if (type == "hx") then
        count = thist.stacksize;
      end

      AUCTIONATOR_PRICING_HISTORY[itemname][newtag] = tostring(thist.price)..":"..tostring(count);

    else

      local hist = AUCTIONATOR_PRICING_HISTORY[itemname][newtag];

      local when, type, price, stacksize, numauctions = ParseHist (newtag, hist);

      local newNumAuctions = numauctions + thist.numauctions;
      local newPrice     = ((price * numauctions) + (thist.price * thist.numauctions)) / newNumAuctions;

      AUCTIONATOR_PRICING_HISTORY[itemname][newtag] = tostring(newPrice)..":"..tostring(newNumAuctions);
    end
  end

end

-----------------------------------------

function Atr_Build_PostingsList ()
  Auctionator.Debug.Message( 'Atr_Build_PostingsList' )

  -- Condense the data if needed - only once per session for each item

  if (gCurrentPane:IsScanNil()) then
    return;
  end

  local itemName = gCurrentPane.activeScan.itemName;

  if (gCondensedThisSession[itemName] == nil) then

    gCondensedThisSession[itemName] = true;

    Atr_Condense_History(itemName);
  end

  -- build the sorted history list

  gCurrentPane.sortedHist = {};

  -- add any external information

  local hints = Atr_BuildHints (gCurrentPane.activeScan.itemName, gCurrentPane.activeScan.itemLink);

  local n;
  for n = 1, #hints do

    local entry = {};

    entry.when      = time();
    entry.whenText    = hints[n].text;
    entry.itemPrice   = hints[n].price;
    entry.yours     = true;   -- so doesn't undercut

    table.insert (gCurrentPane.sortedHist, entry)
  end

  -- now add all the posting history

  if (AUCTIONATOR_PRICING_HISTORY[itemName]) then
    local tag, hist;
    for tag, hist in pairs (AUCTIONATOR_PRICING_HISTORY[itemName]) do
      if (tag ~= "is") then
        local when, type, price = ParseHist (tag, hist);
        local entry = {};

        entry.itemPrice   = price;
        entry.type      = type;
        entry.when      = when;
        entry.yours     = true;
        entry.whenText    = Atr_BuildPostHistText (entry);

        table.insert (gCurrentPane.sortedHist, entry)
      end
    end
  end

  table.sort (gCurrentPane.sortedHist, Atr_SortHistoryData);

  if (#gCurrentPane.sortedHist > 0) then
    return gCurrentPane.sortedHist[1].itemPrice;
  end

end

-----------------------------------------

function Atr_GetMostRecentSale (itemName)
  Auctionator.Debug.Message( 'Atr_GetMostRecentSale', itemName )

  local recentPrice;
  local recentWhen = 0;

  if (AUCTIONATOR_PRICING_HISTORY and AUCTIONATOR_PRICING_HISTORY[itemName]) then
    local n = 1;
    local tag, hist;
    for tag, hist in pairs (AUCTIONATOR_PRICING_HISTORY[itemName]) do
      if (tag ~= "is") then
        local when, type, price = ParseHist (tag, hist);

        if (when > recentWhen) then
          recentPrice = price;
          recentWhen  = when;
        end
      end
    end
  end

  return recentPrice;

end




-----------------------------------------

function Atr_UpdateRecommendation (updatePrices)
  Auctionator.Debug.Message( 'Atr_UpdateRecommendation', updatePrices )

  if (gCurrentPane == gSellPane and gJustPosted.ItemLink and GetAuctionSellItemInfo() == nil) then
    return;
  end

  local scn = gCurrentPane.activeScan
  if (scn == nil) then
    scn = Atr_FindScan (nil)
  end

  local basedata;

  if (Atr_ShowingSearchSummary()) then

  elseif (Atr_IsSelectedTab_Current()) then

    if (gCurrentPane:GetProcessingState() ~= Auctionator.Constants.SearchStates.NULL) then
      return;
    end

    if (#scn.sortedData == 0) then
      Atr_SetMessage (ZT("No current auctions found"));
      return;
    end

    if (not gCurrentPane.currIndex) then
      if (scn.numMatches == 0) then
        Atr_SetMessage (ZT("No current auctions found\n\n(related auctions shown)"));
      elseif (scn.numMatchesWithBuyout == 0) then
        Atr_SetMessage (ZT("No current auctions with buyouts found"));
      else
        Atr_SetMessage ("");
      end
      return;
    end

    basedata = scn.sortedData[gCurrentPane.currIndex];

  else

    basedata = zc.GetArrayElemOrFirst (gCurrentPane.sortedHist, gCurrentPane.histIndex);
    if (basedata == nil) then
      Atr_SetMessage (ZT("Auctionator has yet to record any auctions for this item"));
      return;
    end
  end

  if (Atr_StackSize() == 0) then
    return;
  end

  local new_Item_BuyoutPrice;

  if (gItemPostingInProgress and gCurrentPane.itemLink == gJustPosted.ItemLink) then  -- handle the unusual case where server is still in the process of creating the last auction

    new_Item_BuyoutPrice = gJustPosted.BuyoutPrice / gJustPosted.StackSize;

  elseif (basedata) then      -- the normal case

    new_Item_BuyoutPrice = basedata.itemPrice;

    if (not basedata.yours and not basedata.altname) then
      new_Item_BuyoutPrice = Atr_CalcUndercutPrice (new_Item_BuyoutPrice);
    end
  end

  if (new_Item_BuyoutPrice == nil or gCurrentPane ~= gSellPane) then
    return;
  end

  local new_Item_StartPrice = Atr_CalcStartPrice (new_Item_BuyoutPrice);

  Atr_ShowElems (recommendElements);
  AuctionatorMessageFrame:Hide();
  AuctionatorMessage2Frame:Hide();

  Atr_Recommend_Text:SetText (ZT("Recommended Buyout Price"));
  Atr_RecommendPerStack_Text:SetText (string.format (ZT("for your stack of %d"), Atr_StackSize()));

  Atr_SetTextureButton ("Atr_RecommendItem_Tex", Atr_StackSize(), scn.itemLink);

  MoneyFrame_Update ("Atr_RecommendPerItem_Price",  zc.round(new_Item_BuyoutPrice));
  MoneyFrame_Update ("Atr_RecommendPerStack_Price", zc.round(new_Item_BuyoutPrice * Atr_StackSize()));

  if (updatePrices) then
    MoneyInputFrame_SetCopper (Atr_StackPrice,    new_Item_BuyoutPrice * Atr_StackSize());
    MoneyInputFrame_SetCopper (Atr_StartingPrice,   new_Item_StartPrice * Atr_StackSize());
    MoneyInputFrame_SetCopper (Atr_ItemPrice,   new_Item_BuyoutPrice);
  end

  local cheapestStack = scn.bestPrices[Atr_StackSize()];

  Atr_Recommend_Basis_Text:SetTextColor (1,1,1);

  if (Atr_IsSelectedTab_Hints()) then
    Atr_Recommend_Basis_Text:SetTextColor (.8,.8,1);
    Atr_Recommend_Basis_Text:SetText ("("..ZT("based on").." "..basedata.whenText..")");
  elseif (scn.absoluteBest and basedata.stackSize == scn.absoluteBest.stackSize and basedata.buyoutPrice == scn.absoluteBest.buyoutPrice) then
    Atr_Recommend_Basis_Text:SetText ("("..ZT("based on cheapest current auction")..")");
  elseif (cheapestStack and basedata.stackSize == cheapestStack.stackSize and basedata.buyoutPrice == cheapestStack.buyoutPrice) then
    Atr_Recommend_Basis_Text:SetText ("("..ZT("based on cheapest stack of the same size")..")");
  else
    Atr_Recommend_Basis_Text:SetText ("("..ZT("based on selected auction")..")");
  end

end


-----------------------------------------

function Atr_StackPriceChangedFunc ()
  Auctionator.Debug.Message( 'Atr_StackPriceChangedFunc' )

  local new_Stack_BuyoutPrice = MoneyInputFrame_GetCopper (Atr_StackPrice);
  local new_Item_BuyoutPrice  = math.floor (new_Stack_BuyoutPrice / Atr_StackSize());
  local new_Item_StartPrice   = Atr_CalcStartPrice (new_Item_BuyoutPrice);

  local calculatedStackPrice = MoneyInputFrame_GetCopper(Atr_ItemPrice) * Atr_StackSize();

  -- check to prevent looping

  if (calculatedStackPrice ~= new_Stack_BuyoutPrice) then
    MoneyInputFrame_SetCopper (Atr_ItemPrice,   new_Item_BuyoutPrice);
    MoneyInputFrame_SetCopper (Atr_StartingPrice, new_Item_StartPrice * Atr_StackSize());
  end

end

-----------------------------------------

function Atr_ItemPriceChangedFunc ()
  Auctionator.Debug.Message( 'Atr_ItemPriceChangedFunc' )

  local new_Item_BuyoutPrice = MoneyInputFrame_GetCopper (Atr_ItemPrice);
  local new_Item_StartPrice  = Atr_CalcStartPrice (new_Item_BuyoutPrice);

  local calculatedItemPrice = math.floor (MoneyInputFrame_GetCopper (Atr_StackPrice) / Atr_StackSize());

  -- check to prevent looping

  if (calculatedItemPrice ~= new_Item_BuyoutPrice) then
    MoneyInputFrame_SetCopper (Atr_StackPrice,    new_Item_BuyoutPrice * Atr_StackSize());
    MoneyInputFrame_SetCopper (Atr_StartingPrice, new_Item_StartPrice  * Atr_StackSize());
  end

end

-----------------------------------------

function Atr_StackSizeChangedFunc ()
  Auctionator.Debug.Message( 'Atr_StackSizeChangedFunc' )

  local item_BuyoutPrice    = MoneyInputFrame_GetCopper (Atr_ItemPrice);
  local new_Item_StartPrice   = Atr_CalcStartPrice (item_BuyoutPrice);

  MoneyInputFrame_SetCopper (Atr_StackPrice,    item_BuyoutPrice * Atr_StackSize());
  MoneyInputFrame_SetCopper (Atr_StartingPrice, new_Item_StartPrice  * Atr_StackSize());

--  Atr_MemorizeButton:Show();

  gSellPane.UINeedsUpdate = true;

end

-----------------------------------------

function Atr_NumAuctionsChangedFunc (x)
  Auctionator.Debug.Message( 'Atr_NumAuctionsChangedFunc' )

--  Atr_MemorizeButton:Show();

  gSellPane.UINeedsUpdate = true;
end


-----------------------------------------

local gABPIC_Previous = nil;    -- performance

-----------------------------------------

function ATR_AddToBattlePetIconCache (itemLink, texture)
  Auctionator.Debug.Message( 'ATR_AddToBattlePetIconCache', itemLink, texture )

  if (itemLink ~= gABPIC_Previous and itemLink ~= nil) then
    gABPIC_Previous = itemLink;
    gATR_BattlePetIconCache[itemLink] = texture;
  end

end

-----------------------------------------

function Atr_SetTextureButton (elementName, count, itemlink)
  Auctionator.Debug.Message( 'Atr_SetTextureButton', elementName, count, itemlink )

  local texture = GetItemIcon (itemlink)

  if (texture == nil) then
    texture = gATR_BattlePetIconCache[itemlink];
  end

  Atr_SetTextureButtonByTexture (elementName, count, texture)

end

-----------------------------------------

function Atr_SetTextureButtonByTexture (elementName, count, texture)
  Auctionator.Debug.Message( 'Atr_SetTextureButtonByTexture', elementName, count, texture )

  local textureElement = _G[elementName]

  if (texture) then
    textureElement:Show()
    textureElement:SetNormalTexture (texture)
    Atr_SetTextureButtonCount (elementName, count)
  else
    --textureElement:Hide()   -- if hidden can't be dragged into
    Atr_SetTextureButtonCount (elementName, 0)
  end

end


-----------------------------------------

function Atr_SetTextureButtonCount (elementName, count)
  Auctionator.Debug.Message( 'Atr_SetTextureButtonCount', elementName, count )

  local countElement   = _G[elementName.."Count"];

  if (count > 1) then
    countElement:SetText (count);
    countElement:Show();
  else
    countElement:Hide();
  end

end

-----------------------------------------

function Atr_ShowRecTooltip ()
  -- Auctionator.Debug.Message( 'Atr_ShowRecTooltip' )

  local link = gCurrentPane.activeScan.itemLink;
  local num  = Atr_StackSize();

  if (not link) then
    link = gJustPosted.ItemLink;
    num  = gJustPosted.StackSize;
  end

  if (link) then
    if (num < 1) then num = 1; end;

    if (zc.IsBattlePetLink (link)) then
      local speciesID, level, breedQuality, maxHealth, power, speed, battlePetID, name = zc.ParseBattlePetLink(link)

      BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)

      BattlePetTooltip:ClearAllPoints();
      BattlePetTooltip:SetPoint("BOTTOMLEFT", Atr_RecommendItem_Tex, "BOTTOMRIGHT", 10, 0)

    else
      GameTooltip:SetOwner(Atr_RecommendItem_Tex, "ANCHOR_RIGHT");
      GameTooltip:SetHyperlink (link, num);
      gCurrentPane.tooltipvisible = true;
    end
  end

end

-----------------------------------------

function Atr_HideRecTooltip ()
  Auctionator.Debug.Message( 'Atr_HideRecTooltip' )

  gCurrentPane.tooltipvisible = nil;
  GameTooltip:Hide();
  BattlePetTooltip:Hide();

end

-----------------------------------------

function Atr_ClickRecItemTexture ()
  Auctionator.Debug.Message( 'Atr_ClickRecItemTexture' )

  if ( IsModifiedClick() and gCurrentPane and gCurrentPane.activeScan and gCurrentPane.activeScan.itemLink) then
    if (IsModifiedClick ("CHATLINK")) then
      if (auctionator_orig_ChatEdit_InsertLink) then
        auctionator_orig_ChatEdit_InsertLink (gCurrentPane.activeScan.itemLink)
      end
    end
  end
end


-----------------------------------------

function Atr_OnAuctionHouseShow()
  Auctionator.Debug.Message( 'Atr_OnAuctionHouseShow' )

  if (AUCTIONATOR_DEFTAB == 1) then   Atr_SelectPane (SELL_TAB);  end
  if (AUCTIONATOR_DEFTAB == 2) then   Atr_SelectPane (BUY_TAB); end
  if (AUCTIONATOR_DEFTAB == 3) then   Atr_SelectPane (MORE_TAB);  end

  Atr_ResetDuration();

  gJustPosted.ItemName = nil;
  gSellPane:ClearSearch();

  if (gCurrentPane) then
    gCurrentPane.UINeedsUpdate = true;
  end
end

-----------------------------------------

function Atr_OnAuctionHouseClosed()
  Auctionator.Debug.Message( 'Atr_OnAuctionHouseClosed' )

  Atr_HideAllDialogs();

  Atr_CheckingActive_Finish ();

  Atr_ClearScanCache();

  gSellPane:ClearSearch();
  gShopPane:ClearSearch();
  gMorePane:ClearSearch();

end

-----------------------------------------

function Atr_HideAllDialogs()
  Auctionator.Debug.Message( 'Atr_HideAllDialogs' )

  Atr_CheckActives_Frame:Hide();
  Atr_Error_Frame:Hide();
  Atr_Buy_Confirm_Frame:Hide();
  Atr_FullScanFrame:Hide();
  Atr_Adv_Search_Dialog:Hide();
  Atr_Mask:Hide();
  Atr_SList_Conflict_Frame:Hide()
  Atr_ShpList_Edit_Frame:Hide()
end



-----------------------------------------

local function Bump_MaxButton_Hack()
  Auctionator.Debug.Message( 'Bump_MaxButton_Hack' )

  if (NXInit) then    -- hack seems to interfere with Carbonite
--    zc.md ("Carbonite detected");
    return;
  end

  if ( UIDROPDOWNMENU_MAXBUTTONS < 29 ) then

    local toggle;
    if ( not WorldMapFrame:IsVisible() ) then
      ToggleFrame(WorldMapFrame);
      toggle = true;
    end
    SetMapZoom(2);
    if ( toggle ) then
      ToggleFrame(WorldMapFrame);
    end
  end

end


-----------------------------------------

function Atr_OnUpdate(self, elapsed)

  -- update the global "precision" timer

  gAtr_ptime = gAtr_ptime and gAtr_ptime + elapsed or 0;


  -- check deferred call queue

  if (zc.periodic (self, "dcq_lastUpdate", 0.05, elapsed)) then
    zc.CheckDeferredCall();
  end

  -- special idle routine for full scan analyze phase gets called more often

--  if (Atr_FullScanFrameIdle == nil) then
--    Atr_Error_Display ("Looks like you installed Auctionator\n without quitting out of WoW.\n\nPlease quit and restart\nWoW to complete the install.")
--  else
    local handled = Atr_FullScanFrameIdle()
    if (handled) then
      return
    end
--  end

  -- the core Idle routine

  if (zc.periodic (self, "idle_lastUpdate", 0.2, elapsed)) then
    Atr_Idle (self, elapsed);
  end


end


-----------------------------------------
local verCheckMsgState = 0;
-----------------------------------------

function Atr_Idle(self, elapsed)

  if (gCurrentPane and gCurrentPane.tooltipvisible) then
    Atr_ShowRecTooltip();
  end

  if (Atr_IsModeBuy()) then
    Atr_Shop_Idle();
  end


  if (verCheckMsgState == 0) then
    verCheckMsgState = time();
  end

  if (verCheckMsgState > 1 and time() - verCheckMsgState > 5) then  -- wait 5 seconds
    verCheckMsgState = 1;

    local guildname = GetGuildInfo ("player");
    if (guildname) then
      Atr_SendAddon_VREQ ("GUILD");
    end

  end

  Atr_Update_ShareRequest()

  if (not Atr_IsTabSelected() or AuctionatorMessageFrame == nil) then
    return;
  end

  if (gHentryTryAgain) then
    Atr_HEntryOnClick();
    return;
  end

  if (gCurrentPane.activeSearch and gCurrentPane.activeSearch.processing_state == Auctionator.Constants.SearchStates.PRE_QUERY) then   ------- check whether to send a new auction query to get the next page -------
    gCurrentPane.activeSearch:Continue();
  end

  Atr_UpdateUI ();

  Atr_CheckingActiveIdle();

  Atr_Buy_Idle();

  if (gHideAPFrameCheck == nil) then  -- for the addon 'Auction Profit' (flags for efficiency so we only check one time)
    gHideAPFrameCheck = true;
    if (AP_Bid_MoneyFrame) then
      AP_Bid_MoneyFrame:Hide();
      AP_Buy_MoneyFrame:Hide();
    end
  end
end

-----------------------------------------

local gPrevSellItemLink;

-----------------------------------------

function Atr_OnNewAuctionUpdate()
  Auctionator.Debug.Message( 'Atr_OnNewAuctionUpdate' )

  if (not gAtr_ClickAuctionSell) then
    gPrevSellItemLink = nil;
    return;
  end

  gAtr_ClickAuctionSell = false;

  local auctionItemName, auctionCount, auctionLink = Atr_GetSellItemInfo();

  if (gPrevSellItemLink ~= auctionLink) then

    gPrevSellItemLink = auctionLink;

    if (auctionLink) then
      gJustPosted.ItemName = nil;
      Atr_ClearList();    -- better UE
      Atr_SetToShowCurrent();
    end

    MoneyInputFrame_SetCopper (Atr_StackPrice, 0);
    MoneyInputFrame_SetCopper (Atr_StartingPrice,  0);
    Atr_ResetDuration();

    if (gJustPosted.ItemName == nil) then
      local item_link = Auctionator.ItemLink:new({ item_link = auctionLink })

      local cacheHit = gSellPane:DoSearch (auctionItemName, item_link:IdString(), auctionLink, 20);

      gSellPane.totalItems  = Atr_GetNumItemInBags (auctionLink);
      gSellPane.fullStackSize = auctionLink and (select (8, GetItemInfo (auctionLink))) or 0;

      -- multi sell doesn't work with Battle Pets.  Even in Blizzard UI
      if (zc.IsBattlePetLink (auctionLink)) then
        gSellPane.totalItems = 1;
        gSellPane.fullStackSize = 1;
      end

      local prefNumStacks, prefStackSize = Atr_GetSellStacking (auctionLink, auctionCount, gSellPane.totalItems);

      if (time() - gAutoSingleton < 5) then
        Atr_SetInitialStacking (1, 1);
      else
        Atr_SetInitialStacking (prefNumStacks, prefStackSize);
      end

      if (cacheHit) then
        Atr_OnSearchComplete ();
      end

      Atr_SetTextureButton ("Atr_SellControls_Tex", Atr_StackSize(), auctionLink);
      Atr_SellControls_TexName:SetText (auctionItemName);
    else
      Atr_SetTextureButton ("Atr_SellControls_Tex", 0, nil);
      Atr_SellControls_TexName:SetText ("");
    end

  elseif (Atr_StackSize() ~= auctionCount) then

    local prefNumStacks, prefStackSize = Atr_GetSellStacking (auctionLink, auctionCount, gSellPane.totalItems);

    Atr_SetInitialStacking (prefNumStacks, prefStackSize);

    Atr_SetTextureButton ("Atr_SellControls_Tex", Atr_StackSize(), auctionLink);

    Atr_FindBestCurrentAuction();
    Atr_ResetDuration();
  end

  gSellPane.UINeedsUpdate = true;

end

---------------------------------------------------------

function Atr_UpdateUI ()
  -- Auctionator.Debug.Message( 'Atr_UpdateUI' )

  local needsUpdate = gCurrentPane.UINeedsUpdate;

  if (gCurrentPane.UINeedsUpdate) then

    gCurrentPane.UINeedsUpdate = false;

    if (Atr_ShowingSearchSummary()) then
      Atr_ShowSearchSummary();
    elseif (Atr_IsSelectedTab_Current()) then
      Atr_ShowCurrentAuctions();
    elseif (Atr_IsSelectedTab_History()) then
      Atr_ShowHistory();
    else
      Atr_ShowOldPostings();
    end

    Atr_SetMessage ("");
    local scn = gCurrentPane.activeScan;

    if (scn == nil or scn:IsNil()) then
      Atr_ListTabs:Hide();
    else
      Atr_ListTabs:Show();
    end

    if (Atr_IsModeCreateAuction()) then

      Atr_UpdateRecommendation (false);
    else
      Atr_HideElems (recommendElements);

      if (scn == nil or scn:IsNil()) then
        Atr_ShowItemNameAndTexture (gCurrentPane.activeSearch.searchText);
      else
        Atr_ShowItemNameAndTexture (scn.itemName);
      end

      if (Atr_IsModeBuy()) then

        if (gCurrentPane.activeSearch.searchText == "") then
          Atr_SetMessage (ZT("Select an item from the list on the left\n or type a search term above to start a scan."));
        end
      end

    end


    if (Atr_IsTabSelected(BUY_TAB)) then
      Atr_Shop_UpdateUI();
    end

  end

  -- update the hlist if needed

  if (gHlistNeedsUpdate and Atr_IsModeActiveAuctions()) then
    gHlistNeedsUpdate = false;
    Atr_DisplayHlist();
  end

  if (Atr_IsTabSelected(SELL_TAB)) then
    Atr_UpdateUI_SellPane (needsUpdate);
  end

end

---------------------------------------------------------

function Atr_UpdateUI_SellPane (needsUpdate)
  -- Auctionator.Debug.Message( 'Atr_UpdateUI_SellPane', needsUpdate )

  local auctionItemName, auctionTexture = GetAuctionSellItemInfo();

  if (needsUpdate) then

    if (gCurrentPane.activeSearch and gCurrentPane.activeSearch.processing_state ~= Auctionator.Constants.SearchStates.NULL) then
      Atr_CreateAuctionButton:Disable();
      Atr_FullScanButton:Disable();
      Auctionator1Button:Disable();
      MoneyInputFrame_SetCopper (Atr_StartingPrice,  0);
      return;
    else
      Atr_FullScanButton:Enable();
      Auctionator1Button:Enable();


      if (Atr_Batch_Stacksize.oldStackSize ~= Atr_StackSize()) then
        Atr_Batch_Stacksize.oldStackSize = Atr_StackSize();
        local itemPrice = MoneyInputFrame_GetCopper(Atr_ItemPrice);
        MoneyInputFrame_SetCopper (Atr_StackPrice,  itemPrice * Atr_StackSize());
      end

      Atr_StartingPriceDiscountText:SetText (ZT("Starting Price Discount")..":  "..AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT.."%");

      if (Atr_Batch_NumAuctions:GetNumber() < 2) then
        Atr_Batch_Stacksize_Text:SetText (ZT("stack of"));
        Atr_CreateAuctionButton:SetText (ZT("Create Auction"));
      else
        Atr_Batch_Stacksize_Text:SetText (ZT("stacks of"));
        Atr_CreateAuctionButton:SetText (string.format (ZT("Create %d Auctions"), Atr_Batch_NumAuctions:GetNumber()));
      end

      if (Atr_StackSize() > 1) then
        Atr_StackPriceText:SetText (ZT("Buyout Price").." |cff55ddffx"..Atr_StackSize().."|r");
        Atr_ItemPriceText:SetText (ZT("Per Item"));
        Atr_ItemPriceText:Show();
        Atr_ItemPrice:Show();
      else
        Atr_StackPriceText:SetText (ZT("Buyout Price"));
        Atr_ItemPriceText:Hide();
        Atr_ItemPrice:Hide();
      end

      Atr_SetTextureButtonByTexture ("Atr_SellControls_Tex", Atr_StackSize(), auctionTexture);


      local maxAuctions = 0;
      if (Atr_StackSize() > 0) then
        maxAuctions = math.floor (gCurrentPane.totalItems / Atr_StackSize());
      end

      Atr_Batch_MaxAuctions_Text:SetText (ZT("max")..": "..maxAuctions);
      Atr_Batch_MaxStacksize_Text:SetText (ZT("max")..": "..gCurrentPane.fullStackSize);

      Atr_SetDepositText();
    end

    if (gJustPosted.ItemName ~= nil) then

      Atr_Recommend_Text:SetText (string.format (ZT("Auction created for %s"), gJustPosted.ItemName));
      MoneyFrame_Update ("Atr_RecommendPerStack_Price", gJustPosted.BuyoutPrice);
      Atr_SetTextureButton ("Atr_RecommendItem_Tex", gJustPosted.StackSize, gJustPosted.ItemLink);

      gCurrentPane.currIndex = gCurrentPane.activeScan:FindInSortedData (gJustPosted.StackSize, gJustPosted.BuyoutPrice);

      if (Atr_IsSelectedTab_Current()) then
        Atr_HighlightEntry (gCurrentPane.currIndex);    -- highlight the newly created auction(s)
      else
        Atr_HighlightEntry (gCurrentPane.histIndex);
      end

    elseif (gCurrentPane:IsScanNil()) then
      Atr_SetMessage (ZT("Drag an item you want to sell to this area."));
    end
  end

  -- stuff we should do every time (not just when needsUpdate is true)

  local start   = MoneyInputFrame_GetCopper(Atr_StartingPrice);
  local buyout  = MoneyInputFrame_GetCopper(Atr_StackPrice);

  local pricesOK  = (start > 0 and (start <= buyout or buyout == 0) and (auctionItemName ~= nil));

  local numToSell = Atr_Batch_NumAuctions:GetNumber() * Atr_Batch_Stacksize:GetNumber();

  zc.EnableDisable (Atr_CreateAuctionButton,  pricesOK and (numToSell <= gCurrentPane.totalItems));

end

-----------------------------------------

function Atr_SetDepositText()
  Auctionator.Debug.Message( 'Atr_SetDepositText' )

  _, auctionCount = Atr_GetSellItemInfo();

  if (auctionCount > 0) then
    local duration = UIDropDownMenu_GetSelectedValue(Atr_Duration);

    local deposit1 = CalculateAuctionDeposit (duration) / auctionCount;
    local numAuctionString = "";
    if (Atr_Batch_NumAuctions:GetNumber() > 1) then
      numAuctionString = "  |cffff55ff x"..Atr_Batch_NumAuctions:GetNumber();
    end

    Atr_Deposit_Text:SetText (ZT("Deposit")..":    "..zc.priceToMoneyString(deposit1 * Atr_StackSize(), true)..numAuctionString);
  else
    Atr_Deposit_Text:SetText ("");
  end
end


-----------------------------------------

function Atr_BuildActiveAuctions ()
  Auctionator.Debug.Message( 'Atr_BuildActiveAuctions' )

  gActiveAuctions = {};

  local i = 1;
  while (true) do
    local name, _, count = GetAuctionItemInfo ("owner", i);
    if (name == nil) then
      break;
    end

    if (count > 0) then   -- count is 0 for sold items

      local link    = GetAuctionItemLink ("owner", i);
      local item_link = Auctionator.ItemLink:new({ item_link = link })

      if (gActiveAuctions[ item_link:IdString() ] == nil) then
        gActiveAuctions[ item_link:IdString() ] = { link=link, name=name, count=1 }
      else
        gActiveAuctions[ item_link:IdString() ].count = gActiveAuctions[ item_link:IdString() ].count + 1;
      end
    end

    i = i + 1;
  end
end

-----------------------------------------

function Atr_GetUCIcon (itemLink)
  Auctionator.Debug.Message( 'Atr_GetUCIcon', itemLink )

  local icon = "|TInterface\\BUTTONS\\\UI-PassiveHighlight:18:18:0:0|t "

  local undercutFound = false

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })
  local scan = Atr_FindScan( item_link:IdString() )

  if (scan and scan.absoluteBest and scan.whenScanned ~= 0 and scan.yourBestPrice and scan.yourWorstPrice) then

    local absBestPrice = scan.absoluteBest.itemPrice;

    if (scan.yourBestPrice <= absBestPrice and scan.yourWorstPrice > absBestPrice) then
      icon = "|TInterface\\AddOns\\Auctionator\\Images\\CrossAndCheck:18:18:0:0|t "
      undercutFound = true;
    elseif (scan.yourBestPrice <= absBestPrice) then
      icon = "|TInterface\\RAIDFRAME\\\ReadyCheck-Ready:18:18:0:0|t "
    else
      icon = "|TInterface\\RAIDFRAME\\\ReadyCheck-NotReady:18:18:0:0|t "
      undercutFound = true;
    end
  end

  if (gAtr_CheckingActive_State ~= ATR_CACT_NULL and undercutFound) then
    gAtr_CheckingActive_NumUndercuts = gAtr_CheckingActive_NumUndercuts + 1;
  end

  return icon;

end

-----------------------------------------

function Atr_DisplayHlist ()
  Auctionator.Debug.Message( 'Atr_DisplayHlist' )

  if (Atr_IsTabSelected (BUY_TAB)) then   -- done this way because OnScrollFrame always calls Atr_DisplayHlist
    Atr_DisplaySlist();
    return;
  end

  Atr_BuildGlobalHistoryList ();

  local numrows = #gHistoryItemList;

  local line;             -- 1 through NN of our window to scroll
  local dataOffset;         -- an index into our data calculated from the scroll offset

  FauxScrollFrame_Update (Atr_Hlist_ScrollFrame, numrows, ITEM_HIST_NUM_LINES, 16);

  for line = 1,ITEM_HIST_NUM_LINES do

    gCurrentPane.hlistScrollOffset = FauxScrollFrame_GetOffset (Atr_Hlist_ScrollFrame);

    dataOffset = line + gCurrentPane.hlistScrollOffset;

    local lineEntry = _G["AuctionatorHEntry"..line];

    lineEntry:SetID(dataOffset);

    if (dataOffset <= numrows and gHistoryItemList[dataOffset]) then

      local lineEntry_text = _G["AuctionatorHEntry"..line.."_EntryText"];

      local iName = gHistoryItemList[dataOffset].name;
      local iLink = gHistoryItemList[dataOffset].link;

      local icon = "";

      if (not doFull) then
        icon = Atr_GetUCIcon (iLink);
      end

      lineEntry_text:SetText  (icon..Atr_AbbrevItemName (iName));

      local item_link = Auctionator.ItemLink:new({ item_link = iLink })
      local IDstring = item_link:IdString()

      if (IDstring and IDstring == gCurrentPane.activeSearch.IDstring) then
        lineEntry:SetButtonState ("PUSHED", true);
      else
        lineEntry:SetButtonState ("NORMAL", false);
      end

      lineEntry:Show();
    else
      lineEntry:Hide();
    end
  end


end

-----------------------------------------

function Atr_ClearHlist ()
  Auctionator.Debug.Message( 'Atr_ClearHlist' )

  local line;
  for line = 1,ITEM_HIST_NUM_LINES do
    local lineEntry = _G["AuctionatorHEntry"..line];
    lineEntry:Hide();

    local lineEntry_text = _G["AuctionatorHEntry"..line.."_EntryText"];
    lineEntry_text:SetText    ("");
    lineEntry_text:SetTextColor (.7,.7,.7);
  end

end

-----------------------------------------

function Atr_HEntryOnClick(self)
  Auctionator.Debug.Message( 'Atr_HEntryOnClick', self )

  Atr_SetToShowCurrent();

  if (gCurrentPane == gShopPane) then
    Atr_SEntryOnClick(self);
    return;
  end

  local line = self;

  if (gHentryTryAgain) then
    line = gHentryTryAgain;
    gHentryTryAgain = nil;
  end

  local _, itemLink;
  local IDstring;
  local entryIndex = line:GetID();

  itemName = gHistoryItemList[entryIndex].name;
  itemLink = gHistoryItemList[entryIndex].link;

  if (IsAltKeyDown() and Atr_IsModeActiveAuctions()) then
    Atr_Cancel_Undercuts_OnClick (itemName)
    return;
  end

  gCurrentPane.UINeedsUpdate = true;

  Atr_ClearAll();

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })
  local cacheHit = gCurrentPane:DoSearch( itemName, item_link:IdString(), itemLink )

  Atr_ClearHistory()

  -- for the highlight
  Atr_DisplayHlist()

  if cacheHit then
    Atr_OnSearchComplete()
  end

  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-----------------------------------------

function Atr_ListTabOnClick (id)
  Auctionator.Debug.Message( 'Atr_ListTabOnClick', id )

  if (gCurrentPane.activeSearch.processing_state ~= Auctionator.Constants.SearchStates.NULL) then   -- if we're scanning auctions don't respond
    return;
  end

  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

  Atr_SetToShowTab (id);

  Atr_ClearHistory();

end

-----------------------------------------

function Atr_IsSelectedTab_Current ()
  Auctionator.Debug.Message( 'Atr_IsSelectedTab_Current' )

  return (PanelTemplates_GetSelectedTab (Atr_ListTabs) == 1);
end

-----------------------------------------

function Atr_IsSelectedTab_History ()
  Auctionator.Debug.Message( 'Atr_IsSelectedTab_History' )
  return (PanelTemplates_GetSelectedTab (Atr_ListTabs) == 2);
end

-----------------------------------------

function Atr_IsSelectedTab_Hints ()
  Auctionator.Debug.Message( 'Atr_IsSelectedTab_Hints' )
  return (PanelTemplates_GetSelectedTab (Atr_ListTabs) == 3);
end

-----------------------------------------

function Atr_SetToShowTab (which)
  Auctionator.Debug.Message( 'Atr_SetToShowTab', which )

  if (PanelTemplates_GetSelectedTab (Atr_ListTabs) == which) then
    return;
  end

  PanelTemplates_SetTab(Atr_ListTabs, which);
  gCurrentPane.UINeedsUpdate = true;
end

-----------------------------------------

function Atr_SetToShowCurrent ()
  Auctionator.Debug.Message( 'Atr_SetToShowCurrent' )
  Atr_SetToShowTab (1);
end

-----------------------------------------

function Atr_SetToShowHistory ()
  Auctionator.Debug.Message( 'Atr_SetToShowHistory' )
  Atr_SetToShowTab (2);
end

-----------------------------------------

function Atr_SetToShowHints ()
  Auctionator.Debug.Message( 'Atr_SetToShowHints' )
  Atr_SetToShowTab (3);
end

-----------------------------------------

function Atr_ShowingSearchSummary ()
  Auctionator.Debug.Message( 'Atr_ShowingSearchSummary' )

  if (gCurrentPane.activeSearch and gCurrentPane.activeSearch.searchText ~= "" and gCurrentPane:IsScanNil() and gCurrentPane.activeSearch:NumScans() > 0) then

    return true;
  end

  return false;
end


-----------------------------------------

function Atr_RedisplayAuctions ()
  Auctionator.Debug.Message( 'Atr_RedisplayAuctions' )

  if (Atr_ShowingSearchSummary()) then
    Atr_ShowSearchSummary();
  elseif (Atr_IsSelectedTab_Current()) then
    Atr_ShowCurrentAuctions();
  elseif Atr_IsSelectedTab_History() then
    Atr_ShowHistory();
  else
    Atr_ShowOldPostings();
  end
end

-----------------------------------------

function Atr_BuildPostHistText(data)
  Auctionator.Debug.Message( 'Atr_BuildPostHistText', data )

  local stacktext = "";
--  if (data.stackSize > 1) then
--    stacktext = " (stack of "..data.stackSize..")";
--  end

  local now   = time();
  local nowtime = date ("*t");

  local when    = data.when;
  local whentime  = date ("*t", when);

  local datestr = "";

  if (data.type == "hy") then
    return ZT("average of your auctions for").." "..whentime.year;
  elseif (data.type == "hm") then
    if (nowtime.year == whentime.year) then
      return ZT("average of your auctions for").." "..date("%B", when);
    else
      return ZT("average of your auctions for").." "..date("%B %Y", when);
    end
  elseif (data.type == "hd") then
    return ZT("average of your auctions for").." "..monthDay(whentime);
  else
    return ZT("your auction on").." "..monthDay(whentime)..date(" at %I:%M %p", when);
  end
end

-----------------------------------------

function monthDay (when)
  Auctionator.Debug.Message( 'monthDay', when )

  local t = time(when);

  local s = date("%b ", t);

  return s..when.day;

end

-----------------------------------------

function Atr_ShowLineTooltip (self)
  Auctionator.Debug.Message( 'Atr_ShowLineTooltip', self )

  local itemLink = self.itemLink;

  if (zc.IsBattlePetLink (itemLink)) then

    local speciesID, level, breedQuality, maxHealth, power, speed, battlePetID, name = zc.ParseBattlePetLink(itemLink)

    BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)

    BattlePetTooltip:ClearAllPoints();
    BattlePetTooltip:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 10, 0)

  else   -- normal case

    local fname = self:GetName()
    local ftname = fname.."_EntryText"
    local textPart = _G[ftname]

    if (itemLink) then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -280)
      GameTooltip:SetHyperlink (itemLink, 1)
    end
  end
end




-----------------------------------------

function Atr_HideLineTooltip (self)
  Auctionator.Debug.Message( 'Atr_HideLineTooltip', self )

  GameTooltip:Hide();
  BattlePetTooltip:Hide();
end


-----------------------------------------

function Atr_Onclick_Back ()
  Auctionator.Debug.Message( 'Atr_Onclick_Back' )

  gCurrentPane.activeScan = Atr_FindScan (nil);
  gCurrentPane.UINeedsUpdate = true;

  if (gCurrentPane.savedScrollOffset) then
    FauxScrollFrame_SetOffset (AuctionatorScrollFrame, gCurrentPane.savedScrollOffset)
    AuctionatorScrollFrame:SetVerticalScroll(gCurrentPane.savedVertScroll);
    gCurrentPane.savedScrollOffset = nil;
  end
end

-----------------------------------------

function Atr_Onclick_Col1 ()
  Auctionator.Debug.Message( 'Atr_Onclick_Col1' )

  if (gCurrentPane.activeSearch) then
    gCurrentPane.activeSearch:ClickPriceCol();
    gCurrentPane.UINeedsUpdate = true;
  end

end

-----------------------------------------

function Atr_Onclick_Col3 ()
  Auctionator.Debug.Message( 'Atr_Onclick_Col3' )

  if (gCurrentPane.activeSearch) then
    gCurrentPane.activeSearch:ClickNameCol();
    gCurrentPane.UINeedsUpdate = true;
  end

end

-----------------------------------------

function Atr_ShowSearchSummary()
  Auctionator.Debug.Message( 'Atr_ShowSearchSummary' )

  Atr_Col1_Heading:Hide();
  Atr_Col3_Heading:Hide();
  Atr_Col1_Heading_Button:Show();
  Atr_Col3_Heading_Button:Show();
  Atr_Col4_Heading:Show();

  gCurrentPane.activeSearch:UpdateArrows ();

  local numrows = gCurrentPane.activeSearch:NumScans();

  if (gCurrentPane.activeScan.hasStack) then
    Atr_Col4_Heading:SetText (ZT("Total Price"));
  else
    Atr_Col4_Heading:SetText ("");
  end

  local iLevelStr;
  local highIndex  = 0;
  local line     = 0;                             -- 1 through 12 of our window to scroll
  local dataOffset = FauxScrollFrame_GetOffset (AuctionatorScrollFrame);      -- an index into our data calculated from the scroll offset

  FauxScrollFrame_Update (AuctionatorScrollFrame, numrows, 12, 16);

  Atr_HideRecTooltip()

  while (line < 12) do

    dataOffset  = dataOffset + 1;
    line    = line + 1;

    local lineEntry = _G["AuctionatorEntry"..line];

    lineEntry:SetID(dataOffset);

    local scn;

    if (gCurrentPane.activeSearch and gCurrentPane.activeSearch:NumSortedScans() > 0) then
      scn = gCurrentPane.activeSearch.sortedScans[dataOffset];
    end

    Auctionator.Debug.Message( 'Atr_ShowSearchSummary line ', line )
    -- Auctionator.Util.Print( scn, 'Scan ' .. line )


    if (dataOffset > numrows or not scn) then

      lineEntry:Hide();

    else
      local data = scn.absoluteBest;

      local lineEntry_item_tag = "AuctionatorEntry"..line.."_PerItem_Price";

      local lineEntry_item    = _G[lineEntry_item_tag];
      local lineEntry_itemtext  = _G["AuctionatorEntry"..line.."_PerItem_Text"];
      local lineEntry_text    = _G["AuctionatorEntry"..line.."_EntryText"];
      local lineEntry_stack   = _G["AuctionatorEntry"..line.."_StackPrice"];

      lineEntry_itemtext:SetText  ("");
      lineEntry_text:SetText  ("");
      lineEntry_stack:SetText ("");

      lineEntry_text:GetParent():SetPoint ("LEFT", 157, 0);

      Atr_SetMFcolor (lineEntry_item_tag);

      lineEntry:Show();

      lineEntry.itemLink = scn.itemLink;

      local r = scn.itemTextColor[1]
      local g = scn.itemTextColor[2]
      local b = scn.itemTextColor[3]

      lineEntry_text:SetTextColor (r, g, b)
      lineEntry_stack:SetTextColor (1, 1, 1)

      -- Auctionator.Util.Print( scn, "Atr_ShowSearchSummary Scan" )
      local icon = Atr_GetUCIcon( scn.itemLink )

      if (not scn:IsNil()) then

        iLevelStr = ""
        if scn.itemClass == LE_ITEM_CLASS_WEAPON or scn.itemClass == LE_ITEM_CLASS_ARMOR then
          iLevelStr = " ("..scn.itemLevel..")"
        end

        if (zc.IsBattlePetLink (scn.itemLink)) then
          iLevelStr = " (Level "..scn.itemLevel..")"
        end

        lineEntry_text:SetText (icon.."  "..scn.itemName..iLevelStr)
        lineEntry_stack:SetText (scn:GetNumAvailable().." "..ZT("available"))
      end

      if (data == nil or scn.sortedData == nil or #scn.sortedData == 0) then
        lineEntry_item:Hide();
        lineEntry_itemtext:Show();
        if (scn.sortedData and #scn.sortedData == 0) then
          lineEntry_itemtext:SetText (ZT("none available"));
        else
          lineEntry_itemtext:SetText (ZT("no buyout price"));
        end
      else
        lineEntry_item:Show();
        lineEntry_itemtext:Hide();
        MoneyFrame_Update (lineEntry_item_tag, zc.round(data.buyoutPrice/data.stackSize) );
      end

      if (zc.StringSame (scn.itemName , gCurrentPane.SS_hilite_itemName)) then
        highIndex = dataOffset;
      end


    end
  end

  Atr_HighlightEntry (highIndex);   -- need this for when called from onVerticalScroll

end

-----------------------------------------

function Atr_ShowCurrentAuctions()
  Auctionator.Debug.Message( 'Atr_ShowCurrentAuctions' )

  Atr_Col1_Heading:Hide()
  Atr_Col3_Heading:Hide()
  Atr_Col4_Heading:Hide()
  Atr_Col1_Heading_Button:Hide()
  Atr_Col3_Heading_Button:Hide()

  local scn = gCurrentPane.activeScan
  if (scn == nil) then
    scn = Atr_FindScan(nil)
  end

  numrows = #scn.sortedData

  if (numrows > 0) then
    Atr_Col1_Heading:Show();
    Atr_Col3_Heading:Show();
    Atr_Col4_Heading:Show();
  end

  Atr_Col1_Heading:SetText (ZT("Item Price"));
  Atr_Col3_Heading:SetText (ZT("Current Auctions"));

  if (scn.hasStack) then
    Atr_Col4_Heading:SetText (ZT("Stack Price"));
  else
    Atr_Col4_Heading:SetText ("");
  end

  local line     = 0;                             -- 1 through 12 of our window to scroll
  local dataOffset = FauxScrollFrame_GetOffset (AuctionatorScrollFrame);      -- an index into our data calculated from the scroll offset

  FauxScrollFrame_Update (AuctionatorScrollFrame, numrows, 12, 16);

  while (line < 12) do

    dataOffset  = dataOffset + 1;
    line    = line + 1;

    local lineEntry = _G["AuctionatorEntry"..line];

    lineEntry:SetID(dataOffset);

    lineEntry.itemLink = nil;

    if (dataOffset > numrows or not scn.sortedData[dataOffset]) then

      lineEntry:Hide();

    else
      local data = scn.sortedData[dataOffset];

      local lineEntry_item_tag = "AuctionatorEntry"..line.."_PerItem_Price";

      local lineEntry_item    = _G[lineEntry_item_tag];
      local lineEntry_itemtext  = _G["AuctionatorEntry"..line.."_PerItem_Text"];
      local lineEntry_text    = _G["AuctionatorEntry"..line.."_EntryText"];
      local lineEntry_stack   = _G["AuctionatorEntry"..line.."_StackPrice"];

      lineEntry_itemtext:SetText  ("");
      lineEntry_text:SetText  ("");
      lineEntry_stack:SetText ("");

      lineEntry_text:GetParent():SetPoint ("LEFT", 172, 0);

      Atr_SetMFcolor (lineEntry_item_tag);

      local entrytext = "";

      if (data.type == "n") then

        lineEntry:Show();

        if (data.count == 1) then
          entrytext = string.format ("%i %s %i", data.count, ZT ("stack of"), data.stackSize);
        else
          entrytext = string.format ("%i %s %i", data.count, ZT ("stacks of"), data.stackSize);
        end

        lineEntry_text:SetTextColor (0.6, 0.6, 0.6);

        if ( data.stackSize == Atr_StackSize() or Atr_StackSize() == 0 or gCurrentPane ~= gSellPane) then
          lineEntry_text:SetTextColor (1.0, 1.0, 1.0);
        end

        if (data.yours) then
           entrytext = entrytext.." ("..ZT("yours")..")";
        elseif (data.altname) then
           entrytext = entrytext.." ("..data.altname..")";
        end

        lineEntry_text:SetText (entrytext);

        if (data.buyoutPrice == 0) then
          lineEntry_item:Hide();
          lineEntry_itemtext:Show();
          lineEntry_itemtext:SetText (ZT("no buyout price"));
        else
          lineEntry_item:Show();
          lineEntry_itemtext:Hide();
          MoneyFrame_Update (lineEntry_item_tag, zc.round(data.buyoutPrice/data.stackSize) );

          if (data.stackSize > 1) then
            lineEntry_stack:SetText (zc.priceToString(data.buyoutPrice));
            lineEntry_stack:SetTextColor (0.6, 0.6, 0.6);
          end
        end

      else
        zc.msg_red ("Unknown datatype:");
        zc.msg_red (data.type);
      end
    end
  end

  Atr_HighlightEntry (gCurrentPane.currIndex);    -- need this for when called from onVerticalScroll
end

-----------------------------------------

function Atr_ClearHistory ()
  Auctionator.Debug.Message( 'Atr_ClearHistory' )

  gCurrentPane.sortedHist = nil;
end

-----------------------------------------

function Atr_ShowOldPostings()
  Auctionator.Debug.Message( 'Atr_ShowOldPostings' )

  Atr_ShowHistory (true);
end

-----------------------------------------

function Atr_ShowHistory (showPosts)
  Auctionator.Debug.Message( 'Atr_ShowHistory', showPosts )


  if (gCurrentPane.sortedHist == nil) then

    if (showPosts) then
      Atr_Build_PostingsList();
      Atr_FindBestHistoricalAuction ();
    else
      Atr_BuildSortedScanHistoryList(gCurrentPane.activeScan.itemName);
    end
  end

  local showScanHist = (not showPosts);

  Atr_Col1_Heading:Hide();
  Atr_Col3_Heading:Hide();
  Atr_Col4_Heading:Hide();

  if (showScanHist) then
    Atr_Col3_Heading:SetText (ZT("Date"));
    Atr_Col4_Heading:SetText (ZT("Low Low Price"));
  end

  local numrows = gCurrentPane.sortedHist and #gCurrentPane.sortedHist or 0;

--zc.msg ("gCurrentPane.sortedHist: "..numrows,1,0,0);

  if (numrows > 0) then
    Atr_Col1_Heading:Show();
    Atr_Col3_Heading:Show();
--    if (showScanHist) then
--      Atr_Col4_Heading:Show();
--    end
  end

  local line;             -- 1 through 12 of our window to scroll
  local dataOffset;         -- an index into our data calculated from the scroll offset

  FauxScrollFrame_Update (AuctionatorScrollFrame, numrows, 12, 16);

  for line = 1,12 do

    dataOffset = line + FauxScrollFrame_GetOffset (AuctionatorScrollFrame);

    local lineEntry = _G["AuctionatorEntry"..line];

    lineEntry:SetID(dataOffset);

    if (dataOffset <= numrows and gCurrentPane.sortedHist[dataOffset]) then

      local data = gCurrentPane.sortedHist[dataOffset];

      local lineEntry_item_tag = "AuctionatorEntry"..line.."_PerItem_Price";

      local lineEntry_item    = _G[lineEntry_item_tag];
      local lineEntry_itemtext  = _G["AuctionatorEntry"..line.."_PerItem_Text"];
      local lineEntry_text    = _G["AuctionatorEntry"..line.."_EntryText"];
      local lineEntry_stack   = _G["AuctionatorEntry"..line.."_StackPrice"];

      lineEntry_text:GetParent():SetPoint ("LEFT", 172, 0);

      lineEntry_item:Show();
      lineEntry_itemtext:Hide();

      lineEntry_stack:SetText ("");

      Atr_SetMFcolor (lineEntry_item_tag);

      MoneyFrame_Update (lineEntry_item_tag, zc.round(data.itemPrice) );

      lineEntry_text:SetText (data.whenText);
      lineEntry_text:SetTextColor (0.8, 0.8, 1.0);

      lineEntry:Show();
    else
      lineEntry:Hide();
    end
  end

  if (Atr_IsTabSelected (SELL_TAB)) then
    Atr_HighlightEntry (gCurrentPane.histIndex);    -- need this for when called from onVerticalScroll
  else
    Atr_HighlightEntry (-1);
  end
end


-----------------------------------------

function Atr_FindBestCurrentAuction()
  Auctionator.Debug.Message( 'Atr_FindBestCurrentAuction' )

  local scan = gCurrentPane.activeScan;

  if    (Atr_IsModeCreateAuction()) then  gCurrentPane.currIndex = scan:FindCheapest ();
  elseif  (Atr_IsModeBuy()) then        gCurrentPane.currIndex = scan:FindCheapest ();
  else                    gCurrentPane.currIndex = scan:FindMatchByYours ();
  end

end

-----------------------------------------

function Atr_FindBestHistoricalAuction()
  Auctionator.Debug.Message( 'Atr_FindBestHistoricalAuction' )

  gCurrentPane.histIndex = nil;

  if (gCurrentPane.sortedHist and #gCurrentPane.sortedHist > 0) then
    gCurrentPane.histIndex = 1;
  end
end

-----------------------------------------

function Atr_HighlightEntry(entryIndex)
  Auctionator.Debug.Message( 'Atr_HighlightEntry', entryIndex )

  local line;       -- 1 through 12 of our window to scroll

  for line = 1,12 do

    local lineEntry = _G["AuctionatorEntry"..line];

    if (lineEntry:GetID() == entryIndex) then
      lineEntry:SetButtonState ("PUSHED", true);
    else
      lineEntry:SetButtonState ("NORMAL", false);
    end
  end

  local doEnableCancel = false;
  local doEnableBuy = false;
  local data;

  if (Atr_IsSelectedTab_Current() and entryIndex ~= nil and entryIndex > 0 and entryIndex <= #gCurrentPane.activeScan.sortedData) then
    data = gCurrentPane.activeScan.sortedData[entryIndex];
    if (data.yours) then
      doEnableCancel = true;
    end

    if (not data.yours and not data.altname and data.buyoutPrice > 0) then
      doEnableBuy = true;
    end
  end

  Atr_Buy1_Button:Disable();
  Atr_CancelSelectionButton:Disable();

  if (doEnableCancel) then
    Atr_CancelSelectionButton:Enable();

    if (data.count == 1) then
      Atr_CancelSelectionButton:SetText (CANCEL_AUCTION);
    else
      Atr_CancelSelectionButton:SetText (ZT("Cancel Auctions"));
    end
  end

  if (doEnableBuy) then
    Atr_Buy1_Button:Enable();
  end

end




-----------------------------------------

function Atr_EntryOnClick(entry)
  Auctionator.Debug.Message( 'Atr_EntryOnClick', entry )

  Atr_Clear_Owner_Item_Indices();

  local entryIndex = entry:GetID();

  if     (Atr_ShowingSearchSummary())   then
  elseif (Atr_IsSelectedTab_Current())  then    gCurrentPane.currIndex = entryIndex;
  else                        gCurrentPane.histIndex = entryIndex;
  end

  if (Atr_ShowingSearchSummary()) then
    local scn = gCurrentPane.activeSearch.sortedScans[entryIndex];

    gCurrentPane.savedScrollOffset = FauxScrollFrame_GetOffset (AuctionatorScrollFrame)
    gCurrentPane.savedVertScroll   = AuctionatorScrollFrame:GetVerticalScroll()

    FauxScrollFrame_SetOffset (AuctionatorScrollFrame, 0);
    gCurrentPane.activeScan = scn;
    gCurrentPane.currIndex = scn:FindMatchByYours ();
    if (gCurrentPane.currIndex == nil) then
      gCurrentPane.currIndex = scn:FindCheapest();
    end

    gCurrentPane.SS_hilite_itemName = scn.itemName;
    gCurrentPane.UINeedsUpdate = true;
  else
    Atr_HighlightEntry (entryIndex);
    Atr_UpdateRecommendation(true);
  end

  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-----------------------------------------

function AuctionatorMoneyFrame_OnLoad(self)
  Auctionator.Debug.Message( 'AuctionatorMoneyFrame_OnLoad', self )

  self.small = 1;
  MoneyFrame_SetType(self, "AUCTION");
end


-----------------------------------------

function Atr_GetNumItemInBags (targItemLink)
  Auctionator.Debug.Message( 'Atr_GetNumItemInBags', targItemLink )

  local numItems = 0;
  local b, bagID, slotID, numslots;

  local targItemName, targIsBattlePet = zc.ItemNamefromLink (targItemLink)

  --zz (zc.printableLink(targItemLink))
  --zz (zc.printableLink(targItemName), targIsBattlePet)

  for b = 1, #kBagIDs do
    bagID = kBagIDs[b];

    numslots = GetContainerNumSlots (bagID);
    for slotID = 1,numslots do
      local itemLink = GetContainerItemLink(bagID, slotID);
      if (itemLink) then
        local itemName, isBattlePet = zc.ItemNamefromLink (itemLink)

        if (itemName == targItemName and isBattlePet == targIsBattlePet) then

          local _, itemCount  = GetContainerItemInfo(bagID, slotID)
          numItems = numItems + itemCount;
        end
      end
    end
  end

  return numItems;

end

-----------------------------------------

function Atr_DoesAuctionMatch (list, i, name, buyout, stacksize)
  Auctionator.Debug.Message( 'Atr_DoesAuctionMatch', list, i, name, buyout, stacksize )

  local aname, _, astacksize, _, _, _, _, _, _, abuyout, _, _, _ = GetAuctionItemInfo (list, i);

  Auctionator.Debug.Message( 'Atr_DoesAuctionMatch', aname, astacksize, abuyout )

  if (aname and aname == name and abuyout == buyout and astacksize == stacksize) then
    Auctionator.Debug.Message( 'Atr_DoesAuctionMatch', true )
    return true;
  end

  Auctionator.Debug.Message( 'Atr_DoesAuctionMatch', false )

  return false;

end

-----------------------------------------

function Atr_CancelAuction(x)
  Auctionator.Debug.Message( 'Atr_CancelAuction', x )

  CancelAuction(x);

end

-----------------------------------------

function Atr_Clear_Owner_Item_Indices()
  Auctionator.Debug.Message( 'Atr_Clear_Owner_Item_Indices' )

  gAtr_Owner_Item_Indices = {};

end




-----------------------------------------

function Atr_LogCancelAuction(numCancelled, itemLink, stackSize)
  Auctionator.Debug.Message( 'Atr_LogCancelAuction', numCancelled, itemLink, stackSize )

  local SSstring = "";
  if (stackSize and stackSize > 1) then
    SSstring = "|cff00ddddx"..stackSize;
  end

  if (numCancelled > 1) then
    zc.msg_yellow (numCancelled..ZT(" auctions cancelled for ")..itemLink..SSstring);
  elseif (numCancelled == 1) then
    zc.msg_yellow (ZT("Auction cancelled for ")..itemLink..SSstring);
  end

end

-----------------------------------------

function Atr_CancelSelection_OnClick()
  Auctionator.Debug.Message( 'Atr_CancelSelection_OnClick' )

  if (not Atr_IsSelectedTab_Current()) then
    return;
  end

  Atr_CancelAuction_ByIndex (gCurrentPane.currIndex);
end

-----------------------------------------

function Atr_CancelAuction_ByIndex(index)
  Auctionator.Debug.Message( 'Atr_CancelAuction_ByIndex', index )

  local data = gCurrentPane.activeScan.sortedData[index];

  if (data == nil or not data.yours) then
    return;
  end

  local numCancelled  = 0;
  local itemLink    = gCurrentPane.activeScan.itemLink;
  local itemName    = gCurrentPane.activeScan.itemName;

  -- build a list of indices if we don't currently have one

  Auctionator.Debug.Message( 'Atr_CancelAuction_ByIndex', itemLink, itemName )
  if (#gAtr_Owner_Item_Indices == 0) then

    local numInList = Atr_GetNumAuctionItems ("owner");
    local i;
    local x = 1;

    for i = 1,numInList do

      if (Atr_DoesAuctionMatch ("owner", i, itemName, data.buyoutPrice, data.stackSize)) then
        gAtr_Owner_Item_Indices[x] = i;
        x = x + 1;
      end
    end
  end

  Auctionator.Util.Print( gAtr_Owner_Item_Indices, 'Owner Items' )

  -- cancel the last item in the list and remove it

  local numInMatchList = #gAtr_Owner_Item_Indices;

  for x = numInMatchList,1,-1 do

    i = gAtr_Owner_Item_Indices[x];

    table.remove (gAtr_Owner_Item_Indices);

    if (Atr_DoesAuctionMatch ("owner", i, itemName, data.buyoutPrice, data.stackSize)) then
      Atr_CancelAuction (i);
      numCancelled = numCancelled + 1;
      AuctionatorSubtractFromScan (itemLink, data.stackSize, data.buyoutPrice);
      gJustPosted.ItemName = nil;
      Atr_LogCancelAuction (numCancelled, itemLink, data.stackSize);
      break;
    end
  end
end

-----------------------------------------

function Atr_StackingPrefs_Init ()
  Auctionator.Debug.Message( 'Atr_StackingPrefs_Init' )

  AUCTIONATOR_STACKING_PREFS = {};
end

-----------------------------------------

function Atr_Has_StackingPrefs (key)
  Auctionator.Debug.Message( 'Atr_Has_StackingPrefs', key )

  local lkey = key:lower();

  return (AUCTIONATOR_STACKING_PREFS[lkey] ~= nil);
end

-----------------------------------------

function Atr_Clear_StackingPrefs (key)
  Auctionator.Debug.Message( 'Atr_Clear_StackingPrefs', key )

  local lkey = key:lower();

  AUCTIONATOR_STACKING_PREFS[lkey] = nil;
end

-----------------------------------------

function Atr_Get_StackingPrefs (key)
  Auctionator.Debug.Message( 'Atr_Get_StackingPrefs', key )

  local lkey = key:lower();

  if (Atr_Has_StackingPrefs(lkey)) then
    return AUCTIONATOR_STACKING_PREFS[lkey].numstacks, AUCTIONATOR_STACKING_PREFS[lkey].stacksize;
  end

  return nil, nil;

end

-----------------------------------------

function Atr_Set_StackingPrefs_numstacks (key, numstacks)
  Auctionator.Debug.Message( 'Atr_Set_StackingPrefs_numstacks', key, numstacks )

  local lkey = key:lower();

  if (not Atr_Has_StackingPrefs(lkey)) then
    AUCTIONATOR_STACKING_PREFS[lkey] = { stacksize = 0 };
  end

  AUCTIONATOR_STACKING_PREFS[lkey].numstacks = zc.Val (numstacks, 1);
  zz ("Setting stacking prefs (numstacks): ", lkey, AUCTIONATOR_STACKING_PREFS[lkey].numstacks)
end

-----------------------------------------

function Atr_Set_StackingPrefs_stacksize (key, stacksize)
  Auctionator.Debug.Message( 'Atr_Set_StackingPrefs_stacksize', key, stacksize )

  local lkey = key:lower();

  if (not Atr_Has_StackingPrefs(lkey)) then
    AUCTIONATOR_STACKING_PREFS[lkey] = { numstacks = 0};
  end

  AUCTIONATOR_STACKING_PREFS[lkey].stacksize = zc.Val (stacksize, 1);

  zz ("Setting stacking prefs (stacksize): ", lkey, AUCTIONATOR_STACKING_PREFS[lkey].stacksize)
end

-----------------------------------------

function Atr_GetStackingPrefs_ByItem (itemLink)
  Auctionator.Debug.Message( 'Atr_GetStackingPrefs_ByItem', itemLink )

  local SP_NumStacks, SP_StackSize, isUserSpecified

  if (itemLink) then

    SP_NumStacks, SP_StackSize, isUserSpecified =  Atr_Special_SP_ByItem (itemLink);

--zz ("SP_NumStacks, SP_StackSize, isUserSpecified", SP_NumStacks, SP_StackSize, isUserSpecified)

    if (isUserSpecified) then
      return SP_NumStacks, SP_StackSize
    end

    local itemName = GetItemInfo (itemLink);
    local text, spinfo;

    for text, spinfo in pairs (AUCTIONATOR_STACKING_PREFS) do

      if (zc.StringContains (itemName, text)) then
        return spinfo.numstacks, spinfo.stacksize
      end
    end

  end

  return SP_NumStacks, SP_StackSize;
end

-----------------------------------------

function Atr_Special_SP_ByItem (itemLink)
  Auctionator.Debug.Message( 'Atr_Special_SP_ByItem', itemLink )

  if (itemLink) then

    local itemName = GetItemInfo (itemLink);

    local text, spinfo

    for text, spinfo in pairs (AUCTIONATOR_STACKING_PREFS) do

      -- skip over any that were set automatically rather than explicitly by the user

      if (spinfo.numstacks ~= 0) then
        if (zc.StringSame (text, itemName)) then
          return spinfo.numstacks, spinfo.stacksize, true
        end
      end
    end

    if (itemLink) then
      if    (Atr_IsGlyph (itemLink))                then    return Atr_Special_SP (ATR_SK_GLYPHS, 0, 1)
      elseif  (Atr_IsCutGem (itemLink))               then    return Atr_Special_SP (ATR_SK_GEMS_CUT, 0, 1)
      elseif  (Atr_IsGem (itemLink))                  then    return Atr_Special_SP (ATR_SK_GEMS_UNCUT, 1, 0)
      elseif  (Atr_IsItemEnhancement (itemLink))            then    return Atr_Special_SP (ATR_SK_ITEM_ENH, 0, 1)
      elseif  (Atr_IsPotion (itemLink) or Atr_IsElixir (itemLink))  then    return Atr_Special_SP (ATR_SK_POT_ELIX, 1, 0)
      elseif  (Atr_IsFlask (itemLink))                then    return Atr_Special_SP (ATR_SK_FLASKS, 1, 0)
      elseif  (Atr_IsHerb (itemLink))                 then    return Atr_Special_SP (ATR_SK_HERBS, 1, 0)
      end
    end
  end

  return nil, nil, false
end


-----------------------------------------

function Atr_Special_SP (key, default_numstack, default_stacksize)
  Auctionator.Debug.Message( 'Atr_Special_SP', key, default_numstack, default_stacksize )

  if (Atr_Has_StackingPrefs (key)) then
    local numstacks, stacksize = Atr_Get_StackingPrefs(key)
    return numstacks, stacksize, true
  end

  return default_numstack, default_stacksize, false;
end

-----------------------------------------

function Atr_GetSellStacking (itemLink, numDragged, numTotal)
  Auctionator.Debug.Message( 'Atr_GetSellStacking', itemLink, numDragged, numTotal )

  local prefNumStacks, prefStackSize = Atr_GetStackingPrefs_ByItem (itemLink);

  if (prefNumStacks == nil) then
    return 1, numDragged;
  end

  if (prefNumStacks <= 0 and prefStackSize <= 0) then   -- shouldn't happen but just in case
    prefStackSize = 1;
  end

--zc.msg (prefNumStacks, prefStackSize);

  local numStacks = prefNumStacks;
  local stackSize = prefStackSize;
  local numToSell = numDragged;

  if (numStacks == -1) then   -- max number of stacks
    numToSell = numTotal;

  elseif (stackSize == 0) then    -- auto stacksize
    stackSize = math.floor (numDragged / numStacks);

  elseif (numStacks > 0) then
    numToSell = math.min (numStacks * stackSize, numTotal);
  end

  numStacks = math.floor (numToSell / stackSize);

--zc.msg_pink (numStacks, stackSize);

  if (numStacks == 0) then
    numStacks = 1;
    stackSize = numToSell;
--zc.msg_red (numStacks, stackSize);
  end

  return numStacks, stackSize;

end



-----------------------------------------

local gInitial_NumStacks;
local gInitial_StackSize;

-----------------------------------------

function Atr_SetInitialStacking (numStacks, stackSize)
  Auctionator.Debug.Message( 'Atr_SetInitialStacking', numStacks, stackSize )

  gInitial_NumStacks = numStacks;
  gInitial_StackSize = stackSize;

  Atr_Batch_NumAuctions:SetText (numStacks);
  Atr_SetStackSize (stackSize);
end

-----------------------------------------

function Atr_Memorize_Stacking_If ()
  Auctionator.Debug.Message( 'Atr_Memorize_Stacking_If' )

  local _, _, isUserSpecified =  Atr_Special_SP_ByItem (gCurrentPane.activeScan.itemLink);
  if (isUserSpecified) then
--    zz ("Not memorizing stacking for ", gCurrentPane.activeScan.itemLink)
    return
  end

  local newNumStacks = Atr_Batch_NumAuctions:GetNumber();
  local newStackSize = tonumber (Atr_StackSize());

--zz (gInitial_NumStacks, newNumStacks, gInitial_StackSize, newStackSize)

  local stackSizeChanged = (tonumber (gInitial_StackSize) ~= newStackSize);

  if (stackSizeChanged) then

    local itemName = string.lower(gCurrentPane.activeScan.itemName);
    if (itemName) then

      -- see if user is trying to set it back to default

      if (newNumStacks == 1) then
        local _, _, auctionCount = GetAuctionSellItemInfo();
        if (auctionCount == newStackSize) then
          Atr_Clear_StackingPrefs (itemName);
          return;
        end
      end

      -- else remember the new stack size

      Atr_Set_StackingPrefs_stacksize (itemName, Atr_StackSize());
    end
  end
end




-----------------------------------------

function Atr_Duration_OnShow(self)
  Auctionator.Debug.Message( 'Atr_Duration_OnShow', self )

  UIDropDownMenu_Initialize (self, Atr_Duration_Initialize);
  local val = UIDropDownMenu_GetSelectedValue(self)

  if (val == nil) then
    UIDropDownMenu_SetSelectedValue (self, 1);
  end
end

-----------------------------------------

function Atr_Duration_Initialize(self)
  Auctionator.Debug.Message( 'Atr_Duration_Initialize', self )

  Atr_Dropdown_AddPick (self, AUCTION_DURATION_ONE, 1, Atr_Duration_OnClick);
  Atr_Dropdown_AddPick (self, AUCTION_DURATION_TWO, 2, Atr_Duration_OnClick);
  Atr_Dropdown_AddPick (self, AUCTION_DURATION_THREE, 3, Atr_Duration_OnClick);

end

-----------------------------------------

function Atr_Duration_OnClick(self)
  Auctionator.Debug.Message( 'Atr_Duration_OnClick', self )

  UIDropDownMenu_SetSelectedValue (self.owner, self.value);
  Atr_SetDepositText();
end


----------------------------------------------------------------------------------
--------------------------   Dropdown Menu Functions  ----------------------------
----------------------------------------------------------------------------------

local _atr_info = {};   -- table reuse
-----------------------------------------

function Atr_Dropdown_AddPick (frame, text, value, func)
  Auctionator.Debug.Message( 'Atr_Dropdown_AddPick', frame, text, value, func )

  _atr_info.owner     = frame;
  _atr_info.text      = text;
  _atr_info.value     = value;
  _atr_info.checked   = nil;

  if (func) then
    _atr_info.func = func;
  else
    _atr_info.func = Atr_Dropdown_OnClick;
  end

  UIDropDownMenu_AddButton(_atr_info);
end

-----------------------------------------

function Atr_Dropdown_OnClick (info)
  Auctionator.Debug.Message( 'Atr_Dropdown_OnClick', info )

  UIDropDownMenu_SetSelectedValue (info.owner, info.value);
end

-----------------------------------------

function Atr_Dropdown_Refresh (frame)   -- useful for forcing the initialization function to be called again

  Auctionator.Debug.Message( 'Atr_Dropdown_Refresh', frame )

  frame:Hide();
  frame:Show();
end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


function Atr_IsTabSelected(whichTab)
  -- Auctionator.Debug.Message( 'Atr_IsTabSelected', whichTab )

  if (not AuctionFrame or not AuctionFrame:IsShown()) then
    return false;
  end

  if (not whichTab) then
    return (Atr_IsTabSelected(SELL_TAB) or Atr_IsTabSelected(MORE_TAB) or Atr_IsTabSelected(BUY_TAB));
  end

  return (PanelTemplates_GetSelectedTab (AuctionFrame) == Atr_FindTabIndex(whichTab));
end

-----------------------------------------

function Atr_IsAuctionatorTab (tabIndex)
  Auctionator.Debug.Message( 'Atr_IsAuctionatorTab', tabIndex )

  if (tabIndex == Atr_FindTabIndex(SELL_TAB) or tabIndex == Atr_FindTabIndex(MORE_TAB) or tabIndex == Atr_FindTabIndex(BUY_TAB) ) then

    return true;

  end

  return false;
end

-----------------------------------------

function Atr_Confirm_Yes()
  Auctionator.Debug.Message( 'Atr_Confirm_Yes' )

  if (Atr_Confirm_Proc_Yes) then
    Atr_Confirm_Proc_Yes();
    Atr_Confirm_Proc_Yes = nil;
  end

  Atr_Confirm_Frame:Hide();

end


-----------------------------------------

function Atr_Confirm_No()
  Auctionator.Debug.Message( 'Atr_Confirm_No' )

  Atr_Confirm_Frame:Hide();

end


-----------------------------------------

function Atr_AddHistoricalPrice (itemName, price, stacksize, itemLink, testwhen)
  Auctionator.Debug.Message( 'Atr_AddHistoricalPrice', itemName, price, stacksize, itemLink, testwhen )

  if (itemName == nil) then
    zz (" !!!!!!!!!!!!!!   itemName == nil");
    return;
  end

  if (not AUCTIONATOR_PRICING_HISTORY[itemName] ) then
    AUCTIONATOR_PRICING_HISTORY[itemName] = {};
  end

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })

  AUCTIONATOR_PRICING_HISTORY[itemName]["is"]  = item_link:IdString()

  local hist = tostring( zc.round( price ) ) .. ":" .. stacksize

  -- so multiple auctions close together don't generate too many entries
  local roundtime = floor (time() / 60) * 60;

  local tag = tostring(ToTightTime(roundtime));

  if (testwhen) then
    tag = tostring(ToTightTime(testwhen));
  end

  AUCTIONATOR_PRICING_HISTORY[itemName][tag] = hist;

  gCurrentPane.sortedHist = nil;

end

-----------------------------------------

function Atr_HasHistoricalData (itemName)
  Auctionator.Debug.Message( 'Atr_HasHistoricalData', itemName )

  if (AUCTIONATOR_PRICING_HISTORY[itemName] ) then
    return true;
  end

  return false;
end


-----------------------------------------

local function sortHistoryList (x, y)
  Auctionator.Debug.Message( 'sortHistoryList', x, y )

  return (x.name < y.name)

end

-----------------------------------------

function Atr_BuildGlobalHistoryList()
  Auctionator.Debug.Message( 'Atr_BuildGlobalHistoryList' )

  gHistoryItemList  = {};

  if (zc.tableIsEmpty (gActiveAuctions)) then
    Atr_BuildActiveAuctions()
  end

  local info, IDstring
  for IDstring, info in pairs (gActiveAuctions) do
    if (info.link and info.count ~= 0) then
      table.insert (gHistoryItemList, info)
    end
  end

  table.sort (gHistoryItemList, sortHistoryList);
end



-----------------------------------------

function Atr_FindHListIndexByLink (itemLink)
  Auctionator.Debug.Message( 'Atr_FindHListIndexByLink', itemLink )

  local x;

  for x = 1, #gHistoryItemList do
    if (itemLink == gHistoryItemList[x].link) then
      return x;
    end
  end

  return 0;

end

-----------------------------------------

local gAtr_CheckingActive_State     = ATR_CACT_NULL
local gAtr_CheckingActive_AndCancel   = false
local gAtr_CheckingActive_Index
local gAtr_CheckingActive_NextItemName
local gAtr_CheckingActive_NextItemLink

gAtr_CheckingActive_NumUndercuts  = 0;


-----------------------------------------

function Atr_CheckActive_OnClick (andCancel)
  Auctionator.Debug.Message( 'Atr_CheckActive_OnClick', andCancel )

  if (gAtr_CheckingActive_State == ATR_CACT_NULL) then

    Atr_CheckActiveList (andCancel);

  else    -- stop checking
    Atr_CheckingActive_Finish ();
    gCurrentPane.activeSearch:Abort();
    gCurrentPane:ClearSearch();
    Atr_SetMessage(ZT("Checking stopped"));
  end

end


-----------------------------------------

function Atr_CheckActiveList (andCancel)
  Auctionator.Debug.Message( 'Atr_CheckActiveList', andCancel )

  if (#gHistoryItemList == 0) then
    return
  end

  gAtr_CheckingActive_State     = ATR_CACT_READY;
  gAtr_CheckingActive_NextItemName  = gHistoryItemList[1].name;
  gAtr_CheckingActive_NextItemLink  = gHistoryItemList[1].link;
  gAtr_CheckingActive_AndCancel   = andCancel;
  gAtr_CheckingActive_NumUndercuts  = 0;

  Atr_SetToShowCurrent();

  Atr_CheckingActiveIdle ();

end

-----------------------------------------

function Atr_CheckingActive_Finish()
  Auctionator.Debug.Message( 'Atr_CheckingActive_Finish' )

  gAtr_CheckingActive_State = ATR_CACT_NULL;    -- done

  Atr_CheckActiveButton:SetText(ZT("Check for Undercuts"));

end



-----------------------------------------

function Atr_CheckingActiveIdle()
  -- Auctionator.Debug.Message( 'Atr_CheckingActiveIdle' )

  if (gAtr_CheckingActive_State == ATR_CACT_READY) then
    if (gAtr_CheckingActive_NextItemName == nil) then

      Atr_CheckingActive_Finish ();

      if (gAtr_CheckingActive_NumUndercuts > 0) then
        Atr_ResetMassCancel();
        Atr_CheckActives_Frame:Show();
      end

    else
      gAtr_CheckingActive_State = ATR_CACT_PROCESSING;

      Atr_CheckActiveButton:SetText(ZT("Stop Checking"))

      local itemName = gAtr_CheckingActive_NextItemName
      local itemLink = gAtr_CheckingActive_NextItemLink

      local x = Atr_FindHListIndexByLink (itemLink);

      gAtr_CheckingActive_NextItemName = nil
      gAtr_CheckingActive_NextItemLink = nil

      if ((x > 0 and #gHistoryItemList >= x+1)) then
        gAtr_CheckingActive_NextItemName = gHistoryItemList[x+1].name
        gAtr_CheckingActive_NextItemLink = gHistoryItemList[x+1].link
      end

      local item_link = Auctionator.ItemLink:new({ item_link = itemLink })

      -- don't use a rescanThreshold as events won't fire properly for different items with the same name
      gCurrentPane:DoSearch( itemName, item_link:IdString(), itemLink )

      Atr_Hilight_Hentry( itemLink )
    end
  end
end


-----------------------------------------

function Atr_CheckActive_IsBusy()
  Auctionator.Debug.Message( 'Atr_CheckActive_IsBusy' )

  return (gAtr_CheckingActive_State ~= ATR_CACT_NULL);

end

-----------------------------------------

function Atr_CheckingActive_OnSearchComplete()
  Auctionator.Debug.Message( 'Atr_CheckingActive_OnSearchComplete' )

  if (gAtr_CheckingActive_State == ATR_CACT_PROCESSING) then

    if (gAtr_CheckingActive_AndCancel) then
      zc.AddDeferredCall (0.1, "Atr_CheckingActive_CheckCancel");   -- need to defer so UI can update and show auctions about to be canceled
    else
      zc.AddDeferredCall (0.1, "Atr_CheckingActive_Next");      -- need to defer so UI can update
    end
  end
end

-----------------------------------------

function Atr_CheckingActive_CheckCancel()
  Auctionator.Debug.Message( 'Atr_CheckingActive_CheckCancel' )

  if (gAtr_CheckingActive_State == ATR_CACT_PROCESSING) then

    Atr_CancelUndercuts_CurrentScan(false);

    if (gAtr_CheckingActive_State ~= ATR_CACT_WAITING_ON_CANCEL_CONFIRM) then
      zc.AddDeferredCall (0.1, "Atr_CheckingActive_Next");    -- need to defer so UI can update
    end
  end

end

-----------------------------------------

function Atr_CheckingActive_Next ()
  Auctionator.Debug.Message( 'Atr_CheckingActive_Next' )

  if (gAtr_CheckingActive_State == ATR_CACT_PROCESSING) then
    gAtr_CheckingActive_State = ATR_CACT_READY;
  end
end


-----------------------------------------

function Atr_CancelUndercut_Confirm (yesCancel)
  Auctionator.Debug.Message( 'Atr_CancelUndercut_Confirm', yesCancel )

  gAtr_CheckingActive_State = ATR_CACT_PROCESSING;
  Atr_CancelAuction_Confirm_Frame:Hide();
  if (yesCancel) then
    Atr_CancelUndercuts_CurrentScan(true);
  end
  zc.AddDeferredCall (0.1, "Atr_CheckingActive_Next");
end

-----------------------------------------

function Atr_CancelUndercuts_CurrentScan(confirmed)
  Auctionator.Debug.Message( 'Atr_CancelUndercuts_CurrentScan', confirmed )

  local scan = gCurrentPane.activeScan;

  for x = #scan.sortedData,1,-1 do

    local data = scan.sortedData[x];

    if (data.yours and data.itemPrice > scan.absoluteBest.itemPrice) then

      if (not confirmed) then
        gAtr_CheckingActive_State = ATR_CACT_WAITING_ON_CANCEL_CONFIRM;
        Atr_CancelAuction_Confirm_Frame_text:SetText (string.format (ZT("Your auction has been undercut:\n%s%s"), "|cffffffff", scan.itemName));
        Atr_CancelAuction_Confirm_Frame:Show ();
        return;
      end

      Atr_CancelAuction_ByIndex (x);
    end
  end

end

-----------------------------------------

local gAtr_MassCancelList = {};

-----------------------------------------

function Atr_ResetMassCancel ()
  Auctionator.Debug.Message( 'Atr_ResetMassCancel' )

  gAtr_MassCancelList = {};

  local i;
  local num = Atr_GetNumAuctionItems ("owner");
  local x = 1;

  -- build the list of items to cancel

  for i = 1, num do
    local name, _, stackSize, _, _, _, _, _, _, buyoutPrice = GetAuctionItemInfo ("owner", i);

    if (name) then
      local itemLink = GetAuctionItemLink ("owner", i)

      local item_link = Auctionator.ItemLink:new({ item_link = itemLink })

      local scan = Atr_FindScan( item_link:IdString() )
      if (scan and scan.absoluteBest and scan.whenScanned ~= 0 and scan.yourBestPrice and scan.yourWorstPrice) then

        local absBestPrice = scan.absoluteBest.itemPrice;

        if (stackSize > 0) then
          local itemPrice = math.floor (buyoutPrice / stackSize);

          if (itemPrice > absBestPrice) then

            gAtr_MassCancelList[x] = {};
            gAtr_MassCancelList[x].index    = i;
            gAtr_MassCancelList[x].name     = name;
            gAtr_MassCancelList[x].link     = itemLink;
            gAtr_MassCancelList[x].buyout   = buyoutPrice;
            gAtr_MassCancelList[x].stackSize  = stackSize;
            gAtr_MassCancelList[x].itemPrice  = itemPrice;
            gAtr_MassCancelList[x].absBestPrice = absBestPrice;
            x = x + 1;

          end
        end
      end
    end
  end

  Atr_CheckActives_Text:SetText (string.format (ZT("%d of your auctions are not the lowest priced.\n\nWould you like to cancel them?"), #gAtr_MassCancelList));

  Atr_CheckActives_Yes_Button:Enable();
  Atr_CheckActives_Yes_Button:SetText (ZT("Start canceling"));
  Atr_CheckActives_No_Button:SetText (ZT("No, leave them"));
end

-----------------------------------------

function Atr_Cancel_Undercuts_OnClick ()
  Auctionator.Debug.Message( 'Atr_Cancel_Undercuts_OnClick' )

  if (#gAtr_MassCancelList == 0) then
    return;
  end

  local success = Atr_Cancel_One_Undercuts_OnClick ()

  if (not success) then
    Atr_ResetMassCancel();
  end

  Atr_CheckActives_Text:SetText (string.format (ZT("%d of your auctions are not the lowest priced.\n\nWould you like to cancel them?"), #gAtr_MassCancelList));

  if (#gAtr_MassCancelList == 0) then
    Atr_CheckActives_Yes_Button:Disable();
    PlaySound(SOUNDKIT.AUCTION_WINDOW_CLOSE);
  else
    Atr_CheckActives_Yes_Button:Enable();
  end

  Atr_CheckActives_Yes_Button:SetText (ZT("Keep going"));
  Atr_CheckActives_No_Button:SetText (ZT("Done"));

end

-----------------------------------------

function Atr_Cancel_One_Undercuts_OnClick ()
  Auctionator.Debug.Message( 'Atr_Cancel_One_Undercuts_OnClick' )

  local x = #gAtr_MassCancelList;

  local i       = gAtr_MassCancelList[x].index;
  local name      = gAtr_MassCancelList[x].name;
  local link      = gAtr_MassCancelList[x].link;
  local buyout    = gAtr_MassCancelList[x].buyout;
  local stackSize   = gAtr_MassCancelList[x].stackSize;
  local itemPrice   = gAtr_MassCancelList[x].itemPrice;
  local absBestPrice  = gAtr_MassCancelList[x].absBestPrice;

  if (not Atr_DoesAuctionMatch ("owner", i, name, buyout, stackSize)) then
    return false;
  end

  table.remove ( gAtr_MassCancelList);

  Atr_CancelAuction (i);

--  zc.md (" index:", i, "  ", name, " price:", itemPrice, "  best price:", absBestPrice);

  AuctionatorSubtractFromScan (link, stackSize, buyout);
  Atr_LogCancelAuction (1, link, stackSize);
  gJustPosted.ItemName = nil;

  Atr_DisplayHlist();

  return true;

end

-----------------------------------------

function Atr_Hilight_Hentry(itemLink)
  Auctionator.Debug.Message( 'Atr_Hilight_Hentry', itemLink )

  for line = 1,ITEM_HIST_NUM_LINES do

    dataOffset = line + FauxScrollFrame_GetOffset (Atr_Hlist_ScrollFrame);

    local lineEntry = _G["AuctionatorHEntry"..line];

    if (dataOffset <= #gHistoryItemList and gHistoryItemList[dataOffset]) then

      if (gHistoryItemList[dataOffset].link == itemLink) then
        lineEntry:SetButtonState ("PUSHED", true);
      else
        lineEntry:SetButtonState ("NORMAL", false);
      end
    end
  end
end

-----------------------------------------

function Atr_Item_Autocomplete(self)
  Auctionator.Debug.Message( 'Atr_Item_Autocomplete', self )

  local text = self:GetText();
  local textlen = strlen(text);
  local name;

  -- first search shopping lists

  local numLists = #AUCTIONATOR_SHOPPING_LISTS;
  local n;

  for n = 1,numLists do
    local slist = AUCTIONATOR_SHOPPING_LISTS[n];

    local numItems = #slist.items;

    if ( numItems > 0 ) then
      for i=1, numItems do
        name = slist.items[i];
        if ( name and text and (strfind(strupper(name), strupper(text), 1, 1) == 1) ) then
          self:SetText(name);
          if ( self:IsInIMECompositionMode() ) then
            self:HighlightText(textlen - strlen(arg1), -1);
          else
            self:HighlightText(textlen, -1);
          end
          return;
        end
      end
    end
  end

  -- next search posted DB

  numItems = #gHistoryItemList;

  if ( numItems > 0 ) then
    for i=1, numItems do
      name = gHistoryItemList[i].name;
      if ( name and text and (strfind(strupper(name), strupper(text), 1, 1) == 1) ) then
        self:SetText(name);
        if ( self:IsInIMECompositionMode() ) then
          self:HighlightText(textlen - strlen(arg1), -1);
        else
          self:HighlightText(textlen, -1);
        end
        return;
      end
    end
  end

  -- next search the scan db
--[[
  local info;
  for name, info in pairs(gAtr_ScanDB) do
    if ( name and text and (strfind(strupper(name), strupper(text), 1, 1) == 1) ) then
      self:SetText(name);
      if ( self:IsInIMECompositionMode() ) then
        self:HighlightText(textlen - strlen(arg1), -1);
      else
        self:HighlightText(textlen, -1);
      end
      return;
    end
  end
]]--

end

-----------------------------------------

function Atr_GetCurrentPane ()      -- so other modules can use gCurrentPane
  Auctionator.Debug.Message( 'Atr_GetCurrentPane' )

  return gCurrentPane;
end

-----------------------------------------

function Atr_SetUINeedsUpdate ()      -- so other modules can easily set
  Auctionator.Debug.Message( 'Atr_SetUINeedsUpdate' )

  gCurrentPane.UINeedsUpdate = true;
end


-----------------------------------------

function Atr_CalcUndercutPrice (price)
  Auctionator.Debug.Message( 'Atr_CalcUndercutPrice', price )

  if  (price > 5000000) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._5000000); end;
  if  (price > 1000000) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._1000000); end;
  if  (price >  200000) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._200000);  end;
  if  (price >   50000) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._50000); end;
  if  (price >   10000) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._10000); end;
  if  (price >    2000) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._2000);  end;
  if  (price >     500) then return roundPriceDown (price, AUCTIONATOR_SAVEDVARS._500);   end;
  if  (price >       0) then return math.floor (price - 1); end;

  return 0;
end

-----------------------------------------

function Atr_CalcStartPrice (buyoutPrice)
  Auctionator.Debug.Message( 'Atr_CalcStartPrice', buyoutPrice )

  local discount = 1.00 - (AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT / 100);

  local newStartPrice = math.floor(buyoutPrice * discount);

  if (AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT == 0) then    -- zero means zero
    newStartPrice = buyoutPrice;
  end

  return newStartPrice;

end

-----------------------------------------

function Atr_AbbrevItemName (itemName)
  Auctionator.Debug.Message( 'Atr_AbbrevItemName', itemName )

  return string.gsub (itemName, "Scroll of Enchant", "SoE");

end

-----------------------------------------

function Atr_IsMyToon (name)
  Auctionator.Debug.Message( 'Atr_IsMyToon', name )

  if (name and (AUCTIONATOR_TOONS[name] or AUCTIONATOR_TOONS[string.lower(name)])) then
    return true;
  end

  return false;
end

-----------------------------------------

function Atr_Error_Display (errmsg)
  Auctionator.Debug.Message( 'Atr_Error_Display', errmsg )

  if (errmsg) then
    Atr_Error_Text:SetText (errmsg);
    Atr_Error_Frame:Show ();
    return;
  end
end



-----------------------------------------
-- roundPriceDown - rounds a price down to the next lowest multiple of a.
--          - if the result is not at least a/2 lower, rounds down by a/2.
--
--  examples:   (128790, 500)  ->  128500
--        (128700, 500)  ->  128000
--        (128400, 500)  ->  128000
-----------------------------------------

function roundPriceDown (price, a)
  Auctionator.Debug.Message( 'roundPriceDown', price, a )

  if (a == 0) then
    return price;
  end

  local newprice = math.floor((price-1) / a) * a;

  if ((price - newprice) < a/2) then
    newprice = newprice - a;
  end

  if (newprice == price) then
    newprice = newprice - 1;
  end

  return newprice;

end

-----------------------------------------

function ToTightHour(t)
  Auctionator.Debug.Message( 'ToTightHour', t )

  return floor((t - gTimeTightZero)/3600);

end

-----------------------------------------

function FromTightHour(tt)
  Auctionator.Debug.Message( 'FromTightHour', tt )

  return (tt*3600) + gTimeTightZero;

end


-----------------------------------------

function ToTightTime(t)
  Auctionator.Debug.Message( 'ToTightTime', t )

  return floor((t - gTimeTightZero)/60);

end

-----------------------------------------

function FromTightTime(tt)
  Auctionator.Debug.Message( 'FromTightTime', tt )

  return (tt*60) + gTimeTightZero;

end

