local lib = LibStub:NewLibrary("LibAHTab-1-0", 2)

if not lib or lib.internalState then return end

local MIN_TAB_WIDTH = 70
local TAB_PADDING = 20

local tabIDErrorMessage = "tabID should be a string"

function lib:DoesIDExist(tabID)
  assert(type(tabID) == "string", tabIDErrorMessage)
  return lib.internalState and lib.internalState.usedIDs[tabID] ~= nil
end

function lib:CreateTab(tabID, attachedFrame, displayText, tabHeader)
  assert(AuctionHouseFrame, "Wait for the AH to open before creating your tab")
  assert(type(tabID) == "string", tabIDErrorMessage)
  assert(type(attachedFrame) == "table" and attachedFrame.IsObjectType and attachedFrame:IsObjectType("Frame"), "attachedFrame should be a frame")
  assert(type(displayText) == "string", "displayText should be a string")
  assert(tabHeader == nil or type(tabHeader) == "string", "tabHeader should be a string")

  if not lib.internalState then
    lib.internalState = {
      Tabs = {},
      usedIDs = {},
      selectedTab = nil,
    }
    lib.internalState.rootFrame = CreateFrame("Frame", nil, AuctionHouseFrame)
    lib.internalState.rootFrame:SetSize(10, 10)
    lib.internalState.rootFrame:SetPoint("TOPLEFT", AuctionHouseFrame.Tabs[#AuctionHouseFrame.Tabs], "TOPRIGHT")

    hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", function(self, mode)
      if mode ~= nil and #mode > 0 then
        for _, tab in ipairs(lib.internalState.Tabs) do
          tab.frameRef:Hide()
          PanelTemplates_DeselectTab(tab)
        end
      end
    end)
  end

  if lib:DoesIDExist(tabID) then
    error("The tab id already exists")
  end

  local newTab = CreateFrame("Button", nil, lib.internalState.rootFrame, "AuctionHouseFrameDisplayModeTabTemplate")
  table.insert(lib.internalState.Tabs, newTab)

  newTab:SetText(displayText)

  lib.internalState.usedIDs[tabID] = newTab

  PanelTemplates_TabResize(newTab, TAB_PADDING, nil, MIN_TAB_WIDTH)

  if #lib.internalState.Tabs > 1 then
    newTab:SetPoint("TOPLEFT", lib.internalState.Tabs[#lib.internalState.Tabs - 1], "TOPRIGHT", 3, 0)
  else
    newTab:SetPoint("TOPLEFT", lib.internalState.rootFrame, "TOPLEFT", 3, 0)
  end

  PanelTemplates_DeselectTab(newTab)

  newTab.frameRef = attachedFrame
  newTab.tabHeader = tabHeader or displayText

  attachedFrame:Hide()

  newTab:SetScript("OnClick", function()
    lib:SetSelected(tabID)
  end)
end

function lib:GetButton(tabID)
  assert(type(tabID) == "string", tabIDErrorMessage)
  return lib.internalState.usedIDs[tabID]
end

function lib:SetSelected(tabID)
  assert(type(tabID) == "string", tabIDErrorMessage)
  if lib.internalState == nil or not lib:DoesIDExist(tabID) then
    error("Tab doesn't exist")
  end

  AuctionHouseFrame:SetDisplayMode({})
  AuctionHouseFrame.displayMode = nil

  for _, tab in ipairs(lib.internalState.Tabs) do
    tab.frameRef:Hide()
    PanelTemplates_DeselectTab(tab)
  end

  for _, tab in ipairs(AuctionHouseFrame.Tabs) do
    PanelTemplates_DeselectTab(tab)
  end

  local selectedTab = lib:GetButton(tabID)
  PanelTemplates_SelectTab(selectedTab)

  AuctionHouseFrame:SetTitle(selectedTab.tabHeader)
  selectedTab.frameRef:Show()
end
