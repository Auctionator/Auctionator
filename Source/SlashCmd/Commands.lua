local SLASH_COMMAND_DESCRIPTIONS = {
  {commands = "ra, resetall", message = "Reset database and full scan timer." },
  {commands = "rdb, resetdatabase", message = "Reset Auctionator database."},
  {commands = "rt, resettimer", message = "Reset full scan timer."},
  {commands = "rc, resetconfig", message = "Reset configuration to defaults."},
  {commands = "d, debug", message = "Toggle debug mode."},
  {commands = "c, config", message = "Show current configuration values."},
  {commands = "c [toggle-name], config [toggle-name]", message = "Toggle the value of the configuration value [toggle-name]."},
  {commands = "v, version", message = "Show current version."},
  {commands = "h, help", message = "Show this help message."},
}

function Auctionator.SlashCmd.ToggleDebug()
  Auctionator.Debug.Toggle()
  if Auctionator.Debug.IsOn() then
    Auctionator.Utilities.Message("Debug mode on")
  else
    Auctionator.Utilities.Message("Debug mode off")
  end
end

function Auctionator.SlashCmd.ResetDatabase()
  if Auctionator.Debug.IsOn() then
    -- See Source/Variables/Main.lua for variable usage
    AUCTIONATOR_PRICE_DATABASE = nil
    Auctionator.Utilities.Message("Price database reset")
    Auctionator.Variables.InitializeDatabase()
  else
    Auctionator.Utilities.Message("Requires debug mode.")
  end
end

function Auctionator.SlashCmd.ResetTimer()
  if Auctionator.Debug.IsOn() then
    Auctionator.SavedState.TimeOfLastScan = nil
    Auctionator.Utilities.Message("Scan timer reset.")
  else
    Auctionator.Utilities.Message("Requires debug mode.")
  end
end

function Auctionator.SlashCmd.CleanReset()
  Auctionator.SlashCmd.ResetTimer()
  Auctionator.SlashCmd.ResetDatabase()
end

function Auctionator.SlashCmd.ResetConfig()
  if Auctionator.Debug.IsOn() then
    Auctionator.Config.Reset()
    Auctionator.Utilities.Message("Config reset.")
  else
    Auctionator.Utilities.Message("Requires debug mode.")
  end
end

function Auctionator.SlashCmd.Config(name)
  if name == nil then
    Auctionator.Utilities.Message("Current config:")
    for _, name in pairs(Auctionator.Config.Options) do
      Auctionator.Utilities.Message(name .. "=" .. tostring(Auctionator.Config.Get(name)) .. " (" .. type(Auctionator.Config.Get(name)) .. ")")
    end
  elseif type(Auctionator.Config.Get(name)) == "boolean" then
    Auctionator.Config.Set(name, not Auctionator.Config.Get(name))
    Auctionator.Utilities.Message("Config set " .. name .. " = " .. tostring(Auctionator.Config.Get(name)))
  elseif Auctionator.Config.Get(name) ~= nil then
    Auctionator.Utilities.Message("Unable to modify " .. name .. " at this time")
  else
    Auctionator.Utilities.Message("Unknown config " .. name)
  end
end

function Auctionator.SlashCmd.Version()
  Auctionator.Utilities.PrintVersion()
end

function Auctionator.SlashCmd.Help()
  for index = 1, #SLASH_COMMAND_DESCRIPTIONS do
    local description = SLASH_COMMAND_DESCRIPTIONS[index]
    Auctionator.Utilities.Message(description.commands .. ": " .. description.message)
  end
end
