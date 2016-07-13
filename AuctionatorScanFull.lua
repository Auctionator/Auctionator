
local addonName, addonTable = ...
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc
local zz = zc.md
local _

-----------------------------------------

ATR_FS_NULL         = 0
ATR_FS_STARTED        = 1
ATR_FS_SLOW_QUERY_SENT    = 2
ATR_FS_SLOW_QUERY_NEEDED  = 3
ATR_FS_ANALYZING      = 4
ATR_FS_UPDATING_DB      = 5
ATR_FS_CLEANING_UP      = 6

local BIGNUM = 999999999999;

gDefaultFullScanChunkSize = 50;

gAtr_FullScanState    = ATR_FS_NULL

local gFullScanPosition
local gCanQueryAll

local gFSNumNullItemNames
local gFSNumNullItemLinks
local gFSNumNullOwners

local gFullScanStart

local gSlowScanPage
local gSlowScanTotalPages

local gNumScanned
local gNumAdded
local gNumUpdated

local gDoSlowScan = false;
local gDeniedCounter

local gScanDetails = {}

local gLowPrices = {};
local gQualities = {};

local badItemCount = 0

local gGetAllTotalAuctions
local gGetAllNumBatchAuctions
local gGetAllSuccess

-----------------------------------------

function Atr_FullScanStart()

  local canStart = gCanQueryAll

  if (gDoSlowScan) then
    canStart = CanSendAuctionQuery();
  end

  if (canStart) then

    Atr_FullScanStatus:SetText (ZT("Waiting for auction data").."...");
    Atr_FullScanStartButton:Disable();
    Atr_FullScanDone:Disable();

    gFullScanPosition = nil

    gFullScanStart = time()

    gFSNumNullItemNames = 0
    gFSNumNullItemLinks = 0
    gFSNumNullOwners = 0

    SortAuctionClearSort ("list")

    gNumAdded   = 0
    gNumUpdated = 0
    gNumScanned = 0

    gGetAllSuccess = true

    gDeniedCounter = 0;

    if (gDoSlowScan) then
      gAtr_FullScanState = ATR_FS_SLOW_QUERY_NEEDED;
      gSlowScanPage = 0
    else
      gAtr_FullScanState = ATR_FS_STARTED;
      QueryAuctionItems( "", nil, nil, 0, 0, 0, false, false, nil )
    end

  end

end

-----------------------------------------

function Atr_FullScanFrameIdle()

  ---- ui stuff ----


  if (gAtr_FullScanState == ATR_FS_NULL) then

    gDoSlowScan = IsControlKeyDown()

    if (gDoSlowScan) then
      Atr_FullScanStartButton:SetText ("Slow scan")
      Atr_FullScanStartButton:Enable();
    else
      Atr_FullScanStartButton:SetText ("Start Scanning")
      if (gCanQueryAll) then
        Atr_FullScanStartButton:Enable();
      else
        Atr_FullScanStartButton:Disable();
      end
    end

    return false;
  end

  -- processing stuff --

  if (gAtr_FullScanState == ATR_FS_ANALYZING and not gDoSlowScan) then
    Atr_FullScanAnalyze()
  end

  local statusText;

  if (gAtr_FullScanState == ATR_FS_SLOW_QUERY_NEEDED and not CanSendAuctionQuery()) then
    gDeniedCounter = gDeniedCounter+1;
  end

  if (gAtr_FullScanState == ATR_FS_SLOW_QUERY_NEEDED and CanSendAuctionQuery()) then

    zz ("gDeniedCounter", gDeniedCounter);
    gDeniedCounter = 0;

    QueryAuctionItems( "", nil, nil, gSlowScanPage, 0, 0, false, false, nil )

    gAtr_FullScanState = ATR_FS_SLOW_QUERY_SENT
    if (gSlowScanTotalPages) then
      statusText = string.format ("Page %s of %s", gSlowScanPage, gSlowScanTotalPages)
    end
  end

  if (gAtr_FullScanState == ATR_FS_STARTED)   then  statusText = "Waiting for auction data"   end
  if (gAtr_FullScanState == ATR_FS_UPDATING_DB) then  statusText = "Updating database"      end
  if (gAtr_FullScanState == ATR_FS_CLEANING_UP) then  statusText = "Scan complete"        end
  if (gAtr_FullScanState == ATR_FS_ANALYZING )  then  statusText = "Analyzing data ["..gFullScanPosition.." out of "..gGetAllTotalAuctions.."]";        end





  if (gAtr_FullScanState == ATR_FS_CLEANING_UP) then

    if (Atr_GetNumAuctionItems("list") < 100) then
      PlaySound("AuctionWindowClose");
      Atr_PurgeObsoleteItems ();
      gAtr_FullScanState = ATR_FS_NULL;
    end
  end

  local btext = Atr_FullScanStatus:GetText ();
  if (btext and statusText) then
    Atr_FullScanStatus:SetText (string.format (statusText.." (%s)", Atr_FullScan_GetDurString()));
  end


  return true;
end


-----------------------------------------

function Atr_FullScanBeginAnalyzePhase()

  gAtr_FullScanState = ATR_FS_ANALYZING;

  local numBatchAuctions, totalAuctions, returnedTotalAuction = Atr_GetNumAuctionItems("list");

  gGetAllTotalAuctions  = returnedTotalAuction
  gGetAllNumBatchAuctions = numBatchAuctions

  if (totalAuctions ~= returnedTotalAuction) then
    gGetAllSuccess      = false
  end

  gFullScanPosition = 1


  if (not gDoSlowScan) then
    gLowPrices = {}
    gQualities = {}

    zz ("FULL SCAN:"..numBatchAuctions.." out of  "..totalAuctions)
    zz ("AUCTIONATOR_FS_CHUNK: ", AUCTIONATOR_FS_CHUNK)
  end

end

-----------------------------------------

function Atr_FullScanAnalyze()

  if gFullScanPosition == nil then
    zc.msg_anm ("|cffff3333Warning:|r Atr_FullScanAnalyze: gFullScanPosition is nil!");
  end

  local firstScanPosition = gFullScanPosition;
  local numBatchAuctions  = gGetAllNumBatchAuctions;

  if gDoSlowScan then
    local numBatchAuctions, totalAuctions = Atr_GetNumAuctionItems( "list" )

    firstScanPosition = 1
    gSlowScanTotalPages = ceil( totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE )

    if (numBatchAuctions == 0) then   -- slow scan done
      Atr_FullScanUpdateDB();
      return;
    end
  end

  local dataIsGood = true

  if numBatchAuctions > 0 then

    local chunk_size = gDefaultFullScanChunkSize
    if AUCTIONATOR_FS_CHUNK ~= nil then
      chunk_size = AUCTIONATOR_FS_CHUNK
    end

    for x = firstScanPosition, numBatchAuctions do

      local name, texture, count, quality, canUse, level, huh, minBid,
        minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName,
        owner, ownerFullName, saleStatus = GetAuctionItemInfo( "list", x )

      gNumScanned = gNumScanned + 1

      if name == nil then
        gFSNumNullItemNames = gFSNumNullItemNames + 1
      end

      if owner == nil then
        gFSNumNullOwners = gFSNumNullOwners + 1
      end

      if name == nil or name == "" then
        badItemCount = badItemCount + 1
        dataIsGood = false
        zz( "bad item scanned.  name: ", name, " count: ", count, "badItemCount: ", badItemCount )
      else
        -- TODO fix to prevent error from unknown quality returned from GetAuctionItemInfo, above
        -- Should constantize (1 means white)
        gQualities[ name ] = quality or 1

        if buyoutPrice ~= nil then

          local itemPrice = math.floor( buyoutPrice / count )

          if itemPrice > 0 then
            if not gLowPrices[name] then
              gLowPrices[ name ] = BIGNUM
            end

            gLowPrices[ name ] = math.min( gLowPrices[name], itemPrice )
          end
        end
      end

      -- analyze fast scan data in chunks so as not to cause client to timeout?
      if not gDoSlowScan and ( x % chunk_size ) == 0 and x < numBatchAuctions then
        gFullScanPosition = x + 1
        return
      end
    end
  end

  if gDoSlowScan then
    if dataIsGood then
      gSlowScanPage = gSlowScanPage + 1
    else
      zz( "*** bad scan data.  requerying page: ", gSlowScanPage )
    end

    gAtr_FullScanState = ATR_FS_SLOW_QUERY_NEEDED
  else
    -- if we get to here on a fast scan, we're done
    Atr_FullScanUpdateDB()
  end
end

-----------------------------------------

function Atr_FullScanUpdateDB()

  gAtr_FullScanState = ATR_FS_UPDATING_DB

  zz ("Updating DB")

  local numEachQual = {0, 0, 0, 0, 0, 0, 0, 0, 0};
  local totalItems = 0;
  local numRemoved = { 0, 0, 0, 0, 0, 0, 0, 0 };

  for name,newprice in pairs (gLowPrices) do

    if (newprice < BIGNUM) then

      local qx = gQualities[name] + 1;

      if (qx == nil or numEachQual[qx] == nil) then
        zz ("ERROR: numEachQual[qx] == nil,  qx: ", qx, " name: ", name, " totalItems: ", totalItems);
      end

      numEachQual[qx] = numEachQual[qx] + 1;
      totalItems    = totalItems + 1;

      if (type(AUCTIONATOR_SCAN_MINLEVEL) ~= "number") then
        AUCTIONATOR_SCAN_MINLEVEL = 1;
      end

      if ((qx < AUCTIONATOR_SCAN_MINLEVEL) and gAtr_ScanDB[name]) then
        numRemoved[qx] = numRemoved[qx] + 1;
        gAtr_ScanDB[name] = nil;
      end

      if (qx >= AUCTIONATOR_SCAN_MINLEVEL) then

        if (gAtr_ScanDB[name] == nil) then
          gNumAdded = gNumAdded + 1;
        else
          gNumUpdated = gNumUpdated + 1;
        end

        Atr_UpdateScanDBprice (name, newprice);
      end
    end
  end

  zz ("Cleaning up")

  gScanDetails.numBatchAuctions   = gNumScanned;
  gScanDetails.totalItems       = totalItems;
  gScanDetails.numEachQual      = numEachQual;
  gScanDetails.numRemoved       = numRemoved;
  gScanDetails.gNumAdded        = gNumAdded;
  gScanDetails.gNumUpdated      = gNumUpdated;

  gAtr_FullScanState = ATR_FS_CLEANING_UP;

  Atr_FullScanMoreDetails();

  Atr_FullScanDone:Enable();
  Atr_FullScanStatus:SetText ("");

  Atr_FSR_scanned_count:SetText (gNumScanned);
  Atr_FSR_added_count:SetText   (gNumAdded);
  Atr_FSR_updated_count:SetText (gNumUpdated);
  Atr_FSR_ignored_count:SetText (totalItems - (gNumAdded + gNumUpdated));

  Atr_FullScanHTML:Hide();
  Atr_FullScanResults:Show();

  Atr_FullScanResults:SetBackdropColor (0.3, 0.3, 0.4);

  if (not gDoSlowScan) then
    AUCTIONATOR_LAST_SCAN_TIME = time();
  end

  Atr_UpdateFullScanFrame ();

  Atr_Broadcast_DBupdated (totalItems, "fullscan");

  Atr_ClearBrowseListings();

  gLowPrices = {};

  collectgarbage ("collect");

end

-----------------------------------------

function Atr_ShowFullScanFrame()

  Atr_FullScanHTML:Show();
  Atr_FullScanResults:Hide();

  Atr_FullScanFrame:Show();
  Atr_FullScanFrame:SetBackdropColor(0,0,0,100);

  Atr_UpdateFullScanFrame();
  Atr_FullScanStatus:SetText ("");

  local expText = "<html><body>"
          .."<p>"
          ..ZT("SCAN_EXPLANATION")
          .."</p>"
          .."</body></html>"
          ;



  Atr_FullScanHTML:SetText (expText);
  Atr_FullScanHTML:SetSpacing (3);
end

-----------------------------------------

function Atr_UpdateFullScanFrame()

  Atr_FullScanDBsize:SetText (Atr_GetDBsize());

  if (AUCTIONATOR_LAST_SCAN_TIME) then
    Atr_FullScanDBwhen:SetText (date ("%A, %B %d at %I:%M %p", AUCTIONATOR_LAST_SCAN_TIME));
  else
    Atr_FullScanDBwhen:SetText (ZT("Never"));
  end

  local canQuery

  canQuery, gCanQueryAll = CanSendAuctionQuery();

  if (gCanQueryAll) then
    Atr_FullScanStatus:SetText ("");
    Atr_FullScanStartButton:Enable();
    Atr_FullScanNext:SetText(ZT("Now"));
  else
    Atr_FullScanStartButton:Disable();

    if (AUCTIONATOR_LAST_SCAN_TIME) then
      local when = 15*60 - (time() - AUCTIONATOR_LAST_SCAN_TIME);

      when = math.floor (when/60);

      if (when == 0) then
        Atr_FullScanNext:SetText (ZT("in less than a minute"));
      elseif (when == 1) then
        Atr_FullScanNext:SetText (ZT("in about one minute"));
      elseif (when > 0) then
        Atr_FullScanNext:SetText (string.format (ZT("in about %d minutes"), when));
      else
        Atr_FullScanNext:SetText (ZT("unknown"));
      end
    else
      Atr_FullScanNext:SetText (ZT("unknown"));
    end
  end
end

-----------------------------------------

function Atr_FullScan_GetDurString()

  local fullScanDur = time()- gFullScanStart;

  local minutes = math.floor (fullScanDur/60);
  local seconds = fullScanDur - (minutes * 60);

  return string.format ("%d:%02d", minutes, seconds);
end



-----------------------------------------

function GetIgnoredString (qx)

  if (qx < AUCTIONATOR_SCAN_MINLEVEL) then
    return " |cffeeeeee(ignored)|r"
  end

  return ""

end
-----------------------------------------

function Atr_FullScanMoreDetails ()

  zc.msg (" ");
  zc.msg_anm (ZT("Auctions scanned")..": |cffffffff", gScanDetails.numBatchAuctions, " |r("..gScanDetails.totalItems, "items) ", "time: ", Atr_FullScan_GetDurString());
  zc.msg_anm ("|cffa335ee   "..ZT("Epic items")..": |r",    gScanDetails.numEachQual[5]..GetIgnoredString(5));
  zc.msg_anm ("|cff0070dd   "..ZT("Rare items")..": |r",    gScanDetails.numEachQual[4]..GetIgnoredString(4));
  zc.msg_anm ("|cff1eff00   "..ZT("Uncommon items")..": |r",  gScanDetails.numEachQual[3]..GetIgnoredString(3));
  zc.msg_anm ("|cffffffff   "..ZT("Common items")..": |r",  gScanDetails.numEachQual[2]..GetIgnoredString(2));
  zc.msg_anm ("|cff9d9d9d   "..ZT("Poor items")..": |r",    gScanDetails.numEachQual[1]..GetIgnoredString(1));

  if (gScanDetails.numRemoved[4] > 0) then    zc.msg_anm (ZT("Rare items").." "..ZT("removed from database")..": |cffffffff",   gScanDetails.numRemoved[4]);    end
  if (gScanDetails.numRemoved[3] > 0) then    zc.msg_anm (ZT("Uncommon items").." "..ZT("removed from database")..": |cffffffff", gScanDetails.numRemoved[3]);    end
  if (gScanDetails.numRemoved[2] > 0) then    zc.msg_anm (ZT("Common items").." "..ZT("removed from database")..": |cffffffff", gScanDetails.numRemoved[2]);    end
  if (gScanDetails.numRemoved[1] > 0) then    zc.msg_anm (ZT("Poor items").." "..ZT("removed from database")..": |cffffffff",   gScanDetails.numRemoved[1]);    end

  zc.msg_anm (ZT("Items added to database")..": |cffffffff", gScanDetails.gNumAdded);
  zc.msg_anm (ZT("Items updated in database")..": |cffffffff", gScanDetails.gNumUpdated);

  if (gFSNumNullItemNames > 0) then
    zc.msg_anm (string.format ("|cffff3333%d auctions returned empty results (out of %d)|r", gFSNumNullItemNames, gScanDetails.numBatchAuctions));
  end

  if (gFSNumNullItemLinks > 0) then
    zc.msg_anm (string.format ("|cffff3333%d auctions returned null itemLinks (out of %d)|r", gFSNumNullItemLinks, gScanDetails.numBatchAuctions));
  end

  if (not gGetAllSuccess) then
    zc.msg (" ");
    zc.msg_anm ("|cffff3333Warning:|r Blizzard server failed to return all items: ", gGetAllTotalAuctions, gGetAllNumBatchAuctions);
    zc.msg_anm ("You might want to try slow scanning.");
  end

  zc.msg (" ");
end

