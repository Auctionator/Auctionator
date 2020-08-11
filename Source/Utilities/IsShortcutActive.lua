local LEFT_BUTTON = "LeftButton"
local RIGHT_BUTTON = "RightButton"

local function isLeftClickShortcutActive(shortcutOption, button)
  return
    shortcutOption == Auctionator.Config.Shortcuts.LEFT_CLICK and button == LEFT_BUTTON and
    not IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
end

local function isRightClickShortcutActive(shortcutOption, button)
  return
    shortcutOption == Auctionator.Config.Shortcuts.RIGHT_CLICK and button == RIGHT_BUTTON and
    not IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
end

local function isAltLeftClickShortcutActive(shortcutOption, button)
  return
    shortcutOption == Auctionator.Config.Shortcuts.ALT_LEFT_CLICK and button == LEFT_BUTTON and
    not IsShiftKeyDown() and IsAltKeyDown() and not IsControlKeyDown()
end

local function isAltRightClickShortcutActive(shortcutOption, button)
  return
    shortcutOption == Auctionator.Config.Shortcuts.ALT_RIGHT_CLICK and button == RIGHT_BUTTON and
    not IsShiftKeyDown() and IsAltKeyDown() and not IsControlKeyDown()
end

local function isShiftLeftClickShortcutActive(shortcutOption, button)
  return
    shortcutOption == Auctionator.Config.Shortcuts.SHIFT_LEFT_CLICK and button == LEFT_BUTTON and
    IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
end

local function isShiftRightClickShortcutActive(shortcutOption, button)
  return
    shortcutOption == Auctionator.Config.Shortcuts.SHIFT_RIGHT_CLICK and button == RIGHT_BUTTON and
    IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown()
end

function Auctionator.Utilities.IsShortcutActive(shortcutOption, button)
  return
    isLeftClickShortcutActive(shortcutOption, button) or
    isRightClickShortcutActive(shortcutOption, button) or
    isAltLeftClickShortcutActive(shortcutOption, button) or
    isAltRightClickShortcutActive(shortcutOption, button) or
    isShiftLeftClickShortcutActive(shortcutOption, button) or
    isShiftRightClickShortcutActive(shortcutOption, button)
end
