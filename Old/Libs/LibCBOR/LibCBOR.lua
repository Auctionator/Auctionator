-- Modified by plusmouse for World of Warcraft addons
--
-- Concise Binary Object Representation (CBOR)
-- RFC 7049

local LibCBOR
if not LibStub then
  LibCBOR = {}
else
  LibCBOR = LibStub:NewLibrary("LibCBOR-1.0", 4)
end

if not LibCBOR then
  return
end

local NaN = math.sin(math.huge)
local b_rshift = bit and bit.rshift or function (a, b) return math.max(0, math.floor(a / (2 ^ b))); end
local wipe = table and table.wipe or function(tbl) for key in pairs(tbl) do tbl[key] = nil end end

local encoder = {};

-- Major types 0, 1 and length encoding for others
local function integer(num, m)
  if num < 24 then
    return string.char(m + num);
  elseif num < 2 ^ 8 then
    return string.char(m + 24, num);
  elseif num < 2 ^ 16 then
    return string.char(m + 25, b_rshift(num, 8), num % 0x100);
  elseif num < 2 ^ 32 then
    return string.char(m + 26,
      b_rshift(num, 24) % 0x100,
      b_rshift(num, 16) % 0x100,
      b_rshift(num, 8) % 0x100,
      num % 0x100);
  elseif num < 2 ^ 64 then
    local high = math.floor(num / 2 ^ 32);
    num = num % 2 ^ 32;
    return string.char(m + 27,
      b_rshift(high, 24) % 0x100,
      b_rshift(high, 16) % 0x100,
      b_rshift(high, 8) % 0x100,
      high % 0x100,
      b_rshift(num, 24) % 0x100,
      b_rshift(num, 16) % 0x100,
      b_rshift(num, 8) % 0x100,
      num % 0x100);
  end
  error "int too large";
end

local function encode1(obj)
  return encoder[type(obj)](obj)
end

local function encode2(root)
  if type(root) == "table" then
    local keychain = {}
    local keychainIndex = 0
    local keychainLimit = 0
    local current
    while true do
      local obj
      local currentKey
      if current then
        currentKey = current.keys[current.index]
        obj = current.root[currentKey]
      else
        obj = root
      end
      local objType = type(obj)
      if objType == "table" then
        local keys = {}
        local isArray, i = true, 1
        for key in pairs(obj) do
          keys[#keys + 1] = key
          if isArray and i ~= key then
            isArray = false
            i = i + 1
          end
        end
        keychainIndex = keychainIndex + 1
        if keychainIndex <= keychainLimit then
          current = keychain[keychainIndex]
          current.root, current.keys, current.index, current.isArray = obj, keys, 1, isArray
        else
          keychain[keychainIndex] = {root = obj, keys = keys, index = 1, results = {}, isArray = isArray}
          keychainLimit = keychainIndex
          current = keychain[keychainIndex]
        end
        if isArray then
          current.results[1] = integer(#keys, 128)
        else
          current.results[1] = integer(#keys, 160)
        end
      elseif current.isArray and obj ~= nil then
        current.results[current.index + 1] = encoder[objType](obj)
        current.index = current.index + 1
      elseif obj ~= nil then
        local index2 = current.index * 2
        current.results[index2] = encoder[type(currentKey)](currentKey)
        current.results[index2 + 1] = encoder[objType](obj)
        current.index = current.index + 1
      else
        local isArray = true
        local result = table.concat(current.results)
        wipe(current.results)
        keychainIndex = keychainIndex - 1
        current = keychain[keychainIndex]
        if current == nil then
          return result
        elseif current.isArray then
          current.results[current.index + 1] = result
          current.index = current.index + 1
        else
          local currentKey = current.keys[current.index]
          local index2 = current.index * 2
          current.results[index2] = encoder[type(currentKey)](currentKey)
          current.results[index2 + 1] = result
          current.index = current.index + 1
        end
      end
    end
  else
    return encoder[type(root)](root)
  end
end

-- Major type 7
local function encoder_float(num)
  if (num < 0) == (num >= 0) then -- NaN shortcut
    return "\249\255\255";
  end
  local sign = (num > 0 or 1 / num > 0) and 0 or 1;
  num = math.abs(num)
  if num == math.huge then
    return string.char(251, sign * 128 + 128 - 1) .. "\240\0\0\0\0\0\0";
  end
  local fraction, exponent = math.frexp(num)
  if fraction == 0 then
    return string.char(251, sign * 128) .. "\0\0\0\0\0\0\0";
  end
  fraction = fraction * 2;
  exponent = exponent + 1024 - 2;
  if exponent <= 0 then
    fraction = fraction * 2 ^ (exponent - 1)
    exponent = 0;
  else
    fraction = fraction - 1;
  end
  return string.char(251,
    sign * 2 ^ 7 + math.floor(exponent / 2 ^ 4) % 2 ^ 7,
    exponent % 2 ^ 4 * 2 ^ 4 +
    math.floor(fraction * 2 ^ 4 % 0x100),
    math.floor(fraction * 2 ^ 12 % 0x100),
    math.floor(fraction * 2 ^ 20 % 0x100),
    math.floor(fraction * 2 ^ 28 % 0x100),
    math.floor(fraction * 2 ^ 36 % 0x100),
    math.floor(fraction * 2 ^ 44 % 0x100),
    math.floor(fraction * 2 ^ 52 % 0x100)
  )
end

-- Number types dispatch
function encoder.number(num)
  if num % 1 == 0 and num < 2^64 and num > - 2^64 + 1 then
    -- Major types 0, 1
    return num < 0 and integer(- 1 - num, 32) or integer(num, 0)
  else
    return encoder_float(num)
  end
end

-- Major type 2 - byte strings
function encoder.bytestring(s)
  return integer(#s, 64) .. s;
end

-- Major type 3 - UTF-8 strings
function encoder.utf8string(s)
  return integer(#s, 96) .. s;
end

-- Modern Lua strings are UTF-UTF-8
encoder.string = encoder.utf8string;

function encoder.boolean(bool)
  return bool and "\245" or "\244";
end

encoder["nil"] = function() return "\246"; end

function encoder.table(t)
  -- the table is encoded as an array iff when we iterate over it,
  -- we see successive integer keys starting from 1.  The lua
  -- language doesn't actually guarantee that this will be the case
  -- when we iterate over a table with successive integer keys, but
  -- due an implementation detail in PUC Rio Lua, this is what we
  -- usually observe.  See the Lua manual regarding the # (length)
  -- operator.  In the case that this does not happen, we will fall
  -- back to a map with integer keys, which becomes a bit larger.
  local array, map, i = { integer(#t, 128) }, { "\191" }, 1
  local is_array = true;
  for k, v in pairs(t) do
    is_array = is_array and i == k;
    i = i + 1;

    local encoded_v = encode1(v);
    array[i] = encoded_v;

    table.insert(map, encode1(k))
    table.insert(map, encoded_v)
  end
  --map[#map + 1] = "\255";
  map[1] = integer(i - 1, 160);
  return table.concat(is_array and array or map);
end

encoder["function"] = function ()
  error "can't encode function";
end

local function read_length(fh, mintyp)
  if mintyp < 24 then
    return mintyp;
  elseif mintyp < 28 then
    local bytes = 2 ^ (mintyp - 24)
    local n1, n2, n3, n4, n5, n6, n7, n8 = fh.readbytes(bytes)
    if n8 then
      return n1 * 256 ^ 7 + n2 * 256 ^ 6 + n3 * 256 ^ 5 + n4 * 256 ^ 4 + n5 * 256 ^ 3 + n6 * 256 ^ 2 + n7 * 256 + n8
    elseif n4 then
      return n1 * 256 ^ 3 + n2 * 256 ^ 2 + n3 * 256 + n4
    elseif n2 then
      return n1 * 256 + n2
    else
      return n1
    end
  else
    error "invalid length";
  end
end

local decoder = {};

local function read_object(fh)
  local byte = fh.readbyte();
  local typ, mintyp = b_rshift(byte, 5), byte % 32;
  return decoder[typ](fh, mintyp);
end

local read_integer = read_length

local function read_negative_integer(fh, mintyp)
  return -1 - read_length(fh, mintyp);
end

local function read_string(fh, mintyp)
  if mintyp ~= 31 then
    return fh.read(read_length(fh, mintyp));
  end
  local out = {};
  local i = 1;
  local v = read_object(fh);
  while v ~= nil do
    out[i], i = v, i + 1;
    v = read_object(fh);
  end
  return table.concat(out);
end

local read_unicode_string = read_string

local function read_array(fh, mintyp)
  local out = {};
  if mintyp == 31 then
    local i = 1;
    local v = read_object(fh);
    while v ~= nil do
      out[i], i = v, i + 1;
      v = read_object(fh);
    end
  else
    local len = read_length(fh, mintyp);
    for i = 1, len do
      out[i] = read_object(fh);
    end
  end
  return out;
end

local function read_map(fh, mintyp)
  local out = {};
  local k;
  if mintyp == 31 then
    local i = 1;
    k = read_object(fh);
    while k ~= nil do
      out[k], i = read_object(fh), i + 1;
      k = read_object(fh);
    end
  else
    local len = read_length(fh, mintyp);
    for _ = 1, len do
      k = read_object(fh);
      out[k] = read_object(fh);
    end
  end
  return out;
end

local tagged_decoders = {};

local function read_semantic(fh, mintyp)
  local tag = read_length(fh, mintyp);
  local value = read_object(fh);
  local postproc = tagged_decoders[tag];
  if postproc then
    return postproc(value);
  end
  return nil;
end

local function read_half_float(fh)
  local exponent, fraction = fh.readbytes(2);
  local sign = exponent < 128 and 1 or -1; -- sign is highest bit

  fraction = fraction + (exponent * 256) % 1024; -- copy two(?) bits from exponent to fraction
  exponent = b_rshift(exponent, 2) % 32; -- remove sign bit and two low bits from fraction;

  if exponent == 0 then
    return sign * math.ldexp(fraction, -24);
  elseif exponent ~= 31 then
    return sign * math.ldexp(fraction + 1024, exponent - 25);
  elseif fraction == 0 then
    return sign * math.huge;
  else
    return NaN;
  end
end

local function read_float(fh)
  local exponent, fraction = fh.readbytes(2);
  local sign = exponent < 128 and 1 or -1; -- sign is highest bit
  exponent = exponent * 2 % 256 + b_rshift(fraction, 7);
  fraction = fraction % 128;
  fraction = fraction * 256 + fh.readbyte();
  fraction = fraction * 256 + fh.readbyte();

  if exponent == 0 then
    return sign * math.ldexp(exponent, -149);
  elseif exponent ~= 0xff then
    return sign * math.ldexp(fraction + 2 ^ 23, exponent - 150);
  elseif fraction == 0 then
    return sign * math.huge;
  else
    return NaN;
  end
end

local function read_double(fh)
  local exponent, fraction = fh.readbytes(2);
  local sign = exponent < 128 and 1 or -1; -- sign is highest bit

  exponent = exponent %  128 * 16 + b_rshift(fraction, 4);
  fraction = fraction % 16;
  fraction = fraction * 256 + fh.readbyte();
  fraction = fraction * 256 + fh.readbyte();
  fraction = fraction * 256 + fh.readbyte();
  fraction = fraction * 256 + fh.readbyte();
  fraction = fraction * 256 + fh.readbyte();
  fraction = fraction * 256 + fh.readbyte();

  if exponent == 0 then
    return sign * math.ldexp(exponent, -149);
  elseif exponent ~= 0xff then
    return sign * math.ldexp(fraction + 2 ^ 52, exponent - 1075);
  elseif fraction == 0 then
    return sign * math.huge;
  else
    return NaN;
  end
end

local function read_simple(fh, value)
  -- Unassigned value
  if value == 24 then
     fh.readbyte();
     return nil
  end

  if value == 20 then
    return false;
  elseif value == 21 then
    return true;
  --elseif value == 22 then
  --  return nil;
  --elseif value == 23 then
  --  return nil;
  elseif value == 25 then
    return read_half_float(fh);
  elseif value == 26 then
    return read_float(fh);
  elseif value == 27 then
    return read_double(fh);
  --elseif value == 31 then
  --  return BREAK;
  else
    return nil;
  end
end

decoder[0] = read_integer;
decoder[1] = read_negative_integer;
decoder[2] = read_string;
decoder[3] = read_unicode_string;
decoder[4] = read_array;
decoder[5] = read_map;
decoder[6] = read_semantic;
decoder[7] = read_simple;

local function decode1(s)
  local fh = {};
  local pos = 1;

  function fh.read(bytes)
    local newPos = pos + bytes
    local ret = string.sub(s, pos, newPos - 1);
    pos = newPos;
    return ret;
  end

  function fh.readbyte()
    local oldPos = pos
    pos = pos + 1
    return string.byte(s, oldPos)
  end

  function fh.readbytes(bytes)
    local oldPos = pos
    pos = pos + bytes
    return string.byte(s, oldPos, pos - 1)
  end

  return read_object(fh);
end

local function decode2(s)
  local pos = 1;

  local fh = {}

  function fh.read(bytes)
    local newPos = pos + bytes
    local ret = string.sub(s, pos, newPos - 1);
    pos = newPos;
    return ret;
  end

  function fh.readbyte()
    local oldPos = pos
    pos = pos + 1
    return string.byte(s, oldPos)
  end

  function fh.readbytes(bytes)
    local oldPos = pos
    pos = pos + bytes
    return string.byte(s, oldPos, pos - 1)
  end

  local tree = {}
  local treeIndex = 1
  local treeLimit = 1
  local current

  do
    local byte = string.byte(s, pos)
    pos = pos + 1
    local typ, mintyp = b_rshift(byte, 5), byte % 32;

    if typ ~= 4 and typ ~= 5 then
      return decoder[typ](fh, mintyp)
    end

    -- assumes a map or array
    tree[treeIndex] = { left = -1, isArray = typ == 4, obj = {} }
    current = tree[treeIndex]
    if mintyp ~= 31 then
      current.left = read_length(fh, mintyp)
    end
  end

  local strlen = #s
  local decoder = decoder
  while pos <= strlen or current.left == 0 do
    local key
    if current.left ~= 0 then
      if current.isArray then
        key = #current.obj + 1
      else
        local byte = string.byte(s, pos)
        pos = pos + 1
        local typ, mintyp = b_rshift(byte, 5), byte % 32;
        key = decoder[typ](fh, mintyp)
      end
      current.left = current.left - 1
    end
    if key == nil then
      treeIndex = treeIndex - 1
      if treeIndex == 0 then
        return tree[1].obj
      else
        current = tree[treeIndex]
      end
    else
      local byte = string.byte(s, pos)
      pos = pos + 1
      local typ, mintyp = b_rshift(byte, 5), byte % 32;
      if typ == 4 or typ == 5 then
        local oldCurrent = current
        treeIndex = treeIndex + 1
        if treeIndex > treeLimit then
          tree[treeIndex] = {}
          treeLimit = treeIndex
        end
        current = tree[treeIndex]
        current.isArray = typ == 4
        current.obj = {}
        current.left = mintyp == 31 and -1 or read_length(fh, mintyp)
        oldCurrent.obj[key] = current.obj
      else
        current.obj[key] = decoder[typ](fh, mintyp)
      end
    end
  end

  error("didn't finish data")
end

for key, val in pairs({
  encode = encode2;
  decode = decode1;
  decode2 = decode2;
  Serialize = function(_, ...) return encode2(...) end;
  Deserialize = function(_, ...) return decode2(...) end;
}) do
  LibCBOR[key] = val
end
return LibCBOR
