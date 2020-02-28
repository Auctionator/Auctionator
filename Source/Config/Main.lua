Auctionator.Config.Options = {
  DEBUG = "debug",
  MAILBOX_TOOLTIPS = "mailbox_tooltips",
  VENDOR_TOOLTIPS = "vendor_tooltips",
  AUCTION_TOOLTIPS = "auction_tooltips",
  ENCHANT_TOOLTIPS = "enchant_tooltips",
  SHIFT_STACK_TOOLTIPS = "shift_stack_tooltips",
  SHOW_LISTS = "show_lists",
  AUTOSCAN = "autoscan",
  AUTO_LIST_SEARCH = "auto_list_search",
  UNDERCUT_PERCENTAGE = "undercut_percentage",
  AUCTION_DURATION = "auction_duration",
}

local defaults = {
  [Auctionator.Config.Options.DEBUG] = false,
  [Auctionator.Config.Options.MAILBOX_TOOLTIPS] = true,
  [Auctionator.Config.Options.VENDOR_TOOLTIPS] = true,
  [Auctionator.Config.Options.AUCTION_TOOLTIPS] = true,
  [Auctionator.Config.Options.ENCHANT_TOOLTIPS] = true,
  [Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS] = true,
  [Auctionator.Config.Options.SHOW_LISTS] = true,
  [Auctionator.Config.Options.AUTOSCAN] = true,
  [Auctionator.Config.Options.AUTO_LIST_SEARCH] = true,
  [Auctionator.Config.Options.UNDERCUT_PERCENTAGE] = 5,
  [Auctionator.Config.Options.AUCTION_DURATION] = 24,
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
