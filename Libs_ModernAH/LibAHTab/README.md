# LibAHTab

This library applies to 10.0.0 (Dragonflight pre-patch) and newer versions of
World of Warcraft.  Leaving the library unused, but loaded, won't error in older
versions of WoW.

Adding an addon tab to the Auction House via the standard `PanelTemplates_`
functions causes taint, which affects the player's bags, and persists even in
combat after having left the AH. For one way to trigger the blocked error see
https://github.com/Auctionator/LibAHTab/wiki/The-Issue

```lua
local LibAHTab = LibStub("LibAHTab-1-0")
local frame = CreateFrame("Frame")
local UNIQUE_TAB_ID = "My id"

frame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")

frame:SetScript("OnEvent", function(_, eventName, panelType)
  if eventName == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" and panelType == Enum.PlayerInteractionType.Auctioneer then
    local attachedFrame = CreateFrame("Frame")
    attachedFrame:SetScript("OnShow", function()
      -- do something when the tab is selected
    end)
    LibAHTab:CreateTab(UNIQUE_TAB_ID, attachedFrame, "Tab text")
  end
end)

-- API
LibAHTab:CreateTab(UNIQUE_TAB_ID, attachedFrame, "Tab Button Text", "Optional tab header")
LibAHTab:DoesIDExist(UNIQUE_TAB_ID)
LibAHTab:GetButton(UNIQUE_TAB_ID)
LibAHTab:SetSelected(UNIQUE_TAB_ID)
```
