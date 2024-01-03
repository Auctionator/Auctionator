local LibSerialize = LibStub and LibStub:GetLibrary("LibSerialize") or require("LibSerialize")

local pairs = pairs
local type = type
local tostring = tostring
local assert = assert
local unpack = unpack
local pcall = pcall

function LibSerialize:RunTests()
    --[[---------------------------------------------------------------------------
        Examples from the top of LibSerialize.lua
    --]]---------------------------------------------------------------------------

    do
        local t = { "test", [false] = {} }
        t[ t[false] ] = "hello"
        local serialized = LibSerialize:Serialize(t, "extra")
        local success, tab, str = LibSerialize:Deserialize(serialized)
        assert(success)
        assert(tab[1] == "test")
        assert(tab[ tab[false] ] == "hello")
        assert(str == "extra")
    end

    do
        local serialized = LibSerialize:SerializeEx(
            { errorOnUnserializableType = false },
            print, { a = 1, b = print })
        local success, fn, tab = LibSerialize:Deserialize(serialized)
        assert(success)
        assert(fn == nil)
        assert(tab.a == 1)
        assert(tab.b == nil)
    end

    do
        local t = { a = 1 }
        t.t = t
        t[t] = "test"
        local serialized = LibSerialize:Serialize(t)
        local success, tab = LibSerialize:Deserialize(serialized)
        assert(success)
        assert(tab.t.t.t.t.t.t.a == 1)
        assert(tab[tab.t] == "test")
    end

    do
        local t = { a = 1, b = print, c = 3 }
        local nested = { a = 1, b = print, c = 3 }
        t.nested = nested
        setmetatable(nested, { __LibSerialize = {
            filter = function(t, k, v) return k ~= "c" end
        }})
        local opts = {
            filter = function(t, k, v) return LibSerialize:IsSerializableType(k, v) end
        }
        local serialized = LibSerialize:SerializeEx(opts, t)
        local success, tab = LibSerialize:Deserialize(serialized)
        assert(success)
        assert(tab.a == 1)
        assert(tab.b == nil)
        assert(tab.c == 3)
        assert(tab.nested.a == 1)
        assert(tab.nested.b == nil)
        assert(tab.nested.c == nil)
    end


    --[[---------------------------------------------------------------------------
        Test of stable serialization
    --]]---------------------------------------------------------------------------

    do
        local t = { a = 1, b = print, c = 3 }
        local nested = { a = 1, b = print, c = 3 }
        t.nested = nested
        setmetatable(nested, { __LibSerialize = {
            filter = function(t, k, v) return k ~= "c" end
        }})
        local opts = {
            filter = function(t, k, v) return LibSerialize:IsSerializableType(k, v) end,
            stable = true
        }
        local serialized = LibSerialize:SerializeEx(opts, t)
        local success, tab = LibSerialize:Deserialize(serialized)
        assert(success)
        assert(tab.a == 1)
        assert(tab.b == nil)
        assert(tab.c == 3)
        assert(tab.nested.a == 1)
        assert(tab.nested.b == nil)
        assert(tab.nested.c == nil)
    end

    do
        local t1 = { x = "y", "test", [false] = { 1, 2, 3, a = "b" } }
        local opts = {
            stable = true,
            filter = function(t, k, v) return not tonumber(k) or tonumber(k) < 100 end
        }
        local serialized1 = LibSerialize:SerializeEx(opts, t1)
        local success1, tab1 = LibSerialize:Deserialize(serialized1)
        assert(success1)
        assert(tab1[1] == "test")
        assert(tab1.x == "y")
        assert(tab1[false][1] == 1)
        assert(tab1[false][2] == 2)
        assert(tab1[false][3] == 3)
        assert(tab1[false].a == "b")

        -- make a copy of the original table, but first insert a bunch of extra keys (which we'll
        -- filter out) to force the order of the hashes to be different (tested with lua 5.1 and 5.2)
        local t2 = {}
        for i = 100, 10000 do
            t2[tostring(i)] = i
        end
        t2.x = "y"
        t2[1] = "test"
        t2[false] = { 1, 2, 3, a = "b" }

        -- ensure the iteration order is different
        local isDifferent = false
        local k1, k2 = nil, nil
        while true do
            k1 = next(t1, k1)
            -- get the next key from t2 that's not going to be filtered
            while true do
                k2 = next(t2, k2)
                if k2 == nil or not tonumber(k2) or tonumber(k2) < 100 then
                    break
                end
            end
            if k1 == nil and k2 == nil then
                break
            end
            assert(k1 ~= nil and k2 ~= nil)
            isDifferent = isDifferent or k1 ~= k2
        end
        assert(isDifferent)

        -- serialize the copy and ensure the result is the same
        local serialized2 = LibSerialize:SerializeEx(opts, t2)
        assert(serialized2 == serialized1)
    end


    --[[---------------------------------------------------------------------------
        Utilities
    --]]---------------------------------------------------------------------------

    local function isnan(value)
        return (value < 0) == (value >= 0)
    end

    local function tCompare(lhsTable, rhsTable, depth)
        depth = depth or 1
        for key, value in pairs(lhsTable) do
            if type(value) == "table" then
                local rhsValue = rhsTable[key]
                if type(rhsValue) ~= "table" then
                    return false
                end
                if depth > 1 then
                    if not tCompare(value, rhsValue, depth - 1) then
                        return false
                    end
                end
            elseif value ~= rhsTable[key] then
                -- print("mismatched value: " .. key .. ": " .. tostring(value) .. ", " .. tostring(rhsTable[key]))
                return false
            end
        end
        -- Check for any keys that are in rhsTable and not lhsTable.
        for key, value in pairs(rhsTable) do
            if lhsTable[key] == nil then
                -- print("mismatched key: " .. key)
                return false
            end
        end
        return true
    end


    --[[---------------------------------------------------------------------------
        Test cases for serialization
    --]]---------------------------------------------------------------------------

    local function fail(value, desc)
        assert(false, ("Test failed (%s): %s"):format(tostring(value), desc))
    end

    local function testfilter(t, k, v)
        return k ~= "banned" and v ~= "banned"
    end

    local function check(value, bytelen, cmp)
        local serialized = LibSerialize:SerializeEx({ errorOnUnserializableType = false, filter = testfilter }, value)
        if #serialized ~= bytelen then
            fail(value, ("Unexpected serialized length (%d, expected %d)"):format(#serialized, bytelen))
        end

        local success, deserialized = LibSerialize:Deserialize(serialized)
        if not success then
            fail(value, ("Deserialization failed: %s"):format(deserialized))
        end

        -- Tests involving NaNs will be compared in string form.
        if type(value) == "number" and isnan(value) then
            value = tostring(value)
            deserialized = tostring(deserialized)
        end

        local typ = type(value)
        if typ == "table" and not tCompare(cmp or value, deserialized) then
            fail(value, "Non-matching deserialization result")
        elseif typ ~= "table" and value ~= deserialized then
            fail(value, ("Non-matching deserialization result: %s"):format(tostring(deserialized)))
        end
    end

    -- Format: each test case is { value, bytelen, cmp }. The value will be serialized
    -- and then deserialized, checking for success and equality, and the length of
    -- the serialized string will be compared against bytelen. If `cmp` is provided,
    -- it will be used for comparison against the deserialized result instead of `value`.
    -- Note that the length always contains one extra byte for the version number.
    local testCases = {
        { nil, 2 },
        { true, 2 },
        { false, 2 },
        { 0, 2 },
        { 1, 2 },
        { 127, 2 },
        { 128, 3 },
        { 4095, 3 },
        { 4096, 4 },
        { 65535, 4 },
        { 65536, 5 },
        { 16777215, 5 },
        { 16777216, 6 },
        { 4294967295, 6 },
        { 4294967296, 9 },
        { 9007199254740992, 9 },
        { 1.5, 6 },
        { 27.32, 8 },
        { 123.45678901235, 10 },
        { 148921291233.23, 10 },
        { -0, 2 },
        { -1, 3 },
        { -4095, 3 },
        { -4096, 4 },
        { -65535, 4 },
        { -65536, 5 },
        { -16777215, 5 },
        { -16777216, 6 },
        { -4294967295, 6 },
        { -4294967296, 9 },
        { -9007199254740992, 9 },
        { -1.5, 6 },
        { -123.45678901235, 10 },
        { -148921291233.23, 10 },
        { 0/0, 10 },  -- -1.#IND or -nan(ind)
        { 1/0, 10 },  -- 1.#INF or inf
        { -1/0, 10 }, -- -1.#INF or -inf
        { "", 2 },
        { "a", 3 },
        { "abcdefghijklmno", 17 },
        { "abcdefghijklmnop", 19 },
        { ("1234567890"):rep(30), 304 },
        { {}, 2 },
        { { 1 }, 3 },
        { { 1, 2, 3, 4, 5 }, 7 },
        { { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 17 },
        { { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }, 19 },
        { { 1, 2, 3, 4, a = 1, b = 2, [true] = 3, d = 4 }, 17 },
        { { 1, 2, 3, 4, 5, a = 1, b = 2, c = true, d = 4 }, 21 },
        { { 1, 2, 3, 4, 5, a = 1, b = 2, c = 3, d = 4, e = false }, 24 },
        { { a = 1, b = 2, c = 3 }, 11 },
        { { "aa", "bb", "aa", "bb" }, 14 },
        { { "aa1", "bb2", "aa3", "bb4" }, 18 },
        { { "aa1", "bb2", "aa1", "bb2" }, 14 },
        { { "aa1", "bb2", "bb2", "aa1" }, 14 },
        { { "abcdefghijklmno", "abcdefghijklmno", "abcdefghijklmno", "abcdefghijklmno" }, 24 },
        { { "abcdefghijklmno", "abcdefghijklmno", "abcdefghijklmno", "abcdefghijklmnop" }, 40 },
        { { 1, 2, 3, print, print, 6 }, 7, { 1, 2, 3, nil, nil, 6 } },
        { { 1, 2, 3, print, 5, 6 }, 8, { 1, 2, 3, nil, 5, 6 } },
        { { a = print, b = 1, c = print }, 5, { b = 1 } },
        { { a = print, [print] = "a" }, 2, {} },
        { { "banned", 1, 2, 3, banned = 4, test = "banned", a = 1 }, 9, { nil, 1, 2, 3, a = 1 } },
        { { 1, 2, [math.huge] = "f", [3] = 3 }, 16 },
        { { 1, 2, [-math.huge] = "f", [3] = 3 }, 16 },
    }

    do
        local t = { a = 1, b = 2 }
        table.insert(testCases, { { t, t, t }, 13 })
        table.insert(testCases, { { { a = 1, b = 2 }, { a = 1, b = 2 }, { a = 1, b = 2 } }, 23 })
    end

    for _, testCase in ipairs(testCases) do
        check(unpack(testCase))
    end

    -- Since all the above tests assume serialization success, try some failures now.
    local failCases = {
        { print },
        { [print] = true },
        { [true] = print },
        print,
    }

    for _, testCase in ipairs(failCases) do
        local success = pcall(LibSerialize.Serialize, LibSerialize, testCase)
        assert(success == false)
    end

    print("All tests passed!")
end

-- Run tests immediately when executed from a non-WoW environment.
if require then
    LibSerialize:RunTests()
end
