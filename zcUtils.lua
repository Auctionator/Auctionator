-- Zirco's utilities
-- This module should contain no globals as it is intended to be "linked" in to each of Zirco's addons

local addonName, addonTable = ...;
local zc = addonTable.zc or {};
local _

addonTable.zc = zc;

-----------------------------------------

function zc.words(str)
  local t = {}
  local function helper(word) table.insert(t, word) return "" end
  if (not str:gsub("[^%s]+", helper):find"%S") then
    if (#t == 1) then return t[1]; end;
    if (#t == 2) then return t[1],t[2]; end;
    if (#t == 3) then return t[1],t[2],t[3]; end;
    if (#t == 4) then return t[1],t[2],t[3],t[4]; end;
    if (#t == 5) then return t[1],t[2],t[3],t[4],t[5]; end;
    return t;
  end
end

-----------------------------------------

function zc.round (v)
  return math.floor (v + 0.5);
end

-----------------------------------------

function zc.val2gsc (v)
  local rv = zc.round(v)

  local g = math.floor (rv/10000);

  rv = rv - g*10000;

  local s = math.floor (rv/100);

  rv = rv - s*100;

  local c = rv;

  return g, s, c
end

-----------------------------------------

local goldicon    = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:4:0|t"
local silvericon  = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t"
local coppericon  = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t"

-----------------------------------------

function zc.priceToMoneyString (val, noZeroCoppers)

  local gold, silver, copper  = zc.val2gsc(val);

  local st = "";

  if (gold ~= 0) then
    st = gold..goldicon.."  ";
  end


  if (st ~= "") then
    st = st..format("%02i%s  ", silver, silvericon);
  elseif (silver ~= 0) then
    st = st..silver..silvericon.."  ";
  end

  if (noZeroCoppers and copper == 0) then
    return st;
  end

  if (st ~= "") then
    st = st..format("%02i%s", copper, coppericon);
  elseif (copper ~= 0) then
    st = st..copper..coppericon;
  end

  return st;

end
