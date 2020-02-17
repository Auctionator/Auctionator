function Auctionator.Events.AddonLoaded(...)
  Auctionator.Debug.Message("Auctionator.Events.AddonLoaded", ...)

  Auctionator.ShoppingLists.InitializeDialogs()
end

local gPrevTime = 0;

function Atr_OnAddonLoaded(...)
  Auctionator.Debug.Message( 'Atr_OnAddonLoaded', ... )

  local addonName = select (1, ...);

  if (zc.StringSame (addonName, "Blizzard_AuctionHouseUI")) then
    Auctionator.Events.InitializeAddon();
  end

  Atr_Check_For_Conflicts (addonName);

  local now = time();

  gPrevTime = now;

  if (zc.StringSame (addonName, "blizzard_tradeskillui")) then
    Atr_ModTradeSkillFrame();
  end

end

-- Put this on the Auctionator Object; introduce state table?
AuctionatorInited = false;

local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;

function Auctionator.Events.InitializeAddon()
  -- Atr_Init();
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

  Atr_AddMainPanel();

  gShopPane = Atr_AddSellTab (ZT("Buy"), Auctionator.Constants.Tabs.BUY_TAB);
  gSellPane = Atr_AddSellTab (ZT("Sell"), Auctionator.Constants.Tabs.SELL_TAB);
  gMorePane = Atr_AddSellTab (ZT("More").."...",  Auctionator.Constants.Tabs.MORE_TAB);



  Atr_SetupHookFunctions ();

  -- create the lines that appear in the item history scroll pane

  local line, n;

  for n = 1, Auctionator.Constants.History.NUMBER_OF_LINES do
    local y = -5 - ((n-1)*16);
    line = CreateFrame("BUTTON", "AuctionatorHEntry"..n, Atr_Hlist, "Atr_HEntryTemplate");
    line:SetPoint("TOPLEFT", 0, y);
  end

  Atr_ShowHide_StartingPrice();

  Atr_LocalizeFrames();

end

function AddSellTab()
  Auctionator.Debug.Message( 'AddSellTab')

  local frame = CreateFrame("Button", "AuctionatorSellFrame", AuctionHouseFrame, "AuctionHouseFrameTabTemplate")
  frame:SetID(4)
  frame:SetText("AU Sell")
  frame:SetNormalFontObject(_G["AtrFontOrange"]);

  frame.auctionatorTab = Auctionator.Constants.Tabs.SELL_TAB
  frame:SetPoint("LEFT", _G["AuctionHouseFrameTab3"], "RIGHT", -8, 0);

  return AtrPane.create(Auctionator.Constants.Tabs.SELL_TAB)
end

-----------------------------------------

function Atr_AddSellTab (tabtext, whichTab)
  Auctionator.Debug.Message( 'Atr_AddSellTab', tabtext, whichTab )

  local n = AuctionHouseFrame.numTabs + 1;

  Auctionator.Util.Print(AuctionHouseFrame.numTabs)
  local framename = "AuctionHouseFrameTab"..n;

  local frame = CreateFrame("Button", framename, AuctionHouseFrame, "AuctionHouseFrameTabTemplate");

  frame:SetID(n);
  frame:SetText(tabtext);

  frame:SetNormalFontObject(_G["AtrFontOrange"]);

  frame.auctionatorTab = whichTab;

  frame:SetPoint("LEFT", _G["AuctionHouseFrameTab"..n-1], "RIGHT", -8, 0);

  PanelTemplates_SetNumTabs (AuctionHouseFrame, n);
  -- PanelTemplates_EnableTab  (AuctionHouseFrame, n);

  return AtrPane.create (whichTab);
end