Auctionator.Config.Options.SMALL_TABS = "small_tabs"
Auctionator.Config.Options.PET_TOOLTIPS = "pet_tooltips"
Auctionator.Config.Options.AUTOSCAN = "autoscan_2"
Auctionator.Config.Options.AUTOSCAN_INTERVAL = "autoscan_interval"
Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT = "selling_cancel_shortcut"
Auctionator.Config.Options.SELLING_BUY_SHORTCUT = "selling_buy_shortcut"
Auctionator.Config.Options.SELLING_SPLIT_PANELS = "selling_split_panels"

Auctionator.Config.Options.AUCTION_DURATION = "auction_duration"
Auctionator.Config.Options.AUCTION_SALES_PREFERENCE = "auction_sales_preference"
Auctionator.Config.Options.UNDERCUT_PERCENTAGE = "undercut_percentage"
Auctionator.Config.Options.UNDERCUT_STATIC_VALUE = "undercut_static_value"
Auctionator.Config.Options.SELLING_GEAR_USE_ILVL = "gear_use_ilvl"

Auctionator.Config.Options.DEFAULT_QUANTITIES = "default_quantities"
Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO = "undercut_scan_not_lifo"

Auctionator.Config.Defaults[Auctionator.Config.Options.SMALL_TABS] = false
Auctionator.Config.Defaults[Auctionator.Config.Options.PET_TOOLTIPS] = true
Auctionator.Config.Defaults[Auctionator.Config.Options.AUTOSCAN] = false
Auctionator.Config.Defaults[Auctionator.Config.Options.AUTOSCAN_INTERVAL] = 15
Auctionator.Config.Defaults[Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO] = true
Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT] = Auctionator.Config.Shortcuts.RIGHT_CLICK
Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_BUY_SHORTCUT] = Auctionator.Config.Shortcuts.ALT_RIGHT_CLICK
Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_SPLIT_PANELS] = false

Auctionator.Config.Defaults[Auctionator.Config.Options.AUCTION_DURATION] = 24
Auctionator.Config.Defaults[Auctionator.Config.Options.AUCTION_SALES_PREFERENCE] = Auctionator.Config.SalesTypes.PERCENTAGE
Auctionator.Config.Defaults[Auctionator.Config.Options.UNDERCUT_PERCENTAGE] = 0
Auctionator.Config.Defaults[Auctionator.Config.Options.UNDERCUT_STATIC_VALUE] = 0
Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_GEAR_USE_ILVL] = true

Auctionator.Config.Defaults[Auctionator.Config.Options.DEFAULT_QUANTITIES] = {
  [Enum.ItemClass.Weapon]           = 1,
  [Enum.ItemClass.Armor]            = 1,
  [Enum.ItemClass.Container]        = 0,
  [Enum.ItemClass.Gem]              = 0,
  [Enum.ItemClass.ItemEnhancement]  = 0,
  [Enum.ItemClass.Consumable]       = 0,
  [Enum.ItemClass.Glyph]            = 0,
  [Enum.ItemClass.Tradegoods]       = 0,
  [Enum.ItemClass.Recipe]           = 0,
  [Enum.ItemClass.Battlepet]        = 1,
  [Enum.ItemClass.Questitem]        = 0,
  [Enum.ItemClass.Miscellaneous]    = 0,
}
