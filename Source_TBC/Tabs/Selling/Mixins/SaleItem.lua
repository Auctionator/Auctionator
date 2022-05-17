local SALE_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
}

local function IsEquipment(itemInfo)
  return itemInfo.classId == Enum.ItemClass.Weapon or itemInfo.classId == Enum.ItemClass.Armor
end

local function IsValidItem(item)
  return item ~= nil and
    -- May be a favourite with no items available, ignore it.
    item.location ~= nil and
    -- Location may be invalid because of items being moved in the bag
    C_Item.DoesItemExist(item.location)
end

local function GetAmountWithUndercut(amount)
  local salesPreference = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE)
  local undercutAmount = 0
  if salesPreference == Auctionator.Config.SalesTypes.STATIC then
    undercutAmount = Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE)
  else
    undercutAmount = math.ceil(amount * Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE) / 100)
  end

  return math.max(0, amount - undercutAmount)
end


AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnLoad()
  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    self.PostButton:SetPoint("TOPLEFT", self.Duration, "BOTTOMLEFT", 20, 0)
    self.BidPrice:Show()
  end

  self:SetupTabbing()
  self.clickedSellItem = true
end

-- Make pressing tab work to jump between edit boxes in the SaleItemFrame
function AuctionatorSaleItemMixin:SetupTabbing()
  self.UnitPrice.MoneyInput:SetNextEditBox(self.StackPrice.MoneyInput.GoldBox)
  self.StackPrice.MoneyInput:SetNextEditBox(self.Stacks.NumStacks)
  self.Stacks.NumStacks.nextEditBox = self.Stacks.StackSize
  self.Stacks.StackSize.previousEditBox = self.Stacks.NumStacks

  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    self.Stacks.StackSize.nextEditBox = self.BidPrice.MoneyInput.GoldBox
    self.BidPrice.MoneyInput.GoldBox.previousEditBox = self.Stacks.StackSize
  end
end

function AuctionatorSaleItemMixin:OnShow()
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.Selling.Events.ConfirmPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Buying.Events.AuctionFocussed,
    Auctionator.Buying.Events.HistoricalPrice,
    Auctionator.Components.Events.EnterPressed,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorSaleItemMixin")

  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.SELLING_POST_SHORTCUT), "CLICK AuctionatorPostButton:LeftButton")
  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SKIP_SHORTCUT), "CLICK AuctionatorSkipPostingButton:LeftButton")

  self:UpdateSkipButton()
  self:Reset()
end

function AuctionatorSaleItemMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.Selling.Events.ConfirmPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Buying.Events.AuctionFocussed,
    Auctionator.Buying.Events.HistoricalPrice,
    Auctionator.Components.Events.EnterPressed,
  })
  Auctionator.EventBus:UnregisterSource(self)
  self:UnlockItem()
  ClearOverrideBindings(self)
end

function AuctionatorSaleItemMixin:UpdateSkipButton()
  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT) then
    self.PostButton:SetSize(104, 22)
    self.SkipButton:Show()
  else
    self.PostButton:SetSize(184, 22)
    self.SkipButton:Hide()
  end
end

function AuctionatorSaleItemMixin:UnlockItem()
  if self.itemInfo ~= nil then
    --Existence check added because of a bug report from a user where (for an
    --unknown reason) the item no longer existed.
    if self.itemInfo.count > 0 and C_Item.DoesItemExist(self.itemInfo.location) then
      C_Item.UnlockItem(self.itemInfo.location)
    end
    self.itemInfo = nil
  end
end

function AuctionatorSaleItemMixin:LockItem()
  if self.itemInfo.count > 0 then
    C_Item.LockItem(self.itemInfo.location)
  end
end

function AuctionatorSaleItemMixin:UpdatePrices()
  if self.UnitPrice:GetAmount() ~= self.prevUnitPrice then
    self.prevUnitPrice = self.UnitPrice:GetAmount()
    self.prevStackPrice = self.prevUnitPrice * self.prevStackSize
    self.StackPrice:SetAmount(self.prevStackPrice)
    self.BidPrice:SetAmount(self:GetAutoBidAmount())

  elseif self.StackPrice:GetAmount() ~= self.prevStackPrice then
    self.prevStackPrice = self.StackPrice:GetAmount()
    if self.prevStackSize ~= 0 then
      self.prevUnitPrice = math.ceil(self.prevStackPrice / self.prevStackSize)
      self.UnitPrice:SetAmount(self.prevUnitPrice)
      self.BidPrice:SetAmount(self:GetAutoBidAmount())
    end

  elseif self:GetStackSize() ~= self.prevStackSize then
    self.prevStackSize = self:GetStackSize()
    self.prevStackPrice = self:GetStackSize() * self.UnitPrice:GetAmount()
    self.StackPrice:SetAmount(self.prevStackPrice)
    self.BidPrice:SetAmount(self:GetAutoBidAmount())
    self:DisplayMaxNumStacks()
  end
end

function AuctionatorSaleItemMixin:OnUpdate()
  if not self.clickedSellItem then
    if Auctionator.AH.IsNotThrottled() then
      self:SellItemClick()
    end
    return

  elseif self.itemInfo == nil then
    return

  elseif self.itemInfo.count == 0 then
    return

  elseif not C_Item.DoesItemExist(self.itemInfo.location) then
    --Bag item location invalid due to posting (race condition)
    self.itemInfo = nil
    self:Reset()
    return
  end

  self:UpdatePrices()

  self.TotalPrice:SetText(
    Auctionator.Utilities.CreateMoneyString(
      self:GetNumStacks() * self:GetStackSize() * self.UnitPrice:GetAmount()
    )
  )

  self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(self:GetDeposit()))
  self:UpdatePostButtonState()
  self:UpdateSkipButtonState()
end

function AuctionatorSaleItemMixin:GetAutoBidAmount()
  local startingPricePercentage = Auctionator.Config.Get(Auctionator.Config.Options.STARTING_PRICE_PERCENTAGE) / 100
  return math.ceil(startingPricePercentage * self.StackPrice:GetAmount())
end

function AuctionatorSaleItemMixin:GetBidAmount()
  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    return self.BidPrice:GetAmount()
  else
    return self:GetAutoBidAmount()
  end
end

function AuctionatorSaleItemMixin:GetStackSize()
  return math.min(self.Stacks.StackSize:GetNumber(), math.min(self.itemInfo.count, self.itemInfo.stackSize))
end

function AuctionatorSaleItemMixin:GetNumStacks()
  return math.min(self.Stacks.NumStacks:GetNumber(), self.itemInfo.count)
end

function AuctionatorSaleItemMixin:GetDeposit()
  return GetAuctionDeposit(
    self:GetDuration(),
    math.min(self:GetBidAmount(), MAXIMUM_BID_PRICE),
    math.min(self.StackPrice:GetAmount(), MAXIMUM_BID_PRICE),
    self:GetStackSize(),
    self:GetNumStacks()
  )
end

-- We need to wait for whatever item is being posted to finish posting
-- before accepting the new item, hence the throttle check and this extra
-- function.
-- Also, when using right-click as a shortcut to select the item or reselecting
-- the same item this fails on the first couple of attempts.
function AuctionatorSaleItemMixin:SellItemClick()
  self.clickedSellItem = true

  ClearCursor()

  -- Remove any item already selected in the Auctions frame, as if it is the
  -- same as the item we're trying to add it will cause the add to fail.
  ClickAuctionSellItemButton()
  if C_Cursor.GetCursorItem() then
    Auctionator.Debug.Message("some sell item already selected")
    ClearCursor()
  end

  if IsValidItem(self.itemInfo) then
    if self.itemInfo.location:IsBagAndSlot() then
      PickupContainerItem(self.itemInfo.location:GetBagAndSlot())
    else
      PickupInventoryItem(self.itemInfo.location:GetEquipmentSlot())
    end

    ClickAuctionSellItemButton()
    ClearCursor()

    -- Check we didn't fail
    if (GetAuctionSellItemInfo()) ~= nil then
      Auctionator.Debug.Message("Valid sell item", GetAuctionSellItemInfo())
      self:LockItem()
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.RefreshBuying, self.itemInfo)
    -- Failed; this item can't be auctioned
    else
      Auctionator.Debug.Message("Invalid sell item")
      self.itemInfo = nil
      self:Update()
    end
  else
    if self.itemInfo ~= nil then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.RefreshBuying, self.itemInfo)
    end
    self.itemInfo = nil
  end
end

function AuctionatorSaleItemMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.BagItemClicked then
    local itemInfo = ...

    self:UnlockItem()
    self.clickedSellItem = false

    self.itemInfo = itemInfo

    if self.itemInfo ~= nil and self.itemInfo.stackSize == nil then
      self.itemInfo = nil

      local item
      if itemInfo.location ~= nil then
        item = Item:CreateFromItemLocation(itemInfo.location)
      else
        item = Item:CreateFromItemLink(itemInfo.itemLink)
      end

      item:ContinueOnItemLoad(function()
        itemInfo.stackSize = select(8, GetItemInfo(itemInfo.itemLink))
        self.itemInfo = itemInfo

        self:Update()
      end)
    end
    self:Update()

  elseif event == Auctionator.AH.Events.ThrottleUpdate then
    self:UpdatePostButtonState()

  elseif event == Auctionator.Selling.Events.RequestPost then
    self:PostItem()

  elseif event == Auctionator.Selling.Events.ConfirmPost then
    self:PostItem(true)

  elseif event == Auctionator.Components.Events.EnterPressed then
    self:PostItem()

  elseif event == Auctionator.Buying.Events.AuctionFocussed and
         self.itemInfo ~= nil then
    local info = ...
    if info ~= nil then
      self:UpdateForHistoryPrice(info.unitPrice)
      if not info.isOwned then
        self:SetUnitPrice(GetAmountWithUndercut(info.unitPrice))
      else
        self:SetUnitPrice(info.unitPrice)
      end
    end
  elseif event == Auctionator.Buying.Events.HistoricalPrice and
         self.itemInfo ~= nil then
    local price = ...
    self:SetUnitPrice(price)
  end
end

function AuctionatorSaleItemMixin:Update()
  self:UpdateVisuals()

  if self.itemInfo ~= nil then
    self:UpdateForNewItem()
  else
    self:UpdateForNoItem()
  end

  self:UpdatePostButtonState()
  self:UpdateSkipButtonState()
end

function AuctionatorSaleItemMixin:UpdateVisuals()
  self.Icon:SetItemInfo(self.itemInfo)

  if self.itemInfo ~= nil then
    self:SetItemName()

    self.Icon:HideCount()

  else
    -- No item, reset all the visuals
    self.TitleArea.Text:SetText("")
  end
end

-- The exact item name is only loaded when needed as it slows down loading the
-- bag items too much to do in BagDataProvider.
function AuctionatorSaleItemMixin:SetItemName()
  if self.itemInfo then
    local name = Auctionator.Utilities.GetNameFromLink(self.itemInfo.itemLink)
    local color = ITEM_QUALITY_COLORS[self.itemInfo.quality].color
    self.TitleArea.Text:SetText(color:WrapTextInColorCode(name))

    if IsEquipment(self.itemInfo) then
      local item = Item:CreateFromItemLink(self.itemInfo.itemLink)
      item:ContinueOnItemLoad(function()
        local itemLevel = GetDetailedItemLevelInfo(self.itemInfo.itemLink)
        self.TitleArea.Text:SetText(color:WrapTextInColorCode(name .. " (" .. itemLevel .. ")"))
      end)
    end
  end
end

function AuctionatorSaleItemMixin:UpdateForHistoryPrice(newPrice)
  if self.minPriceSeen == 0 then
    self.minPriceSeen = newPrice
  else
    self.minPriceSeen = math.min(self.minPriceSeen, newPrice)
  end
end

function AuctionatorSaleItemMixin:UpdateForNewItem()
  self:SetDuration()

  self.Stacks:SetMaxStackSize(math.min(self.itemInfo.stackSize, self.itemInfo.count))

  self:SetQuantity()

  Auctionator.Utilities.DBKeyFromLink(self.itemInfo.itemLink, function(dbKeys)
    local price = Auctionator.Database:GetFirstPrice(dbKeys)

    if price ~= nil then
      self:SetUnitPrice(price)
    elseif IsEquipment(self.itemInfo) then
      self:SetEquipmentMultiplier(self.itemInfo.itemLink)
    else
      self:SetUnitPrice(0)
    end
  end)

  self.minPriceSeen = 0
end

function AuctionatorSaleItemMixin:UpdateForNoItem()
  self.Stacks.NumStacks:SetNumber(0)
  self.Stacks.StackSize:SetNumber(0)
  self.Stacks:SetMaxStackSize(0)
  self.Stacks:SetMaxNumStacks(0)
  self:SetUnitPrice(0)

  self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(0))
  self.TotalPrice:SetText(Auctionator.Utilities.CreateMoneyString(0))
end

function AuctionatorSaleItemMixin:SetDuration()
  self.Duration:SetSelectedValue(
    Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_DURATION)
  )
end

function AuctionatorSaleItemMixin:SetQuantity()
  local defaultStacks = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_SELLING_STACKS)

  -- Determine what the stack size would be without using stack size memory.
  -- This is used to clear stack size memory when the max/min is used
  if defaultStacks.stackSize == 0 then
    self.normalStackSize = math.min(self.itemInfo.count, self.itemInfo.stackSize)
  else
    self.normalStackSize = math.min(defaultStacks.stackSize, self.itemInfo.stackSize)
  end

  local previousStackSize = Auctionator.Config.Get(Auctionator.Config.Options.STACK_SIZE_MEMORY)[Auctionator.Utilities.BasicDBKeyFromLink(self.itemInfo.itemLink)]

  if previousStackSize ~= nil then
    self.Stacks.StackSize:SetNumber(math.min(self.itemInfo.count, previousStackSize))
  else
    self.Stacks.StackSize:SetNumber(self.normalStackSize)
  end

  local numStacks = math.floor(self.itemInfo.count/self.Stacks.StackSize:GetNumber())
  if previousStackSize ~= nil and previousStackSize ~= 0 then
    numStacks = math.floor(self.itemInfo.count/previousStackSize)
  end

  if numStacks == 0 then
    numStacks = 1
  end

  if defaultStacks.numStacks == 0 then
    self.Stacks.NumStacks:SetNumber(numStacks)
  else
    self.Stacks.NumStacks:SetNumber(math.min(numStacks, defaultStacks.numStacks))
  end

  self:DisplayMaxNumStacks()
end

function AuctionatorSaleItemMixin:DisplayMaxNumStacks()
  local numStacks = math.floor(self.itemInfo.count / self:GetStackSize())
  if numStacks == 0 or self:GetStackSize() == 0 then
    numStacks = 1
  end

  self.Stacks:SetMaxNumStacks(numStacks)
end

function AuctionatorSaleItemMixin:Reset()
  self:UnlockItem()

  self:Update()
end

function AuctionatorSaleItemMixin:SetUnitPrice(salesPrice)
  if salesPrice == 0 then
    self.UnitPrice:SetAmount(0)
  else
    self.UnitPrice:SetAmount(salesPrice)
  end

  self.StackPrice:SetAmount(self.UnitPrice:GetAmount() * self.Stacks.StackSize:GetNumber())
  self.BidPrice:SetAmount(self:GetAutoBidAmount())

  self.prevStackSize = self.Stacks.StackSize:GetNumber()
  self.prevUnitPrice = self.UnitPrice:GetAmount()
  self.prevStackPrice = self.StackPrice:GetAmount()
end

function AuctionatorSaleItemMixin:SetEquipmentMultiplier(itemLink)
  self:SetUnitPrice(0)

  local item = Item:CreateFromItemLink(itemLink)
  item:ContinueOnItemLoad(function()
    local multiplier = Auctionator.Config.Get(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER)
    local vendorPrice = select(11, GetItemInfo(itemLink))
    if multiplier ~= 0 and vendorPrice ~= 0 then
      -- Check for a vendor price multiplier being set (and a vendor price)
      self:SetUnitPrice(
        vendorPrice * multiplier + self:GetDeposit()
      )
    end
  end)
end

function AuctionatorSaleItemMixin:GetCommodityResult(itemId)
  if C_AuctionHouse.GetCommoditySearchResultsQuantity(itemId) > 0 then
    return C_AuctionHouse.GetCommoditySearchResultInfo(itemId, 1)
  else
    return nil
  end
end

function AuctionatorSaleItemMixin:GetPostButtonState()
  return
    self.itemInfo ~= nil and
    self.itemInfo.count > 0 and
    self.clickedSellItem and

    C_Item.DoesItemExist(self.itemInfo.location) and

    self.StackPrice:GetAmount() <= MAXIMUM_BID_PRICE and

    -- Sufficient money to cover deposit
    GetMoney() > self:GetDeposit() and

    -- Valid quantity
    self.Stacks.NumStacks:GetNumber() > 0 and
    self.Stacks.StackSize:GetNumber() > 0 and
    self.Stacks.StackSize:GetNumber() <= self.itemInfo.stackSize and
    self.Stacks.NumStacks:GetNumber() * self.Stacks.StackSize:GetNumber() <= self.itemInfo.count and

    -- Positive price
    self.UnitPrice:GetAmount() > 0 and

    -- Not throttled
    Auctionator.AH.IsNotThrottled()
end

function AuctionatorSaleItemMixin:GetConfirmationMessage()
  -- Determine if the item is worth more to sell to a vendor than to post on the
  -- AH.
  local itemInfo = { GetItemInfo(self.itemInfo.itemLink) }
  local vendorPrice = itemInfo[Auctionator.Constants.ITEM_INFO.SELL_PRICE]
  if Auctionator.Utilities.IsVendorable(itemInfo) and
     vendorPrice * self:GetStackSize() * self:GetNumStacks() + self:GetDeposit()
       > math.floor(self.StackPrice:GetAmount() * self:GetNumStacks() * Auctionator.Constants.AfterAHCut) then
    return AUCTIONATOR_L_CONFIRM_POST_BELOW_VENDOR
  end
end

function AuctionatorSaleItemMixin:RequiresConfirmationState()
  return
    Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CONFIRM_LOW_PRICE) and
    self:GetConfirmationMessage() ~= nil
end

function AuctionatorSaleItemMixin:UpdatePostButtonState()
  if self:GetPostButtonState() then
    self.PostButton:Enable()
  else
    self.PostButton:Disable()
  end
end

function AuctionatorSaleItemMixin:UpdateSkipButtonState()
  self.SkipButton:SetEnabled(self.SkipButton:IsShown() and IsValidItem(self.itemInfo and self.itemInfo.nextItem))
end

local AUCTION_DURATIONS = {
  [12] = 1,
  [24] = 2,
  [48] = 3,
}

function AuctionatorSaleItemMixin:GetDuration()
  return AUCTION_DURATIONS[self.Duration:GetValue()]
end

function AuctionatorSaleItemMixin:PostItem(confirmed)
  if not self:GetPostButtonState() then
    Auctionator.Debug.Message("Trying to post when we can't. Returning")
    return
  elseif not confirmed and self:RequiresConfirmationState() then
    StaticPopupDialogs[Auctionator.Constants.DialogNames.SellingConfirmPost].text = self:GetConfirmationMessage()
    StaticPopup_Show(Auctionator.Constants.DialogNames.SellingConfirmPost)
    return
  end

  local numStacks = self.Stacks.NumStacks:GetNumber()
  local stackSize = self.Stacks.StackSize:GetNumber()
  local duration = self:GetDuration()
  local startingBid = self:GetBidAmount()
  local buyoutPrice = self.StackPrice:GetAmount()
  local deposit = self:GetDeposit()

  local stackSizeMemory = Auctionator.Config.Get(Auctionator.Config.Options.STACK_SIZE_MEMORY)
  local basicDBKey = Auctionator.Utilities.BasicDBKeyFromLink(self.itemInfo.itemLink)
  -- Only save stack size if its different to the global default
  if stackSize ~= self.normalStackSize then
    stackSizeMemory[basicDBKey] = stackSize
  else
    stackSizeMemory[basicDBKey] = nil
  end

  Auctionator.AH.PostAuction(startingBid, buyoutPrice, duration, stackSize, numStacks)

  --Print auction to chat
  if Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG) then
    Auctionator.Utilities.Message(Auctionator.Selling.ComposeAuctionPostedMessage({
      itemLink = self.itemInfo.itemLink,
      numStacks = numStacks,
      stackSize = stackSize,
      stackBuyout = buyoutPrice,
    }))
  end

  Auctionator.EventBus:Fire(self,
    Auctionator.Selling.Events.AuctionCreated,
    {
      itemLink = self.itemInfo.itemLink,
      quantity = numStacks * stackSize,
      buyoutAmount = self.UnitPrice:GetAmount(),
      bidAmount = startingBid,
      deposit = deposit,
    }
  )

  -- If not seen in any queries before this, then this price is the first one
  -- listed. Update the database to include this price.
  if self.minPriceSeen == 0 or self.minPriceSeen > self.UnitPrice:GetAmount() then
    local minPrice = self.UnitPrice:GetAmount()
    Auctionator.Utilities.DBKeyFromLink(self.itemInfo.itemLink, function(dbKeys)
      for _, key in ipairs(dbKeys) do
        Auctionator.Database:SetPrice(key, minPrice)
      end
    end)
  end

  -- Save item info for refreshing search results
  local lastItemInfo = self.itemInfo
  self:Reset()

  if (Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT) and
      IsValidItem(lastItemInfo.nextItem)
     ) then
    -- Option to automatically select the next item in the bag view
    Auctionator.EventBus:Fire(
      self, Auctionator.Selling.Events.BagItemClicked, lastItemInfo.nextItem
    )

  else
    -- Search for current auctions of the last item posted
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.RefreshBuying, lastItemInfo)
  end
end

function AuctionatorSaleItemMixin:SkipItem()
  if self.SkipButton:IsEnabled() then
    Auctionator.EventBus:Fire(
      self, Auctionator.Selling.Events.BagItemClicked, self.itemInfo.nextItem
    )
  end
end
