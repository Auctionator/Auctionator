function Auctionator.Utilities.IsShortcutActive(shortcutOption, button)
  return (
    shortcutOption == Auctionator.Config.Shortcuts.LEFT_CLICK and button == "LeftButton" and
    not IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
  ) or (
    shortcutOption == Auctionator.Config.Shortcuts.RIGHT_CLICK and button == "RightButton" and
    not IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
  ) or (
    shortcutOption == Auctionator.Config.Shortcuts.ALT_LEFT_CLICK and button == "LeftButton" and
    not IsShiftKeyDown() and IsAltKeyDown() and not IsControlKeyDown()
  ) or (
    shortcutOption == Auctionator.Config.Shortcuts.SHIFT_LEFT_CLICK and button == "LeftButton" and
    IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
  ) or (
    shortcutOption == Auctionator.Config.Shortcuts.ALT_RIGHT_CLICK and button == "RightButton" and
    not IsShiftKeyDown() and IsAltKeyDown() and not IsControlKeyDown()
  ) or (
    shortcutOption == Auctionator.Config.Shortcuts.SHIFT_RIGHT_CLICK and button == "RightButton" and
    IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
  )
end
