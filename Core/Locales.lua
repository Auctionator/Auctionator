---@class addonTableAuctionator
local addonTable = select(2, ...)
addonTable.Locales = CopyTable(AUCTIONATOR_LOCALES.enUS)
for key, translation in pairs(AUCTIONATOR_LOCALES[GetLocale()]) do
  addonTable.Locales[key] = translation
end
for key, translation in pairs(addonTable.Locales) do
  _G["AUCTIONATOR_L_" .. key] = translation

  if key:match("^BINDING") then
    _G["BINDING_NAME_AUCTIONATOR_" .. key:match("BINDING_(.*)")] = translation
  end
end
