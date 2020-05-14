Auctionator.Config.Options = {
  DEBUG = "debug",
  MAILBOX_TOOLTIPS = "mailbox_tooltips",
  PET_TOOLTIPS = "pet_tooltips",
  VENDOR_TOOLTIPS = "vendor_tooltips",
  AUCTION_TOOLTIPS = "auction_tooltips",
  ENCHANT_TOOLTIPS = "enchant_tooltips",
  SHIFT_STACK_TOOLTIPS = "shift_stack_tooltips",
  AUTOSCAN = "autoscan",
  FULL_SCAN_STEP = "full_scan_step",
  AUTO_LIST_SEARCH = "auto_list_search",
  AUCTION_CHAT_LOG = "auction_chat_log",

  NOT_LIFO_AUCTION_DURATION = "not_lifo_auction_duration",
  NOT_LIFO_AUCTION_SALES_PREFERENCE = "not_lifo_auction_sales_preference",
  NOT_LIFO_UNDERCUT_PERCENTAGE = "not_lifo_undercut_percentage",
  NOT_LIFO_UNDERCUT_STATIC_VALUE = "not_lifo_undercut_static_value",

  LIFO_AUCTION_DURATION = "lifo_auction_duration",
  LIFO_AUCTION_SALES_PREFERENCE = "lifo_auction_sales_preference",
  LIFO_UNDERCUT_PERCENTAGE = "lifo_undercut_percentage",
  LIFO_UNDERCUT_STATIC_VALUE = "lifo_undercut_static_value",

  PRICE_HISTORY_DAYS = "price_history_days",

  FEATURE_SELLING_1 = "feature_selling_1",

  SPLASH_SCREEN_VERSION = "splash_screen_version",
  HIDE_SPLASH_SCREEN = "hide_splash_screen",

  UNDERCUT_SCAN_NOT_LIFO = "undercut_scan_not_lifo",

  SILENCE_AUCTION_ERRORS = "silence_auction_errors"
}

Auctionator.Config.SalesTypes = {
  PERCENTAGE = "percentage",
  STATIC = "static"
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
  [Auctionator.Config.Options.FULL_SCAN_STEP] = 250,
  [Auctionator.Config.Options.AUTO_LIST_SEARCH] = true,
  [Auctionator.Config.Options.AUCTION_CHAT_LOG] = true,

  [Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION] = 48,
  [Auctionator.Config.Options.NOT_LIFO_AUCTION_SALES_PREFERENCE] = Auctionator.Config.SalesTypes.PERCENTAGE,
  [Auctionator.Config.Options.NOT_LIFO_UNDERCUT_PERCENTAGE] = 0,
  [Auctionator.Config.Options.NOT_LIFO_UNDERCUT_STATIC_VALUE] = 0,

  [Auctionator.Config.Options.LIFO_AUCTION_DURATION] = 24,
  [Auctionator.Config.Options.LIFO_AUCTION_SALES_PREFERENCE] = Auctionator.Config.SalesTypes.PERCENTAGE,
  [Auctionator.Config.Options.LIFO_UNDERCUT_PERCENTAGE] = 0,
  [Auctionator.Config.Options.LIFO_UNDERCUT_STATIC_VALUE] = 0,

  [Auctionator.Config.Options.PRICE_HISTORY_DAYS] = 21,
  [Auctionator.Config.Options.FEATURE_SELLING_1] = true,

  [Auctionator.Config.Options.SPLASH_SCREEN_VERSION] = "anything",
  [Auctionator.Config.Options.HIDE_SPLASH_SCREEN] = false,

  [Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO] = true,

  [Auctionator.Config.Options.SILENCE_AUCTION_ERRORS] = true,
}

local function isValidOption(name)
  for _, option in pairs(Auctionator.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

function Auctionator.Config.Set(name, value)
  if AUCTIONATOR_CONFIG == nil then
    error("AUCTIONATOR_CONFIG not initialized")
  elseif not isValidOption(name) then
    error("Invalid option '" .. name .. "'")
  else
    AUCTIONATOR_CONFIG[name] = value
  end
end

function Auctionator.Config.Reset()
  AUCTIONATOR_CONFIG = {}
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
  end
end

function Auctionator.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if AUCTIONATOR_CONFIG == nil then
    return defaults[name]
  else
    return AUCTIONATOR_CONFIG[name]
  end
end
