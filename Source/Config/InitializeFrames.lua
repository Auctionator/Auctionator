function Auctionator.Config.InternalInitializeFrames(templateNames)
  for _, name in ipairs(templateNames) do
    CreateFrame(
      "FRAME",
      "AuctionatorConfig" .. name .. "Frame",
      InterfaceOptionsFrame,
      "AuctionatorConfig" .. name .. "FrameTemplate")
  end
end
