local AUCTIONATOR_EVENTS = {
  "CRAFT_SHOW",
}

AuctionatorInitializeVanillaMixin = {}

function AuctionatorInitializeVanillaMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_EVENTS)
end

function AuctionatorInitializeVanillaMixin:OnEvent(event, ...)
  if event == "CRAFT_SHOW" then
    Auctionator.EnchantInfo.Initialize()
    self:CraftShown()
  end
end

function AuctionatorInitializeVanillaMixin:CraftShown()
  Auctionator.Debug.Message("AuctionatorInitializeVanillaMixin::CraftShown()")

  if self.initializedCraftHooks then
    return
  end

  local reagentHook = function(self)
    if IsModifiedClick("CHATLINK") and AuctionatorShoppingFrame ~= nil and AuctionatorShoppingFrame:IsVisible() then
      local name = GetCraftReagentInfo(GetCraftSelectionIndex(), self:GetID())

      if name == nil then
        return
      end

      local searchTerm = "\"" .. name .. "\""
      AuctionatorShoppingFrame:DoSearch({searchTerm}, {})
      AuctionatorShoppingFrame.SearchOptions:SetSearchTerm(searchTerm)
      Auctionator.Shopping.Recents.Save(searchTerm)
    end
  end
  CraftReagent1:HookScript("OnClick", reagentHook)
  CraftReagent2:HookScript("OnClick", reagentHook)
  CraftReagent3:HookScript("OnClick", reagentHook)
  CraftReagent4:HookScript("OnClick", reagentHook)

  self.initializedCraftHooks = true
end
