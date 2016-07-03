
local addonName, addonTable = ...
local ZT = addonTable.ztt.ZT;
local zc = addonTable.zc
local zz = zc.md
local _

-----------------------------------------

local function BuildAddonsString ()

	local acnt = "";
	
	local familyNames = {};
	local f, i, found;
	
	for i = 1, GetNumAddOns() do
		local name, title, notes, enabled = GetAddOnInfo(i)
		if (enabled) then
			found = false;

			if (zc.StringStartsWith (name, "DBM")) then
				name = "DBM";
			end
			if (zc.StringStartsWith (name, "Auc-")) then
				name = "AUCTIONEER";
			end

			for f = 1,#familyNames do
				if (zc.StringStartsWith (name, familyNames[f])) then
					found = true;
				end
			end
			
			if (not found) then
				table.insert (familyNames, name);
				acnt = acnt..", "..name;
			end
		end
	end

	return acnt;
end

-----------------------------------------

local origErrorHandler
local inAtrErrorHandler = false

-----------------------------------------

function Atr_Error_Handler (...)

	if (inAtrErrorHandler) then
		if (origErrorHandler) then
			origErrorHandler (...);
		end
		return;
	end

	inAtrErrorHandler = true;
	
	local msg		= zc.msg_str (...);
	local funcnames	= zc.printstack ( { silent=true } );
	local funcstr	= table.concat (funcnames, " > ");

	local looksLikeAuctionatorError = (zc.StringContains (msg, "auctionator.lua", "auctionatorQuery.lua", "auctionatorConflicts.lua", "auctionatorPane.lua", "auctionatorBuy.lua", "auctionatorConfig.lua", "auctionatorVendor.lua", "auctionator.xml", "auctionatorDatabase.lua", "auctionatorLocalize.lua", "auctionatorScan.lua", "auctionatorScanFull.lua", "auctionatorShop.lua", "auctionatorHints.lua", "zcutils"));

	if (zc.StringContains (msg, "auctionatorMiniFeatures")) then
		looksLikeAuctionatorError = false
	end
	
	if (zc.StringSame (select(1,...), "xxx")) then
		msg = "Debugging Information";
		looksLikeAuctionatorError = true;
	end

	if (looksLikeAuctionatorError) then

		Atr_LUA_explanation:SetText ("Ooops.  Looks like you've run into a bug in Auctionator. "
							.."You can help the author fix this bug by copying and pasting the information below, "
							.."and sending it to him along with a short description of what you were doing at the time the bug occurred. "
							.."|n|nSee |cffaaffffhttp://auctionatoraddon.com/bugs|r for instructions on where to send it."
							.."|nIt would be even more helpful if you could disable all other addons and let the author know if this error still occurs.");
	
		Atr_LUA_Error:Show();
		
		local fschunk = zc.Val (AUCTIONATOR_FS_CHUNK, "<nil>") ;
		
		local dbversion = 0;
		if (AUCTIONATOR_PRICE_DATABASE and AUCTIONATOR_PRICE_DATABASE["__dbversion"]) then
			dbversion = AUCTIONATOR_PRICE_DATABASE["__dbversion"];
		end
		
		local numShoppingLists = 0
		if (AUCTIONATOR_SHOPPING_LISTS) then
			numShoppingLists = #AUCTIONATOR_SHOPPING_LISTS
		end
		
		Atr_LUA_ErrorMsg:SetText (msg.."\n------------\nVERS:"..AuctionatorVersion.."   MEM:"..Atr_GetAuctionatorMemString().."   DB:"..Atr_GetDBsize()..
										"   SE:"..GetCVar("scripterrors").."  SL:"..numShoppingLists.."  FSCHUNK:"..fschunk.."  DBVERS:"..dbversion..
										"\n------------\nREALMS: "..GetRealmFacInfoString()..
										"\n------------\nSTACK: "..funcstr..
										"\n------------\nADDONS: "..BuildAddonsString());
		
	elseif (origErrorHandler) then
		origErrorHandler (...);
	end

	inAtrErrorHandler = false;
end


-----------------------------------------

function Atr_Install_Error_Handler ()

	local installOurOwnErrorHandler = true
	local i
	
	for i = 1, GetNumAddOns() do
		local name, title, notes, enabled = GetAddOnInfo(i)
		if (enabled) then
			if (zc.StringSame (name, "BugSack") or zc.StringSame (name, "!BugGrabber") or zc.StringSame (name, "!Swatter")) then
				zz (name, "found - not installing errorhandler");
				installOurOwnErrorHandler = false
			end
		end
	end
	
	if (installOurOwnErrorHandler) then
		origErrorHandler = geterrorhandler()
		seterrorhandler (Atr_Error_Handler)
	end

end




