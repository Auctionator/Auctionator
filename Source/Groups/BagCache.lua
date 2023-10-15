AuctionatorBagCacheMixin = {}
function AuctionatorBagCacheMixin:OnLoad()
  self.cache = {}
  self.loaders = {}
  self.contents = {}

  self.cacheOn = 0
  Auctionator.Groups.CallbackRegistry:RegisterCallback("BagCacheOn", function()
    self.cacheOn = self.cacheOn + 1
    if self.cacheOn > 0 then
      self:SetScript("OnUpdate", self.DoBagRefresh)
    end
  end)
  Auctionator.Groups.CallbackRegistry:RegisterCallback("BagCacheOff", function()
    self.cacheOn = self.cacheOn - 1
    if self.cacheOn <= 0 then
      self:SetScript("OnUpdate", self.DoBagRefresh)
    end
  end)
  self:RegisterEvent("BAG_UPDATE")
end

function AuctionatorBagCacheMixin:OnEvent(eventName, ...)
  if self.cacheOn > 0 and eventName == "BAG_UPDATE" then
    self:SetScript("OnUpdate", self.DoBagRefresh)
  end
end

local function SplitLink(linkString)
  return linkString:match("^(.*)|H(.-)|h(.*)$")
end

-- Assumes itemLink is in the format found at
-- https://wowpedia.fandom.com/wiki/ItemLink
-- itemID : enchantID : gemID1 : gemID2 : gemID3 : gemID4
-- : suffixID : uniqueID : linkLevel : specializationID : modifiersMask : itemContext
-- : numBonusIDs[:bonusID1:bonusID2:...] : numModifiers[:modifierType1:modifierValue1:...]
-- : relic1NumBonusIDs[:relicBonusID1:relicBonusID2:...] : relic2NumBonusIDs[...] : relic3NumBonusIDs[...]
-- : crafterGUID : extraEnchantID
local function KeyPartsItemLink(itemLink)
  local pre, hyperlink, post = SplitLink(itemLink)

  local parts = { strsplit(":", hyperlink) }

  -- offset by 1 because the first item in "item", not the id
  for i = 3, 7 do
    parts[i] = ""
  end

  -- Remove uniqueID, linkLevel, specializationID, modifiersMask and itemContext
  for i = 9, 13 do
    parts[i] = ""
  end

  local bonusIDStart = 14
  local numBonusIDs = tonumber(parts[14] or "") or 0
  local modStart = bonusIDStart + numBonusIDs + 1

  local numMods = tonumber(parts[modStart] or "") or 0
  -- complicated way to only keep the modifiers that affect item level and scrap
  -- any tmog/crafting details
  -- Details of modifiers at https://warcraft.wiki.gg/wiki/ItemLink#Modifier_Types
  if numMods > 0 then
    local wantedMods = {}
    for i = 1, numMods do
      local id = tonumber(parts[modStart + i * 2 - 1])
      -- timewalker level, artifact tier, pvp rating, dragonflight quality id
      if id == 9 or id == 24 or id == 26 or id == 38 then
        table.insert(wantedMods, id)
        table.insert(wantedMods, parts[modStart + i * 2])
      end
    end
    numMods = #wantedMods / 2
    parts[modStart] = tostring(numMods)
    for i = 1, #wantedMods do
      parts[modStart + i] = tostring(wantedMods[i])
    end
  end
  if numMods > 0 then
    for i = modStart + numMods * 2 + 1, #parts do
      parts[i] = nil
    end
  else
    for i = modStart, #parts do
      parts[i] = nil
    end
  end

  return Auctionator.Utilities.StringJoin(parts, ":")
end

local function KeyPartsPetLink(itemLink)
  local pre, hyperlink, post = SplitLink(itemLink)

  local parts = { strsplit(":", hyperlink) }

  local wantedBits = Auctionator.Utilities.Slice(parts, 1, 7)

  return Auctionator.Utilities.StringJoin(wantedBits, ":")
end

local function GetItemKey(entry)
  -- Battle pets
  if entry.classID == Enum.ItemClass.Battlepet then
    return "p:" .. KeyPartsPetLink(entry.itemLink)
  -- Equipment
  elseif Auctionator.Utilities.IsEquipment(entry.classID) then
    local cleanLink = KeyPartsItemLink(entry.itemLink)
    return "g:" .. strjoin("_", cleanLink, tostring(entry.auctionable))
  -- Everything else
  else
    return "i:" .. strjoin("_", tostring(entry.itemID), tostring(entry.auctionable))
  end
end

function AuctionatorBagCacheMixin:PostUpdate(bagContents)
  local byKey = {}
  for _, item in ipairs(bagContents) do
    if byKey[item.key] == nil then
      byKey[item.key] = {
        count = 0,
        entries = {}
      }
    end
    local existingEntry = byKey[item.key]
    existingEntry.count = existingEntry.count + item.itemCount
    table.insert(existingEntry.entries, item)
  end
  self.contents = byKey
  Auctionator.Groups.CallbackRegistry:TriggerEvent("BagCacheUpdated", self)
end

local linkInstantCache = {}
function AuctionatorBagCacheMixin:GetByLinkInstant(suppliedItemLink, auctionable)
  local entry = linkInstantCache[suppliedItemLink]

  if entry == nil then
    return
  end

  entry.auctionable = auctionable

  local key = GetItemKey(entry)
  local realEntry = self.contents[key]

  local itemCount = 0
  local locations = {}

  if realEntry ~= nil then
    for _, e in ipairs(realEntry.entries) do
      table.insert(locations, e.location)
    end
    itemCount = realEntry.count
  end

  return {
    locations = locations,
    itemCount = itemCount,
    auctionable = auctionable,
    itemName = entry.itemName,
    itemLink = entry.itemLink,
    itemID = entry.itemID,
    itemLevel = entry.itemLevel,
    quality = entry.quality,
    iconTexture = entry.iconTexture,
    classID = entry.classID,
    sortKey = key,
  }
end

function AuctionatorBagCacheMixin:GetByKey(key)
  local value = self.contents[key]
  if value ~= nil then
    local entry = value.entries[1]
    local locations = {}
    for _, e in ipairs(value.entries) do
      table.insert(locations, e.location)
    end

    local itemLink = entry.itemLink
    local cleanLink
    if itemLink:match("battlepet") then
      local pre, hyperlink, post = SplitLink(itemLink)
      cleanLink = pre .. "|H" .. KeyPartsPetLink(entry.itemLink) .. "|h" .. post
    else
      local pre, h, post = SplitLink(itemLink)
      cleanLink = pre .. "|H" .. KeyPartsItemLink(itemLink) .. "|h" .. post
    end

    return {
      locations = locations,
      itemCount = value.count,
      itemName = entry.itemName,
      itemID = entry.itemID,
      itemLevel = entry.itemLevel,
      auctionable = entry.auctionable,
      itemLink = cleanLink,
      quality = entry.quality,
      iconTexture = entry.iconTexture,
      classID = entry.classID,
      sortKey = key,
    }
  end
end

function AuctionatorBagCacheMixin:CacheLinkInfo(suppliedItemLink, callback)
  local existingEntry = linkInstantCache[suppliedItemLink]
  if existingEntry then
    callback()
    return
  end

  callback = callback or function() end

  local realEntry

  if suppliedItemLink:match("battlepet") then
    local itemName, iconTexture = C_PetJournal.GetPetInfoBySpeciesID(tonumber(suppliedItemLink:match("battlepet:(%d+)")))
    local pre, hyperlink, post = SplitLink(suppliedItemLink)

    local entry = {
      itemLink = pre .. "|H" .. KeyPartsPetLink(suppliedItemLink) .. "|h" .. post,
      itemID = Auctionator.Constants.PET_CAGE_ID,
      itemName = itemName,
      iconTexture = iconTexture,
      itemCount = 0,
      classID = Enum.ItemClass.Battlepet,
      quality = tonumber(suppliedItemLink:match("battlepet:%d*:%d*:(%d+)") or "3")
    }
    entry.key = GetItemKey(entry)
    linkInstantCache[suppliedItemLink] = entry

    callback()
  else
    -- Ignore mythic keystones, etc.
    local itemID = GetItemInfoInstant(suppliedItemLink)
    if itemID == nil then
      return
    end

    local item = Item:CreateFromItemLink(suppliedItemLink)
    item:ContinueOnItemLoad(function()
      local itemName, itemLink = GetItemInfo(suppliedItemLink)

      local pre, h, post = SplitLink(itemLink)
      local entry = {
        itemLink = pre .. "|H" .. KeyPartsItemLink(itemLink) .. "|h" .. post,
        iconTexture = item:GetItemIcon(),
        itemName = itemName,
        itemID = itemID,
        itemLink = itemLink,
        itemCount = 0,
        classID = select(6, GetItemInfoInstant(itemLink)),
        quality = item:GetItemQuality(),
      }
      if Auctionator.Utilities.IsEquipment(entry.classID) then
        entry.itemStats = GetItemStats(entry.itemLink)
        entry.itemLevel = GetDetailedItemLevelInfo(entry.itemLink)
      end
      linkInstantCache[suppliedItemLink] = entry
      callback()
    end)
  end
end

function AuctionatorBagCacheMixin:GetAllContents()
  local result = {}
  for key in pairs(self.contents) do
    table.insert(result, self:GetByKey(key))
  end
  return result
end

function AuctionatorBagCacheMixin:DoBagRefresh()
  self:SetScript("OnUpdate", nil)
  if self.waiting then
    for _, l in pairs(self.loaders) do
      l()
    end
  end
  self.loaders = {}

  self.waiting = true

  local entireBag = {}
  local waitingCount = 0

  local loopFinished = false
  local loaderIndex = 0
  for _, bagID in ipairs(Auctionator.Groups.Constants.BagIDs) do
    for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
      local location = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
      local slotInfo = C_Container.GetContainerItemInfo(bagID, slotID)

      if slotInfo then
        waitingCount = waitingCount + 1
        local item = Item:CreateFromItemID(slotInfo.itemID)

        local function FinishSlot()
          local entry = self:AddToCache(location, slotInfo)
          if entry then
            table.insert(entireBag, entry)
          end
          waitingCount = waitingCount - 1
          if loopFinished and waitingCount == 0 then
            self.loaders = {}
            self.waiting = false
            self:PostUpdate(entireBag)
          end
        end
        local li = loaderIndex + 1

        -- Load item data to determine whether it can be auctioned, its quality,
        -- item level, etc.
        if not Auctionator.Groups.Constants.IsRetail then
          local classID = select(6, GetItemInfoInstant(slotInfo.itemID))
          local _, spellID = GetItemSpell(slotInfo.itemID)
          -- Classic: Special case to load spell data for item charge info for
          -- auctionable check
          if classID == Enum.ItemClass.Consumable and spellID then
            C_Spell.RequestLoadSpellData(spellID)
            local spell = Spell:CreateFromSpellID(spellID)
            self.loaders[li] = spell:ContinueWithCancelOnSpellLoad(function()
              if C_Item.IsItemDataCached(location) then
                self.loaders[li] = nil
                FinishSlot()
              else
                self.loaders[li] = item:ContinueWithCancelOnItemLoad(FinishSlot)
              end
            end)
          elseif C_Item.IsItemDataCached(location) then
            FinishSlot()
          else
            self.loaders[li] = item:ContinueWithCancelOnItemLoad(FinishSlot)
          end
        -- We check for the item data being cached as its a significant time
        -- saving over waiting for the mixin to call back in that case.
        elseif C_Item.IsItemDataCached(location) then
          FinishSlot()
        else
          self.loaders[li] = item:ContinueWithCancelOnItemLoad(FinishSlot)
        end
      end
    end
  end
  loopFinished = true

  if waitingCount == 0 then
    self.loaders = {}
    self.waiting = false
    self:PostUpdate(entireBag)
  end
end

local detailsCache = {}

function AuctionatorBagCacheMixin:AddToCache(location, slotInfo)
  local entry = {}

  entry.itemID = slotInfo.itemID

  entry.location = location

  entry.iconTexture, entry.itemCount, entry.quality, entry.itemLink = slotInfo.iconFileID, slotInfo.stackCount, slotInfo.quality, slotInfo.hyperlink

  local savedDetails = detailsCache[entry.itemLink]
  if savedDetails ~= nil then
    entry.classID = savedDetails.classID
    entry.itemName = savedDetails.itemName
    entry.stackCount = savedDetails.stackCount
    entry.itemLevel = savedDetails.itemLevel
    entry.quality = savedDetails.quality
  else
    if entry.itemLink:match("battlepet:") then
      entry.classID = Enum.ItemClass.Battlepet
      entry.itemName = C_PetJournal.GetPetInfoBySpeciesID(tonumber(entry.itemLink:match("battlepet:(%d+)")))
      entry.stackCount = 1
    else
      local itemName, _, quality, _, _, _, _, stackCount, _, _, _, classID, _ = GetItemInfo(entry.itemLink)
      if itemName == nil then --mythic keystones don't have a normal item link
        return nil
      end
      entry.classID = select(6, GetItemInfoInstant(slotInfo.itemID))
      entry.itemName = itemName
      entry.stackCount = stackCount
      entry.quality = quality
    end
    if Auctionator.Utilities.IsEquipment(entry.classID) then
      entry.itemLevel = GetDetailedItemLevelInfo(entry.itemLink)
    end
    detailsCache[entry.itemLink] = entry
  end

  if C_AuctionHouse == nil then -- Classic, check if the item can be auctioned
    local currentDurability, maxDurability
    if location:IsBagAndSlot() then
      currentDurability, maxDurability = C_Container.GetContainerItemDurability(location:GetBagAndSlot())
    else
      local slot = location:GetEquipmentSlot()
      currentDurability, maxDurability = GetInventoryItemDurability(slot)
    end

    entry.auctionable = not C_Item.IsBound(location) and currentDurability == maxDurability

    if entry.auctionable and entry.classID == Enum.ItemClass.Consumable and location:IsBagAndSlot() then
      entry.auctionable = Auctionator.Utilities.IsAtMaxCharges(location)
    end
  else
    entry.auctionable = C_AuctionHouse.IsSellItemValid(location, false)
  end

  entry.key = GetItemKey(entry)

  return entry
end
