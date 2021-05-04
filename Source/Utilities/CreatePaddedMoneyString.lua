local function getCopper(amount)
  return amount % 100
end

local function getSilver(amount)
  return (amount % 10000 - getCopper(amount)) / 100
end

local function getGold(amount)
  return (amount - getSilver(amount) * 100 - getCopper(amount)) / 10000
end

local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:4:0|t"
local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t"
local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t"
local padding = "  "

function Auctionator.Utilities.CreatePaddedMoneyString(amount)
  amount = math.floor(amount)

  local gold, silver, copper = getGold(amount), getSilver(amount), getCopper(amount)

  local result = copper .. copperIcon

  if (gold ~= 0 or silver ~= 0) and copper < 10 then
    result = "0" .. result
  end

  if silver ~= 0 or gold ~= 0 then
    result = silver .. silverIcon .. padding .. result
  end

  if gold ~= 0 and silver < 10 then
    result = "0" .. result
  end

  if gold ~= 0 then
    result = gold .. goldIcon .. padding ..result
  end

  return result
end
