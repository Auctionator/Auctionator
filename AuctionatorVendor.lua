local addonName, addonTable = ...
local ZT = addonTable.ztt.ZT
local zc = addonTable.zc
local zz = zc.md
local _

ATR_CAN_BE_AUCTIONED = 0
ATR_BIND_ON_PICKUP = 1
ATR_BINDS_TO_ACCOUNT = 2
ATR_QUEST_ITEM = 4
ATR_BINDTYPE_UNKNOWN = -1

local AtrBindTypeCache = {}

-----------------------------------------

function AtrReadBindText(itemID, txt)

    -- zz (itemID, txt);

    if (txt) then

        if txt == ITEM_BIND_ON_EQUIP then return ATR_CAN_BE_AUCTIONED end
        if txt == ITEM_BIND_ON_USE then return ATR_CAN_BE_AUCTIONED end
        if txt == ITEM_BIND_ON_PICKUP then return ATR_BIND_ON_PICKUP end
        if txt == ITEM_BIND_TO_ACCOUNT then return ATR_BINDS_TO_ACCOUNT end
        if txt == ITEM_BIND_TO_BNETACCOUNT then
            return ATR_BINDS_TO_ACCOUNT
        end
        if txt == ITEM_BIND_QUEST then return ATR_QUEST_ITEM end
    end

    return ATR_BINDTYPE_UNKNOWN
end

-----------------------------------------

function Atr_AddBondTypeToCache(itemID)
    -- patch submitted by @teyasio (unable to reproduce offending bug)
    if itemID == nil then return end

    if not AtrBindTypeToolTip then
        CreateFrame('GameTooltip', 'AtrBindTypeToolTip', UIParent,
                    'GameTooltipTemplate')
    end

    local tt = AtrBindTypeToolTip
    tt:SetOwner(UIParent, 'ANCHOR_NONE')
    tt:SetItemByID(itemID)

    local result = ATR_BINDTYPE_UNKNOWN

    if AtrBindTypeToolTip:NumLines() > 1 then
        result = AtrReadBindText(itemID, AtrBindTypeToolTipTextLeft2:GetText())
        if (result == ATR_BINDTYPE_UNKNOWN) then
            result = AtrReadBindText(itemID,
                                     AtrBindTypeToolTipTextLeft3:GetText())
        end

    end
    tt:Hide()

    if (result == ATR_BINDTYPE_UNKNOWN) then
        AtrBindTypeCache[itemID] = ATR_CAN_BE_AUCTIONED
    else
        AtrBindTypeCache[itemID] = result
    end

    -- zz ("Adding to cache: ", itemID, AtrBindTypeCache[itemID]);

end

-----------------------------------------

function Atr_GetBondType(itemID)

    if (AtrBindTypeCache[itemID] == nil) then Atr_AddBondTypeToCache(itemID) end

    return AtrBindTypeCache[itemID]
end