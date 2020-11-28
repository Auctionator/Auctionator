Auctionator.Config.Options = {
  DEBUG = "debug",
  MAILBOX_TOOLTIPS = "mailbox_tooltips",
  PET_TOOLTIPS = "pet_tooltips",
  VENDOR_TOOLTIPS = "vendor_tooltips",
  AUCTION_TOOLTIPS = "auction_tooltips",
  ENCHANT_TOOLTIPS = "enchant_tooltips",
  SHIFT_STACK_TOOLTIPS = "shift_stack_tooltips",
  AUTOSCAN = "autoscan",
  ALTERNATE_SCAN_MODE = "alternate_scan_mode",
  FULL_SCAN_STEP = "full_scan_step",
  AUTO_LIST_SEARCH = "auto_list_search",
  DEFAULT_LIST = "default_list",

  DEFAULT_TAB = "default_tab",

  AUCTION_CHAT_LOG = "auction_chat_log",
  SHOW_SELLING_PRICE_HISTORY = "show_selling_price_history",
  SELLING_BAG_COLLAPSED = "selling_bag_collapsed",
  SELLING_BAG_SELECT_SHORTCUT = "selling_bag_select_shortcut",
  SELLING_CANCEL_SHORTCUT = "selling_cancel_shortcut",
  SELLING_BUY_SHORTCUT = "selling_buy_shortcut",
  SHOW_SELLING_BAG = "show_selling_bag",
  SELLING_ICON_SIZE = "selling_icon_size",
  SELLING_IGNORED_KEYS = "selling_ignored_keys",
  SELLING_FAVOURITE_KEYS = "selling_favourite_keys",
  SELLING_AUTO_SELECT_NEXT = "selling_auto_select_next",

  NOT_LIFO_AUCTION_DURATION = "not_lifo_auction_duration",
  NOT_LIFO_AUCTION_SALES_PREFERENCE = "not_lifo_auction_sales_preference",
  NOT_LIFO_UNDERCUT_PERCENTAGE = "not_lifo_undercut_percentage",
  NOT_LIFO_UNDERCUT_STATIC_VALUE = "not_lifo_undercut_static_value",
  NOT_LIFO_DEFAULT_QUANTITY = "not_lifo_default_quantity",
  GEAR_PRICE_MULTIPLIER = "gear_vendor_price_multiplier",

  LIFO_AUCTION_DURATION = "lifo_auction_duration",
  LIFO_AUCTION_SALES_PREFERENCE = "lifo_auction_sales_preference",
  LIFO_UNDERCUT_PERCENTAGE = "lifo_undercut_percentage",
  LIFO_UNDERCUT_STATIC_VALUE = "lifo_undercut_static_value",
  LIFO_DEFAULT_QUANTITY = "lifo_default_quantity",

  PRICE_HISTORY_DAYS = "price_history_days",

  FEATURE_SELLING_1 = "feature_selling_1",

  SPLASH_SCREEN_VERSION = "splash_screen_version",
  HIDE_SPLASH_SCREEN = "hide_splash_screen",

  UNDERCUT_SCAN_NOT_LIFO = "undercut_scan_not_lifo",

  SILENCE_AUCTION_ERRORS = "silence_auction_errors",
}

Auctionator.Config.SalesTypes = {
  PERCENTAGE = "percentage",
  STATIC = "static"
}

Auctionator.Config.Shortcuts = {
  LEFT_CLICK = "left click",
  RIGHT_CLICK = "right click",
  ALT_LEFT_CLICK = "alt left click",
  SHIFT_LEFT_CLICK = "shift left click",
  ALT_RIGHT_CLICK = "alt right click",
  SHIFT_RIGHT_CLICK = "shift right click",
  NONE = "none",
}

local defaults = {
  [Auctionator.Config.Options.DEBUG] = false,
  [Auctionator.Config.Options.MAILBOX_TOOLTIPS] = true,
  [Auctionator.Config.Options.PET_TOOLTIPS] = true,
  [Auctionator.Config.Options.VENDOR_TOOLTIPS] = true,
  [Auctionator.Config.Options.AUCTION_TOOLTIPS] = true,
  [Auctionator.Config.Options.ENCHANT_TOOLTIPS] = true,
  [Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS] = true,
  [Auctionator.Config.Options.AUTOSCAN] = true,
  [Auctionator.Config.Options.ALTERNATE_SCAN_MODE] = false,
  [Auctionator.Config.Options.FULL_SCAN_STEP] = 250,
  [Auctionator.Config.Options.AUTO_LIST_SEARCH] = true,
  [Auctionator.Config.Options.DEFAULT_LIST] = 0,
  [Auctionator.Config.Options.AUCTION_CHAT_LOG] = true,
  [Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY] = true,
  [Auctionator.Config.Options.SELLING_BAG_COLLAPSED] = false,
  [Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT] = Auctionator.Config.Shortcuts.ALT_LEFT_CLICK,
  [Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT] = Auctionator.Config.Shortcuts.RIGHT_CLICK,
  [Auctionator.Config.Options.SELLING_BUY_SHORTCUT] = Auctionator.Config.Shortcuts.ALT_RIGHT_CLICK,
  [Auctionator.Config.Options.SHOW_SELLING_BAG] = true,
  [Auctionator.Config.Options.SELLING_ICON_SIZE] = 42,
  [Auctionator.Config.Options.SELLING_IGNORED_KEYS] = {},
  [Auctionator.Config.Options.SELLING_FAVOURITE_KEYS] = {},
  [Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT] = false,

  [Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION] = 48,
  [Auctionator.Config.Options.NOT_LIFO_AUCTION_SALES_PREFERENCE] = Auctionator.Config.SalesTypes.PERCENTAGE,
  [Auctionator.Config.Options.NOT_LIFO_UNDERCUT_PERCENTAGE] = 0,
  [Auctionator.Config.Options.NOT_LIFO_UNDERCUT_STATIC_VALUE] = 0,
  [Auctionator.Config.Options.NOT_LIFO_DEFAULT_QUANTITY] = 1,
  [Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER] = 0,

  [Auctionator.Config.Options.LIFO_AUCTION_DURATION] = 24,
  [Auctionator.Config.Options.LIFO_AUCTION_SALES_PREFERENCE] = Auctionator.Config.SalesTypes.PERCENTAGE,
  [Auctionator.Config.Options.LIFO_UNDERCUT_PERCENTAGE] = 0,
  [Auctionator.Config.Options.LIFO_UNDERCUT_STATIC_VALUE] = 0,
  [Auctionator.Config.Options.LIFO_DEFAULT_QUANTITY] = 0,

  [Auctionator.Config.Options.PRICE_HISTORY_DAYS] = 21,
  [Auctionator.Config.Options.FEATURE_SELLING_1] = true,

  [Auctionator.Config.Options.SPLASH_SCREEN_VERSION] = "anything",
  [Auctionator.Config.Options.HIDE_SPLASH_SCREEN] = false,

  [Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO] = true,

  [Auctionator.Config.Options.SILENCE_AUCTION_ERRORS] = true,
  [Auctionator.Config.Options.DEFAULT_TAB] = 0,
}

local function isValidOption(name)
  for _, option in pairs(Auctionator.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

function Auctionator.Config.Create(constant, name, defaultValue)
  Auctionator.Config.Options[constant] = name

  defaults[Auctionator.Config.Options[constant]] = defaultValue
end

function Auctionator.Config.Set(name, value)
  if AUCTIONATOR_CONFIG == nil then
    error("AUCTIONATOR_CONFIG not initialized")
  elseif not isValidOption(name) then
    error("Invalid option '" .. name .. "'")
  elseif AUCTIONATOR_CHARACTER_CONFIG ~= nil then
    AUCTIONATOR_CHARACTER_CONFIG[name] = value
  else
    AUCTIONATOR_CONFIG[name] = value
  end
end

function Auctionator.Config.SetCharacterConfig(enabled)
  if enabled then
    if AUCTIONATOR_CHARACTER_CONFIG == nil then
      AUCTIONATOR_CHARACTER_CONFIG = {}
    end

    Auctionator.Config.InitializeCharacterConfig()
  else
    AUCTIONATOR_CHARACTER_CONFIG = nil
  end
end

function Auctionator.Config.IsCharacterConfig()
  return AUCTIONATOR_CHARACTER_CONFIG ~= nil
end

function Auctionator.Config.Reset()
  AUCTIONATOR_CONFIG = {}
  AUCTIONATOR_CHARACTER_CONFIG = nil
  for option, value in pairs(defaults) do
    AUCTIONATOR_CONFIG[option] = value
  end
end

function Auctionator.Config.Initialize()
  if AUCTIONATOR_CONFIG == nil then
    Auctionator.Config.Reset()
  else
    for option, value in pairs(defaults) do
      if AUCTIONATOR_CONFIG[option] == nil then
        Auctionator.Debug.Message("Setting default config for "..option)
        AUCTIONATOR_CONFIG[option] = value
      end
    end
    Auctionator.Config.InitializeCharacterConfig()
  end
end

function Auctionator.Config.InitializeCharacterConfig()
  if Auctionator.Config.IsCharacterConfig() then
    for key, value in pairs(AUCTIONATOR_CONFIG) do
      if AUCTIONATOR_CHARACTER_CONFIG[key] == nil then
        AUCTIONATOR_CHARACTER_CONFIG[key] = value
      end
    end
  end
end

function Auctionator.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if AUCTIONATOR_CONFIG == nil then
    return defaults[name]
  elseif AUCTIONATOR_CHARACTER_CONFIG ~= nil then
    return AUCTIONATOR_CHARACTER_CONFIG[name]
  else
    return AUCTIONATOR_CONFIG[name]
  end
end
