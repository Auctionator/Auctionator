Auctionator.Tabs = {}

Auctionator.Tabs.State = {
  knownTabs = {}
}

-- details = {
--  name, -> string
--  textLabel, -> string
--  tabTemplate, -> string
--  tabHeader, -> string
--  displayModeKey, -> string
--  tabOrder -> number
-- }
function Auctionator.Tabs.Register(details)
  table.insert(Auctionator.Tabs.State.knownTabs, details)
end

Auctionator.Tabs.Register( {
  name = "Shopping",
  textLabel = AUCTIONATOR_L_SHOPPING_TAB,
  tabTemplate = "AuctionatorShoppingClassicTabFrameTemplate",
  tabHeader = AUCTIONATOR_L_SHOPPING_TAB_HEADER_2,
  tabFrameName = "AuctionatorShoppingFrame",
  tabOrder = 1,
})
Auctionator.Tabs.Register( {
  name = "Auctionator",
  textLabel = AUCTIONATOR_L_AUCTIONATOR,
  tabTemplate = "AuctionatorConfigurationTabFrameTemplate",
  tabHeader = AUCTIONATOR_L_INFO_TAB_HEADER,
  tabFrameName = "AuctionatorConfigFrame",
  tabOrder = 4,
})
Auctionator.Tabs.Register( {
  name = "Cancelling",
  textLabel = AUCTIONATOR_L_CANCELLING_TAB,
  tabTemplate = "AuctionatorCancellingTabFrameNoRefreshTemplate",
  tabHeader = AUCTIONATOR_L_CANCELLING_TAB_HEADER,
  tabFrameName = "AuctionatorCancellingFrame",
  tabOrder = 3,
})
Auctionator.Tabs.Register( {
  name = "Selling",
  textLabel = AUCTIONATOR_L_SELLING_TAB,
  tabTemplate = "AuctionatorSellingTabFrameTemplate",
  tabHeader = AUCTIONATOR_L_SELLING_TAB_HEADER,
  tabFrameName = "AuctionatorSellingFrame",
  tabOrder = 2,
})
