
function Auctionator.Events.VariablesLoaded()
  Auctionator.Debug.Message("Auctionator.Events.VariablesLoaded")

  Auctionator.State.CurrentVersion = GetAddOnMetadata("Auctionator", "Version")
  Auctionator.State.Loaded = true

  Auctionator.InitializeSlashCommands()
  Auctionator.Database.Initialize()
end

function Auctionator.InitializeSlashCommands()
  SlashCmdList["Auctionator"] = Atr_SlashCmdFunction
  SLASH_Auctionator1 = "/auctionator"
  SLASH_Auctionator2 = "/atr"

  -- TODO Finish setting up the slash commands in Atr_SlashCmdFunction
end



function Atr_OnLoad()
  Auctionator.Debug.Message( 'Atr_OnLoad' )

  -- AuctionatorVersion = GetAddOnMetadata("Auctionator", "Version");

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

  -- if ( IsAddOnLoaded("Blizzard_AuctionUI") ) then   -- need this for AH_QuickSearch since that mod forces Blizzard_AuctionUI to load at a startup
  --   Auctionator.Events.InitializeAddon();
  -- end

  Atr_ModTradeSkillFrame()
end

function Atr_SlashCmdFunction(msg)
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


