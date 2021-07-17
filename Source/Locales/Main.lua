local currentLocale = {}

local function FixMissingTranslations(incomplete, locale)
  if locale == "enUS" then
    return
  end

  local enUS = AUCTIONATOR_LOCALES["enUS"]()
  for key, val in pairs(enUS) do
    if incomplete[key] == nil then
      incomplete[key] = val
    end
  end
end

local function AddNewLines(full)
  for key, val in pairs(full) do
    full[key] = string.gsub(full[key], "\\n", "\n")
  end
end

if AUCTIONATOR_LOCALES_OVERRIDE ~= nil then
  currentLocale = AUCTIONATOR_LOCALES_OVERRIDE()

  FixMissingTranslations(currentLocale, "OVERRIDE")
elseif AUCTIONATOR_LOCALES[GetLocale()] ~= nil then
  currentLocale = AUCTIONATOR_LOCALES[GetLocale()]()

  FixMissingTranslations(currentLocale, GetLocale())
else
  currentLocale = AUCTIONATOR_LOCALES["enUS"]()
end

AddNewLines(currentLocale)

-- Export constants into the global scope (for XML frames to use)
for key, value in pairs(currentLocale) do
  _G["AUCTIONATOR_L_"..key] = value
end

function Auctionator.Locales.Apply(s, ...)
  if currentLocale[s] ~= nil then
    return string.format(currentLocale[s], ...)
  else
    error("Unknown/missing locale string '" .. s .. "'")
  end
end
