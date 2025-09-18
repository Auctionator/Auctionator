---@class addonTableAuctionator
local addonTable = select(2, ...)
function addonTable.Utilities.Message(text)
  print(LIGHTBLUE_FONT_COLOR:WrapTextInColorCode("Auctionator") .. ": " .. text)
end

do
  local callbacksPending = {}
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(_, _, addonName)
    if callbacksPending[addonName] then
      for _, cb in ipairs(callbacksPending[addonName]) do
        xpcall(cb, CallErrorHandler)
      end
      callbacksPending[addonName] = nil
    end
  end)

  local AddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

  -- Necessary because cannot nest EventUtil.ContinueOnAddOnLoaded
  function addonTable.Utilities.OnAddonLoaded(addonName, callback)
    if select(2, AddOnLoaded(addonName)) then
      xpcall(callback, CallErrorHandler)
    else
      callbacksPending[addonName] = callbacksPending[addonName] or {}
      table.insert(callbacksPending[addonName], callback)
    end
  end
end

local queue = {}
local reporter = CreateFrame("Frame")
function reporter:OnUpdate()
  if #queue > 0 then
    for _, entry in ipairs(queue) do
      print(entry[1], entry[2])
    end
    queue = {}
  else
    self:SetScript("OnUpdate", nil)
  end
end
function addonTable.Utilities.DebugOutput(label, value)
  table.insert(queue, {label, value})
  reporter:SetScript("OnUpdate", reporter.OnUpdate)
end

local pendingItems = {}
local itemFrame = CreateFrame("Frame")
itemFrame.elapsed = 0
itemFrame:SetScript("OnEvent", function(_, _, itemID)
  if pendingItems[itemID] ~= nil then
    addonTable.ReportEntry()
    local forItemID = pendingItems[itemID]
    pendingItems[itemID] = nil
    for _, callback in ipairs(forItemID) do
      callback()
    end
  end
end)
itemFrame.OnUpdate = function(self, elapsed)
  itemFrame.elapsed = itemFrame.elapsed + elapsed
  if itemFrame.elapsed > 0.4 then
    for itemID in pairs(pendingItems) do
      C_Item.RequestLoadItemDataByID(itemID)
    end
    itemFrame.elapsed = 0
  end

  if next(pendingItems) == nil then
    itemFrame.elapsed = 0
    self:SetScript("OnUpdate", nil)
    self:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
  end
end

function addonTable.Utilities.LoadItemData(itemID, callback)
  pendingItems[itemID] = pendingItems[itemID] or {}
  table.insert(pendingItems[itemID], callback)
  itemFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
  itemFrame:SetScript("OnUpdate", itemFrame.OnUpdate)
  C_Item.RequestLoadItemDataByID(itemID)
end
