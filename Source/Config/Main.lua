Auctionator.Config.Option = {
  DEBUG = "debug",
  MAILBOX_TOOLTIPS = "mailbox_tooltips",
  VENDOR_TOOLTIPS = "vendor_tooltips",
  AUCTION_TOOLTIPS = "auction_tooltips",
  ENCHANT_TOOLTIPS = "enchant_tooltips"
}

local defaults = {
  [Auctionator.Config.Option.DEBUG] = false,
  [Auctionator.Config.Option.MAILBOX_TOOLTIPS] = true,
  [Auctionator.Config.Option.VENDOR_TOOLTIPS] = true,
  [Auctionator.Config.Option.AUCTION_TOOLTIPS] = true,
  [Auctionator.Config.Option.ENCHANT_TOOLTIPS] = true
}

function validOption(name)
  for _, option in pairs(Auctionator.Config.Option) do
    if option == name then
      return true
    end
  end
  return false
end

function Auctionator.Config.Set(name, value)
  if AUCTIONATOR_CONFIG == nil then
    error("AUCTIONATOR_CONFIG not initialized")
  elseif not validOption(name) then
    error("Invalid option '" .. name .. "'")
  else
    AUCTIONATOR_CONFIG[name] = value
  end
end

function Auctionator.Config.Reset()
  AUCTIONATOR_CONFIG = {}
end

function Auctionator.Config.Get(name)
  if AUCTIONATOR_CONFIG == nil then
    return nil
  elseif AUCTIONATOR_CONFIG[name] == nil then
    return defaults[name]
  else
    return AUCTIONATOR_CONFIG[name]
  end
end
