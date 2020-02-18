local DEFAULTS = {
  ["debug"] = false,
  ["mailbox tooltips"] = true
}
function Auctionator.Config.Set(name, value)
  if AUCTIONATOR_CONFIG == nil then
    error("AUCTIONATOR_CONFIG not initialized")
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
    return DEFAULTS[name]
  else
    return AUCTIONATOR_CONFIG[name]
  end
end
