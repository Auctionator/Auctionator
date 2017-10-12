
local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local zz = zc.md;
local _

Atr_LoadOptionsSubPanel_NumCalls = 0;

-----------------------------------------

function Atr_LoadOptionsMainPanel (f)
  InterfaceOptions_AddCategory(f);

end

-----------------------------------------

function Atr_LoadOptionsSubPanel (f, name, title, subtitle)

  f.name    = name
  f.parent  = "Auctionator";
  f.cancel  = Atr_Options_Cancel;

  local frameName = f:GetName();

  f.okay   = _G[frameName.."_Save"];

  Atr_LoadOptionsSubPanel_NumCalls = Atr_LoadOptionsSubPanel_NumCalls + 1;

  if (title    == nil) then title = name; end
  if (subtitle == nil) then subtitle = ""; end

  _G[frameName.."_ATitle"]:SetText (title);
  _G[frameName.."_BTitle"]:SetText (subtitle);

  InterfaceOptions_AddCategory (f);

  f:SetScript("OnShow", Atr_OptionsSubPanel_OnShow)

end

-----------------------------------------

function Atr_OptionsSubPanel_OnShow (self)

  self.atr_hasBeenShown = true;

  if (self.atr_onShow) then
    self.atr_onShow (self);
  end
end

-----------------------------------------

function Atr_Options_Cancel ()

  Atr_InitOptionsPanels();

end


-----------------------------------------

function Atr_InitOptionsPanels()

  if (AUCTIONATOR_SAVEDVARS == nil) then
    Atr_ResetSavedVars();
  end

  Atr_SetupBasicOptionsFrame();
  Atr_SetupTooltipsOptionsFrame();
  Atr_SetupUCConfigFrame();
  Atr_SetupStackingFrame();
  Atr_SetupOptionsFrame();
  Atr_SetupScanningConfigFrame();
  Atr_SetupShpListsFrame();

end

-----------------------------------------

function Atr_SetupOptionsFrame()

  local expText = "<html><body>"
          .."<p>"..ZT("The latest information on Auctionator can be found at").." |cFF4499FF http://mods.curse.com/addons/wow/auctionator .".."</p>"
          .."<p><br />"
          .. ZT("Read the FAQ at") .. " |cFF4499FF https://github.com/Auctionator/Auctionator/wiki ." .. "</p>"
          .."<p><br/>"
          .."MoP disenchanting data courtesy of the Norganna's AddOns (the Auctioneer folks)"
          .."</p>"
          .."<p><br/>"
          .."|cffaaaaaa"..string.format (ZT("German translation courtesy of %s"),  "|rCkaotik").."<br/>"
          .."|cffaaaaaa"..string.format (ZT("Russian translation courtesy of %s"), "|rStingerSoft, Wetxius").."<br/>"
          .."|cffaaaaaa"..string.format (ZT("Swedish translation courtesy of %s"), "|rHellManiac").."<br/>"
          .."|cffaaaaaa"..string.format (ZT("French translation courtesy of %s"),  "|rKiskewl and Klep").."<br/>"
          .."|cffaaaaaa"..string.format (ZT("Spanish translation courtesy of %s"),  "|rElfindor").."<br/>"
          .."|cffaaaaaa"..string.format (ZT("Chinese/Taiwan translation courtesy of %s"),  "|rScars").."<br/>"
          .."</p>"
          .."</body></html>"
          ;

  AuctionatorDescriptionHTML:SetText (expText);
  AuctionatorDescriptionHTML:SetSpacing (3);

  AuctionatorVersionText:SetText (ZT("Version")..": "..AuctionatorVersion);

end


-----------------------------------------

function Atr_SetDurationOptionRB(name)

  Atr_RB_S:SetChecked (zc.StringEndsWith (name, "S"));
  Atr_RB_M:SetChecked (zc.StringEndsWith (name, "M"));
  Atr_RB_L:SetChecked (zc.StringEndsWith (name, "L"));

end

-----------------------------------------

function Atr_BasicOptionsFrame_Save (frame)

  if (not frame.atr_hasBeenShown) then
    return;
  end

  local origValues = zc.msg_str (AUCTIONATOR_ENABLE_ALT, AUCTIONATOR_ENABLE_QUICK_SCAN, AUCTIONATOR_SHOW_ST_PRICE, AUCTIONATOR_DEFTAB, AUCTIONATOR_DEF_DURATION);

  AUCTIONATOR_ENABLE_ALT    = zc.BoolToNum(AuctionatorOption_Enable_Alt_CB:GetChecked ());
  AUCTIONATOR_ENABLE_QUICK_SCAN    = zc.BoolToNum(AuctionatorOption_Quick_Scan_CB:GetChecked ());
  AUCTIONATOR_SHOW_ST_PRICE = zc.BoolToNum(AuctionatorOption_Show_StartingPrice_CB:GetChecked ());

  AUCTIONATOR_DEFTAB      = UIDropDownMenu_GetSelectedValue(AuctionatorOption_Deftab);

  AUCTIONATOR_DEF_DURATION = "N";

  if (Atr_RB_S:GetChecked())  then  AUCTIONATOR_DEF_DURATION = "S"; end;
  if (Atr_RB_M:GetChecked())  then  AUCTIONATOR_DEF_DURATION = "M"; end;
  if (Atr_RB_L:GetChecked())  then  AUCTIONATOR_DEF_DURATION = "L"; end;

  local newValues = zc.msg_str (AUCTIONATOR_ENABLE_ALT, AUCTIONATOR_ENABLE_QUICK_SCAN, AUCTIONATOR_SHOW_ST_PRICE, AUCTIONATOR_DEFTAB, AUCTIONATOR_DEF_DURATION);

  if (origValues ~= newValues) then
    zc.msg_anm (ZT ("basic options saved"));
  end

  Atr_ShowHide_StartingPrice();
end


-----------------------------------------

function Atr_SetupBasicOptionsFrame()

  Atr_BasicOptionsFrame_BTitle:SetText (string.format (ZT("Basic Options for %s"), "|cffffff55"..UnitName("player")));

  AuctionatorOption_Enable_Alt_CB:SetChecked      (zc.NumToBool(AUCTIONATOR_ENABLE_ALT));
  AuctionatorOption_Quick_Scan_CB:SetChecked      (zc.NumToBool(AUCTIONATOR_ENABLE_QUICK_SCAN));
  AuctionatorOption_Show_StartingPrice_CB:SetChecked  (zc.NumToBool(AUCTIONATOR_SHOW_ST_PRICE));
  AuctionatorOption_Enable_Debug_CB:SetChecked( AUCTIONATOR_SAVEDVARS.DEBUG_MODE );

  Atr_SetDurationOptionRB (AUCTIONATOR_DEF_DURATION);

end

-----------------------------------------

function Atr_SetupTooltipsOptionsFrame ()

  ATR_tipsVendorOpt_CB:SetChecked   (zc.NumToBool(AUCTIONATOR_V_TIPS));
  ATR_tipsAuctionOpt_CB:SetChecked  (zc.NumToBool(AUCTIONATOR_A_TIPS));
  ATR_tipsDisenchantOpt_CB:SetChecked (zc.NumToBool(AUCTIONATOR_D_TIPS));
  ATR_tipsMailboxOpt_CB:SetChecked( zc.NumToBool( AUCTIONATOR_SHOW_MAILBOX_TIPS ))
end


-----------------------------------------

function Atr_TooltipsOptionsFrame_Save( frame )
  Auctionator.Debug.Message( 'Atr_TooltipsOptionsFrame_Save' )

  if not frame.atr_hasBeenShown then
    return
  end

  local origValues = zc.msg_str (AUCTIONATOR_V_TIPS, AUCTIONATOR_A_TIPS, AUCTIONATOR_D_TIPS, AUCTIONATOR_SHIFT_TIPS, AUCTIONATOR_DE_DETAILS_TIPS);

  AUCTIONATOR_V_TIPS    = zc.BoolToNum(ATR_tipsVendorOpt_CB:GetChecked ());
  AUCTIONATOR_A_TIPS    = zc.BoolToNum(ATR_tipsAuctionOpt_CB:GetChecked ());
  AUCTIONATOR_D_TIPS    = zc.BoolToNum(ATR_tipsDisenchantOpt_CB:GetChecked ());
  AUCTIONATOR_SHOW_MAILBOX_TIPS = zc.BoolToNum( ATR_tipsMailboxOpt_CB:GetChecked() )

  AUCTIONATOR_SHIFT_TIPS    = UIDropDownMenu_GetSelectedValue(Atr_tipsShiftDD);
  AUCTIONATOR_DE_DETAILS_TIPS = UIDropDownMenu_GetSelectedValue(Atr_deDetailsDD);

  local newValues = zc.msg_str (AUCTIONATOR_V_TIPS, AUCTIONATOR_A_TIPS, AUCTIONATOR_D_TIPS, AUCTIONATOR_SHIFT_TIPS, AUCTIONATOR_DE_DETAILS_TIPS);

  if (origValues ~= newValues) then
    zc.msg_anm (ZT("tooltip configuration saved"));
  end

end


-----------------------------------------

function Atr_Opt_Deftab_OnShow(self)

  UIDropDownMenu_Initialize   (self, Atr_Opt_Deftab_Initialize);
  UIDropDownMenu_SetSelectedValue (self, AUCTIONATOR_DEFTAB);
  UIDropDownMenu_JustifyText    (self, "LEFT");
end

-----------------------------------------

function Atr_Opt_Deftab_Initialize(self)

  Atr_Dropdown_AddPick (self, ZT("None"), 0);
  Atr_Dropdown_AddPick (self, ZT("Sell"), 1);
  Atr_Dropdown_AddPick (self, ZT("Buy"),  2);
  Atr_Dropdown_AddPick (self, ZT("More"), 3);
end


-----------------------------------------

function Atr_Opt_TipsShift_OnShow(self)

  UIDropDownMenu_Initialize   (self, Atr_tipsShiftDD_Initialize);
  UIDropDownMenu_SetSelectedValue (self, AUCTIONATOR_SHIFT_TIPS);
  UIDropDownMenu_JustifyText    (self, "LEFT");
end

-----------------------------------------

function Atr_tipsShiftDD_Initialize(self)

  Atr_Dropdown_AddPick (self, ZT("stack price"),    1);
  Atr_Dropdown_AddPick (self, ZT("per item price"), 2);
end

-----------------------------------------

function Atr_Opt_deDetails_OnShow(self)

  UIDropDownMenu_Initialize   (self, Atr_deDetailsDD_Initialize);
  UIDropDownMenu_SetSelectedValue (self, AUCTIONATOR_DE_DETAILS_TIPS);
  UIDropDownMenu_SetWidth     (self, 175, 5);
  UIDropDownMenu_JustifyText    (self, "LEFT");

end

-----------------------------------------

function Atr_deDetailsDD_Initialize(self)

  Atr_Dropdown_AddPick (self, ZT("when SHIFT is held down"),    1);
  Atr_Dropdown_AddPick (self, ZT("when CONTROL is held down"),  2);
  Atr_Dropdown_AddPick (self, ZT("when ALT is held down"),    3);
  Atr_Dropdown_AddPick (self, ZT("never"),            4);
  Atr_Dropdown_AddPick (self, ZT("always"),           5);
end


-----------------------------------------

function Atr_Option_OnClick (self)
  Auctionator.Debug.Message( 'Atr_Option_OnClick', self:GetName() )

  if (zc.StringContains (self:GetName(), "Open_BUY") and self:GetChecked()) then
    AuctionatorOption_Open_SELL_CB:SetChecked (false);
  end

  if (zc.StringContains (self:GetName(), "Open_SELL") and self:GetChecked()) then
    AuctionatorOption_Open_BUY_CB:SetChecked (false);
  end

  if self:GetName():find('AuctionatorOption_Enable_Debug') then
    Auctionator.Debug.Toggle()
  end

end


-----------------------------------------

local kThresh = {}

kThresh[1] = { amt=5000000,   text=ZT("over %d gold"),    v=500 };
kThresh[2] = { amt=1000000,   text=ZT("over %d gold"),    v=100 };
kThresh[3] = { amt=200000,    text=ZT("over %d gold"),    v=20  };
kThresh[4] = { amt=50000,   text=ZT("over %d gold"),    v=5   };
kThresh[5] = { amt=10000,   text=ZT("over 1 gold"),     v=1   };
kThresh[6] = { amt=2000,    text=ZT("over %d silver"),    v=20  };
kThresh[7] = { amt=500,     text=ZT("over %d silver"),    v=5   };

-----------------------------------------

function Atr_SetupUCConfigFrame()

  for i = 1, #kThresh do

    local amt   = kThresh[i].amt;
    local linetext  = string.format (kThresh[i].text, kThresh[i].v);

    _G["UC_"..amt.."_RangeText"]:SetText (linetext);

    MoneyInputFrame_SetCopper (_G["UC_"..amt.."_MoneyInput"], AUCTIONATOR_SAVEDVARS["_"..amt]);
  end

  Atr_Starting_Discount:SetText (AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT);

end


-----------------------------------------

function Atr_UCConfigFrame_Save(frame)

  if (not frame.atr_hasBeenShown) then
    return;
  end

  local origValues  = AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT;

  AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT = Atr_Starting_Discount:GetNumber ();

  local newValues   = AUCTIONATOR_SAVEDVARS.STARTING_DISCOUNT;

  for i = 1, #kThresh do
    local amt = kThresh[i].amt;

    origValues = origValues + AUCTIONATOR_SAVEDVARS["_"..amt];

    AUCTIONATOR_SAVEDVARS["_"..amt] = MoneyInputFrame_GetCopper(_G["UC_"..amt.."_MoneyInput"]);

    newValues = newValues + AUCTIONATOR_SAVEDVARS["_"..amt];
  end

  if (origValues ~= newValues) then
    zc.msg_anm (ZT("undercutting configuration saved"));
  end


end

-----------------------------------------

local function plistEntry (key, txt, num, size)

  return { sortkey=key, text=txt, numstacks=num, stacksize=size }

end

-----------------------------------------

local function plistSort (x, y)

  return x.sortkey < y.sortkey;

end

-----------------------------------------

local kStackList_LinesToDisplay = 12;
local gStackList_SelectedIndex = 0;
local gStackList_plist;


kStackList_categories = {};

kStackList_categories[ATR_SK_GLYPHS]    = { txt=ZT("Glyphs")      }
kStackList_categories[ATR_SK_GEMS_CUT]    = { txt=ZT("Gems - Cut")    }
kStackList_categories[ATR_SK_GEMS_UNCUT]  = { txt=ZT("Gems - Uncut")    }
kStackList_categories[ATR_SK_ITEM_ENH]    = { txt=ZT("Item Enhancements") }
kStackList_categories[ATR_SK_POT_ELIX]    = { txt=ZT("Potions and Elixirs") }
kStackList_categories[ATR_SK_FLASKS]    = { txt=ZT("Flasks")  }
kStackList_categories[ATR_SK_HERBS]     = { txt=ZT("Herbs") }

-----------------------------------------

function Atr_SetupStackingFrame ()

  if (_G["Atr_StackList1"] == nil) then
    local line, n;

    for n = 1, kStackList_LinesToDisplay do
      local y = -5 - ((n-1)*16);
      line = CreateFrame("BUTTON", "Atr_StackList"..n, Atr_Stacking_List, "Atr_StackingEntryTemplate");
      line:SetPoint("TOP", 0, y);
    end
  end

  Atr_StackingList_Display();

end

-----------------------------------------

function Atr_StackingList_Display()

  gStackList_plist = {};

  local plist = gStackList_plist;
  local text, spinfo;
  local sortkey, info;
  local n = 1;

  for sortkey, info in pairs (kStackList_categories) do
    info.overrideFound = false;
  end

  if (AUCTIONATOR_STACKING_PREFS == nil) then
    Atr_StackingPrefs_Init();
  end

  for text, spinfo in pairs (AUCTIONATOR_STACKING_PREFS) do

    -- skip over any that were set automatically rather than explicitly by the user
    -- and mark the built-in categories

    if (spinfo.numstacks ~= 0) then
      local sortkey = text;

      if (kStackList_categories[text]) then
        kStackList_categories[text].overrideFound = true;
        text = kStackList_categories[text].txt;
      end

      plist[n] = plistEntry (sortkey, text, spinfo.numstacks, spinfo.stacksize);
      n = n + 1;
    end
  end

  for sortkey, info in pairs (kStackList_categories) do
    if (not info.overrideFound) then
      plist[n] = plistEntry (sortkey, info.txt, -2, 0);
      n = n + 1;
    end
  end

  table.sort (plist, plistSort)

  local totalRows = #plist;

  local line;             -- 1 through NN of our window to scroll
  local dataOffset;         -- an index into our data calculated from the scroll offset

  FauxScrollFrame_Update (Atr_Stacking_ScrollFrame, totalRows, kStackList_LinesToDisplay, 16);

  for line = 1,kStackList_LinesToDisplay do

    dataOffset = line + FauxScrollFrame_GetOffset (Atr_Stacking_ScrollFrame);

    local lineEntry = _G["Atr_StackList"..line];

    lineEntry:SetID (dataOffset);

    if (dataOffset <= totalRows and plist[dataOffset]) then

      local lineEntry_text = _G["Atr_StackList"..line.."_text"];
      local lineEntry_info = _G["Atr_StackList"..line.."_info"];

      local pdata = plist[dataOffset];

      local colorText = ((pdata.text == pdata.sortkey) and "" or "|cffffff88");

      lineEntry_text:SetText (colorText..pdata.text);

      local numstacks = plist[dataOffset].numstacks;
      local stacksize = plist[dataOffset].stacksize;
      local info = "???";

      if     (numstacks == -2) then info = "|cff777777"..ZT("default behavior");
      elseif (numstacks == -1) then info = string.format (ZT("max. stacks of %d"), stacksize);
      elseif (stacksize == 0)  then info = "1 "..ZT("stack");
      elseif (numstacks == 0)  then info = ZT("stacks of").." "..stacksize;
      elseif (numstacks > 0)   then info = numstacks.." "..ZT("stacks of").." "..stacksize;
      end

      lineEntry_info:SetText (info);

      if (gStackList_SelectedIndex == dataOffset) then
        lineEntry:SetButtonState ("PUSHED", true);
      else
        lineEntry:SetButtonState ("NORMAL", false);
      end

      lineEntry:Show();
    else
      lineEntry:Hide();
    end
  end

  zc.EnableDisable (Atr_StackingOptionsFrame_Edit, gStackList_SelectedIndex > 0);

end

-----------------------------------------

function Atr_StackingEntry_OnClick(self)

  gStackList_SelectedIndex = self:GetID();

  Atr_StackingList_Display();
end

-----------------------------------------

function Atr_StackingEntry_OnDoubleClick(self)

  Atr_StackingEntry_OnClick(self);
  Atr_StackingList_Edit_OnClick();
end

-----------------------------------------

function Atr_Memorize_Show (isNew)

  local numStacks = -1;
  local stackSize = 1;

  zc.ShowHide (Atr_Mem_itemName_static, not isNew);
  zc.ShowHide (Atr_Mem_EB_itemName,       isNew);
  zc.ShowHide (Atr_Mem_Forget,        not isNew);

  Atr_MemorizeFrame["isCategory"] = false;

  if (not isNew) then
    local x   = gStackList_SelectedIndex;
    local plist = gStackList_plist;

    Atr_Mem_itemName_static:SetText (plist[x].text);

    stackSize = plist[x].stacksize
    numStacks = plist[x].numstacks

    local isCategory = (plist[x].sortkey ~= plist[x].text);

    Atr_MemorizeFrame["isCategory"] = isCategory;

    if (isCategory and numStacks == -2) then
      numStacks = -1;
      stackSize = 1;
    end

    zc.SetTextIf (Atr_Mem_itemName_text, isCategory, ZT("Category"), ZT("Item Name"));
    zc.SetTextIf (Atr_Mem_Forget,    isCategory, ZT("Reset to Default"), ZT("Forget this Item"));
  end

  Atr_Mem_EB_stackSize:SetText (stackSize);

  UIDropDownMenu_Initialize   (Atr_Mem_DD_numStacks, Atr_SONumStacks_Initialize);
  UIDropDownMenu_SetSelectedValue (Atr_Mem_DD_numStacks, numStacks);

  Atr_Mem_EB_itemName:SetText ("");

  ShowInterfaceOptionsMask();

  Atr_MemorizeFrame:Show();

  StaticPopup_Hide ("ATR_MEMORIZE_TEXT_BLANK");

end

-----------------------------------------
local Atr_StackingList_Check

function Atr_StackingList_Edit_OnClick()

  Atr_Memorize_Show(false);
  Atr_StackingList_Check = false
end

-----------------------------------------

function Atr_StackingList_New_OnClick()

  Atr_Memorize_Show(true);
  Atr_StackingList_Check = true

end

-----------------------------------------

StaticPopupDialogs[ "ATR_MEMORIZE_TEXT_BLANK" ] = {
  text = "",
  button1 = OKAY,
  OnAccept = function( self )
    Atr_StackingList_New_OnClick();
    return
  end,
  OnShow = function( self )
    local s = string.format (ZT("Item Name must not be blank"));
    self.text:SetText("\n"..s.."\n");
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
};

function Atr_Memorize_Save()
  Auctionator.Debug.Message( 'Atr_Memorize_Save' )

  local x   = gStackList_SelectedIndex
  local plist = gStackList_plist
  local key = Atr_Mem_EB_itemName:GetText()

  if Atr_StackingList_Check then
    if key == nil or key == "" then
      StaticPopup_Show( "ATR_MEMORIZE_TEXT_BLANK" )
    end
  else
    key = plist[ x ].sortkey
  end

  if (key and key ~= "") then
    Atr_Set_StackingPrefs_numstacks (key, UIDropDownMenu_GetSelectedValue (Atr_Mem_DD_numStacks));
    Atr_Set_StackingPrefs_stacksize (key, Atr_Mem_EB_stackSize:GetNumber());
  end

  Atr_StackingList_Display();

end

-----------------------------------------

function Atr_Memorize_Forget()

  local x   = gStackList_SelectedIndex;
  local plist = gStackList_plist;
  local key = plist[x].sortkey;

  if (key) then
    Atr_Clear_StackingPrefs (key);
  end

  if (not Atr_MemorizeFrame["isCategory"]) then
    gStackList_SelectedIndex = 0;
  end

  Atr_StackingList_Display();

end


-----------------------------------------


function Atr_SONumStacks_OnShow(self)

  UIDropDownMenu_Initialize   (self, Atr_SONumStacks_Initialize);
  UIDropDownMenu_JustifyText    (self, "CENTER");
  UIDropDownMenu_SetWidth     (self, 150);
end

-----------------------------------------

function Atr_SONumStacks_Initialize(self)

  Atr_Dropdown_AddPick (self, ZT("As many as possible"),    -1,  Atr_SONumStacks_OnClick)
  Atr_Dropdown_AddPick (self, "1",               1,  Atr_SONumStacks_OnClick)
  Atr_Dropdown_AddPick (self, "2",               2,  Atr_SONumStacks_OnClick)
  Atr_Dropdown_AddPick (self, "3",               3,  Atr_SONumStacks_OnClick)
  Atr_Dropdown_AddPick (self, "4",               4,  Atr_SONumStacks_OnClick)
  Atr_Dropdown_AddPick (self, "5",               5,  Atr_SONumStacks_OnClick)
  Atr_Dropdown_AddPick (self, "10",             10,  Atr_SONumStacks_OnClick)

end

-----------------------------------------

function Atr_SONumStacks_OnClick(self)

  UIDropDownMenu_SetSelectedValue(self.owner, self.value);
  Atr_Mem_stacksOf_text:SetText (ZT ((self.value == 1) and "stack of" or "stacks of"));
end

-----------------------------------------

function Atr_ShowOptionTooltip (elem)

  local name = elem:GetName();
  local text;

  if (zc.StringContains (name, "Enable_Alt")) then
    text = ZT("If this option is checked, holding the Alt key down while clicking an item in your bags will switch to the Auctionator panel, place the item in the Auction Item area, and start the scan.");
  end

  if (zc.StringContains (name, "Deftab")) then
    text = ZT("Select the Auctionator panel to be displayed first whenever you open the Auction House window.");
  end

  if (zc.StringContains (name, "Open_BUY")) then
    text = ZT("If this option is checked, the Auctionator BUY panel will display first whenever you open the Auction House window.");
  end

  if (zc.StringContains (name, "Def_Duration")) then
    text = ZT("If this option is checked, every time you initiate a new auction the auction duration will be reset to the default duration you've selected.");
  end

  if (text) then
    local titleFrame = _G[name.."_CB_Text"] or _G[name.."_Text"];

    local titleText = titleFrame and titleFrame:GetText() or "???";

    GameTooltip:SetOwner(elem, "ANCHOR_LEFT");
    GameTooltip:SetText(titleText, 0.9, 1.0, 1.0);
    GameTooltip:AddLine(text, 0.5, 0.5, 1.0, 1);
    GameTooltip:Show();
  end

end

-----------------------------------------

function Atr_SetupScanningConfigFrame ()

  Atr_ScanningOptionsFrame.atr_onShow = Atr_ScanningConfigFrame_Update;

end

-----------------------------------------

function Atr_ScanOpts_ApplyNow()

  Atr_ScanningOptionsFrame_Save(Atr_ScanningOptionsFrame);
  Atr_PruneScanDB ();
  Atr_ScanningConfigFrame_Update();
end


-----------------------------------------

function Atr_ScanningConfigFrame_Update ()

  Atr_ScanOpts_ItemCntText:SetText  (string.format (ZT("%6d items"), Atr_GetDBsize()));

  collectgarbage  ("collect");

  Atr_ScanOpts_MemUsageText:SetText (Atr_GetAuctionatorMemString());

  Atr_MigtrateMaxHistAge();

  Atr_ScanOpts_MaxHistAge:SetText (AUCTIONATOR_DB_MAXHIST_DAYS);

end

-----------------------------------------

function Atr_ScanningOptionsFrame_Save(frame)

  if (not frame.atr_hasBeenShown) then
    return;
  end

  local origValues = zc.msg_str (AUCTIONATOR_SCAN_MINLEVEL, AUCTIONATOR_DB_MAXITEM_AGE, AUCTIONATOR_DB_MAXHIST_DAYS);

  AUCTIONATOR_SCAN_MINLEVEL = UIDropDownMenu_GetSelectedValue(Atr_scanLevelDD);
  AUCTIONATOR_DB_MAXHIST_DAYS = Atr_ScanOpts_MaxHistAge:GetNumber();

  local newValues = zc.msg_str (AUCTIONATOR_SCAN_MINLEVEL, AUCTIONATOR_DB_MAXITEM_AGE, AUCTIONATOR_DB_MAXHIST_DAYS);

  if (origValues ~= newValues) then
    zc.msg_anm (ZT("scanning options saved"));
  end

end


-----------------------------------------

function Atr_ScanLevel_OnLoad(self)

  Atr_ScanLevel_OnShow(self);
end

-----------------------------------------

function Atr_ScanLevel_OnShow(self)

  UIDropDownMenu_Initialize   (self, Atr_scanLevelDD_Initialize);
  UIDropDownMenu_SetSelectedValue (self, AUCTIONATOR_SCAN_MINLEVEL);
  UIDropDownMenu_JustifyText    (self, "LEFT");
end

-----------------------------------------

function Atr_scanLevelDD_Initialize(self)

  Atr_Dropdown_AddPick (self, "|cffa335ee"..ZT("Epic").."|r",     5);
  Atr_Dropdown_AddPick (self, "|cff0070dd"..ZT("Rare").."|r",     4);
  Atr_Dropdown_AddPick (self, "|cff1eff00"..ZT("Uncommon").."|r",   3);
  Atr_Dropdown_AddPick (self, "|cffffffff"..ZT("Common").."|r",   2);
  Atr_Dropdown_AddPick (self, "|cff9d9d9d"..ZT("Poor (all)").."|r", 1);

end

-----------------------------------------

function Atr_scanLevelDD_showTip(self)

  GameTooltip:SetOwner(self, "ANCHOR_LEFT");
  GameTooltip:SetText(ZT("Minimum Quality Level"), 0.9, 1.0, 1.0);
  GameTooltip:AddLine(ZT("Only include items in the scanning database that are this level or higher"), 0.5, 0.5, 1.0, 1);
  GameTooltip:Show();
end

-----------------------------------------

local gAtr_ConfirmYesAction


-----------------------------------------

function Atr_OnClick_ClearConfirm_Yes()

  if (gAtr_ConfirmYesAction) then
    collectgarbage  ("collect");
    UpdateAddOnMemoryUsage()
    local before = Atr_GetAuctionatorMemString()

    local text = gAtr_ConfirmYesAction()

    collectgarbage  ("collect");
    UpdateAddOnMemoryUsage()
    local after = Atr_GetAuctionatorMemString()

    zc.msg_anm (text, "  Memory went from", before, "to", after);
  end

  gAtr_ConfirmYesAction = nil

  Atr_OnClick_ClearConfirm_Hide()
end

-----------------------------------------

function Atr_OnClick_ClearConfirm_Hide()

  Atr_ConfirmClear_Frame:Hide()
  HideInterfaceOptionsMask()
end


-----------------------------------------

function Atr_OnClick_ClearHistory(self)

  ShowInterfaceOptionsMask();

  Atr_ClearConfirm_Text1:SetText (ZT("Are you sure you want to clear the scanned prices database?"))
  Atr_ClearConfirm_Text2:SetText (ZT("This will clear the pricing history for all items for all your characters - even characters on different servers."))

  gAtr_ConfirmYesAction = function ()

    gAtr_ScanDB = nil;
    AUCTIONATOR_PRICE_DATABASE = nil;
    Atr_InitScanDB();

    return "Pricing history cleared."
    end

  Atr_ConfirmClear_Frame:Show()

end

-----------------------------------------

function Atr_OnClick_ClearPostHistory(self)

  ShowInterfaceOptionsMask();

  Atr_ClearConfirm_Text1:SetText (ZT("Are you sure you want to clear the posting history?"))
  Atr_ClearConfirm_Text2:SetText (ZT("This will clear the information that Auctionator keeps for all items that you've posted - as shown on the \"Other\" tab after you scan for an item that you've sold in the past."))

  gAtr_ConfirmYesAction = function ()

    AUCTIONATOR_PRICING_HISTORY = {}

    return "Posting history cleared."
    end

  Atr_ConfirmClear_Frame:Show()

end


-----------------------------------------

function Atr_OnClick_ClearStackPrefs(self)

  ShowInterfaceOptionsMask();

  Atr_ClearConfirm_Text1:SetText (ZT("Are you sure you want to clear your stacking preferences?"))
  Atr_ClearConfirm_Text2:SetText (ZT("Go ahead - this isn't a big deal.  Auctionator will figure it out again fairly quickly.  This is just some info Auctionator keeps to help it set the default stack size a bit more intelligently."))

  gAtr_ConfirmYesAction = function ()

    Atr_ClearItemStackingPrefs()

    return "Stacking preferences cleared."
    end

  Atr_ConfirmClear_Frame:Show()

end

-----------------------------------------

function Atr_OnClick_ClearShopLists(self)

  ShowInterfaceOptionsMask();

  Atr_ClearConfirm_Text1:SetText (ZT("Are you sure you want to clear your shopping lists?"))
  Atr_ClearConfirm_Text2:SetText (ZT("If you put a lot of time into constructing detailed shopping lists, this will require you to buidl them all over again."))

  gAtr_ConfirmYesAction = function ()

    AUCTIONATOR_SHOPPING_LISTS = {}
    Atr_SList.create (ZT("Recent Searches"), true);

    return "Shopping lists cleared."
    end

  Atr_ConfirmClear_Frame:Show()

end

-------------------------------------------------------------------------------------------------------------------
-- Shopping Lists options panel
-------------------------------------------------------------------------------------------------------------------

local kShpLists_LinesToDisplay  = 18
local kShpLists_LineHeight    = 16
local kShpLists_SelectedIndices = {}
local kShpLists_NeedUpdate    = true
local kShpLists_NumShpLists   = 0

-----------------------------------------

function Atr_SetupShpListsFrame()

  if (_G["Atr_ShpList1"] == nil) then
    local line, n;

    for n = 1, kShpLists_LinesToDisplay do
      local y = -10 - ((n-1)*kShpLists_LineHeight);
      line = CreateFrame("BUTTON", "Atr_ShpList"..n, Atr_ShpList_Frame, "Atr_ShpListsEntryTemplate");
      line:SetPoint("TOP", 0, y);
    end
  end

  if (InterfaceOptionsFrame:GetFrameStrata() == "FULLSCREEN_DIALOG") then     -- Chatter sets to FULLSCREEN_DIALOG which prevents popup from being on top
    InterfaceOptionsFrame:SetFrameStrata ("HIGH")
  end

  kShpLists_NeedUpdate = true
end


-----------------------------------------

function Atr_ShpList_Options_Update(self, elapsed)

  if (Atr_ShpList_Options_Frame:IsShown()) then
    if (kShpLists_NeedUpdate or kShpLists_NumShpLists ~= #AUCTIONATOR_SHOPPING_LISTS) then
      kShpLists_NeedUpdate = false
      Atr_ShpLists_Display()
    end
  end
end

-----------------------------------------

function Atr_ShpLists_Display()

  local sllist = AUCTIONATOR_SHOPPING_LISTS

  kShpLists_NumShpLists = #AUCTIONATOR_SHOPPING_LISTS

  local totalRows = #sllist - 1;    -- minus Recents

  local line;             -- 1 through NN of our window to scroll
  local dataOffset;         -- an index into our data calculated from the scroll offset

  FauxScrollFrame_Update (Atr_ShpList_ScrollFrame, totalRows, kShpLists_LinesToDisplay, 16);

  for line = 1,kShpLists_LinesToDisplay do

    dataOffset = line + FauxScrollFrame_GetOffset (Atr_ShpList_ScrollFrame);

    local lineEntry = _G["Atr_ShpList"..line];

    lineEntry:SetID (dataOffset);

    if (dataOffset <= totalRows and sllist[dataOffset]) then

      local lineEntry_text = _G["Atr_ShpList"..line.."_text"];

      lineEntry_text:SetText (sllist[dataOffset+1].name)      -- +1 to skip Recents

      if (Atr_ShpLists_IsSelected (dataOffset) > 0) then
        lineEntry:SetButtonState ("PUSHED", true);
      else
        lineEntry:SetButtonState ("NORMAL", false);
      end

      lineEntry:Show();
    else
      lineEntry:Hide();
    end
  end

  zc.EnableDisable (Atr_ShpList_DeleteButton,   #kShpLists_SelectedIndices == 1);
  zc.EnableDisable (Atr_ShpList_EditButton,   #kShpLists_SelectedIndices == 1);
  zc.EnableDisable (Atr_ShpList_RenameButton,   #kShpLists_SelectedIndices == 1);
end

-----------------------------------------

function Atr_ShpLists_IsSelected (index)

  local n
  for n = 1,#kShpLists_SelectedIndices do
    if (kShpLists_SelectedIndices[n] == index) then
      return n
    end
  end

  return 0
end

-----------------------------------------

function Atr_ShpListsEntry_OnClick(self)

  index = self:GetID()

  if (IsControlKeyDown()) then

    local selectedIndexHint = Atr_ShpLists_IsSelected (index)

    if (selectedIndexHint == 0) then  -- not selected
      table.insert (kShpLists_SelectedIndices, index)
    else
      table.remove (kShpLists_SelectedIndices, selectedIndexHint)
    end

  else
    kShpLists_SelectedIndices = {}
    table.insert (kShpLists_SelectedIndices, index)
  end

  Atr_ShpLists_Display();
end

-----------------------------------------

function Atr_ShpListsEntry_OnDoubleClick(self)

  index = self:GetID()
  kShpLists_SelectedIndices = {}
  table.insert (kShpLists_SelectedIndices, index)

  Atr_ShpLists_Display();

  Atr_OnClick_ShpList_Edit()

end

-----------------------------------------

function Atr_ShpListsEntry_Select(index)

  kShpLists_SelectedIndices = {}

  table.insert (kShpLists_SelectedIndices, index - 1)   --  minus 1 for recents

  Atr_ShpLists_Display();

end

-----------------------------------------

function Atr_ShpListsEntry_ScrollToShow(index)


  index = index - 1

  local offset = FauxScrollFrame_GetOffset (Atr_ShpList_ScrollFrame)
  local newoffset

  if (index <= offset) then
    newoffset = index - 1
  elseif (index > offset + kShpLists_LinesToDisplay) then
    newoffset = index - kShpLists_LinesToDisplay
  end

  --zz ("index:", index, "offset:", offset, "newoffset:", newoffset)

  if (newoffset) then
    FauxScrollFrame_SetOffset (Atr_ShpList_ScrollFrame, newoffset)
    Atr_ShpList_ScrollFrame:SetVerticalScroll(newoffset*kShpLists_LineHeight);
  end
end

-----------------------------------------

local gShplistIndexToDelete

-----------------------------------------

StaticPopupDialogs["ATR_DEL_SHOPPING_LIST"] = {
  text = "",
  button1 = YES,
  button2 = NO,
  OnAccept = function(self)
    table.remove (AUCTIONATOR_SHOPPING_LISTS, gShplistIndexToDelete);
    Atr_ShpList_SetToRecents()
    kShpLists_SelectedIndices = {}
    Atr_SetUINeedsUpdate()
    kShpLists_NeedUpdate = true
    return
  end,
  OnShow = function(self)
    local name = AUCTIONATOR_SHOPPING_LISTS[gShplistIndexToDelete].name
    local s = string.format (ZT("Really delete the shopping list %s ?"), ": \n\n"..name);
    self.text:SetText("\n"..s.."\n\n");
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
};

-----------------------------------------

function Atr_OnClick_ShpList_Delete(self)

  if (#kShpLists_SelectedIndices == 1) then
    gShplistIndexToDelete = kShpLists_SelectedIndices[1] + 1    -- +1 to skip over Recents

    local dialog = StaticPopup_Show("ATR_DEL_SHOPPING_LIST")
  end
end

-----------------------------------------

local gShplistIndexToRename

-----------------------------------------

StaticPopupDialogs["ATR_RENAME_SHOPPING_LIST"] = {
  text = "New name for this list",
  button1 = OKAY,
  button2 = CANCEL,
  OnAccept = function(self)
    Atr_RenameSList (gShplistIndexToRename, self.editBox:GetText())
    Atr_ShpLists_Display()
  end,
  OnShow = function(self)
    local name = AUCTIONATOR_SHOPPING_LISTS[gShplistIndexToRename].name
    self.editBox:SetText(name)
  end,
  EditBoxOnEnterPressed = function(self)
----    local text = self:GetParent().editBox:GetText()
--    colHeading:SetText(text)
--    self:GetParent():Hide()
  end,
  hasEditBox = 1,
  timeout = 0,
  exclusive = 1,
  hideOnEscape = 1
};
-----------------------------------------

function Atr_OnClick_ShpList_Rename(self)

  if (#kShpLists_SelectedIndices == 1) then
    gShplistIndexToRename = kShpLists_SelectedIndices[1] + 1    -- +1 to skip over Recents

    local dialog = StaticPopup_Show("ATR_RENAME_SHOPPING_LIST")
  end
end

-----------------------------------------

local gShplistIndexToEdit

-----------------------------------------

function Atr_OnClick_ShpList_Edit()

  if (#kShpLists_SelectedIndices == 1) then
    gShplistIndexToEdit = kShpLists_SelectedIndices[1] + 1    -- +1 to skip over Recents
  end

  local n
  local text = ""

  local slist = AUCTIONATOR_SHOPPING_LISTS[gShplistIndexToEdit]

  for n = 1, #slist.items do
    if (n > 1) then
      text = text.."\n"
    end
    text = text..slist.items[n]
  end

  Atr_ShpList_SaveBut:Show()
  Atr_ShpList_SelectAllBut:Hide()
  Atr_ShpList_ImportSaveBut:Hide()

  Atr_ShpList_Explanation:SetText("")

  Atr_ShpList_Edit_Name:SetText(slist.name)

  Atr_ShpList_Edit_Text:SetSpacing(3)
  Atr_ShpList_Edit_Text:SetPoint ("TOPLEFT", 0, -20)

  Atr_ShpList_Edit_Text:SetText(text)

  Atr_ShpList_Edit_Frame:Show()

  Atr_ShpList_Edit_Text:SetFocus()
  Atr_ShpList_Edit_Text:HighlightText(0,0)

end

-----------------------------------------

function Atr_ShpList_Edit_Save()

  local slist = AUCTIONATOR_SHOPPING_LISTS[gShplistIndexToEdit]

  slist.items = {}

  local text  = Atr_ShpList_Edit_Text:GetText()
  local lines = { strsplit("\n", text) }

  if (lines ~= nil) then
    local n
    for n = 1,#lines do
      slist:AddItem (strtrim(lines[n]))
    end
  end

  Atr_DisplaySlist()

  Atr_ShpList_Edit_Frame:Hide()

  gShplistIndexToEdit = nil

end


-----------------------------------------

function Atr_OnClick_ShpList_New(self)

  Atr_NewSlist_OnClick()
end

-----------------------------------------

function Atr_SList_Conflict_SetRB (self, text)
  local tx = _G[self:GetName().."Text"]

  tx:SetWidth(260);
  tx:SetJustifyH ("LEFT")
  tx:SetText (text)
  tx:SetFontObject ("GameFontNormal")
end

-----------------------------------------

function Atr_OnClick_ShpList_Import()

  Atr_ShpList_SaveBut:Hide()
  Atr_ShpList_SelectAllBut:Hide()
  Atr_ShpList_ImportSaveBut:Show()

  Atr_ShpList_Explanation:SetText("Paste text that was previously exported into the text area to the left.")

  Atr_ShpList_Edit_Name:SetText("Import")

  Atr_ShpList_Edit_Text:SetText("")
  Atr_ShpList_Edit_Text:SetSpacing(3)
  Atr_ShpList_Edit_Text:SetPoint ("TOPLEFT", 0, -20)

  Atr_ShpList_Edit_Frame:Show()

  Atr_ShpList_Edit_Text:SetFocus()

end

-----------------------------------------

function Atr_ShpList_Edit_ImportSave()

  local text  = Atr_ShpList_Edit_Text:GetText()

  local lines = { strsplit("\n", text) }

  local existingListNames_Text = ""
  local existingListNames_Num  = 0

  local itemCount = 0

  if (lines ~= nil) then
    local n
    for n = 1,#lines do
      local line = strtrim(lines[n])

      if (zc.StringStartsWith(line, "***")) then
        itemCount = 0

        line = strtrim (line, "*")
        line = strtrim (line)
        if (Atr_SList.FindByName (line)) then
          existingListNames_Num = existingListNames_Num + 1
          if (existingListNames_Num < 4) then
            existingListNames_Text = existingListNames_Text..line.."\n"
          elseif (existingListNames_Num == 4) then
            existingListNames_Text = existingListNames_Text.."and others..."
          end
        end
      elseif (line ~= "") then
        itemCount = itemCount + 1
        if (itemCount > ATR_MAXNUM_ITEMS_ON_SHOPPING_LIST) then
          Atr_Error_Display (ZT("Import failed.").."\n\n"..string.format(ZT("Shopping lists may have at\nmost %d items."), ATR_MAXNUM_ITEMS_ON_SHOPPING_LIST))
          return
        end
      end
    end
  end

  if (existingListNames_Num > 0) then
    Atr_SList_Conflict_OKAY:Disable ()
    Atr_SList_Conflict_Names:SetText (existingListNames_Text)
    Atr_SList_Conflict_ResetRadioButs()
    Atr_SList_Conflict_Frame:Show()
    return
  end

  Atr_SList_ImportCore (false)
end

-----------------------------------------

function Atr_SList_ImportCore (doOverwrite)

  local text  = Atr_ShpList_Edit_Text:GetText()

  local lines = { strsplit("\n", text) }

  if (lines ~= nil) then
    local n, slist
    for n = 1,#lines do
      local line = strtrim(lines[n])

      if (zc.StringStartsWith(line, "***")) then
        line = strtrim (line, "*")
        line = strtrim (line)
        slist = Atr_SList.FindByName (line)
        if (slist) then
          if (doOverwrite) then
            slist:Clear()
            zc.msg_anm ("Shopping list overwritten:", line)
          else
            local newname
            local x
            for x = 1,100 do
              newname = line..x
              if (not Atr_SList.FindByName (newname)) then
                break
              end
            end
            slist = Atr_SList.create (newname)
            zc.msg_anm ("Shopping list created:", newname)
          end
        else
          slist = Atr_SList.create (line)
          zc.msg_anm ("Shopping list created:", line)
        end
      else
        if (slist) then
          slist:AddItem (line)
        end
      end
    end
  end

  Atr_ShpList_Edit_Frame:Hide()

end

-----------------------------------------

function Atr_SList_Conflict_OKAY_OnClick(self)

  if (Atr_SList_Conflict_CreateNew:GetChecked()) then
    Atr_SList_ImportCore (false)
  elseif (Atr_SList_Conflict_Overwrite:GetChecked()) then
    Atr_SList_ImportCore (true)
  end

  Atr_SList_Conflict_Frame:Hide()
end

-----------------------------------------

function Atr_SList_Conflict_ResetRadioButs()

  Atr_SList_Conflict_CreateNew:SetChecked (false);
  Atr_SList_Conflict_Overwrite:SetChecked (false);
  Atr_SList_Conflict_Abort:SetChecked (false);

end

-----------------------------------------

function Atr_SList_Conflict_OnClick(self)

  Atr_SList_Conflict_ResetRadioButs()

  self:SetChecked (true);

  Atr_SList_Conflict_OKAY:Enable ()
end

--[[

*** Ethereal Ink
Ancient Lichen
Dreaming Glory
Felweed
Netherbloom
Nightmare vine
Ragveil
Terocone

*** Celestial Ink
Arthas' tears
Blindweed
Firebloom
Ghost Mushroom
Gromsblood
Purple Lotus
Sungrass
Violet Pigment
]]--
-----------------------------------------

function Atr_ShpList_Export_GetText(slist)

  local text  = "\n*** "..slist.name.."\n"

  for x = 1, #slist.items do
    text = text..slist.items[x].."\n"
  end

  return text
end

-----------------------------------------

function Atr_OnClick_ShpList_Export(self)

  local n, x
  local text = ""

  for n = 1,#kShpLists_SelectedIndices do

    local index = kShpLists_SelectedIndices[n] + 1

    text = text..Atr_ShpList_Export_GetText (AUCTIONATOR_SHOPPING_LISTS[index])
  end

  Atr_ShpList_SaveBut:Hide()
  Atr_ShpList_SelectAllBut:Show()
  Atr_ShpList_ImportSaveBut:Hide()

  Atr_ShpList_Explanation:SetText("Click Select All, type Ctrl-C to copy the text and then paste into any text document.")

  Atr_ShpList_Edit_Name:SetText("Export")

  Atr_ShpList_Edit_Text:SetSpacing(3)
  Atr_ShpList_Edit_Text:SetPoint ("TOPLEFT", 0, -20)

  Atr_ShpList_Edit_Text:SetText(text)

  Atr_ShpList_Edit_Frame:Show()

end

-------------------------------------------------------------------------------------------------------


-----------------------------------------

function Atr_MakeOptionsFrameOpaque ()

  local bd = { bgFile="Interface/RAIDFRAME/UI-RaidFrame-GroupBg",
         edgeFile="Interface/DialogFrame/UI-DialogBox-Border",
         tile=false, edgeSize=32,
         insets={left=11,right=11,top=10,bottom=10}
        };

  local list_bd = {
          bgFile="Interface/CharacterFrame/UI-Party-Background",
          tile=true,
          insets={left=5,right=5,top=5,bottom=5}
          }

  InterfaceOptionsFrame:SetBackdrop ( bd );
  InterfaceOptionsFrameAddOns:SetBackdrop ( list_bd );
  InterfaceOptionsFrameCategories:SetBackdrop ( list_bd );
end

-----------------------------------------

local gInterfaceOptionsMask;

-----------------------------------------

function ShowInterfaceOptionsMask()

  if (gInterfaceOptionsMask == nil) then
    gInterfaceOptionsMask = CreateFrame ("Frame", "Atr_Mask_StdOptions", _G["InterfaceOptionsFrame"], "Atr_Mask_StdOptionsTempl");
    gInterfaceOptionsMask:SetFrameLevel (129);
  end

  gInterfaceOptionsMask:Show();

end

-----------------------------------------

function HideInterfaceOptionsMask()
  if (gInterfaceOptionsMask) then
    gInterfaceOptionsMask:Hide();
  end
end


