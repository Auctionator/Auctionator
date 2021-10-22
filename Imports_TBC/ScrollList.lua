AuctionatorRetailImportScrollListLineMixin = {};

function AuctionatorRetailImportScrollListLineMixin:GetList()
	local scrollFrame = self:GetParent():GetParent();
	return scrollFrame:GetParent();
end


AuctionatorRetailImportScrollListMixin = {};

function AuctionatorRetailImportScrollListMixin:InitializeList()
	self.ScrollFrame.update = function()
		self:RefreshListDisplay();
	end;

	HybridScrollFrame_CreateButtons(self.ScrollFrame, self:GetElementTemplate(), 0, 0);

	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);
end

function AuctionatorRetailImportScrollListMixin:GetNumElementFrames()
	return #self.ScrollFrame.buttons;
end

function AuctionatorRetailImportScrollListMixin:GetElementFrame(frameIndex)
	return self.ScrollFrame.buttons[frameIndex];
end

function AuctionatorRetailImportScrollListMixin:GetListOffset()
	return HybridScrollFrame_GetOffset(self.ScrollFrame);
end

function AuctionatorRetailImportScrollListMixin:ResetDisplay()
	self.ScrollFrame.scrollBar:SetValue(0);
end

function AuctionatorRetailImportScrollListMixin:DisplayList(numResults)
	local lastDisplayedOffset = TemplatedListMixin.DisplayList(self, numResults);

	local numDisplayed = math.min(self:GetNumElementFrames(), numResults);
	local elementHeight = self:GetElementFrame(1):GetHeight();
	local displayedHeight = numDisplayed * elementHeight;
	local totalHeight = numResults * elementHeight;
	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight);

	return lastDisplayedOffset;
end
function AuctionatorRetailImportScrollListMixin:AttachHighlightToElementFrame(selectedHighlight, elementFrame)
	selectedHighlight:SetPoint("TOPLEFT", elementFrame, "TOPLEFT", 4, 0);
	selectedHighlight:SetPoint("BOTTOMRIGHT", elementFrame, "BOTTOMRIGHT", 0, 0);
	selectedHighlight:Show();
end
