AuctionatorConfigShoppingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigShoppingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigShoppingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SHOPPING_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

local function GetShoppingListNames()
  local names = {AUCTIONATOR_L_NONE}
  local values = {Auctionator.Constants.NO_LIST}

  if Auctionator.Shopping.ListManager == nil then
    return names, values
  end

  for index = 1, Auctionator.Shopping.ListManager:GetCount() do
    local list = Auctionator.Shopping.ListManager:GetByIndex(index)
    table.insert(names, list:GetName())
    table.insert(values, list:GetName())
  end
  return names, values
end

function AuctionatorConfigShoppingFrameMixin:ShowSettings()
  self.AutoListSearch:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH))

  self.DefaultShoppingList:InitAgain(GetShoppingListNames())

  local currentDefault = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_LIST)
  if Auctionator.Shopping.ListManager and Auctionator.Shopping.ListManager:GetIndexForName(currentDefault) == nil then
    currentDefault = ""
  end

  self.DefaultShoppingList:SetValue(currentDefault)

  self.ListMissingTerms:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOPPING_LIST_MISSING_TERMS))
end

function AuctionatorConfigShoppingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigShoppingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUTO_LIST_SEARCH, self.AutoListSearch:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_LIST, self.DefaultShoppingList:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.SHOPPING_LIST_MISSING_TERMS, self.ListMissingTerms:GetChecked())
end

function AuctionatorConfigShoppingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigShoppingFrameMixin:Cancel()")
end
