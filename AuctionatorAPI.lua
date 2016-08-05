
local addonName, addonTable = ...;
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local zz = zc.md;
local _

-----------------------------------------

local origGetSellValue		= GetSellValue;
local origGetAuctionBuyout	= GetAuctionBuyout;

-----------------------------------------

function GetSellValue (item)		-- Tekkub's API

	return Atr_GetSellValue(item);
end

-----------------------------------------

function GetAuctionBuyout (item)		-- Tekkub's API

	return Atr_GetAuctionBuyout(item);
end

-----------------------------------------

function Atr_GetSellValue (item)		-- Just like Tekkub's API but for when you want to be sure you're calling Auctionator's version of it

	local sellval = select (11, GetItemInfo(item));

	if (sellval ~= nil) then
		return sellval;
	end

	if (origGetSellValue) then
		return origGetSellValue(item);
	end

	return 0;
end


-----------------------------------------

function Atr_GetAuctionBuyout (item)  -- Just like Tekkub's API but for when you want to be sure you're calling Auctionator's version of it

	local sellval;

	if (type(item) == "string") then
		sellval = Atr_GetAuctionPrice(item);
	end

	if (sellval == nil) then
		local name = GetItemInfo(item);
		if (name) then
			sellval = Atr_GetAuctionPrice(name);
		end
	end


	if (sellval) then
		return sellval;
	end

	if (origGetAuctionBuyout) then
		return origGetAuctionBuyout(item);
	end

	return nil;
end

-----------------------------------------

function Atr_GetDisenchantValue (item)
  local itemName, itemLink, quality, iLevel, _, itemType, sSubType, _, _, _, _, itemClass, itemSubClass = GetItemInfo(item);

	if (itemLink) then
		return Atr_CalcDisenchantPrice( itemClass, itemRarity, itemLevel )
	end

	return nil;
end

-----------------------------------------

function Atr_SearchAH (shoppingListName, items, itemType)

	if (shoppingListName == nil) then
		shoppingListName = "Unknown"
	end

	local slist = Atr_SList.create (shoppingListName, false, true)

	local i;
	for i = 1, #items do
		if (i == 1 and (Atr_IsWeaponType (itemType) or Atr_IsArmorType (itemType))) then
			slist:AddItem (items[i])		-- do substring search for first item if armor or weapon
		else
			slist:AddItem (zc.QuoteString(items[i]))
		end
	end

	if (not Atr_IsTabSelected(SELL_TAB)) then
		Atr_SelectPane (SELL_TAB);
	end

	Atr_SetSearchText ("{ "..shoppingListName.." }");
	Atr_Search_Onclick ();

end

-----------------------------------------

local DBupdateCallbacks = {};

-----------------------------------------

function Atr_RegisterFor_DBupdated (cbFunc)

	table.insert (DBupdateCallbacks, cbFunc);

end

-----------------------------------------

function Atr_Broadcast_DBupdated (num, kind, binfo)

	local n;

	for n = 1,#DBupdateCallbacks do
		local cbFunc = DBupdateCallbacks[n]
		if (type(cbFunc) == "function") then
			cbFunc(num, kind, binfo)
		end
	end

end

-----------------------------------------
--[[
function Atr_TestListener (num, kind, binfo)
	zz (num, "items found", kind)

	if (type(binfo) == "table") then
		local z;
		for z = 1,#binfo do
			zz (z, binfo[z].i, binfo[z].p)
		end
	end
end


Atr_RegisterFor_DBupdated (Atr_TestListener)
]]--
