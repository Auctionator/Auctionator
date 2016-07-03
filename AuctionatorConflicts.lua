
local addonName, addonTable = ...; 
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc;
local _

local Atr_orig_RecipeKnown_EventScan;
local Atr_orig_LootLink_OnEvent;
local Atr_orig_WOWEcon_Scan_AH;

-----------------------------------------


local function Atr_RecipeKnown_EventScan (self, event, ...)

	if (event == "AUCTION_ITEM_LIST_UPDATE") then

		if (Atr_IsTabSelected()) then
			return;
		end
	
		local numBatchAuctions = Atr_GetNumAuctionItems("list");
		if (numBatchAuctions > 50) then		-- full scan
			return;
		end
	end

	Atr_orig_RecipeKnown_EventScan (self, event, ...);
end

-----------------------------------------

local function Atr_LootLink_OnEvent (self, event, ...)

	if (event == "AUCTION_ITEM_LIST_UPDATE") then

		if (Atr_IsTabSelected()) then
			return;
		end
	
		local numBatchAuctions = Atr_GetNumAuctionItems("list");
		if (numBatchAuctions > 50) then		-- full scan
			return;
		end
	end

	Atr_orig_LootLink_OnEvent (self, event, ...);
end

-----------------------------------------

local function Atr_WOWEcon_Scan_AH (self, event, ...)

	if (Atr_IsTabSelected()) then
		return;
	end

	local numBatchAuctions = Atr_GetNumAuctionItems("list");
	if (numBatchAuctions > 50) then		-- full scan
		return;
	end

	Atr_orig_WOWEcon_Scan_AH (self, event, ...);
end


-----------------------------------------

function Atr_Check_For_Conflicts (addonName)

	if (zc.StringSame (addonName, "recipeknown") and RecipeKnown_EventScan) then
		Atr_orig_RecipeKnown_EventScan = RecipeKnown_EventScan;
		RecipeKnown_EventScan = Atr_RecipeKnown_EventScan
		zc.msg_yellow ("Auctionator is patching RecipeKnown to prevent a known conflict.");
	end

	if (zc.StringContains (addonName, "lootlink") and LootLink_OnEvent) then
		Atr_orig_LootLink_OnEvent = LootLink_OnEvent;
		LootLink_OnEvent = Atr_LootLink_OnEvent
		zc.msg_yellow ("Auctionator is patching LootLink to prevent a known conflict.");
	end

	if (zc.StringContains (addonName, "wowecon") and WOWEcon_Scan_AH) then
		Atr_orig_WOWEcon_Scan_AH = WOWEcon_Scan_AH;
		WOWEcon_Scan_AH = Atr_WOWEcon_Scan_AH
		zc.msg_yellow ("Auctionator is patching WowEcon to prevent a known conflict.");
	end

end
