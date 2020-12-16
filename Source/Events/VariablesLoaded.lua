function Auctionator.Events.VariablesLoaded()
  Auctionator.Debug.Message("Auctionator.Events.VariablesLoaded")

  Auctionator.Variables.Initialize()

  Auctionator.SlashCmd.Initialize()
end
