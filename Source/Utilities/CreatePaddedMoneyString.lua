local function getCopper(amount)
  return amount % 100
end

local function getSilver(amount)
  return (amount % 10000 - getCopper(amount)) / 100
end

local function getGold(amount)
  return (amount - getSilver(amount) * 100 - getCopper(amount)) / 10000
end

local goldIcon = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t"
local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t"
local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t"
local leftPadding = " "
local rightPadding = " "

function Auctionator.Utilities.CreatePaddedMoneyString(amount, showSilver, showCopper)
  amount = math.floor(amount)

  local gold, silver, copper = getGold(amount), getSilver(amount), getCopper(amount)

  local paddedCopper = copper
  if copper < 10 then
    paddedCopper = "0" .. copper
  end

  local paddedSilver = silver
  if silver < 10 then
    paddedSilver = "0" .. silver
  end
  
  local result = ''
  
  if showCopper == true or showCopper == nil then
    result = paddedCopper .. rightPadding .. copperIcon
  end

  if silver ~= 0 or gold ~= 0 then
    if showSilver == true or showSilver == nil then
      if result ~= '' then
        result = rightPadding .. result
      end
      result = paddedSilver .. leftPadding .. silverIcon .. result
    end
  end

  if gold ~= 0 then
    if result ~= '' then
      result = rightPadding .. result
    end
    result = gold .. leftPadding .. goldIcon .. result
  end

  return result
end
