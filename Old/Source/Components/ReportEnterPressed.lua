function Auctionator.Components.ReportEnterPressed()
  Auctionator.EventBus
    :RegisterSource(Auctionator.Components.ReportEnterPressed, "ReportEnterPressed")
    :Fire(Auctionator.Components.ReportEnterPressed, Auctionator.Components.Events.EnterPressed)
    :UnregisterSource(Auctionator.Components.ReportEnterPressed)
end
