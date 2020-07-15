-- TODO Initialize all the things here!
-- TODO Document all of our saved vars (started in Objects, should aggregate somewhere)
local VERSION_8_3 = 6

-- All the saved variables from the TOC
-- SavedVariablesPerCharacter:
--   AUCTIONATOR_SHOW_ST_PRICE, AUCTIONATOR_ENABLE_ALT, AUCTIONATOR_OPEN_FIRST,
--   AUCTIONATOR_OPEN_BUY, AUCTIONATOR_DEF_DURATION, AUCTIONATOR_SHOW_TIPS, AUCTIONATOR_D_TIPS,
--   AUCTIONATOR_DE_DETAILS_TIPS, AUCTIONATOR_DEFTAB
-- SavedVariables:
--   AUCTIONATOR_CONFIG, AUCTIONATOR_SAVEDVARS, AUCTIONATOR_PRICING_HISTORY, AUCTIONATOR_SHOPPING_LISTS,
--   AUCTIONATOR_PRICE_DATABASE, AUCTIONATOR_TOONS, AUCTIONATOR_STACKING_PREFS, AUCTIONATOR_DB_MAXITEM_AGE,
--   AUCTIONATOR_DB_MAXHIST_AGE, AUCTIONATOR_DB_MAXHIST_DAYS, AUCTIONATOR_FS_CHUNK, AUCTIONATOR_DE_DATA,
--   AUCTIONATOR_DE_DATA_BAK, ITEM_ID_VERSION


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

function Auctionator.Variables.InitializeDatabase()
  Auctionator.Debug.Message("Auctionator.Database.Initialize()")
  -- Auctionator.Utilities.TablePrint(AUCTIONATOR_PRICE_DATABASE, "AUCTIONATOR_PRICE_DATABASE")

  local realm = GetRealmName()

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

  -- Check for current realm and initialize if not present
  if AUCTIONATOR_PRICE_DATABASE[realm] == nil then
    AUCTIONATOR_PRICE_DATABASE[realm] = {}
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
