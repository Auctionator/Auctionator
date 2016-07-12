
local addonName, addonTable = ...;
local zc = addonTable.zc;
local zz = zc.md
local _

-----------------------------------------

local ztt = {}

addonTable.ztt = ztt;

-----------------------------------------

function ztt.ZT (s)

  if (s == nil or s == "") then
    return s;
  end

  if (AtrL) then
    local s1 = AtrL[s];
    if (s1 and s1 ~= "" and not zc.StringStartsWith ("XXXXX")) then
      return s1;
    end
  end

  return s;
end


-----------------------------------------

local ZT = addonTable.ztt.ZT;

gAtr_ZT = addonTable.ztt.ZT;

AtrL = {};

-----------------------------------------

function Atr_PickLocalizationTable (locale)

  local f = _G["AtrBuildLTable_"..locale];
  if (type (f) == "function") then
    f();
--    DEFAULT_CHAT_FRAME:AddMessage (locale.." found");
  else
    AtrBuildLTable_enUS();
--    DEFAULT_CHAT_FRAME:AddMessage (locale.." not found");
  end

end

-----------------------------------------

Atr_PickLocalizationTable (GetLocale());
--Atr_PickLocalizationTable ("esES");


-----------------------------------------

function zc.IsEnglishLocale()

  return (GetLocale() == "enUS" or GetLocale() == "enGB");

end

-----------------------------------------

local testt = {};
local Atr_excludes = { Cancel=1, Okay=1, Done=1, Close=1 }

-----------------------------------------

local function Atr_LocalizeChildText (frame)
  if ( Atr_IsAuctionatorFrame( frame ) ) then

    local child;
    local subregions = { frame:GetRegions() };
    for _, child in ipairs(subregions) do

      if  (type (child.GetText) == "function") then
        local ftext = child:GetText();
        local fname = tostring(child:GetName());

        if (ftext and ftext ~= "" and not Atr_excludes[ftext] and not zc.StringStartsWith (fname, "AuctionatorEntry")) then
          testt[ftext] = 1;
          child:SetText (ZT(ftext));
        end
      end
    end

    local kids = { frame:GetChildren() };
    for _, child in ipairs(kids) do

      if  (type (child.GetText) == "function") then
        local ftext = child:GetText();
        local fname = tostring(child:GetName());

        if (ftext and ftext ~= "" and not Atr_excludes[ftext] and not zc.StringStartsWith (fname, "AuctionatorEntry")) then
          testt[ftext] = 1;

          if (child:GetObjectType() == "Button") then
            local oldwid = math.floor(child:GetWidth());
            child:SetText (ZT(ftext));
            local newwid = math.floor(child:GetTextWidth()) + 15;
            if (newwid > oldwid) then
              child:SetWidth (newwid+20);
            end
          else
            child:SetText (ZT(ftext));
          end
        end
      end

      if (child:GetObjectType() ~= "Button") then
        Atr_LocalizeChildText (child);
      end
    end
  end
end

-----------------------------------------

function Atr_LocalizeFrames()
  Auctionator.Debug.Message( 'Atr_LocalizeFrames' )

  local frame = EnumerateFrames()

  while frame do
    Atr_LocalizeChildText( frame );
    frame = EnumerateFrames( frame )
  end
end

function Atr_IsAuctionatorFrame( frame )
  if ( Atr_FrameIsAccessible(frame) ) then
    local frame_name = frame:GetName()
    local parent_name = frame:GetParent() and frame:GetParent():GetName() or nil

    return frame_name == "Atr_Main_Panel" or
      ( zc.StringSame (parent_name, "UIParent") and Atr_IsAuctionatorFrameName(frame_name) )
  else
    return false
  end
end

function Atr_FrameIsAccessible( frame )
  if ( not frame:IsForbidden() ) then
    local parent_frame = frame:GetParent()

    if ( parent_frame ) then
      return not parent_frame:IsForbidden()
    end
  end

  return false
end

function Atr_IsAuctionatorFrameName( frame_name )
  return zc.StringStartsWith( frame_name, "Atr" ) or
    zc.StringStartsWith( frame_name, "Auctionator" )
end

-----------------------------------------

local kUncutGems = {
  36924,    -- sky sapphire
  36925,    -- majestic zircon
  52178,    -- zephyrite
  52191,    -- ocean sapphire

  36918,    -- scarlet ruby
  36919,    -- cardinal ruby
  52177,    -- carnelian
  52190,    -- inferno ruby

  36933,    -- forest emerald
  36934,    -- eye of zul
  52182,    -- jasper
  52192,    -- dream emerald

  36930,    -- monarch topaz
  36931,    -- ametrine
  52181,    -- hessonite
  52193,    -- ember topaz

  36927,    -- twilight opal
  36928,    -- dreadstone
  52180,    -- nightstone
  52194,    -- demonseye

  36921,    -- autumns glow
  36922,    -- kings amber
  52179,    -- alicite
  52195,    -- amberjewel

  41334,    -- earthsiege diamond
  41266,    -- skyflare diamond
  52303,    -- shadowspirit diamond

  42225,    -- dragon's eye
  52196,    -- chimera's eye

  115524    -- taladite crystal
  }

-----------------------------------------

function Atr_IsCutGem (itemLink)

  if (not Atr_IsGem (itemLink)) then
    return false;
  end

  local itemID = zc.RawItemIDfromLink (itemLink);

  for n = 1, #kUncutGems do
    if (itemID == tostring (kUncutGems[n])) then
      return false;
    end
  end

  return true;
end

function Atr_IsWeaponType( classID )
  -- Auctionator.Debug.Message( 'Atr_IsWeaponType', classID )
  return classID == LE_ITEM_CLASS_WEAPON
end

function Atr_IsArmorType( classID )
  -- Auctionator.Debug.Message( 'Atr_IsArmorType', classID )
  return classID == LE_ITEM_CLASS_ARMOR
end

function Atr_IsBattlePetType( classID )
  -- Auctionator.Debug.Message( 'Atr_IsBattlePetType', classID )
  return classID == LE_ITEM_CLASS_BATTLEPET
end

function Atr_IsGlyph( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_GLYPH )
end

function Atr_IsGem( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_GEM )
end

function Atr_IsItemEnhancement( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_ITEM_ENHANCEMENT )
end

function Atr_IsPotion( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_CONSUMABLE, Auctionator.Constants.SubClasses.ITEM_CLASS_POTION )
end

function Atr_IsElixir( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_CONSUMABLE, Auctionator.Constants.SubClasses.ITEM_CLASS_ELIXIR )
end

function Atr_IsFlask( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_CONSUMABLE, Auctionator.Constants.SubClasses.ITEM_CLASS_FLASK )
end

function Atr_IsHerb( itemLink )
  return Atr_IsClass( itemLink, LE_ITEM_CLASS_TRADEGOODS, Auctionator.Constants.SubClasses.ITEM_CLASS_HERB )
end

-----------------------------------------

function Atr_IsClass( itemLink, classID, subClassID )
  -- TODO: Would love to get rid of passing nil around... where can itemLink be nil from?
  if itemLink == nil then
    return false
  end

  local _, _, _, _, _, _, _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfo( itemLink )

  return classID == itemClassID and ( subClassID == nil or subClassID == itemSubClassID )
end

-----------------------------------------

local gItemClasses;
local gItemSubClasses;

-----------------------------------------

function Atr_GetAuctionClasses()
  return Auctionator.Constants.ItemClasses
end

-----------------------------------------

function Atr_GetAuctionSubclasses (auctionClass)

  if (gItemSubClasses == nil) then
    gItemSubClasses = {};
  end

  if (gItemSubClasses[auctionClass] == nil) then
    gItemSubClasses[auctionClass] = { GetAuctionItemSubClasses(auctionClass) };
  end

  return gItemSubClasses[auctionClass];
end

-----------------------------------------

function Atr_ItemType2AuctionClass(itemType)
  Auctionator.Debug.Message( 'Atr_ItemType2AuctionClass', itemType )

  local itemClasses = { Atr_GetAuctionClasses() }

  if #itemClasses > 0 then
  local itemClass;
    for x, itemClass in pairs(itemClasses) do
      if (zc.StringSame (itemClass, itemType)) then
        return x;
      end
    end
  end

  return 0;
end


-----------------------------------------

function Atr_SubType2AuctionSubclass(auctionClass, itemSubtype)

  local subclasses = Atr_GetAuctionSubclasses (auctionClass);

  if #subclasses > 0 then
  local itemSubClass;
    for x, itemSubClass in pairs(subclasses) do
      if (zc.StringSame (itemSubClass, itemSubtype)) then
        return x;
      end
    end
  end

  return 0;
end


