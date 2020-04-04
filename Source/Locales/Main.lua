ATR_L = {}

local function fixMissingTranslations(incomplete, locale)
  if locale == "enUS" then
    return
  end
  local enUS = AUCTIONATOR_LOCALES["enUS"]()
  for key, val in pairs(enUS) do
    if incomplete[key] == nil then
      incomplete[key] = "XXX-"..key.."-XXX"
    end
  end
end

if AUCTIONATOR_LOCALES[GetLocale()] ~= nil then
  ATR_L = AUCTIONATOR_LOCALES[GetLocale()]()
  fixMissingTranslations(ATR_L, GetLocale())
else
  ATR_L = AUCTIONATOR_LOCALES["enUS"]()
end

for key, value in pairs(ATR_L) do
  _G["AUCTIONATOR_L_"..key] = value
end

function Auctionator.Locales.Apply(s)
  return ATR_L[s] or s
end
