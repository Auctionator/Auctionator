function Auctionator.API.v1.RegisterForDBUpdate(callerID, callback)
  Auctionator.API.InternalVerifyID(callerID)

  if type(callback) ~= "function" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.RegisterForDBUpdate(string, function)"
    )
  end

  Auctionator.EventBus:Register({
    ReceiveEvent = function()
      callback()
    end
  }, {
    Auctionator.Search.Events.PricesProcessed,
    Auctionator.FullScan.Events.ScanComplete,
  })
end
