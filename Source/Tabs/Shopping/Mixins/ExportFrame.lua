AuctionatorListExportFrameMixin = {}

function AuctionatorListExportFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListExportFrameMixin:OnLoad()")

  self:InitializeCheckBoxes()
  self.copyTextDialog = CreateFrame("Frame", nil, self:GetParent(), "AuctionatorExportTextFrame")
  self.copyTextDialog:SetPoint("CENTER")

  -- self.ExportOption:SetOnChange(function(selectedValue)
  --   if selectedValue == Auctionator.Constants.EXPORT_TYPES.WHISPER then
  --     self.Recipient:Show()
  --     self.Recipient:SetFocus()
  --   else
  --     self.Recipient:Hide()
  --   end
  -- end)
  -- self.ExportOption:SetSelectedValue(Auctionator.Constants.EXPORT_TYPES.STRING)
end

function AuctionatorListExportFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorListExportFrameMixin:OnShow()")

  self:RefreshLists()

  Auctionator.EventBus
    :RegisterSource(self, "lists export dialog 1")
    :Fire(self, Auctionator.Shopping.Tab.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorListExportFrameMixin:OnHide()
  self:Hide()

  Auctionator.EventBus
    :RegisterSource(self, "lists export dialog 1")
    :Fire(self, Auctionator.Shopping.Tab.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorListExportFrameMixin:InitializeCheckBoxes()
  local view = CreateScrollBoxLinearView()
  view:SetPadding(5, 5, 0, 0, 0)
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

  self.ScrollBox.ListListingFrame.OnCleaned = function()
    self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
  end

  self.checkBoxPool = {}
  self.listCount = Auctionator.Shopping.ListManager:GetCount()

  -- Create enough frames for current number of lists
  for i = 1, self.listCount do
    self:AddToPool()
  end

  -- Listen for create/delete events to add more to pool if necessary
  Auctionator.EventBus:Register(self, { Auctionator.Shopping.Events.ListMetaChange })
end

function AuctionatorListExportFrameMixin:AddToPool()
  local newIndex = #self.checkBoxPool + 1

  table.insert(self.checkBoxPool, CreateFrame(
      "FRAME",
      "ExportListCheckbox" .. newIndex,
      self.ScrollBox.ListListingFrame,
      "AuctionatorConfigurationCheckbox"
    )
  )

  self.checkBoxPool[newIndex]:SetHeight( self.checkBoxPool[newIndex]:GetHeight() / 2 )

  if newIndex == 1 then
    self.checkBoxPool[newIndex]:SetPoint("TOPLEFT", self.ScrollBox.ListListingFrame, "TOPLEFT", 0, 0)
    self.checkBoxPool[newIndex]:SetPoint("TOPRIGHT", self.ScrollBox.ListListingFrame, "TOPRIGHT", 0, 0)
  else
    self.checkBoxPool[newIndex]:SetPoint("TOPLEFT", self.checkBoxPool[newIndex - 1], "BOTTOMLEFT", 0, -3)
    self.checkBoxPool[newIndex]:SetPoint("TOPRIGHT", self.checkBoxPool[newIndex - 1], "BOTTOMRIGHT", 0, -3)
  end

end

function AuctionatorListExportFrameMixin:ReceiveEvent(eventName, listName)
  if eventName == Auctionator.Shopping.Events.ListMetaChange then
    -- On list creation, increment listCount, and add a new check box
    -- to our pool, if necesssary
    self.listCount = Auctionator.Shopping.ListManager:GetCount()

    if #self.checkBoxPool < self.listCount then
      self:AddToPool()
    end
  end
end

function AuctionatorListExportFrameMixin:RefreshLists()
  Auctionator.Debug.Message("AuctionatorListExportFrameMixin:RefreshLists()")

  for _, checkbox in ipairs(self.checkBoxPool) do
    checkbox:Hide()
  end

  for index = 1, Auctionator.Shopping.ListManager:GetCount() do
    local list = Auctionator.Shopping.ListManager:GetByIndex(index)
    self.checkBoxPool[index]:SetText(list:GetName())
    self.checkBoxPool[index]:Show()
  end

  self.ScrollBox.ListListingFrame:MarkDirty()
end

function AuctionatorListExportFrameMixin:OnCloseDialogClicked()
  self:Hide()
end

function AuctionatorListExportFrameMixin:OnSelectAllClicked()
  for _, checkbox in ipairs(self.checkBoxPool) do
    checkbox:SetChecked(true)
  end
end

function AuctionatorListExportFrameMixin:OnUnselectAllClicked()
  for _, checkbox in ipairs(self.checkBoxPool) do
    checkbox:SetChecked(false)
  end
end

function AuctionatorListExportFrameMixin:OnExportClicked()
  local exportString = ""

  for _, checkbox in ipairs(self.checkBoxPool) do
    if checkbox:IsVisible() and checkbox:GetChecked() then
      exportString = exportString .. Auctionator.Shopping.Lists.GetBatchExportString(checkbox:GetText()) .. "\n"
    end
  end

  -- if self.ExportOption:GetValue() == 0 then
    self:Hide()
    self.copyTextDialog:SetExportString(exportString)
    self.copyTextDialog:Show()
  -- else
    -- Addon messages can not exceed 254 characters, so do lists one by one?
    -- for _, checkbox in ipairs(self.checkBoxPool) do
    --   if checkbox:IsVisible() and checkbox:GetChecked() then
    --     C_ChatInfo.SendAddonMessage( "Auctionator", Auctionator.Shopping.Lists.GetBatchExportString(checkbox:GetText()), "WHISPER", self.Recipient:GetText())
    --   end
    -- end
    -- C_ChatInfo.SendAddonMessage( "Auctionator", exportString, "WHISPER", self.Recipient:GetText())
  -- end

end
