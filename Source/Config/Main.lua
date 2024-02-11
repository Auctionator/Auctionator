Auctionator.Config.Options = {
  DEBUG = "debug",
  NO_PRICE_DATABASE = "no_price_database",
  MAILBOX_TOOLTIPS = "mailbox_tooltips",
  VENDOR_TOOLTIPS = "vendor_tooltips",
  AUCTION_TOOLTIPS = "auction_tooltips",
  AUCTION_AGE_TOOLTIPS = "auction_age_tooltips",
  AUCTION_MEAN_TOOLTIPS = "auction_mean_tooltips",
  AUCTION_MEAN_DAYS_LIMIT = "auction_mean_days_limit",
  SHIFT_STACK_TOOLTIPS = "shift_stack_tooltips",
  ENCHANT_TOOLTIPS = "enchant_tooltips",
  REPLICATE_SCAN = "replicate_scan_3",
  AUTO_LIST_SEARCH = "auto_list_search",
  DEFAULT_LIST = "default_list_2",

  DEFAULT_TAB = "default_tab",

  AUCTION_CHAT_LOG = "auction_chat_log",
  SELLING_BAG_COLLAPSED = "selling_bag_collapsed",
  SHOW_SELLING_BAG = "show_selling_bag_2",
  SELLING_BAG_SELECT_SHORTCUT = "selling_bag_select_shortcut",
  SELLING_ICON_SIZE = "selling_icon_size_2",
  SELLING_IGNORED_KEYS = "selling_ignored_keys",
  SELLING_FAVOURITE_KEYS = "selling_favourite_keys_2",
  SELLING_AUTO_SELECT_NEXT = "selling_auto_select_next",
  SELLING_MISSING_FAVOURITES = "selling_missing_favourites",
  SELLING_FAVOURITES_SORT_OWNED = "selling_favourites_sort_owned",
  SELLING_RESELECT_ITEM = "selling_reselect_item_2",
  SELLING_SHOULD_RESELECT_ITEM = "selling_should_reselect_item",
  SELLING_POST_SHORTCUT = "selling_post_shortcut",
  SELLING_SKIP_SHORTCUT = "selling_skip_shortcut",
  SELLING_PREV_SHORTCUT = "selling_prev_shortcut",
  SHOW_SELLING_BID_PRICE = "show_selling_bid_price",
  SELLING_CONFIRM_LOW_PRICE = "selling_confirm_low_price",
  SAVE_LAST_DURATION_AS_DEFAULT = "save_last_duration_as_default",

  GEAR_PRICE_MULTIPLIER = "gear_vendor_price_multiplier",

  PRICE_HISTORY_DAYS = "price_history_days",
  POSTING_HISTORY_LENGTH = "auctions_history_length",

  SPLASH_SCREEN_VERSION = "splash_screen_version",
  HIDE_SPLASH_SCREEN = "hide_splash_screen",

  CANCEL_UNDERCUT_SHORTCUT = "cancel_undercut_shortcut",
  UNDERCUT_ITEMS_AHEAD = "undercut_items_ahead",

  COLUMNS_SHOPPING = "columns_shopping",
  COLUMNS_SHOPPING_HISTORICAL_PRICES = "columns_shopping_historical_prices",
  COLUMNS_SELLING_SEARCH = "columns_selling_search_3",
  COLUMNS_HISTORICAL_PRICES = "historical_prices",
  COLUMNS_POSTING_HISTORY = "columns_posting_history",
  COLUMNS_CANCELLING = "columns_cancelling",

  CRAFTING_INFO_SHOW = "crafting_info_show",
  CRAFTING_INFO_SHOW_PROFIT = "crafting_info_show_profit",
  CRAFTING_INFO_SHOW_COST = "crafting_info_show_cost",

  SHOPPING_LIST_MISSING_TERMS = "shopping_list_missing_terms",
  SHOPPING_LAST_CONTAINER_VIEW = "shopping_last_container_view",
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

Auctionator.Config.Defaults = {
  [Auctionator.Config.Options.DEBUG] = false,
  [Auctionator.Config.Options.NO_PRICE_DATABASE] = false,
  [Auctionator.Config.Options.MAILBOX_TOOLTIPS] = true,
  [Auctionator.Config.Options.VENDOR_TOOLTIPS] = true,
  [Auctionator.Config.Options.AUCTION_TOOLTIPS] = true,
  [Auctionator.Config.Options.AUCTION_AGE_TOOLTIPS] = false,
  [Auctionator.Config.Options.AUCTION_MEAN_TOOLTIPS] = false,
  [Auctionator.Config.Options.AUCTION_MEAN_DAYS_LIMIT] = 21,
  [Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS] = true,
  [Auctionator.Config.Options.ENCHANT_TOOLTIPS] = false,
  [Auctionator.Config.Options.REPLICATE_SCAN] = false,
  [Auctionator.Config.Options.AUTO_LIST_SEARCH] = true,
  [Auctionator.Config.Options.DEFAULT_LIST] = Auctionator.Constants.NO_LIST,
  [Auctionator.Config.Options.AUCTION_CHAT_LOG] = true,
  [Auctionator.Config.Options.SELLING_BAG_COLLAPSED] = false,
  [Auctionator.Config.Options.SHOW_SELLING_BAG] = true,
  [Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT] = Auctionator.Config.Shortcuts.ALT_LEFT_CLICK,
  [Auctionator.Config.Options.SELLING_ICON_SIZE] = 42,
  [Auctionator.Config.Options.SELLING_IGNORED_KEYS] = {},
  [Auctionator.Config.Options.SELLING_FAVOURITE_KEYS] = {},
  [Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT] = false,
  [Auctionator.Config.Options.SELLING_MISSING_FAVOURITES] = true,
  [Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED] = false,
  [Auctionator.Config.Options.SELLING_POST_SHORTCUT] = "SPACE",
  [Auctionator.Config.Options.SELLING_SKIP_SHORTCUT] = "SHIFT-SPACE",
  [Auctionator.Config.Options.SELLING_PREV_SHORTCUT] = "BACKSPACE",
  [Auctionator.Config.Options.SHOW_SELLING_BID_PRICE] = false,
  [Auctionator.Config.Options.SELLING_CONFIRM_LOW_PRICE] = true,
  [Auctionator.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT] = false,

  [Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER] = 0,

  [Auctionator.Config.Options.PRICE_HISTORY_DAYS] = 21,
  [Auctionator.Config.Options.POSTING_HISTORY_LENGTH] = 10,

  [Auctionator.Config.Options.SPLASH_SCREEN_VERSION] = "anything",
  [Auctionator.Config.Options.HIDE_SPLASH_SCREEN] = false,

  [Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT] = "SPACE",
  [Auctionator.Config.Options.UNDERCUT_ITEMS_AHEAD] = 0,

  [Auctionator.Config.Options.DEFAULT_TAB] = 0,

  [Auctionator.Config.Options.COLUMNS_SHOPPING] = {},
  [Auctionator.Config.Options.COLUMNS_SHOPPING_HISTORICAL_PRICES] = {},
  [Auctionator.Config.Options.COLUMNS_CANCELLING] = {},
  [Auctionator.Config.Options.COLUMNS_SELLING_SEARCH] = {},
  [Auctionator.Config.Options.COLUMNS_HISTORICAL_PRICES] = {},
  [Auctionator.Config.Options.COLUMNS_POSTING_HISTORY] = {},

  [Auctionator.Config.Options.CRAFTING_INFO_SHOW] = true,
  [Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT] = true,
  [Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST] = true,

  [Auctionator.Config.Options.SHOPPING_LIST_MISSING_TERMS] = false,
  [Auctionator.Config.Options.SHOPPING_LAST_CONTAINER_VIEW] = Auctionator.Constants.ShoppingListViews.Lists,
}

function Auctionator.Config.IsValidOption(name)
  for _, option in pairs(Auctionator.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

function Auctionator.Config.Create(constant, name, defaultValue)
  Auctionator.Config.Options[constant] = name

  Auctionator.Config.Defaults[Auctionator.Config.Options[constant]] = defaultValue

  if AUCTIONATOR_CONFIG ~= nil and AUCTIONATOR_CONFIG[name] == nil then
    AUCTIONATOR_CONFIG[name] = defaultValue
  end
  if AUCTIONATOR_CHARACTER_CONFIG ~= nil and AUCTIONATOR_CHARACTER_CONFIG[name] == nil then
    AUCTIONATOR_CHARACTER_CONFIG[name] = defaultValue
  end
end

function Auctionator.Config.Set(name, value)
  if AUCTIONATOR_CONFIG == nil then
    error("AUCTIONATOR_CONFIG not initialized")
  elseif not Auctionator.Config.IsValidOption(name) then
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
  for option, value in pairs(Auctionator.Config.Defaults) do
    AUCTIONATOR_CONFIG[option] = value
  end
end

function Auctionator.Config.InitializeData()
  if AUCTIONATOR_CONFIG == nil then
    Auctionator.Config.Reset()
  else
    for option, value in pairs(Auctionator.Config.Defaults) do
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
    return Auctionator.Config.Defaults[name]
  elseif AUCTIONATOR_CHARACTER_CONFIG ~= nil then
    return AUCTIONATOR_CHARACTER_CONFIG[name]
  else
    return AUCTIONATOR_CONFIG[name]
  end
end
