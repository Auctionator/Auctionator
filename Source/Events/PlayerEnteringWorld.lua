function Auctionator.Events.PlayerEnteringWorld()
  Auctionator.Debug.Message("Auctionator.Events.PlayerEnteringWorld")

end

auctionatorInited = false

-----------------------------------------
function Atr_OnPlayerEnteringWorld()
  Auctionator.Debug.Message( 'Atr_OnPlayerEnteringWorld' )

  zz ("auctionatorInited = ", auctionatorInited);

  if (auctionatorInited == false) then
    auctionatorInited = true;

    Atr_InitOptionsPanels()
    Atr_InitToolTips()

    if (RegisterAddonMessagePrefix) then
      RegisterAddonMessagePrefix ("ATR")
    end

  end
end