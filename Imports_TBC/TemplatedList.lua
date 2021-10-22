AuctionatorRetailImportTemplatedListElementMixin = {};

function AuctionatorRetailImportTemplatedListElementMixin:InitElement(...)
	-- Override in your mixin.
end

function AuctionatorRetailImportTemplatedListElementMixin:UpdateDisplay()
	-- Override in your mixin.
	assert("Your templated list element must define a display method");
end

function AuctionatorRetailImportTemplatedListElementMixin:OnSelected()
	-- Override in your mixin.
end

function AuctionatorRetailImportTemplatedListElementMixin:OnEnter()
	-- Override in your mixin.
end

function AuctionatorRetailImportTemplatedListElementMixin:OnLeave()
	-- Override in your mixin.
end

function AuctionatorRetailImportTemplatedListElementMixin:Populate(listIndex)
	self.listIndex = listIndex;
	self:UpdateDisplay();
end

function AuctionatorRetailImportTemplatedListElementMixin:OnClick()
	self:GetList():SetSelectedListIndex(self.listIndex);
	self:OnSelected();
end

function AuctionatorRetailImportTemplatedListElementMixin:IsSelected()
	return self:GetListIndex() == self:GetList():GetSelectedListIndex();
end

function AuctionatorRetailImportTemplatedListElementMixin:GetListIndex()
	return self.listIndex;
end

function AuctionatorRetailImportTemplatedListElementMixin:GetList()
	return self:GetParent();
end


AuctionatorRetailImportTemplatedListMixin = {};

function AuctionatorRetailImportTemplatedListMixin:SetElementTemplate(elementTemplate, ...)
	if self.elementTemplate ~= nil then
		assert("You cannot change the element template once it is set, as the necessary frames may have already been created from the old template.");
		return;
	end

	self.elementTemplate = elementTemplate;
	self.elementTemplateInitArgs = SafePack(...);
end

function AuctionatorRetailImportTemplatedListMixin:SetGetNumResultsFunction(getNumResultsFunction)
	self.getNumResultsFunction = getNumResultsFunction;
	self:ResetList();
end

function AuctionatorRetailImportTemplatedListMixin:SetSelectionCallback(selectionCallback)
	self.selectionCallback = selectionCallback;
end

function AuctionatorRetailImportTemplatedListMixin:SetRefreshCallback(refreshCallback)
	self.refreshCallback = refreshCallback;
end

function AuctionatorRetailImportTemplatedListMixin:GetSelectedHighlight()
	return self.ArtOverlay.SelectedHighlight;
end

function AuctionatorRetailImportTemplatedListMixin:OnShow()
	self:CheckListInitialization();
	self:RefreshListDisplay();
end

function AuctionatorRetailImportTemplatedListMixin:IsInitialized()
	return self.isInitialized;
end

function AuctionatorRetailImportTemplatedListMixin:CheckListInitialization()
	if self.isInitialized or (self:GetElementTemplate() == nil) or not self:CanInitialize() then
		return;
	end

	self:InitializeList();
	self:InitializeElements();
	
	self.isInitialized = true;
end

function AuctionatorRetailImportTemplatedListMixin:GetElementTemplate()
	return self.elementTemplate;
end

function AuctionatorRetailImportTemplatedListMixin:GetElementInitializationArgs()
	return SafeUnpack(self.elementTemplateInitArgs);
end

function AuctionatorRetailImportTemplatedListMixin:InitializeElements()
	-- We use a local sub-function to capture the variadic parameters and avoid unpacking multiple times.
	local function InitializeAllElementFrames(...)
		for i = 1, self:GetNumElementFrames() do
			self:GetElementFrame(i):InitElement(...);
		end
	end

	InitializeAllElementFrames(self:GetElementInitializationArgs());
end

function AuctionatorRetailImportTemplatedListMixin:UpdatedSelectedHighlight()
	local selectedHighlight = self:GetSelectedHighlight();
	selectedHighlight:ClearAllPoints();
	selectedHighlight:Hide();

	local selectedListIndex = self:GetSelectedListIndex();
	if self.isInitialized and selectedListIndex ~= nil then
		local elementOffset = selectedListIndex - self:GetListOffset();
		if elementOffset >= 1 and elementOffset <= self:GetNumElementFrames() then
			local elementFrame = self:GetElementFrame(elementOffset);
			self:AttachHighlightToElementFrame(selectedHighlight, elementFrame);
		end
	end
end

function AuctionatorRetailImportTemplatedListMixin:AttachHighlightToElementFrame(selectedHighlight, elementFrame)
	local elementFrame = self:GetElementFrame(elementOffset);
	selectedHighlight:SetPoint("CENTER", elementFrame, "CENTER", 0, 0);
	selectedHighlight:Show();
end

function AuctionatorRetailImportTemplatedListMixin:SetSelectedListIndex(listIndex, skipUpdates)
	local sameIndex = selectedListIndex == listIndex;
	self.selectedListIndex = listIndex;

	if not skipUpdates then
		if self.selectionCallback then
			self.selectionCallback(listIndex);
		end
	end

	if sameIndex or skipUpdates then
		return;
	end

	self:RefreshListDisplay();
end

function AuctionatorRetailImportTemplatedListMixin:GetSelectedListIndex()
	return self.selectedListIndex;
end

function AuctionatorRetailImportTemplatedListMixin:ResetList()
	if self.isInitialized then
		self:ResetDisplay();
	end
end

function AuctionatorRetailImportTemplatedListMixin:CanDisplay()
	if self.elementTemplate == nil then
		return false, "Templated list elementTemplate not set. Use AuctionatorRetailImportTemplatedListMixin:SetElementTemplate.";
	end

	if self.getNumResultsFunction == nil then
		return false, "Templated list getNumResultsFunction not set. Use AuctionatorRetailImportTemplatedListMixin:SetGetNumResultsFunction.";
	end

	if not self.isInitialized then
		return false, "Templated list has not been initialized. This should generally happen in OnShow.";
	end

	return true, nil;
end

function AuctionatorRetailImportTemplatedListMixin:RefreshListDisplay()
	if not self:IsVisible() then
		return;
	end

	local canDisplay, displayError = self:CanDisplay();
	if not canDisplay then
		error(displayError);
		return;
	end

	local numResults = self.getNumResultsFunction();
	local lastDisplayedOffset = self:DisplayList(numResults);
	
	self:UpdatedSelectedHighlight();

	if self.refreshCallback ~= nil then
		self.refreshCallback(lastDisplayedOffset);
	end
end

function AuctionatorRetailImportTemplatedListMixin:DisplayList(numResults)
	local listOffset = self:GetListOffset();
	local numElementFrames = self:GetNumElementFrames();
	local lastDisplayedOffset = 0;

	for i = 1, numElementFrames do
		local listIndex = listOffset + i;
		local elementFrame = self:GetElementFrame(i);

		if listIndex <= numResults then
			elementFrame:Populate(listIndex);
			elementFrame:Show();
			lastDisplayedOffset = i;
		else
			elementFrame:Hide();
		end
	end
	
	return lastDisplayedOffset;
end

function AuctionatorRetailImportTemplatedListMixin:EnumerateElementFrames()
	local numElementFrames = self:GetNumElementFrames();
	local elementFrameIndex = 0;
	local function ElementFrameIterator()
		elementFrameIndex = elementFrameIndex + 1;

		if elementFrameIndex > numElementFrames then
			return nil;
		end

		return self:GetElementFrame(elementFrameIndex);
	end

	return ElementFrameIterator;
end

function AuctionatorRetailImportTemplatedListMixin:CanInitialize()
	return true; -- May be implemented by derived mixins.
end

function AuctionatorRetailImportTemplatedListMixin:InitializeList()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionatorRetailImportTemplatedListMixin:GetNumElementFrames()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionatorRetailImportTemplatedListMixin:GetElementFrame(frameIndex)
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionatorRetailImportTemplatedListMixin:GetListOffset()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function AuctionatorRetailImportTemplatedListMixin:ResetDisplay()
	-- Implemented by derived mixins.
end
