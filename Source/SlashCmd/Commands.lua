local SLASH_COMMAND_DESCRIPTIONS = {
  {commands = "p, post", message = "Posts the chosen item from the \"Selling\" tab." },
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

function Auctionator.SlashCmd.Post()
  Auctionator.Utilities.Message(AUCTIONATOR_L_POST_BUTTON_MACRO)
  Auctionator.EventBus
    :RegisterSource(Auctionator.SlashCmd.Post, "Auctionator.SlashCmd.Post")
    :Fire(Auctionator.SlashCmd.Post, Auctionator.Selling.Events.RequestPost)
    :UnregisterSource(Auctionator.SlashCmd.Post)
end

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

function Auctionator.SlashCmd.Config(name, value)
  if name == nil then
    Auctionator.Utilities.Message("Current config:")
    for _, name in pairs(Auctionator.Config.Options) do
      Auctionator.Utilities.Message(name .. "=" .. tostring(Auctionator.Config.Get(name)) .. " (" .. type(Auctionator.Config.Get(name)) .. ")")
    end
  elseif type(Auctionator.Config.Get(name)) == "boolean" then
    Auctionator.Config.Set(name, not Auctionator.Config.Get(name))
    Auctionator.Utilities.Message("Config set " .. name .. " = " .. tostring(Auctionator.Config.Get(name)))
  elseif type(Auctionator.Config.Get(name)) == "number" then
    if tonumber(value) == nil then
      Auctionator.Utilities.Message("Config " .. name .. " not modified; Numerical value required")
    else
      Auctionator.Config.Set(name, tonumber(value))
    end
    Auctionator.Utilities.Message("Config set " .. name .. " = " .. tostring(Auctionator.Config.Get(name)))
  elseif Auctionator.Config.Get(name) ~= nil then
    Auctionator.Utilities.Message("Unable to modify " .. name .. " at this time")
  else
    Auctionator.Utilities.Message("Unknown config " .. name)
  end
end

function Auctionator.SlashCmd.Version()
  Auctionator.Utilities.Message(AUCTIONATOR_L_VERSION_HEADER .. " " .. Auctionator.State.CurrentVersion)
end

function Auctionator.SlashCmd.Help()
  for index = 1, #SLASH_COMMAND_DESCRIPTIONS do
    local description = SLASH_COMMAND_DESCRIPTIONS[index]
    Auctionator.Utilities.Message(description.commands .. ": " .. description.message)
  end
end
