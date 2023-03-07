AuctionatorListImportFrameMixin = {}

function AuctionatorListImportFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorListImportFrameMixin:OnLoad()")

  self.ScrollFrame:SetHeight(self.Inset:GetHeight())
  self.ScrollFrame.ImportString:SetWidth(300)
end

function AuctionatorListImportFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorListImportFrameMixin:OnShow()")

  self.ScrollFrame.ImportString:SetFocus()

  Auctionator.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, Auctionator.Shopping.Tab.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorListImportFrameMixin:OnHide()
  self.ScrollFrame.ImportString:SetText("")
  self:Hide()
  Auctionator.EventBus
    :RegisterSource(self, "lists import dialog")
    :Fire(self, Auctionator.Shopping.Tab.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorListImportFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Events.ListImportFinished then
    Auctionator.EventBus:Unregister(self, { Auctionator.Shopping.Events.ListImportFinished })
    Auctionator.EventBus
      :RegisterSource(self, "lists import dialog")
      :Fire(self, Auctionator.Shopping.Tab.Events.ListCreated, Auctionator.Shopping.ListManager:GetByName(eventData))
      :UnregisterSource(self)
  end
end

function AuctionatorListImportFrameMixin:OnCloseDialogClicked()
  self:Hide()
end

function AuctionatorListImportFrameMixin:OnImportClicked()
  -- register finished event early as sometimes it fires immediately
  Auctionator.EventBus:Register(self, { Auctionator.Shopping.Events.ListImportFinished })

  local importString = self.ScrollFrame.ImportString:GetText()

  local waiting = true
  if string.match(importString, "%^") then
    Auctionator.Debug.Message("Import shopping list with 8.3+ format")
    Auctionator.Shopping.Lists.BatchImportFromString(importString)
  elseif string.match(importString, "%*") then
    Auctionator.Debug.Message("Import shopping list from old format")
    Auctionator.Shopping.Lists.OldBatchImportFromString(importString)
  elseif string.match(importString, "%,") then
    Auctionator.Debug.Message("Import shopping list from TSM group")
    Auctionator.Shopping.Lists.TSMImportFromString(importString)
  else
    waiting = false
  end

  -- Only listen for the import finished event if a valid format was detected
  if not waiting then
    Auctionator.EventBus:Unregister(self, { Auctionator.Shopping.Events.ListImportFinished })
  end

  self:Hide()
end
