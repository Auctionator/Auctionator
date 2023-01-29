AuctionatorTabContainerMixin = {}

local LibAHTab = LibStub("LibAHTab-1-0")

local padding = 0
local absoluteSize = nil
local minTabWidth = 36

function AuctionatorTabContainerMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorTabContainerMixin:OnLoad()")

  -- Tabs are sorted to avoid inconsistent ordering based on the addon loading
  -- order
  table.sort(
    Auctionator.Tabs.State.knownTabs,
    function(left, right)
      return left.tabOrder < right.tabOrder
    end
  )

  self.Tabs = {}

  for _, details in ipairs(Auctionator.Tabs.State.knownTabs) do
    local frameRef = CreateFrame(
      "FRAME",
      details.tabFrameName,
      AuctionHouseFrame,
      details.tabTemplate
    )
    local buttonFrameName = "AuctionatorTabs_" .. details.name
    LibAHTab:CreateTab(buttonFrameName, frameRef, details.textLabel, details.tabHeader)
    _G[buttonFrameName] = LibAHTab:GetButton(buttonFrameName)
    table.insert(AuctionatorAHTabsContainer.Tabs, _G[buttonFrameName])

    -- Apply small tabs if enabled
    _G[buttonFrameName]:HookScript("OnShow", function(tab)
      if Auctionator.Config.Get(Auctionator.Config.Options.SMALL_TABS) then
        PanelTemplates_TabResize(tab, padding, absoluteSize, minTabWidth)
      end
    end)
    if Auctionator.Config.Get(Auctionator.Config.Options.SMALL_TABS) then
      PanelTemplates_TabResize(_G[buttonFrameName], padding, absoluteSize, minTabWidth)
    end
  end
end

function AuctionatorTabContainerMixin:OnShow()
  if Auctionator.Config.Get(Auctionator.Config.Options.SMALL_TABS) then
    for _, tab in ipairs(AuctionHouseFrame.Tabs) do
      PanelTemplates_TabResize(tab, padding, absoluteSize, minTabWidth)
    end
  end
end
