---@class addonTableAuctionator
local addonTable = select(2, ...)
addonTable.SlashCmd = {}

function addonTable.SlashCmd.Initialize()
  SlashCmdList["Auctionator"] = addonTable.SlashCmd.Handler
  SLASH_Auctionator1 = "/auctionator"
  SLASH_Auctionator2 = "/atr"
end

local INVALID_OPTION_VALUE = "Wrong config value type %s (required %s)"
function addonTable.SlashCmd.Config(optionName, value1, ...)
  if optionName == nil then
    addonTable.Utilities.Message("No config option name supplied")
    for _, name in pairs(addonTable.Config.Options) do
      addonTable.Utilities.Message(name .. ": " .. tostring(addonTable.Config.Get(name)))
    end
    return
  end

  local currentValue = addonTable.Config.Get(optionName)
  if currentValue == nil then
    addonTable.Utilities.Message("Unknown config: " .. optionName)
    return
  end

  if value1 == nil then
    addonTable.Utilities.Message("Config " .. optionName .. ": " .. tostring(currentValue))
    return
  end

  if type(currentValue) == "boolean" then
    if value1 ~= "true" and value1 ~= "false" then
      addonTable.Utilities.Message(INVALID_OPTION_VALUE:format(type(value1), type(currentValue)))
      return
    end
    addonTable.Config.Set(optionName, value1 == "true")
  elseif type(currentValue) == "number" then
    if tonumber(value1) == nil then
      addonTable.Utilities.Message(INVALID_OPTION_VALUE:format(type(value1), type(currentValue)))
      return
    end
    addonTable.Config.Set(optionName, tonumber(value1))
  elseif type(currentValue) == "string" then
    addonTable.Config.Set(optionName, strjoin(" ", value1, ...))
  else
    addonTable.Utilities.Message("Unable to edit option type " .. type(currentValue))
    return
  end
  addonTable.Utilities.Message("Now set " .. optionName .. ": " .. tostring(addonTable.Config.Get(optionName)))
end

function addonTable.SlashCmd.Reset()
  AUCTIONATOR_CONFIG = nil
  ReloadUI()
end

function addonTable.SlashCmd.Scan()
  addonTable.CallbackRegistry:TriggerEvent("RequestScan")
end

function addonTable.SlashCmd.CustomiseUI()
  addonTable.CustomiseDialog.Toggle()
end

local COMMANDS = {
  [""] = addonTable.SlashCmd.CustomiseUI,
  ["c"] = addonTable.SlashCmd.Config,
  ["config"] = addonTable.SlashCmd.Config,
  ["reset"] = addonTable.SlashCmd.Reset,
  [addonTable.Locales.SLASH_RESET] = addonTable.SlashCmd.Reset,
  ["scan"] = addonTable.SlashCmd.Scan,
  [addonTable.Locales.SLASH_SCAN] = addonTable.SlashCmd.Scan,
}
local HELP = {
  {"", addonTable.Locales.SLASH_HELP},
  {addonTable.Locales.SLASH_RESET, addonTable.Locales.SLASH_RESET_HELP},
}

function addonTable.SlashCmd.Handler(input)
  local split = {strsplit("\a", (input:gsub("%s+","\a")))}

  local root = split[1]
  if COMMANDS[root] ~= nil then
    table.remove(split, 1)
    COMMANDS[root](unpack(split))
  else
    if root ~= "help" and root ~= "h" then
      addonTable.Utilities.Message(addonTable.Locales.SLASH_UNKNOWN_COMMAND:format(root))
    end

    for _, entry in ipairs(HELP) do
      if entry[1] == "" then
        addonTable.Utilities.Message("/atr - " .. entry[2])
      else
        addonTable.Utilities.Message("/atr " .. entry[1] .. " - " .. entry[2])
      end
    end
  end
end
