local ColumnWidthConstraints = {
	Fill = 1, -- Width will be distributed by available space.
	Fixed = 2, -- Width is specified when initializing the column.
};

-- Any row or cell is expected to initialize itself in terms of the row data. The dataIndex is provided
-- in case the derived mixin needs to make additional CAPI calls involving it's relative index. The row
-- data may also be needed for a tooltip, so it will be assigned to the row and cells on update.
AuctionatorRetailImportTableBuilderElementMixin = {};

--Derive
function AuctionatorRetailImportTableBuilderElementMixin:Init(...)
end

--Derive
function AuctionatorRetailImportTableBuilderElementMixin:Populate(rowData, dataIndex)
end

AuctionatorRetailImportTableBuilderCellMixin = CreateFromMixins(AuctionatorRetailImportTableBuilderElementMixin);

--Derive
function AuctionatorRetailImportTableBuilderCellMixin:OnLineEnter()
end

--Derive
function AuctionatorRetailImportTableBuilderCellMixin:OnLineLeave()
end


AuctionatorRetailImportTableBuilderRowMixin = CreateFromMixins(AuctionatorRetailImportTableBuilderElementMixin);

--Derive
function AuctionatorRetailImportTableBuilderRowMixin:OnLineEnter()
end

--Derive
function AuctionatorRetailImportTableBuilderRowMixin:OnLineLeave()
end


function AuctionatorRetailImportTableBuilderRowMixin:OnEnter()
	self:OnLineEnter();
	for i, cell in ipairs(self.cells) do
		cell:OnLineEnter();
	end
end

function AuctionatorRetailImportTableBuilderRowMixin:OnLeave()
	self:OnLineLeave();
	for i, cell in ipairs(self.cells) do
		cell:OnLineLeave();
	end
end

-- Defines an entire column within the table builder, by default a column's sizing constraints are set to fill.
AuctionatorRetailImportTableBuilderColumnMixin = {};
function AuctionatorRetailImportTableBuilderColumnMixin:Init(table)
	self.cells = {};
	self.table = table;

	local fillCoefficient = 1.0;
	local padding = 0;
	self:SetFillConstraints(fillCoefficient, padding);
end

-- Constructs the header frame with an optional initializer.
function AuctionatorRetailImportTableBuilderColumnMixin:ConstructHeader(templateType, template, ...)
	local frame = self.table:ConstructHeader(templateType, template);
	self.headerFrame = frame;
	if frame.Init then
		frame:Init(...);
	end
	frame:Show();
end

-- Constructs cells corresponding to each row with an optional initializer.
function AuctionatorRetailImportTableBuilderColumnMixin:ConstructCells(templateType, template, ...)
	local cells = self.table:ConstructCells(templateType, template);
	self.cells = cells;
	for k, cell in pairs(cells) do
		if cell.Init then
			cell:Init(...);
		end
		cell:Show();
	end
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetCellByRowIndex(rowIndex)
	return self.cells[rowIndex];
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetFillCoefficient()
	return self.fillCoefficient;
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetFillCoefficient(fillCoefficient)
	self.fillCoefficient = fillCoefficient;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetPadding()
	return self.padding;
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetPadding(padding)
	self.padding = padding;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetCellPadding()
	return self.leftCellPadding or 0, self.rightCellPadding or 0;
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetCellPadding(leftCellPadding, rightCellPadding)
	self.leftCellPadding = leftCellPadding;
	self.rightCellPadding = rightCellPadding;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetHeaderFrame()
	return self.headerFrame;
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetHeaderFrame(headerFrame)
	self.headerFrame = headerFrame;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetWidthConstraints()
	return self.widthConstraints;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetFixedWidth()
	return self.fixedWidth;
end

-- A header frame for the column is expected to be constructed or assigned prior to calling this.
-- See ConstructHeader() or SetHeaderFrame().
function AuctionatorRetailImportTableBuilderColumnMixin:ConstrainToHeader(padding)
	local header = self:GetHeaderFrame();
	assert(header, "ConstrainToHeader() called with a nil header frame. Use ConstructHeader() or assign one with SetHeaderFrame(), or use SetFixedConstraints to have a headerless column.");
	self:SetFixedConstraints(header:GetWidth(), padding or 0);
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetFixedConstraints(fixedWidth, padding)
	self.widthConstraints = ColumnWidthConstraints.Fixed;
	self.fixedWidth = fixedWidth;
	self:SetFillCoefficient(0);
	self:SetPadding(padding or 0);
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetFillConstraints(fillCoefficient, padding)
	self.widthConstraints = ColumnWidthConstraints.Fill;
	self.fixedWidth = 0;
	self:SetFillCoefficient(fillCoefficient);
	self:SetPadding(padding or 0);
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetCalculatedWidth(calculatedWidth)
	self.calculatedWidth = calculatedWidth;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetCalculatedWidth()
	return self.calculatedWidth;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetCellWidth()
	local leftCellPadding, rightCellPadding = self:GetCellPadding();
	return (self.calculatedWidth - leftCellPadding) - rightCellPadding;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetFullWidth()
	return self:GetCalculatedWidth() + self:GetPadding();
end

function AuctionatorRetailImportTableBuilderColumnMixin:SetDisplayUnderPreviousHeader(displayUnderPreviousHeader)
	self.displayUnderPreviousHeader = displayUnderPreviousHeader;
end

function AuctionatorRetailImportTableBuilderColumnMixin:GetDisplayUnderPreviousHeader()
	return self.displayUnderPreviousHeader;
end

-- Constructs a table of frames within an existing set of row frames. These row frames could originate from
-- a hybrid scroll frame or statically fixed set. To populate the table, assign a data provider (CAPI or lua function)
-- that can retrieve an object by index (number).
AuctionatorRetailImportTableBuilderMixin = {};
function AuctionatorRetailImportTableBuilderMixin:Init(rows)
	self.columns = {};
	self.leftMargin = 0;
	self.rightMargin = 0;
	self.columnHeaderOverlap = 0;
	self.tableWidth = 0;
	self.headerPoolCollection = CreateFramePoolCollection();
	self:SetRows(rows);
end

function AuctionatorRetailImportTableBuilderMixin:GetDataProvider()
	return self.dataProvider;
end

function AuctionatorRetailImportTableBuilderMixin:SetDataProvider(dataProvider)
	self.dataProvider = dataProvider;
end

function AuctionatorRetailImportTableBuilderMixin:GetDataProviderData(dataIndex)
	local dataProvider = self:GetDataProvider();
	return dataProvider and dataProvider(dataIndex) or nil;
end

-- Controls the margins of the left-most and right-most columns within the table.
function AuctionatorRetailImportTableBuilderMixin:SetTableMargins(leftMargin, rightMargin)
	rightMargin = rightMargin or leftMargin; -- Use leftMargin as the default for both.
	self.leftMargin = leftMargin;
	self.rightMargin = rightMargin;
end

-- Column headers overlap to make a consistent display.
function AuctionatorRetailImportTableBuilderMixin:SetColumnHeaderOverlap(columnHeaderOverlap)
	self.columnHeaderOverlap = columnHeaderOverlap;
end

-- Can be used to set the table width, particularly if no header frames are involved.
function AuctionatorRetailImportTableBuilderMixin:SetTableWidth(tableWidth)
	self.tableWidth = tableWidth;
end

function AuctionatorRetailImportTableBuilderMixin:GetTableWidth()
	return self.tableWidth;
end

function AuctionatorRetailImportTableBuilderMixin:GetTableMargins()
	return self.leftMargin, self.rightMargin;
end

function AuctionatorRetailImportTableBuilderMixin:GetColumnHeaderOverlap()
	return self.columnHeaderOverlap;
end

function AuctionatorRetailImportTableBuilderMixin:GetColumns()
	return self.columns;
end

function AuctionatorRetailImportTableBuilderMixin:GetHeaderContainer()
	return self.headerContainer;
end

function AuctionatorRetailImportTableBuilderMixin:SetHeaderContainer(headerContainer)
	assert(headerContainer, "SetHeaderContainer() with a nil header container. Use ConstructHeader() or assign one with SetHeaderFrame(), or use SetFixedConstraints to have a headerless column.");
	self.headerContainer = headerContainer;
	self:SetTableWidth(headerContainer:GetWidth());
end

function AuctionatorRetailImportTableBuilderMixin:ReleaseRowPools()
	local rows = self.rows;
	if rows then
		for k, row in pairs(rows) do
			local poolCollection = row.poolCollection;
			if poolCollection then
				poolCollection:ReleaseAll();
			end
		end
	end
end

function AuctionatorRetailImportTableBuilderMixin:SetRows(rows)
	-- Release any previous rows, though I can't imagine a case where the rows
	-- are being exchanged.
	self:ReleaseRowPools();

	self.rows = rows;
	for k, row in pairs(rows) do
		if not row.poolCollection then
			row.poolCollection = CreateFramePoolCollection();
		end
	end
end

function AuctionatorRetailImportTableBuilderMixin:GetHeaderPoolCollection()
	return self.headerPoolCollection;
end

function AuctionatorRetailImportTableBuilderMixin:GetRows()
	return self.rows;
end

function AuctionatorRetailImportTableBuilderMixin:ConstructHeader(templateType, template)
	local headerContainer = self:GetHeaderContainer();
	assert(headerContainer ~= nil, "A header container must be set with AuctionatorRetailImportTableBuilderMixin:SetHeaderContainer before adding column headers.")
	local headerPoolCollection = self:GetHeaderPoolCollection();
	local pool = headerPoolCollection:GetOrCreatePool(templateType, headerContainer, template);
	return pool:Acquire(template);
end

function AuctionatorRetailImportTableBuilderMixin:ConstructCells(templateType, template)
	local cells = {};
	for k, row in pairs(self:GetRows()) do
		local pool = row.poolCollection:GetOrCreatePool(templateType, row, template);
		local cell = pool:Acquire(template);
		tinsert(cells, cell);
	end
	return cells;
end

function AuctionatorRetailImportTableBuilderMixin:Arrange()
	local columns = self:GetColumns();
	if columns and #columns > 0 then
		self:CalculateColumnSpacing();
		self:ArrangeHeaders();
		self:ArrangeCells();
	end
end

function AuctionatorRetailImportTableBuilderMixin:Reset()
	self.columns = {};
	self:GetHeaderPoolCollection():ReleaseAll();
	self:ReleaseRowPools();
end

function AuctionatorRetailImportTableBuilderMixin:Populate(offset, count)
	local dataProvider = self:GetDataProvider();
	local columns = self:GetColumns();
	for rowIndex = 1, count do
		local dataIndex = rowIndex + offset;
		local rowData = dataProvider(dataIndex);
		if not rowData then
			break;
		end

		local row = self:GetRowByIndex(rowIndex);
		if row then
			-- Data is assigned to the rows and elements so they can
			-- access it later in tooltips.
			row.rowData = rowData;
			if row.Populate then
				row:Populate(rowData, dataIndex);
			end

			for columnIndex, p in ipairs(columns) do
				local cell = self:GetCellByIndex(rowIndex, columnIndex);
				if cell.Populate then
					cell.rowData = rowData;
					cell:Populate(rowData, dataIndex);
				end
			end
		end
	end
end

function AuctionatorRetailImportTableBuilderMixin:GetCellByIndex(rowIndex, index)
	local row = self:GetRowByIndex(rowIndex);
	return row.cells[index];
end

function AuctionatorRetailImportTableBuilderMixin:GetRowByIndex(rowIndex)
	return self.rows[rowIndex];
end

function AuctionatorRetailImportTableBuilderMixin:AddColumn()
	local column = CreateAndInitFromMixin(AuctionatorRetailImportTableBuilderColumnMixin, self);
	tinsert(self.columns, column);
	return column;
end

function AuctionatorRetailImportTableBuilderMixin:CalculateColumnSpacing()
	-- The arrangement of frames is daisy-chained left to right. The margin on the left side
	-- is created by adding the margin to it's anchor offset, and the margin on the right side
	-- is created by subtracting space from the remaining fill space.
	local columns = self:GetColumns();
	local paddingTotal = 0;
	local fillCoefficientTotal = 0;
	local fixedWidthTotal = 0;
	for columnIndex, column in ipairs(columns) do
		if column:GetWidthConstraints() == ColumnWidthConstraints.Fill then
			fillCoefficientTotal = fillCoefficientTotal + column:GetFillCoefficient();
		else
			fixedWidthTotal = fixedWidthTotal + column:GetFixedWidth();
		end

		paddingTotal = paddingTotal + column:GetPadding();
	end

	local tableWidth = self:GetTableWidth();
	local leftMargin, rightMargin = self:GetTableMargins();
	local fillWidthTotal = tableWidth - paddingTotal - (leftMargin + rightMargin) - fixedWidthTotal;
	for k, column in pairs(columns) do
		if fillCoefficientTotal > 0 and column:GetWidthConstraints() == ColumnWidthConstraints.Fill then
			local fillRatio = column:GetFillCoefficient() / fillCoefficientTotal;
			local width = fillRatio * fillWidthTotal;
			column:SetCalculatedWidth(width);
		else
			local width = column:GetFixedWidth();
			column:SetCalculatedWidth(width);
		end
	end
end

function AuctionatorRetailImportTableBuilderMixin:ArrangeHorizontally(frame, relativeTo, width, pointTop, pointRelativeTop, pointBottom, pointRelativeBottom, xOffset)
	frame:SetPoint(pointTop, relativeTo, pointRelativeTop, xOffset, 0);
	frame:SetPoint(pointBottom, relativeTo, pointRelativeBottom, xOffset, 0);
	frame:SetWidth(width);
end

function AuctionatorRetailImportTableBuilderMixin:ArrangeHeaders()
	local headerOverlap = self:GetColumnHeaderOverlap();
	local leftMargin, rightMargin = self:GetTableMargins();
	local columns = self:GetColumns();

	-- Any trailing columns without headers should add to the width of the last column with a header.
	local numColumns = #columns;
	local lastActiveHeaderIndex = numColumns;
	local trailingWidth = 0;
	for i, column in ipairs(columns) do
		if column:GetHeaderFrame() then
			trailingWidth = 0;
			lastActiveHeaderIndex = i;
		else
			trailingWidth = trailingWidth + column:GetFullWidth();
		end
	end

	local previousHeader = nil;
	local accumulatedWidth = 0;
	local columnIndex = 1;

	while columnIndex <= numColumns do
		local column = columns[columnIndex];
		accumulatedWidth = accumulatedWidth + column:GetCalculatedWidth();

		local isLastIndex = columnIndex == lastActiveHeaderIndex;
		local header = column:GetHeaderFrame();
		if header then
			if isLastIndex then
				accumulatedWidth = accumulatedWidth + trailingWidth;
			else
				for j = columnIndex + 1, #columns do
					local nextColumn = columns[j];
					if nextColumn:GetDisplayUnderPreviousHeader() then
						columnIndex = columnIndex + 1;
						accumulatedWidth = accumulatedWidth + nextColumn:GetFullWidth();
					else
						break;
					end
				end
			end

			if previousHeader == nil then
				self:ArrangeHorizontally(header, header:GetParent(), accumulatedWidth, "TOPLEFT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT", leftMargin);
			else
				self:ArrangeHorizontally(header, previousHeader, accumulatedWidth + headerOverlap, "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", column:GetPadding() - headerOverlap);
			end

			accumulatedWidth = 0;
			previousHeader = header;
		end

		if isLastIndex then
			break;
		end

		columnIndex = columnIndex + 1;
	end
end

function AuctionatorRetailImportTableBuilderMixin:ArrangeCells()
	local columns = self:GetColumns();
	local leftMargin, rightMargin = self:GetTableMargins();
	for rowIndex, row in ipairs(self:GetRows()) do
		local cells = {};
		local height = row:GetHeight();

		local column = columns[1];
		local cell = column:GetCellByRowIndex(rowIndex);
		tinsert(cells, cell);
		cell:SetHeight(height);
		local leftCellPadding, rightCellPadding = column:GetCellPadding();
		
		self:ArrangeHorizontally(cell, row, column:GetCellWidth(), "TOPLEFT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMLEFT", leftMargin + leftCellPadding);
		
		local previousCell = cell;
		local previousRightCellPadding = rightCellPadding;
		for columnIndex = 2, #columns do
			column = columns[columnIndex];
			cell = column:GetCellByRowIndex(rowIndex);
			tinsert(cells, cell);
			cell:SetHeight(height);
			leftCellPadding, rightCellPadding = column:GetCellPadding();

			self:ArrangeHorizontally(cell, previousCell, column:GetCellWidth(), "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", column:GetPadding() + leftCellPadding + previousRightCellPadding);
			previousCell = cell;
			previousRightCellPadding = rightCellPadding;
		end

		row.cells = cells;
	end
end

-- ... are additional mixins
function AuctionatorRetailImportCreateTableBuilder(rows, ...)
	local tableBuilder = CreateAndInitFromMixin(AuctionatorRetailImportTableBuilderMixin, rows);
	Mixin(tableBuilder, ...);
	return tableBuilder;
end
