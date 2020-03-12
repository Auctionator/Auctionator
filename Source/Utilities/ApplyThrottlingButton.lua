function Auctionator.Utilities.ApplyThrottlingButton(button, isThrottling)
  button:SetEnabled(not isThrottling)
  if isThrottling then
    button:SetTooltip("Throttled. Waiting for the server.")
  else
    button:SetTooltip("")
  end
end
