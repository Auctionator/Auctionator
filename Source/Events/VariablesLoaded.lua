function Auctionator.Events.VariablesLoaded()
  Auctionator.Debug.Message("Auctionator.Events.VariablesLoaded")

  Auctionator.EventBus = CreateAndInitFromMixin(AuctionatorEventBusMixin)

  Auctionator.Variables.Initialize()

  Auctionator.SlashCmd.Initialize()
end
