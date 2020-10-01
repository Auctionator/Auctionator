local VERSION_8_3 = 6

function Auctionator.Variables.Initialize()
  Auctionator.Variables.InitializeSavedState()

  Auctionator.Config.Initialize()

  Auctionator.State.CurrentVersion = GetAddOnMetadata("Auctionator", "Version")

  Auctionator.Variables.InitializeDatabase()
  Auctionator.Variables.InitializeShoppingLists()

  Auctionator.State.Loaded = true
end

function Auctionator.Variables.InitializeSavedState()
  if AUCTIONATOR_SAVEDVARS == nil then
    AUCTIONATOR_SAVEDVARS = {}
  end
  Auctionator.SavedState = AUCTIONATOR_SAVEDVARS
end

-- All "realms" that are connected together use the same AH database, this
-- determines which database is in use.
function Auctionator.Variables.GetConnectedRealmRoot()
  local currentRealm = GetRealmName()
  local connections = GetAutoCompleteRealms()

  -- We sort so that we always get the same first realm to use for the database
  table.sort(connections)

  if connections[1] ~= nil then
    -- Case where we are on a connected realm
    return connections[1]
  else
    -- We are not on a connected realm
    return currentRealm
  end
end

-- Attempt to import from other connected realms (this may happen if another
-- realm was connected or the databases are not currently shared)
--
-- Assumes rootRealm has no active database
local function ImportFromConnectedRealm(rootRealm)
  local connections = GetAutoCompleteRealms()

  if #connections == 0 then
    return false
  end

  for _, altRealm in ipairs(connections) do

    if AUCTIONATOR_PRICE_DATABASE[altRealm] ~= nil then

      AUCTIONATOR_PRICE_DATABASE[rootRealm] = AUCTIONATOR_PRICE_DATABASE[altRealm]
      -- Remove old database (no longer needed)
      AUCTIONATOR_PRICE_DATABASE[altRealm] = nil
      return true
    end
  end

  return false
end

function Auctionator.Variables.InitializeDatabase()
  Auctionator.Debug.Message("Auctionator.Database.Initialize()")
  -- Auctionator.Utilities.TablePrint(AUCTIONATOR_PRICE_DATABASE, "AUCTIONATOR_PRICE_DATABASE")

  -- First time users need the price database initialized
  if AUCTIONATOR_PRICE_DATABASE == nil then
    AUCTIONATOR_PRICE_DATABASE = {
      ["__dbversion"] = VERSION_8_3
    }
  end

  -- Changing how we record item info, so need to reset the DB if prior to 8.3
  if AUCTIONATOR_PRICE_DATABASE["__dbversion"] < VERSION_8_3 then
    AUCTIONATOR_PRICE_DATABASE = {
      ["__dbversion"] = VERSION_8_3
    }
  end

  local realm = Auctionator.Variables.GetConnectedRealmRoot()

  -- Check for current realm and initialize if not present
  if AUCTIONATOR_PRICE_DATABASE[realm] == nil then
    if not ImportFromConnectedRealm(realm) then
      AUCTIONATOR_PRICE_DATABASE[realm] = {}
    end
  end

  Auctionator.State.LiveDB = AUCTIONATOR_PRICE_DATABASE[realm]

  Auctionator.Database.Prune()
end

function Auctionator.Variables.InitializeShoppingLists()
  if AUCTIONATOR_SHOPPING_LISTS == nil then
    AUCTIONATOR_SHOPPING_LISTS = {}
  end

  Auctionator.ShoppingLists.Lists = AUCTIONATOR_SHOPPING_LISTS
  Auctionator.ShoppingLists.Prune()
  AUCTIONATOR_SHOPPING_LISTS = Auctionator.ShoppingLists.Lists
end
