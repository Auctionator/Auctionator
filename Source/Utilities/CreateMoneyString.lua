local _, addonTable = ...;
local zc = addonTable.zc;

function Auctionator.Utilities.CreateMoneyString(count)
  return zc.priceToMoneyString(count, true)
end
