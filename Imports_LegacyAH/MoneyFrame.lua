-- Tex coords for Interface\MoneyFrame\UI-MoneyIcons
local TextureType = {
	File = 1,
	Atlas = 2,
};

AuctionatorRetailImportMoneyDenominationDisplayType = {
	Copper = { TextureType.File, [[Interface\MoneyFrame\UI-MoneyIcons]], 0.5, 0.75, 0, 1, },
	Silver = { TextureType.File, [[Interface\MoneyFrame\UI-MoneyIcons]], 0.25, 0.5, 0, 1, },
	Gold = { TextureType.File, [[Interface\MoneyFrame\UI-MoneyIcons]], 0, 0.25, 0, 1, },
	AuctionHouseCopper = { TextureType.Atlas, "auctionhouse-icon-coin-copper" },
	AuctionHouseSilver = { TextureType.Atlas, "auctionhouse-icon-coin-silver" },
	AuctionHouseGold = { TextureType.Atlas, "auctionhouse-icon-coin-gold" },
};

AUCTIONATOR_IMPORT_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE = {
	[AuctionatorRetailImportMoneyDenominationDisplayType.Copper] = COPPER_AMOUNT_SYMBOL,
	[AuctionatorRetailImportMoneyDenominationDisplayType.Silver] = SILVER_AMOUNT_SYMBOL,
	[AuctionatorRetailImportMoneyDenominationDisplayType.Gold] = GOLD_AMOUNT_SYMBOL,
	[AuctionatorRetailImportMoneyDenominationDisplayType.AuctionHouseCopper] = COPPER_AMOUNT_SYMBOL,
	[AuctionatorRetailImportMoneyDenominationDisplayType.AuctionHouseSilver] = SILVER_AMOUNT_SYMBOL,
	[AuctionatorRetailImportMoneyDenominationDisplayType.AuctionHouseGold] = GOLD_AMOUNT_SYMBOL,
};

AuctionatorRetailImportMoneyDenominationDisplayMixin = {};

function AuctionatorRetailImportMoneyDenominationDisplayMixin:OnLoad()
	self.amount = 0;
	
	if self.displayType == nil then
		error("A money denomination display needs a type. Add a KeyValue entry, displayType = AuctionatorRetailImportMoneyDenominationDisplayType.[Copper|Silver|Gold|AuctionHouseCopper|AuctionHouseSilver|AuctionHouseGold].");
		return;
	end

	self:UpdateDisplayType();
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetDisplayType(displayType)
	self.displayType = displayType;
	self:UpdateDisplayType();
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:UpdateDisplayType()
	local textureType, fileOrAtlas, l, r, b, t = unpack(self.displayType);

	if textureType == TextureType.Atlas then
		self.Icon:SetAtlas(fileOrAtlas);
		self.Icon:SetSize(12,14);
	else
		self.Icon:SetTexture(fileOrAtlas);
		self.Icon:SetSize(13,13);
	end

	self.Icon:SetTexCoord(l or 0, r or 1, b or 0, t or 1);
	self:UpdateWidth();
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetFontObject(fontObject)
	self.Text:SetFontObject(fontObject);
	self:UpdateWidth();
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:GetFontObject()
	return self.Text:GetFontObject();
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetFontAndIconDisabled(disabled)
	self:SetFontObject(disabled and NumberFontNormalGray or NumberFontNormal);
	self.Icon:SetAlpha(disabled and 0.5 or 1);
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetFormatter(formatter)
	self.formatter = formatter;
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetForcedHidden(forcedHidden)
	self.forcedHidden = forcedHidden;
	self:SetShown(self:ShouldBeShown());
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:IsForcedHidden()
	return self.forcedHidden;
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetShowsZeroAmount(showsZeroAmount)
	self.showsZeroAmount = showsZeroAmount;
	self:SetShown(self:ShouldBeShown());
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:ShowsZeroAmount()
	return self.showsZeroAmount;
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:ShouldBeShown()
	return not self:IsForcedHidden() and self.amount ~= nil and (self.amount > 0 or self:ShowsZeroAmount());
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:SetAmount(amount)
	self.amount = amount;

	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
	if not shouldBeShown then
		return;
	end

	local amountText = amount;
	if self.formatter then
		amountText = self.formatter(amount);
	end

	local colorblindMode = ENABLE_COLORBLIND_MODE == "1";
	if colorblindMode then
		amountText = amountText..AUCTIONATOR_IMPORT_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE[self.displayType];
	end

	self.Text:SetText(amountText);
	self.Icon:SetShown(not colorblindMode);

	self:UpdateWidth();
end

function AuctionatorRetailImportMoneyDenominationDisplayMixin:UpdateWidth()
	local iconWidth = self.Icon:IsShown() and self.Icon:GetWidth() or 0;
	local iconSpacing = 2;
	self.Text:SetPoint("RIGHT", -(iconWidth + iconSpacing), 0);
	self:SetWidth(self.Text:GetStringWidth() + iconWidth + iconSpacing);
end


AuctionatorRetailImportMoneyDisplayFrameMixin = {};

local DENOMINATION_DISPLAY_WIDTH = 36; -- Space for two characters and an anchor offset.

function AuctionatorRetailImportMoneyDisplayFrameMixin:OnLoad()
	self.CopperDisplay:SetShowsZeroAmount(true);
	self.SilverDisplay:SetShowsZeroAmount(true);
	self.GoldDisplay:SetFormatter(BreakUpLargeNumbers);

	if self.hideCopper then
		self.CopperDisplay:SetForcedHidden(true);
	end

	if self.useAuctionHouseIcons then
		self.CopperDisplay:SetDisplayType(AuctionatorRetailImportMoneyDenominationDisplayType.AuctionHouseCopper);
		self.SilverDisplay:SetDisplayType(AuctionatorRetailImportMoneyDenominationDisplayType.AuctionHouseSilver);
		self.GoldDisplay:SetDisplayType(AuctionatorRetailImportMoneyDenominationDisplayType.AuctionHouseGold);
	end

	self:UpdateAnchoring();
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:SetFontAndIconDisabled(disabled)
	self.CopperDisplay:SetFontAndIconDisabled(disabled);
	self.SilverDisplay:SetFontAndIconDisabled(disabled);
	self.GoldDisplay:SetFontAndIconDisabled(disabled);

	if self.resizeToFit then
		self:UpdateWidth();
	end
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:SetFontObject(fontObject)
	self.CopperDisplay:SetFontObject(fontObject);
	self.SilverDisplay:SetFontObject(fontObject);
	self.GoldDisplay:SetFontObject(fontObject);

	if self.resizeToFit then
		self:UpdateWidth();
	end
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:GetFontObject()
	return self.CopperDisplay:GetFontObject();
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:UpdateAnchoring()
	self.CopperDisplay:ClearAllPoints();
	self.SilverDisplay:ClearAllPoints();
	self.GoldDisplay:ClearAllPoints();

	if self.leftAlign then
		self.GoldDisplay:SetPoint("LEFT");

		if self.GoldDisplay:ShouldBeShown() then
			self.SilverDisplay:SetPoint("RIGHT", self.GoldDisplay, "RIGHT", DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.SilverDisplay:SetPoint("LEFT", self.GoldDisplay, "LEFT");
		end
		
		if self.SilverDisplay:ShouldBeShown() then
			self.CopperDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT", DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.CopperDisplay:SetPoint("LEFT", self.SilverDisplay, "LEFT");
		end
	else
		self.CopperDisplay:SetPoint("RIGHT");

		if self.CopperDisplay:ShouldBeShown() then
			self.SilverDisplay:SetPoint("RIGHT", -DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.SilverDisplay:SetPoint("RIGHT", self.CopperDisplay, "RIGHT");
		end
		
		if self.SilverDisplay:ShouldBeShown() then
			self.GoldDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT", -DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.GoldDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT");
		end
	end
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:SetAmount(rawCopper)
	self.rawCopper = rawCopper;
	
	local gold = floor(rawCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((rawCopper - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(rawCopper, COPPER_PER_SILVER);
	self.GoldDisplay:SetAmount(gold);
	self.SilverDisplay:SetAmount(silver);
	self.CopperDisplay:SetAmount(copper);

	if self.resizeToFit then
		self:UpdateWidth();
	else
		self:UpdateAnchoring();
	end
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:UpdateWidth()
	local width = 0;
	local goldDisplayed = self.GoldDisplay:IsShown()
	if goldDisplayed then
		width = width + self.GoldDisplay:GetWidth();
	end

	local silverDisplayed = self.SilverDisplay:IsShown();
	if silverDisplayed then
		if goldDisplayed then
			width = width + DENOMINATION_DISPLAY_WIDTH;
		else
			width = width + self.SilverDisplay:GetWidth();
		end
	end

	if self.CopperDisplay:IsShown() then
		if goldDisplayed or silverDisplayed then
			width = width + DENOMINATION_DISPLAY_WIDTH;
		else
			width = width + self.CopperDisplay:GetWidth();
		end
	end

	self:SetWidth(width);
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:GetAmount()
	return self.rawCopper;
end

function AuctionatorRetailImportMoneyDisplayFrameMixin:SetResizeToFit(resizeToFit)
	self.resizeToFit = resizeToFit;
end
