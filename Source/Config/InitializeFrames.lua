function Auctionator.Config.InternalInitializeFrames(templateNames)
  for _, name in ipairs(templateNames) do
    CreateFrame(
      "FRAME",
      "AuctionatorConfig" .. name .. "Frame",
      SettingsPanel or InterfaceOptionsFrame,
      "AuctionatorConfig" .. name .. "FrameTemplate")
  end
end
