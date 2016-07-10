-- Zirco's utilities
-- This module should contain no globals as it is intended to be "linked" in to each of Zirco's addons

local addonName, addonTable = ...;
local zc = {};
local _

addonTable.zc = zc;

-----------------------------------------

function zc.RGBtoHEX (r,g,b)

  local hex = "";

  return string.format ("%02x%02x%02x", r * 255, g * 255, b * 255);

end

-----------------------------------------

function zc.EnableDisable (elem, b)

  if (b) then
    elem:Enable();
  else
    elem:Disable();
  end
end

-----------------------------------------

function zc.ShowHide (elem, b)

  if (b) then
    elem:Show();
  else
    elem:Hide();
  end
end

-----------------------------------------

function zc.SetTextIf (elem, b, t1, t2)

  if (b) then
    elem:SetText(t1);
  else
    elem:SetText(t2);
  end
end

-----------------------------------------

function zc.Val (val, ifNilVal)

  if (val == nil) then
    return ifNilVal;
  end

  return val;
end

-----------------------------------------

function zc.ToNumberVal (val)

  if (val == nil) then
    return 0;
  end

  return tonumber(val);
end

-----------------------------------------

function zc.Min (a, b)

  if (a == nil) then
    return b;
  end

  if (b == nil) then
    return a;
  end

  return math.min (tonumber (a), tonumber (b));
end

-----------------------------------------

function zc.Max (a, b)

  if (a == nil) then
    return b;
  end

  if (b == nil) then
    return a;
  end

  return math.max (tonumber (a), tonumber (b));
end

-----------------------------------------

function zc.If (b, x, y)

  if (b ~= nil and b ~= false) then
    return x;
  end

  return y;
end

-----------------------------------------

function zc.PrintKeysSorted (t)

  local ta = {};

  for a,v in pairs (t) do
    table.insert (ta, a);
  end

  table.sort (ta, function (a,b) return (a:lower() < b:lower()); end);

  for x = 1, #ta do
    zc.msg_pink (x.."   "..ta[x]);
  end

end

-----------------------------------------

function zc.GetArrayElemOrFirst (a, x)

  if (a and #a > 0) then
    if (x == nil or x < 1 or x > #a) then
      x = 1;
    end

    return a[x];
  end

  return nil;
end

-----------------------------------------

function zc.GetArrayElemOrNil (a, x)

  if (a and #a > 0) then
    if (x == nil or x < 1 or x > #a) then
      return nil;
    end

    return a[x];
  end

  return nil;
end

-----------------------------------------

function zc.padstring (s, n, c)
  while (string.len (s) < n) do
    s = c..s;
  end

  return s;
end


-----------------------------------------

local encTable = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
          "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
          "0","1","2","3","4","5","6","7","8","9",
          "-", "_" };


local decTable;

-----------------------------------------

local function BuildDecTable()

  if (decTable == nil) then
    decTable = {};
    local i;
    for i = 1,64 do
      decTable[encTable[i]] = i-1;
    end
  end

end

-----------------------------------------

function zc.enc64 (n)

  if (n == 0) then
    return encTable[1];
  end

  local k = n;
  local x;
  local result = "";

  while k ~= 0 do
    x = bit.band (k, 63);
    result = encTable[x+1]..result;
    k = bit.rshift (k, 6);
  end

  return result;
end

-----------------------------------------

function zc.dec64 (s)

  if (s == nil or s == "") then
    return 0;
  end

  BuildDecTable();

  local result = 0;
  local len = string.len (s);
  local x;

  for x = 1, len do
    result = result * 64;
    result = result + decTable[string.sub(s,x,x)];
  end

  return result;
end

-----------------------------------------

--[[
function ZF (s)
  BuildDecTable();

  local s2 = "";
  local n;

  for n = 1, s:len() do
    local c = s:sub(n,n);
    local x = decTable[c];

    if (x == nil) then
      s2 = s2..c;
    else
      if    (x < 32) then x = x + 32;
      else  x = x - 32;
      end;
      s2 = s2..encTable[x+1];
    end
  end

  return s2;

end
]]--

-----------------------------------------

function zc.words(str)
  local t = {}
  local function helper(word) table.insert(t, word) return "" end
  if (not str:gsub("%w+", helper):find"%S") then
    if (#t == 1) then return t[1]; end;
    if (#t == 2) then return t[1],t[2]; end;
    if (#t == 3) then return t[1],t[2],t[3]; end;
    if (#t == 4) then return t[1],t[2],t[3],t[4]; end;
    if (#t == 5) then return t[1],t[2],t[3],t[4],t[5]; end;
    return t;
  end
end

-----------------------------------------

local gDeferredCalls = {};

-----------------------------------------

function zc.AddDeferredCall (seconds, funcname, param1, param2, tag)  -- tag is optional.  if present used to overwrite prior call with same tag

  local now = time();

  local cfdEntry = {};

  cfdEntry.funcname = funcname;
  cfdEntry.param1   = param1;
  cfdEntry.param2   = param2;
  cfdEntry.when   = now + seconds;
  cfdEntry.tag    = "";

  if (tag) then
    cfdEntry.tag = tag;

    for i = 1, #gDeferredCalls do
      if (gDeferredCalls[i].tag == tag) then
        gDeferredCalls[i] = cfdEntry;   -- overwrite
        return;
      end
    end
  end

  table.insert (gDeferredCalls, cfdEntry);
end


-----------------------------------------

function zc.CheckDeferredCall ()

  local now = time();
  local i;

  for i = 1, #gDeferredCalls do
    if (gDeferredCalls[i].when < now) then
      local fcn = _G[gDeferredCalls[i].funcname];
      local p1 = gDeferredCalls[i].param1;
      local p2 = gDeferredCalls[i].param2;
      table.remove (gDeferredCalls, i);
      if (type(fcn) == 'function') then
        fcn(p1, p2);
      end

      return;   -- only do one
    end
  end

end

-----------------------------------------

function zc.periodic (elem, name, period, elapsed)

  local t = elem[name] or 0;

  t = t + elapsed;

  if (t > period) then
    elem[name] = 0;
    return true;
  end

  elem[name] = t;
  return false;
end


-----------------------------------------

function zc.tableIsEmpty (t)

  local n, v;
  for n, v in pairs (t) do
    return false;
  end

  return true;
end

-----------------------------------------

function zc.PrintTable (t, indent, norecurse)

  if (not indent) then
    indent = 0;
  end

  local x
  local padding = "";
  for x = 1,indent do
    padding = padding.."  ";
  end

  zc.msg ("-------");

  if (t == nil) then
    zc.msg (padding, "<nil>");
    return;
  end

  for n, v in pairs (t) do
    if (type(v) == "table") then
      zc.msg (padding..n, "TABLE");
      if (not norecurse) then
        zc.PrintTable(v, indent+1);
      end
    elseif (type(v) == "userdata") then
      zc.msg (padding..n, "userdata");
    else
      zc.msg (padding..n, v);
    end
  end

end

-----------------------------------------

function zc.IsBattlePetLink (itemLink)

--zc.msg (zc.printableLink (itemLink));
  return zc.StringContains (itemLink, "Hbattlepet:");
end

-----------------------------------------

function zc.ParseBattlePetLink (itemLink)

  local _, speciesID, level, breedQuality, maxHealth, power, speed, other = strsplit(":", itemLink)

  --local name = string.gsub(string.gsub(itemLink, "^(.*)%[", ""), "%](.*)$", "");

  local battlePetID, name, c, d, e = strsplit ("|", other);

  --zc.msg ( "other:", zc.printableLink(other), "bpid:", battlePetID, "name: ", name, "C", c, "d", d, "e", e)
--zc.msg ("name: ", name);

  name = string.sub (name, 2, string.len(name))

  name = zc.TrimBrackets (name);

  return tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), battlePetID, name

end
-----------------------------------------

function zc.RawItemIDfromLink (itemLink)

  local found, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
  local _, itemId = strsplit(":", itemString)

  return itemId
end

-----------------------------------------

function zc.ItemNamefromLink (itemLink)

  if (itemLink == nil) then
    return "", false;
  end

  if (zc.IsBattlePetLink (itemLink)) then
    local speciesID, level, breedQuality, maxHealth, power, speed, battlePetID, name = zc.ParseBattlePetLink(itemLink)

    return name, true;
  else
    local name = GetItemInfo (itemLink)
    return name, false;
  end

  return "", false
end

-----------------------------------------

function zc.LinkFromItemID (itemID, suffixID)   -- only works if item is already in memory

  if (suffixID == nil) then
    suffixID = 0;
  end

  local itemString = "item:"..itemID..":0:0:0:0:0:"..suffixID..":0";

  local _, itemLink = GetItemInfo(itemString);

  return itemLink
end

-----------------------------------------

function zc.PullItemIntoMemory (itemID, suffixID)

  if (suffixID == nil) then
    suffixID = 0;
  end

  local itemString = "item:"..itemID..":0:0:0:0:0:"..suffixID..":0";

  local _, itemLink = GetItemInfo(itemString);

  if (itemLink == nil) then
    AtrScanningTooltip2:SetHyperlink(itemString);
    _, itemLink = GetItemInfo(itemString);
--    zc.md ("pulling into memory:  ", itemString);
  end

  return itemLink;
end


-----------------------------------------

function zc.BoolToString (b)
  if (b) then
    return "true";
  end

  return "false";
end

-----------------------------------------

function zc.BoolToNum (b)
  if (b) then
    return 1;
  end

  return 0;
end

-----------------------------------------

function zc.NumToBool (n)
  if (n == 0) then
    return false;
  end

  return true;
end

-----------------------------------------

function zc.Negate (b)  -- handles false or nil

  if (b) then
    return false
  end

  return true
end

-----------------------------------------

function zc.pluralizeIf (word, count)

  if (count and count == 1) then
    return word;
  else
    return zc.pluralize(word);
  end
end

-----------------------------------------

function zc.pluralize (word)

  return word.."s";

end

-----------------------------------------

function zc.round (v)
  return math.floor (v + 0.5);
end

-----------------------------------------

function zc.msg_red (...)   zc.msg_color (1,  0,  0, ...);  end
function zc.msg_pink (...)    zc.msg_color (1, .6, .6, ...);  end
function zc.msg_yellow (...)    zc.msg_color (1,  1,  0, ...);  end

-----------------------------------------

function zc.msg_color (r, g, b, ...)

  local options = {};
  options.r = r;
  options.g = g;
  options.b = b;

  zc.msg_ex (options, ...);
end


-----------------------------------------

function zc.msg_str (...)

  local options = {};
  options.str = true;

  return zc.msg_ex (options, ...);
end

-----------------------------------------

function zc.msg_anm (...)

  zc.msg_yellow ("|cff00ffff<"..addonName..">|r", ...);
end

-----------------------------------------

function zc.msg_badErr (...)

  zc.msg_red ("|cff00ffff<"..addonName..">|r", ...);
end


-----------------------------------------

function zc.HSV2RGB (h, s, v)

  local r, g, b;

  local hi = math.floor(h/60) % 6;
  local f  = h/60 - math.floor(h/60);
  local p  = v * (1-s);
  local q  = v * (1-(f*s));
  local t  = v * (1-((1-f)*s));

  if (hi == 0) then return v, t, p;     end
  if (hi == 1) then return q, v, p;     end
  if (hi == 2) then return p, v, t;     end
  if (hi == 3) then return p, q, v;     end
  if (hi == 4) then return t, p, v;     end
  if (hi == 5) then return v, p, q;     end

  return
end

-----------------------------------------

function zc.md (...)

  if (Atr_IsDev) then

    local funcnames = zc.printstack ( { silent=true } );

    local fname = "???"
    local aname = "???"

--    if (funcnames[2]) then
--      fname = string.lower (funcnames[2]);
--    else

    if (funcnames[1]) then
      fname = string.lower (funcnames[1]);
    end

    if (fname == "md" and funcnames[2]) then
      fname = string.lower (funcnames[2]);
    end

    if (zc.StringStartsWith (fname, "oym_", "atr_", "eqx_")) then
      aname = fname:sub (0,4)
      fname = fname:sub (5);
    else
      aname = addonName:sub(0,3)..":";
    end

    local color = "ffffff";

    local n = fname:len();

    if (n > 3) then

      local x = fname:byte(math.floor (n/2)) - string.byte("a");
      local y = fname:byte(n) - string.byte("a");

      local hue = 0;
      if (x > 0) then
        hue = math.floor ( (x/26) * 360 );
      end

      local sat = 0.5;
      if (y > 0) then
        sat = 0.3 + (y/26) * 0.7;
      end

      local r, g, b = zc.HSV2RGB (hue, sat, 1);

      r = math.floor (r * 255);
      g = math.floor (g * 255);
      b = math.floor (b * 255);

--      zc.msg (hue, sat, r, g, b);
      color = string.format ("%02x%02x%02x", r, g, b);
    end

    zc.msg ("|cffff33ff<"..aname.."|cff"..color..fname.."|cff00ffff>|r", ...);
  end
end

-----------------------------------------

function zc.msg (...)

  local options = {};

  zc.msg_ex (options, ...);
end

-----------------------------------------

function zc.msg_ex (options, ...)

  if (not DEFAULT_CHAT_FRAME) then
    return;
  end

  local msg = "";

  local i, m;
  local num = select("#", ...);

  for i = 1, num do

    local v = select (i, ...);

    if    (type(v) == "boolean")  then  m = zc.BoolToString(v);
    elseif  (type(v) == "table")  then  m = "<table>";
    elseif  (type(v) == "function") then  m = "<function>";
    elseif  (v == nil)        then  m = "<nil>";
    else                  m = v;
    end

    msg = msg.." "..m;

  end

  if (options.str) then
    return msg;
  end

  if (options.r ~= nil) then
    DEFAULT_CHAT_FRAME:AddMessage (msg, options.r, options.g, options.b);
  else
    DEFAULT_CHAT_FRAME:AddMessage (msg);
  end
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

function zc.priceToString (val)

  local gold, silver, copper  = zc.val2gsc(val);

  local st = "";


  if (gold ~= 0) then
    st = gold.."g ";
  end


  if (st ~= "") then
    st = st..format("%02is ", silver);
  elseif (silver ~= 0) then
    st = st..silver.."s ";
  end


  if (st ~= "") then
    st = st..format("%02ic", copper);
  elseif (copper ~= 0) then
    st = st..copper.."c";
  end

  return st;
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

-----------------------------------------

function zc.StringSame (s1, s2)
  if (s1 == nil and s2 == nil) then
    return true;
  end

  if (s1 == nil or s2 == nil) then
    return false;
  end

  if (s1 == s2) then    -- maybe will fix german umlaut problem?
    return true;
  end

  return (string.lower (s1) == string.lower (s2));
end

-----------------------------------------

function zc.StringContains (s, sub, ...)
  if (s == nil or sub == nil or sub == "") then
    return false;
  end

  local start, stop = string.find (string.lower(s), string.lower(sub), 1, true);

  local found = (start ~= nil);

  if (found or select("#", ...) == 0) then
    return found;
  end

  return zc.StringContains (s, ...);
end

-----------------------------------------

function zc.StringEndsWith (s, sub)

  if (s == nil or sub == nil or sub == "") then
    return false;
  end

  local i = string.len(s) - string.len(sub);

  if (i < 0) then
    return false;
  end

  local sEnd = string.sub (s, i+1);

  return (string.lower (sEnd) == string.lower (sub));

end

-----------------------------------------

function zc.StringStartsWith (s, sub, ...)

  if (s == nil or sub == nil or sub == "") then
    return false;
  end

  local sublen = string.len (sub);

  local found = false;

  if (string.len (s) >= sublen) then
    found = (string.lower (string.sub(s, 1, sublen)) == string.lower(sub));
  end

  if (found or select("#", ...) == 0) then
    return found;
  end

  return zc.StringStartsWith (s, ...);

end

-----------------------------------------

function zc.IsTextQuoted (s)
  return (zc.StringStartsWith (s, "\"") and zc.StringEndsWith (s, "\""))

end

-----------------------------------------

function zc.QuoteString (s)

  if (zc.IsTextQuoted(s)) then
    return s
  end

  return ("\""..s.."\"")

end

-----------------------------------------

function zc.TrimQuotes (s)

  local start = 1
  local last  = string.len(s)

  if (last > 1) then
    if (s:sub(1,1) == "\"") then
      start = 2
    end
    if (s:sub(last,last) == "\"") then
      last = last-1
    end
  end

  return string.sub (s, start, last)

end

-----------------------------------------

function zc.TrimBrackets (s)

  local start = 1
  local last  = string.len(s)

  if (last > 1) then
    if (s:sub(1,1) == "[") then
      start = 2
    end
    if (s:sub(last,last) == "]") then
      last = last-1
    end
  end

  return string.sub (s, start, last)

end

-----------------------------------------

function zc.ClearTable (t)

  for n, v in pairs (t) do
    t[n] = nil
  end
end

-----------------------------------------

function zc.CopyDeep (dest, src)
  -- Auctionator.Debug.Message( 'zc.CopyDeep', dest, src )

  if type(src) == 'table' then

    for n, v in pairs (src) do
      if (type(v) == "table") then
        dest[n] = {};
        zc.CopyDeep(dest[n], v);
      else
        dest[n] = v;
      end
    end

  else
    dest = src
  end
end

-----------------------------------------

function zc.printableLink (link)      -- return a raw version of the link

  if (link == nil) then
    return "nil";
  end

  local printable = gsub(link, "\124", "\124\124");

  return printable;
end

-----------------------------------------

function zc.printmem ()

  local cmem = math.floor(collectgarbage ("count"))

  UpdateAddOnMemoryUsage();
  local mem = GetAddOnMemoryUsage("Auctionator");
  zc.msg_anm (math.floor(mem).." KB  (total LUA: "..cmem.." KB)");
end

-----------------------------------------

function zc.printstack (options)

  local cstr    = "";
  local funcnames = {};

  if (options == nil) then
    options = {};
  end

  if (options.prefix) then
    cstr = options.prefix;
  end

  local s = debugstack (2);

  if (s == nil) then
    s = debugstack (1);
  end

  if (type(s) == 'string') then
    local lines = { strsplit("\n", s) };

    if (lines ~= nil) then
      local x = 1;
      local n;
      local v;
      for n = 1,#lines do
        v = lines[n];

        local filename = nil;
        local funcname = nil;

        local a,b = string.find (v, "\\[^\\]*:");

        if (a) then
          filename = string.sub (v,a+1,b-1);
          filename = string.gsub (filename, "\.lua", "");
        end

        local a,b = string.find (v, "in function `.*\'");
        if (a) then
          funcname = string.sub (v,a+13,b-1);
          table.insert (funcnames, funcname);
        end

        if (Atr_IsDev and options.verbose) then
          if (filename ~= nil and funcname ~= nil) then
            local colwid = math.floor((100 - string.len(funcname)) / 2);
            local fs = "%-"..colwid.."s (%s)";
            zc.msg_color (.5, 1, .5, string.format (fs, funcname, filename));
          else
            zc.msg (v);
          end
        elseif (not options.silent) then
          if (funcname) then
            if (x == 2) then
              cstr = cstr.." < |cFFFFaa88"..funcname;
            else
              cstr = cstr.." < "..funcname;
            end
            x = x + 1;
          end
        end
      end
    end
  end

  if (Atr_IsDev and not options.verbose and not options.silent) then
    zc.msg (cstr);
  end

  return funcnames;

end



-----------------------------------------

function zc.tallyAdd (ttable, value)

  if (ttable[value]) then
    ttable[value] = ttable[value] + 1;
  else
    ttable[value] = 1;
  end
end


-----------------------------------------

function zc.tallyPrint (ttable, options)

  local sortedTable = {};
  local total = 0;

  local n = 1;
  for value,count in pairs(ttable) do

    sortedTable[n] = {};
    sortedTable[n].value  = value;
    sortedTable[n].count  = count;

    total = total + count;

    n = n + 1;
  end


  if    (options.sortByValue and options.sortDesc) then     table.sort (sortedTable, function(x,y) return x.value > y.value; end);
  elseif  (options.sortByValue and not options.sortDesc) then   table.sort (sortedTable, function(x,y) return x.value < y.value; end);
  elseif  (options.sortDesc) then                 table.sort (sortedTable, function(x,y) return x.count > y.count; end);
  else                              table.sort (sortedTable, function(x,y) return x.count < y.count; end);
  end


  for n = 1, #sortedTable do

    if (not options.printCount or n < options.printCount) then
      zc.msg_pink (sortedTable[n].count.."    "..sortedTable[n].value);
    end
  end

  zc.msg_yellow ("Total: "..total);
end
