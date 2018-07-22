
local addonName, addonTable = ...
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc
local zz = zc.md
local _
local ItemUpgradeInfo = LibStub( 'LibItemUpgradeInfo-1.0' )


local gAllScans = {};

local BIGNUM = 999999999999;

gScanHistDayZero = time({year=2010, month=11, day=15, hour=0});   -- never ever change

local gNumNilItemLinks

-----------------------------------------

AtrScan = {};
AtrScan.__index = AtrScan;

-----------------------------------------

AtrSearch = {};
AtrSearch.__index = AtrSearch;

-----------------------------------------

function Atr_GetExactMatchText (searchText)

  local emtext = nil;

  if (zc.IsTextQuoted (searchText)) then
    emtext = string.sub (searchText, 2, searchText:len()-1);
  end

  return emtext;
end

-----------------------------------------

function Atr_NewSearch (itemName, IDstring, itemLink, rescanThreshold)

  local srch = {};
  setmetatable (srch, AtrSearch);
  srch:Init (itemName, IDstring, itemLink, rescanThreshold);

  return srch;
end

-----------------------------------------

function AtrSearch:Init (searchText, IDstring, itemLink, rescanThreshold)
  Auctionator.Debug.Message( 'AtrSearch:Init', searchText, IDstring, itemLink, rescanThreshold )

  if (searchText == nil) then
    searchText = ""
  end

  self.origSearchText = searchText

  self.exactMatchText = nil;
  self.searchText   = searchText

  if (IDstring == nil) then
    self.exactMatchText = Atr_GetExactMatchText(searchText)
    if (self.exactMatchText) then
      self.searchText = self.exactMatchText
    end
  end

  self.IDstring     = IDstring
  self.processing_state = Auctionator.Constants.SearchStates.NULL
  self.current_page   = -1
  self.items        = {}
  self.query        = Atr_NewQuery()
  self.sortedScans    = nil
  self.sortHow      = Auctionator.Constants.Sort.PRICE_ASCENDING
  self.shopListIndex    = 1
  self.shplist      = Atr_GetShoppingListFromSearchText (self.searchText)


  if Atr_IsCompoundSearch( self.searchText ) then
    _, _, _, _, self.minItemLevel, self.maxItemLevel = Atr_ParseCompoundSearch( self.searchText )
  end

  Auctionator.Util.Print( self, 'AtrSearch:Init' )

  if (IDstring) then

    if (rescanThreshold and rescanThreshold > 0) then
      local scan = Atr_FindScan (IDstring, searchText);
      if (scan and (time() - scan.whenScanned) <= rescanThreshold) then
        self.items[IDstring] = scan;
        self.items[IDstring]:UpdateItemLink (itemLink);
      end
    end

    if (not self.items[IDstring]) then
      self.items[IDstring] = Atr_FindScanAndInit (IDstring, searchText);
      self.items[IDstring]:UpdateItemLink (itemLink);
    end

  end


end

-----------------------------------------

function Atr_FindScanAndInit (IDstring, itemName)
  Auctionator.Debug.Message( 'Atr_FindScanAndInit', IDstring, itemName )

  return Atr_FindScan (IDstring, itemName, true);
end

-----------------------------------------

function Atr_FindScan (IDstring, itemName, init)
  Auctionator.Debug.Message( 'Atr_FindScan', IDstring, itemName, init )

  if (IDstring == nil or IDstring == "" or IDstring == "0") then
    IDstring = "0";
    itemName = "nil";
  end

  if (gAllScans[IDstring] == nil and itemName ~= nil) then  -- if no itemName provided then we can't create
    local scn = {};
    setmetatable (scn, AtrScan);
    gAllScans[IDstring] = scn;
    init = true;
  end

  if (init and gAllScans[IDstring] ~= nil) then
    gAllScans[IDstring]:Init (IDstring, itemName);
  end

  return gAllScans[IDstring];
end

-----------------------------------------

function Atr_ClearScanCache ()

  for a,v in pairs (gAllScans) do
    if (a ~= "0") then
      gAllScans[a] = nil;
    end
  end

end

-----------------------------------------

function AtrScan:Init (IDstring, itemName)

  self.IDstring     = IDstring;

  if (itemName) then
    self.itemName = itemName;
  end

  self.itemLink     = nil;
  self.scanData     = {};
  self.sortedData     = {};
  self.whenScanned    = 0;
  self.lowprice     = BIGNUM;
  self.absoluteBest   = nil;
  self.itemClass      = 0;
  self.itemSubclass   = 0;
  self.itemLevel      = 0;
  self.yourBestPrice    = nil;
  self.yourWorstPrice   = nil;
  self.itemTextColor    = { 1.0, 1.0, 1.0 };
  self.searchText     = nil;

end


-----------------------------------------

function AtrScan:UpdateItemLink (itemLink)
  Auctionator.Debug.Message( itemLink )

  if (itemLink and self.itemLink == nil) then

    self.itemLink = itemLink;

    local _, quality, iLevel, sType, sSubType;

    if (zc.IsBattlePetLink (itemLink)) then

      local speciesID, level, breedQuality = zc.ParseBattlePetLink (itemLink)

      iLevel  = level;
      quality = breedQuality;

      self.itemClass    = LE_ITEM_CLASS_BATTLEPET;
      self.itemSubclass = 0;

    else
      Auctionator.Util.Print( { GetItemInfo( itemLink ) }, 'GET ITEM INFO' .. itemLink )
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
      -- 11: big int
      -- 12: itemClass int
      -- 13: subClass int

      _, _, quality, _, _, sType, sSubType, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemLink);
      iLevel = ItemUpgradeInfo:GetUpgradedItemLevel( itemLink )

      self.itemClass    = itemClass
      self.itemSubclass = itemSubClass
    end

    self.itemQuality  = quality;
    self.itemLevel    = iLevel;

    self.itemTextColor = { 0.75, 0.75, 0.75 };

    if (quality == 0) then  self.itemTextColor = { 0.6, 0.6, 0.6 }; end
    if (quality == 1) then  self.itemTextColor = { 1.0, 1.0, 1.0 }; end
    if (quality == 2) then  self.itemTextColor = { 0.2, 1.0, 0.0 }; end
    if (quality == 3) then  self.itemTextColor = { 0.0, 0.5, 1.0 }; end
    if (quality == 4) then  self.itemTextColor = { 0.7, 0.3, 1.0 }; end
  end

end



-----------------------------------------

function AtrSearch:NumScans()

  if (self.sortedScans) then
    return #self.sortedScans;
  end

  local idstr,scn;
  local count = 0;
  for idstr,scn in pairs (self.items) do
    count = count + 1;
  end

  return count;
end

-----------------------------------------

function AtrSearch:NumSortedScans()

  if (self.sortedScans) then
    return #self.sortedScans;
  end

  return 0;
end

-----------------------------------------

function AtrSearch:GetFirstScan()

  if (self.sortedScans) then
    return self.sortedScans[1];
  end

  local idstr,scn;
  for idstr,scn in pairs (self.items) do
    return scn;
  end

  return nil
end


-----------------------------------------

function AtrSearch:Start ()
  Auctionator.Debug.Message( 'AtrSearch:Start' )
  Auctionator.Util.Print( self, 'AtrSearch:Start' )

  if self.searchText == "" then
    return
  end

  if Atr_IsCompoundSearch( self.searchText ) then
    self.sortHow = Auctionator.Constants.Sort.PRICE_DESCENDING
  end

  -- make sure all the matches in the scan db are in memory

  local numpulled = 0;

  if (self.exactMatchtext == nil and not self.IDstring and not Atr_IsCompoundSearch (self.searchText) and string.len(self.searchText) > 2) then
    local name, info, itemLink;
    for name, info in pairs(gAtr_ScanDB) do
      if (zc.StringContains (name, self.searchText)) then
        if (type(info) == "table" and info.id) then
          local itemID, suffixID = strsplit(":", info.id);
          if (suffixID == nil) then   -- for now; seems problematic for many green "of the" items
            itemLink = zc.PullItemIntoMemory (itemID, suffixID);
            numpulled = numpulled + 1;
          end
        end
      end
    end
  end

  -- make sure all the items in the shopping list are in memory

  if (self.shplist) then
    local n
    for n = 1,self.shplist:GetNumItems() do
      local itemname = zc.TrimQuotes(self.shplist:GetNthItemName (n))
      local dbInfo = gAtr_ScanDB[itemname]
      if (dbInfo and dbInfo.id) then
        zc.PullItemIntoMemory (dbInfo.id);
        numpulled = numpulled + 1;
      end
    end
  end

  gNumNilItemLinks = 0

  self.processing_state = Auctionator.Constants.SearchStates.SETTING_SORT;

  if (Atr_ILevelHist_Init) then
    Atr_ILevelHist_Init()
  end

  SortAuctionClearSort ("list");

  -- not necessary but nice when user switches to Browse tab
  local displayText = Atr_ParseCompoundSearch( self.searchText )
  BrowseName:SetText( displayText )

  self.current_page   = 0;
  self.processing_state = Auctionator.Constants.SearchStates.PRE_QUERY;

  self:Continue();

end

-----------------------------------------

function AtrSearch:Abort ()

  if (self.processing_state == Auctionator.Constants.SearchStates.NULL) then
    return;
  end

  self.processing_state = Auctionator.Constants.SearchStates.NULL;
  self:Init();
end



-----------------------------------------

function AtrSearch:CapturePageInfo ()

  self.query:CapturePageInfo(self.current_page)
end

-----------------------------------------

function AtrSearch:CheckForDuplicatePage ()

  local isDup = self.query:CheckForDuplicatePage(self.current_page);

  if (isDup) then
    self.current_page   = self.current_page - 1;   -- requery the page
    self.processing_state = Auctionator.Constants.SearchStates.PRE_QUERY;
  end

  return isDup;
end


-----------------------------------------

function AtrSearch:ShouldAnalyze()
  -- hopefully this will never happen but need check to avoid looping
  if self.query.numDupPages > 50 then
    return false
  end

  -- give Blizz servers a break (200 pages)
  if self.current_page == 1 and self.query.totalAuctions > 10000 then
    Atr_Error_Display( ZT( "Too many results\n\nPlease narrow your search" ))
    return false
  end

  return true
end

function AtrSearch:SetScanningMessage()
  local shoppingListItemName = Atr_GetShoppingListItem( self )
  local message = nil

  if shoppingListItemName then
    local pageText = ""

    if self.current_page > 1 then
      pageText = string.format( ZT( ": page %d" ), self.current_page)
    else
      pageText = "             "
    end

    message = string.format( ZT( "Scanning auctions for %s%s"), shoppingListItemName, pageText )
  elseif self.query.totalAuctions >= 50 then
    message = string.format(
      ZT( "Scanning auctions: page %d of %d"), self.current_page,
        ceil( self.query.totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE
      )
    )
  end

  if message then
    Atr_SetMessage( message )
  end
end

function AtrSearch:AnalyzeResultsPage()
  Auctionator.Debug.Message( 'AnalyzeResultsPage:', self.query.totalAuctions )

  self.processing_state = Auctionator.Constants.SearchStates.ANALYZING;

  if not self:ShouldAnalyze() then
    return true
  end

  self:SetScanningMessage()

  -- analyze

  local numNilOwners = 0

  if self.query.curPageInfo.numOnPage > 0 then

    for x = 1, self.query.curPageInfo.numOnPage do
      local item = self.query.curPageInfo.auctionInfo[ x ]

      if item.itemLink then
        local item_link = Auctionator.ItemLink:new({ item_link = item.itemLink })

        if Atr_ILevelHist_Update then
          Atr_ILevelHist_Update( item.itemLink )
        end

        if zc.IsBattlePetLink( item.itemLink ) then
          Auctionator.Debug.Message( 'AtrSearch:AnalyzeResultsPage isBattlePet ', item_link:IdString() )
          Auctionator.Util.Print( item_link, 'Battle Pet Item Link')
          ATR_AddToBattlePetIconCache( item.itemLink, item.texture )
        end

        local OKitemLevel = true

        if self.minItemLevel or self.maxItemLevel then
          local iLevel = ItemUpgradeInfo:GetUpgradedItemLevel( item.itemLink )

          OKitemLevel = not (
            ( self.minItemLevel and iLevel < self.minItemLevel ) or
            ( self.maxItemLevel and iLevel > self.maxItemLevel )
          )
        end

        if OKitemLevel and owner == nil then
          numNilOwners = numNilOwners + 1
        end

        if OKitemLevel and ( self.exactMatchText == nil or zc.StringSame( item.name, self.exactMatchText )) then

          if self.items[ item_link:IdString() ] == nil then
            self.items[ item_link:IdString() ] = Atr_FindScanAndInit( item_link:IdString(), item.name )
          end

          local scn = self.items[ item_link:IdString() ]

          if scn then
            local curpage = tonumber( self.current_page ) - 1

            scn:AddScanItem( item.count, item.buyoutPrice, item.owner, 1, curpage )
            scn:UpdateItemLink( item.itemLink )
          end
        end
      else
        gNumNilItemLinks = gNumNilItemLinks + 1
      end
    end
  end

  local done = self.query.curPageInfo.numOnPage < 50

  if done and self.shplist then
    self.shopListIndex = self.shopListIndex + 1
    local nextSearchItem = Atr_GetShoppingListItem( self )

    if nextSearchItem then
      self.current_page = 0
      self.exactMatchText = nil
      done = false
    end
  end

  -- scan only one page
  if self.current_page > 1 and AUCTIONATOR_ENABLE_QUICK_SCAN == 1 then
    done = true
  end

  if not done then
    self.processing_state = Auctionator.Constants.SearchStates.PRE_QUERY
  end

  return done
end

-----------------------------------------

function AtrScan:AddScanItem (stackSize, buyoutPrice, owner, numAuctions, curpage)

  local sd = {};
  local i;

  if (numAuctions == nil) then
    numAuctions = 1;
  end

  for i = 1, numAuctions do
    sd["stackSize"]   = stackSize;
    sd["buyoutPrice"] = buyoutPrice;
    sd["owner"]     = owner;
    sd["pagenum"]   = curpage;

    tinsert (self.scanData, sd);

    if (buyoutPrice and buyoutPrice > 0) then
      local itemPrice = math.floor (buyoutPrice / stackSize);

      self.lowprice = math.min (self.lowprice, itemPrice);
    end
  end

end


-----------------------------------------

function AtrScan:SubtractScanItem (stackSize, buyoutPrice)

  local sd;
  local i;

  for i,sd in ipairs (self.scanData) do

    if (sd.stackSize == stackSize and sd.buyoutPrice == buyoutPrice) then

      tremove (self.scanData, i);
      return;
    end
  end

end


-----------------------------------------

function Atr_IsShoppingListSearch (searchString)

  if (searchString == nil) then
    return false;
  end

  return zc.StringStartsWith (searchString, "{ ") and zc.StringEndsWith (searchString, " }");
end

-----------------------------------------

function Atr_GetShoppingListFromSearchText (searchString)

  if (Atr_IsShoppingListSearch (searchString)) then
    local len = string.len(searchString);

    local shoppingListName = string.sub (searchString, 3, len-2);

    return Atr_SList.FindByName (shoppingListName);
  end

  return nil
end

-----------------------------------------

function Atr_GetShoppingListItem (search)

  if (search.shplist) then
    return search.shplist:GetNthItemName (search.shopListIndex);
  end

  return nil;
end

-----------------------------------------

function Atr_IsCompoundSearch (searchString)
  Auctionator.Debug.Message( 'Atr_IsCompoundSearch', searchString )

  if (searchString == nil) then
    return false;
  end

  Auctionator.Debug.Message( 'Atr_IsCompoundSearch', zc.StringContains (searchString, ">") or zc.StringContains (searchString, Auctionator.Constants.AdvancedSearchDivider) )

  return zc.StringContains (searchString, ">") or zc.StringContains (searchString, Auctionator.Constants.AdvancedSearchDivider);
end

-----------------------------------------

local function toItemLevel (s)    -- returns nil if not of the form i72 or i277, etc

  if (string.len(s) > 1 and string.sub(s,1,1) == "i") then
    return tonumber (string.sub(s,2))
  end

  return nil
end

-----------------------------------------

function Atr_ParseCompoundSearch( searchString )
  local delimiter = Auctionator.Constants.AdvancedSearchDivider

  if zc.StringContains( searchString, ">" ) then
    delimiter = ">"
  end

  local queryString, filterKey, minLevel, maxLevel, minItemLevel, maxItemLevel =
    strsplit( delimiter, searchString )

  local filter = Auctionator.FilterLookup[ filterKey ]

  -- TODO: Make this into an object when this works (sort of is as query, but needs a lot of work
  -- to incorporate everywhere)
  minLevel = tonumber( minLevel )
  maxLevel = tonumber( maxLevel )
  minItemLevel = tonumber( minItemLevel )
  maxItemLevel = tonumber( maxItemLevel )

  if minLevel == 0 then
    minLevel = nil
  end

  if maxLevel == 0 then
    maxLevel = nil
  end

  if minItemLevel == 0 then
    minItemLevel = nil
  end

  if maxItemLevel == 0 then
    maxItemLevel = nil
  end

  return queryString, filter, minLevel, maxLevel, minItemLevel, maxItemLevel
end

-----------------------------------------

function AtrSearch:Continue()
  local canQuery = CanSendAuctionQuery()

  Auctionator.Debug.Message( 'AtrSearch:Continue', canQuery )


  if canQuery then

    self.processing_state = KM_IN_QUERY;

    local queryString;

    local filterData = nil
    local minLevel    = nil;
    local maxLevel    = nil;

    if (Atr_IsCompoundSearch(self.searchText)) then
      queryString, filterData, minLevel, maxLevel = Atr_ParseCompoundSearch (self.searchText);

    elseif (self.shplist) then
      queryString = Atr_GetShoppingListItem (self)

      self.exactMatchText = Atr_GetExactMatchText(queryString)
      if (self.exactMatchText) then
        queryString = self.exactMatchText
      end

      -- skip nested shopping lists or compound searches
      while (Atr_IsShoppingListSearch(queryString) or Atr_IsCompoundSearch(queryString)) do
        zc.md ("Skipping ", queryString);
        self.shopListIndex = self.shopListIndex + 1
        queryString = Atr_GetShoppingListItem (self)
        if (queryString == nil) then
          break
        end
      end

      if (queryString == nil) then
        queryString = "?????";
      end
    else
      queryString = self.searchText;
    end

    local exactMatch = (self.exactMatchText ~= nil or self.IDstring ~= nil)

    local filter = nil
    if filterData ~= nil then
      filter = filterData.filter
    end

    queryString = Auctionator.Util.UTF8_Truncate( queryString ) -- attempting to reduce number of disconnects

    Auctionator.Util.Print( filter )

    Auctionator.Util.Print(
      { queryString, minLevel, maxLevel, self.current_page, nil, nil, false, exactMatch, filter },
      'QUERY AUCTION ITEMS PARAMS'
    )

    -- sort search result by buyout (total, so just the cheapest stacks of 1 item will be used to determine price)
    SortAuctionClearSort("list")
    SortAuctionSetSort("list", "buyout")
    SortAuctionApplySort("list")

    QueryAuctionItems (queryString, minLevel, maxLevel, self.current_page, nil, nil, false, exactMatch, filter )

    self.query_sent_when  = gAtr_ptime;
    self.processing_state = Auctionator.Constants.SearchStates.POST_QUERY;

    self.current_page   = self.current_page + 1;
  end

end

-----------------------------------------

local gSortScansBy;

-----------------------------------------

local function Atr_SortScans (x, y)

  if (gSortScansBy == Auctionator.Constants.Sort.NAME_ASCENDING) then   return string.lower (x.itemName) < string.lower (y.itemName); end
  if (gSortScansBy == Auctionator.Constants.Sort.NAME_DESCENDING) then   return string.lower (x.itemName) > string.lower (y.itemName); end

  local xprice = 0;
  local yprice = 0;

  if (x.absoluteBest) then  xprice = zc.round(x.absoluteBest.buyoutPrice/x.absoluteBest.stackSize);   end;
  if (y.absoluteBest) then  yprice = zc.round(y.absoluteBest.buyoutPrice/y.absoluteBest.stackSize);   end;

  if (gSortScansBy == Auctionator.Constants.Sort.PRICE_ASCENDING) then    return xprice < yprice;   end
  if (gSortScansBy == Auctionator.Constants.Sort.PRICE_DESCENDING) then    return xprice > yprice;   end

end

-----------------------------------------

function AtrSearch:Finish()

  local finishTime = time();

  self.processing_state = Auctionator.Constants.SearchStates.NULL;
  self.current_page   = -1;
  self.query_sent_when  = nil;

  -- add scans for items that weren't found (at least for items that are in the scan db)

  if (self.exactMatchText == nil and not self.IDstring) then
    if (not Atr_IsCompoundSearch (self.searchText)) then
      local name, info;
      for name, info in pairs(gAtr_ScanDB) do
        if (zc.StringContains (name, self.searchText)) then
          if (info.id and self.items[info.id] == nil) then
            local itemID, suffixID = strsplit(":", info.id);
            if (suffixID == nil) then   -- for now; seems problematic for many green "of the" items
              self.items[info.id] = Atr_FindScanAndInit (info.id, name);
              local itemLink = zc.LinkFromItemID (itemID, suffixID);
              if (itemLink) then
                self.items[info.id]:UpdateItemLink (itemLink)
              end
            end
          end
        end
      end
    end
  end

  -- add scans for items in the shopping list that weren't found

  if (self.shplist) then
    local n
    for n = 1,self.shplist:GetNumItems() do
      local itemname = zc.TrimQuotes(self.shplist:GetNthItemName (n))

      local dbInfo = gAtr_ScanDB[itemname]
      if (dbInfo and dbInfo.id) then
        local IDstring = dbInfo.id
        if (self.items[IDstring] == nil) then
          self.items[IDstring] = Atr_FindScanAndInit (IDstring, itemname)
          local itemLink = zc.LinkFromItemID (IDstring);
          if (itemLink) then
            self.items[IDstring]:UpdateItemLink (itemLink)
          end
        end
      else    -- not in scandb
        local IDstring = "***"..itemname
        self.items[IDstring] = Atr_FindScanAndInit (IDstring, itemname)
      end
    end
  end

  -- create an empty scan if there were no matches

  self.sortedScans = nil;

  if (self:NumScans() == 0) then

    local dbInfo = gAtr_ScanDB[self.searchText]

    if (dbInfo and dbInfo.id) then  -- so that we see the history tab, etc.
      local IDstring = dbInfo.id;
      self.items[IDstring] = Atr_FindScan (IDstring, self.searchText, true);
    else
      self.items["0"] = Atr_FindScan (nil);
    end

  end

  -- process the scans

  local broadcastInfo = {};

  local x = 1;
  self.sortedScans = {};

  for IDstring,scn in pairs (self.items) do

    self.sortedScans[x] = scn;
    x = x + 1;

    scn.whenScanned   = finishTime;
    scn.searchText    = self.searchText;

    scn:CondenseAndSort ();

    -- update the fullscan DB

    if (scn.lowprice < BIGNUM) then

      if scn.itemQuality == nil then
        Auctionator.Debug.Message( 'Error: scn.itemQuality == nil, scn.itemName: ' .. scn.itemName )
      end

      if (scn.itemQuality ~= nil and (scn.itemQuality + 1 >= AUCTIONATOR_SCAN_MINLEVEL or scn.quality == -1)) then    --  battle pets can be UNKNOWN (-1) quality

        Atr_UpdateScanDBprice   (scn.itemName, scn.lowprice);
        Atr_UpdateScanDBclassInfo (scn.itemName, scn.itemClass, scn.itemSubclass);
        Atr_UpdateScanDBitemID    (scn.itemName, scn.itemLink);

        table.insert (broadcastInfo, {i=scn.IDstring, p=scn.lowprice});
      end
    end
  end

  if (gNumNilItemLinks > 0) then
    zc.msg_anm ("Number of nil links found during scan: ", gNumNilItemLinks)
  end

  Atr_Broadcast_DBupdated (#broadcastInfo, "partialscan", broadcastInfo);

  if (Atr_ILevelHist_Print) then
    Atr_ILevelHist_Print()
  end


  gSortScansBy = self.sortHow;
  table.sort (self.sortedScans, Atr_SortScans);
end

-----------------------------------------

function AtrSearch:ClickPriceCol()

  if (self.sortHow == Auctionator.Constants.Sort.PRICE_ASCENDING) then
    self.sortHow = Auctionator.Constants.Sort.PRICE_DESCENDING;
  else
    self.sortHow = Auctionator.Constants.Sort.PRICE_ASCENDING;
  end

  gSortScansBy = self.sortHow;
  table.sort (self.sortedScans, Atr_SortScans);

end

-----------------------------------------

function AtrSearch:ClickNameCol()

  if (self.sortHow == Auctionator.Constants.Sort.NAME_ASCENDING) then
    self.sortHow = Auctionator.Constants.Sort.NAME_DESCENDING;
  else
    self.sortHow = Auctionator.Constants.Sort.NAME_ASCENDING;
  end

  gSortScansBy = self.sortHow;
  table.sort (self.sortedScans, Atr_SortScans);
end

-----------------------------------------

function AtrSearch:UpdateArrows()

  Atr_Col1_Heading_ButtonArrow:Hide();
  Atr_Col3_Heading_ButtonArrow:Hide();

  if (self.sortHow == Auctionator.Constants.Sort.PRICE_ASCENDING) then
    Atr_Col1_Heading_ButtonArrow:Show();
    Atr_Col1_Heading_ButtonArrow:SetTexCoord(0, 0.5625, 0, 1.0);
  elseif (self.sortHow == Auctionator.Constants.Sort.PRICE_DESCENDING) then
    Atr_Col1_Heading_ButtonArrow:Show();
    Atr_Col1_Heading_ButtonArrow:SetTexCoord(0, 0.5625, 1.0, 0);
  elseif (self.sortHow == Auctionator.Constants.Sort.NAME_ASCENDING) then
    Atr_Col3_Heading_ButtonArrow:Show();
    Atr_Col3_Heading_ButtonArrow:SetTexCoord(0, 0.5625, 0, 1.0);
  elseif (self.sortHow == Auctionator.Constants.Sort.NAME_DESCENDING) then
    Atr_Col3_Heading_ButtonArrow:Show();
    Atr_Col3_Heading_ButtonArrow:SetTexCoord(0, 0.5625, 1.0, 0);
  end
end

-----------------------------------------

function Atr_ClearBrowseListings()


  if (CanSendAuctionQuery()) then
    QueryAuctionItems("xyzzy", 43, 43, 0, 7, 0);
    zz ("Atr_ClearBrowseListings succeeded");
  end


end

-----------------------------------------

function Atr_SortAuctionData (x, y)

  return x.itemPrice < y.itemPrice;

end

-----------------------------------------

function AtrScan:CondenseAndSort ()

  ----- Condense the scan data into a table that has only a single entry per stacksize/price combo

  self.sortedData = {};

  local i,sd;
  local conddata = {};

  for i,sd in ipairs (self.scanData) do

    local ownerCode = "x";
    local dataType  = "n";    -- normal

    if (sd.owner == UnitName("player")) then
      ownerCode = "y";
--    elseif (Atr_IsMyToon (sd.owner)) then
--      ownerCode = sd.owner;
    end

    local key = "_"..sd.stackSize.."_"..sd.buyoutPrice.."_"..ownerCode..dataType;

    if (conddata[key]) then
      conddata[key].count   = conddata[key].count + 1;
    else
      local data = {};

      data.stackSize    = sd.stackSize;
      data.buyoutPrice  = sd.buyoutPrice;
      data.itemPrice    = sd.buyoutPrice / sd.stackSize;
      data.count      = 1;
      data.type     = dataType;
      data.yours      = (ownerCode == "y");

      if (ownerCode ~= "x" and ownerCode ~= "y") then
        data.altname = ownerCode;
      end

      if (sd.volume) then
        data.volume = sd.volume;
      end

      conddata[key] = data;
    end

  end

  ----- create a table of these entries

  local n = 1;

  local i, v;

  for i,v in pairs (conddata) do
    self.sortedData[n] = v;
    n = n + 1;
  end

  -- sort the table by itemPrice

  table.sort (self.sortedData, Atr_SortAuctionData);

  -- analyze and store some info about the data

  self:AnalyzeSortData ();

end

-----------------------------------------

function AtrScan:AnalyzeSortData ()

  self.absoluteBest     = nil;
  self.bestPrices       = {};   -- a table with one entry per stacksize that is the cheapest auction for that particular stacksize
  self.numMatches       = 0;
  self.numMatchesWithBuyout = 0;
  self.hasStack       = false;
  self.yourBestPrice      = nil;
  self.yourWorstPrice     = nil;

  local j, sd;

  ----- find the best price per stacksize and overall -----

  for j,sd in ipairs(self.sortedData) do

    if (sd.type == "n") then

      self.numMatches = self.numMatches + 1;

      if (sd.itemPrice > 0) then

        self.numMatchesWithBuyout = self.numMatchesWithBuyout + 1;

        if (self.bestPrices[sd.stackSize] == nil or self.bestPrices[sd.stackSize].itemPrice >= sd.itemPrice) then
          self.bestPrices[sd.stackSize] = sd;
        end

        if (self.absoluteBest == nil or self.absoluteBest.itemPrice > sd.itemPrice) then
          self.absoluteBest = sd;
        end

        if (sd.yours) then
          if (self.yourBestPrice == nil or self.yourBestPrice > sd.itemPrice) then
            self.yourBestPrice = sd.itemPrice;
          end

          if (self.yourWorstPrice == nil or self.yourWorstPrice < sd.itemPrice) then
            self.yourWorstPrice = sd.itemPrice;
          end

        end
      end

      if (sd.stackSize > 1) then
        self.hasStack = true;
      end
    end
  end
end

-----------------------------------------

function AtrScan:FindInSortedData (stackSize, buyoutPrice)
  local j = 1;
  for j = 1,#self.sortedData do
    sd = self.sortedData[j];
    if (sd.stackSize == stackSize and sd.buyoutPrice == buyoutPrice and sd.yours) then
      return j;
    end
  end

  return 0;
end


-----------------------------------------

function AtrScan:FindMatchByStackSize (stackSize)

  local index = nil;

  local basedata = self.absoluteBest;

  if (self.bestPrices[stackSize]) then
    basedata = self.bestPrices[stackSize];
  end

  local numrows = #self.sortedData;

  local n;

  for n = 1,numrows do

    local data = self.sortedData[n];

    if (basedata and data.itemPrice == basedata.itemPrice and data.stackSize == basedata.stackSize and data.yours == basedata.yours) then
      index = n;
      break;
    end
  end

  return index;

end

-----------------------------------------

function AtrScan:FindMatchByYours ()

  local index = nil;

  local j;
  for j = 1,#self.sortedData do
    sd = self.sortedData[j];
    if (sd.yours) then
      index = j;
      break;
    end
  end

  return index;

end

-----------------------------------------

function AtrScan:FindCheapest ()

  local index = nil;

  local j;
  for j = 1,#self.sortedData do
    sd = self.sortedData[j];
    if (sd.itemPrice > 0) then
      index = j;
      break;
    end
  end

  return index;

end


-----------------------------------------

function AtrScan:GetNumAvailable ()

  local num = 0;

  local j, data;
  for j = 1,#self.sortedData do

    data = self.sortedData[j];
    num = num + (data.count * data.stackSize);
  end

  return num;
end

-----------------------------------------

function AtrScan:IsNil ()

  if (self.itemName == nil or self.itemName == "" or self.itemName == "nil") then
    return true;
  end

  return false;
end


-----------------------------------------

function Atr_GetDBsize()

  local n = 0;
  local a,v;

  for a,v in pairs (gAtr_ScanDB) do
    n = n + 1;
  end

  return n;
end


-----------------------------------------

function Atr_UpdateScanDBitemID (itemName, itemLink)

  if (itemLink == nil) then
    return;
  end

  if (not gAtr_ScanDB[itemName]) then
    gAtr_ScanDB[itemName] = {};
  end

  local item_link = Auctionator.ItemLink:new({ item_link = itemLink })
  gAtr_ScanDB[itemName].id = item_link:IdString()
end

-----------------------------------------

function Atr_UpdateScanDBclassInfo (itemName, class, subclass)

  if (not gAtr_ScanDB[itemName]) then
    gAtr_ScanDB[itemName] = {};
  end

  gAtr_ScanDB[itemName].cc = class;
  gAtr_ScanDB[itemName].sc = subclass;

--  zc.md ("Setting class info for:", itemName, "    ", class, subclass);

end

-----------------------------------------

function Atr_UpdateScanDBprice (itemName, currentLowPrice, db)

  if (currentLowPrice == nil) then
    zc.msg_badErr ("currentLowPrice in NIL!!!!!!", itemName)
--    zc.printstack()
    return
  end

  if (type(currentLowPrice) ~= "number") then
    zc.msg_badErr ("currentLowPrice in not a number !!!!!!", type(currentLowPrice), itemName)
--    zc.printstack()
    return
  end

  if (db == nil) then
    db = gAtr_ScanDB;
  end

  if (db and type (db) ~= "table") then
    zc.msg_badErr ("Scanning history database appears to be corrupt")
    zc.msg_badErr ("db:", db)
    return nil
  end

  if (not db[itemName]) then
    db[itemName] = {};
  end

  db[itemName].mr = currentLowPrice;

  local daysSinceZero = Atr_GetScanDay_Today();

  local lowlow  = db[itemName]["L"..daysSinceZero];
  local highlow = db[itemName]["H"..daysSinceZero];

  local olow  = lowlow;
  local ohigh = highlow;

  if (highlow == nil or currentLowPrice > highlow) then
    db[itemName]["H"..daysSinceZero] = currentLowPrice;
    highlow = currentLowPrice;
  end

  -- save memory by only saving lowlow when different from highlow

  local isLowerThanLow    = (lowlow ~= nil and currentLowPrice < lowlow);
  local isNewAndDifferent   = (lowlow == nil and currentLowPrice < highlow);

  if (isLowerThanLow or isNewAndDifferent) then
    db[itemName]["L"..daysSinceZero] = currentLowPrice;
--    zz (itemName, "currentLowPrice:", currentLowPrice, "highlow:", highlow, "lowlow:", lowlow, "ohigh:", ohigh, "olow:", olow);
  end

  if (db[itemName]["po"]) then  -- unmark this item so it isn't purged
    db[itemName]["po"] = nil;
  end
end

-----------------------------------------

function Atr_PurgeObsoleteItems ()

  -- one time removal of old items - called after a full scan

  local a = 0
  local b = 0
  local potentials = 0;
  local doPurge, mostRecentDay, key, price, name, itemInfo

  local todayDay  = Atr_GetScanDay_Today()

  for name, itemInfo in pairs (gAtr_ScanDB) do

    doPurge = false;

    if (type(itemInfo) == "table") then

      mostRecentDay = -1

      for key, price in pairs (itemInfo) do
        char1 = string.sub (key, 1, 1)
        if (char1 == "H") then
          day = tonumber (string.sub(key, 2))
          mostRecentDay = math.max (day, mostRecentDay)
        end
      end

      if (itemInfo["po"]) then
        potentials = potentials + 1;
      end

      if (itemInfo["po"] and todayDay - mostRecentDay > 10) then
        doPurge = true;
      end
    end

    if (doPurge) then
      gAtr_ScanDB[name] = nil
      a = a + 1
    end

    b = b + 1
  end

--  zz ("potentials:", potentials);
--  zz ("purged:", a, "out of", b)
end

-----------------------------------------

function Atr_PrunePostDB()

  -- remove old items from the posting history database

  if (AUCTIONATOR_PRICING_HISTORY == nil) then
    return;
  end

  local now = time();
  local x = 0;
  local total = 0;

  local tempDB = {};
  zc.CopyDeep (tempDB, AUCTIONATOR_PRICING_HISTORY);

  for itemName, info in pairs(tempDB) do

    local recentWhen = 0;
    local tag, hist;

    for tag, hist in pairs (info) do
      if (tag ~= "is") then
        local when, type, price = ParseHist (tag, hist);

        if (when > recentWhen) then
          recentWhen  = when;
        end
      end
    end

    if (now - recentWhen > 180 * 86400) then
      AUCTIONATOR_PRICING_HISTORY[itemName] = nil;
      --zc.md (itemName, "   ", date("%A, %B %d %Y", recentWhen));
      x = x + 1;
    end

    total = total + 1;
  end

  collectgarbage  ("collect");

  if (x > 0) then
    zc.md (x, "of", total, "items pruned from post DB");
  end
end

-----------------------------------------

function Atr_MigtrateMaxHistAge()   -- 21 was too much

  if (AUCTIONATOR_DB_MAXHIST_AGE and AUCTIONATOR_DB_MAXHIST_AGE ~= 21 and AUCTIONATOR_DB_MAXHIST_AGE ~= -1) then
    zz ("AUCTIONATOR_DB_MAXHIST_AGE:", AUCTIONATOR_DB_MAXHIST_AGE, "AUCTIONATOR_DB_MAXHIST_DAYS:", AUCTIONATOR_DB_MAXHIST_DAYS)
    AUCTIONATOR_DB_MAXHIST_DAYS = AUCTIONATOR_DB_MAXHIST_AGE;
  end

  AUCTIONATOR_DB_MAXHIST_AGE = -1;
end

-----------------------------------------

function Atr_PruneScanDB(verbose)

  local start = time();

  collectgarbage  ("collect");

  local startMem = Atr_GetAuctionatorMemString();

  local dbCopy = {};

  local todayDays = Atr_GetScanDay_Today();

  Atr_MigtrateMaxHistAge();

  local histCutoff  = todayDays - AUCTIONATOR_DB_MAXHIST_DAYS;
  local itemCutoff  = todayDays - AUCTIONATOR_DB_MAXITEM_AGE;

  local x = 0;
  local h = 0;
  local y = 0;
  local z = 0;

  local key, price, char1, day, doCopy;

  if (gAtr_ScanDB and type (gAtr_ScanDB) ~= "table") then
    zc.msg_badErr ("Scanning history database appears to be corrupt")
    zc.msg_badErr ("gAtr_ScanDB:", gAtr_ScanDB)
    return
  end

  for itemName, info in pairs (gAtr_ScanDB) do

    local mostRecentDay = -1;

    -- first pass over item

    for key, price in pairs (info) do
      char1 = string.sub (key, 1, 1);
      if (char1 == "H") then
        day = tonumber (string.sub(key, 2));
        mostRecentDay = math.max (day, mostRecentDay);
      end
    end

    -- decide if the item should be retained

    if (mostRecentDay == -1 or mostRecentDay >= itemCutoff) then

      dbCopy[itemName] = {};
      y = y + 1;

      for key, price in pairs (info) do     -- second pass over item
        doCopy = true;

        char1 = string.sub (key, 1, 1);
        if (char1 == "H" or char1 == "L") then
          day = tonumber (string.sub(key, 2));
          if (day < histCutoff and day ~= mostRecentDay) then
            doCopy = false;
            h = h + 1;
          end
        end

        if (doCopy) then
          dbCopy[itemName][key] = price;
          z = z + 1;
        end
      end
    else
      x = x + 1;
    end


  end

  zc.ClearTable (gAtr_ScanDB);
  zc.CopyDeep (gAtr_ScanDB, dbCopy);

  dbCopy = nil;

  collectgarbage  ("collect");

  if (verbose or Atr_IsDev) then
    local endMem = Atr_GetAuctionatorMemString();
--    zc.msg_anm ("Memory usage went from", startMem, "to", endMem);
  end

--  zc.md ("Historical prices pruned: ", h, "out of", h+z, "   Items pruned: ", x, "out of", x+y, "   Time taken: ", time() - start);

end

-----------------------------------------

function Atr_BuildSortedScanHistoryList (itemName)

  local currentPane = Atr_GetCurrentPane();

  local todayScanDay = Atr_GetScanDay_Today();

  -- build the sorted history list

  currentPane.sortedHist = {};

  if (gAtr_ScanDB[itemName]) then
    local n = 1;
    local key, highlowprice, char1, day, when;
    for key, highlowprice in pairs (gAtr_ScanDB[itemName]) do

      char1 = string.sub (key, 1, 1);

      if (char1 == "H") then

        day = tonumber (string.sub(key, 2));

        when = gScanHistDayZero + (day *86400);

        local lowlowprice = gAtr_ScanDB[itemName]["L"..day];
        if (lowlowprice == nil) then
          lowlowprice = highlowprice;
        end

        highlowprice = tonumber (highlowprice)
        lowlowprice  = tonumber (lowlowprice)

        currentPane.sortedHist[n]       = {};
        currentPane.sortedHist[n].itemPrice   = zc.round ((highlowprice + lowlowprice) / 2);
        currentPane.sortedHist[n].when      = when;
        currentPane.sortedHist[n].yours     = true;
        currentPane.sortedHist[n].type      = "n";

        if (day == todayScanDay) then
          currentPane.sortedHist[n].whenText = ZT("Today");
        elseif (day == todayScanDay - 1) then
          currentPane.sortedHist[n].whenText = ZT("Yesterday");
        else
          currentPane.sortedHist[n].whenText = date("%A, %B %d", when);
        end

        n = n + 1;
      end
    end
  end

  table.sort (currentPane.sortedHist, Atr_SortHistoryData);

  if (#currentPane.sortedHist > 0) then
    return currentPane.sortedHist[1].itemPrice;
  end

end

-----------------------------------------

function Atr_GetScanDay_Today()

  return (math.floor ((time() - gScanHistDayZero) / (86400)));

end

-----------------------------------------

function Atr_GetNumAuctionItems (which)

  local numBatchAuctions, totalAuctions = GetNumAuctionItems(which);

  local returnTotalAuctions = totalAuctions

  if (totalAuctions > 500000 or totalAuctions < 0) then
    totalAuctions = numBatchAuctions;
  end

  return numBatchAuctions, totalAuctions, returnTotalAuctions

end




