﻿function AtrBuildLTable_deDE ()

-- Translated by ckaotik

-- ToDo: Please let Atr_AbbrevItemName run through a list of abbreviations, not just one ;)
--        Would help tons for other languages!
-- Some strings that you localise in this file are actually part of the GlobalStrings.lua (e.g. Common, Rare etc)


AtrL = {};

-- New Vars
--- Globals
AUCTIONATOR_SELL_TAB_TEXT = "Sell"
AUCTIONATOR_AUCTION_DURATION = "Default Auction Duration"
AUCTIONATOR_DEFAULT_AUCTIONATOR_TAB = "Default Auctionator tab"
AUCTIONATOR_MINIMUM_QUALITY_LEVEL = "Minimum quality level:"
AUCTIONATOR_MEMORY_USAGE = "Auctionator Memory Usage"
AUCTIONATOR_ITEMS_IN_THE_DATABASE = "Items in the database:"
AUCTIONATOR_DELETE_HISTORICAL_PRICES = "On start-up delete historical prices older than:"
AUCTIONATOR_DELETE_HISTORICAL_PRICES_DAYS = "day/s"
AUCTIONATOR_CLEAR_SCANNING_HISTORY_BTN = "Clear Scanning History"
AUCTIONATOR_CLEAR_POSTING_HISTORY_BTN = "Clear Posting History"
AUCTIONATOR_CLEAR_STACKING_PREFERENCES_BTN = "Clear Stacking Preferences"
AUCTIONATOR_CLEAR_SHOPPING_LISTS_BTN = "Clear Shopping Lists"
AUCTIONATOR_SHOPPING_LISTS_OPTION_DESCRIPTION = "Select multiple shopping lists by holding down the control key while clicking"
AUCTIONATOR_SHPLIST_IMPORTSAVEBTN = "Shopping List Import Button"
AUCTIONATOR_SHPLIST_SAVEBTN = "Save"
AUCTIONATOR_SHPLIST_SELECTALLBTN = "Select All"
AUCTIONATOR_SHPLIST_ALREADY_EXIST = "The following shopping list(s) already exist:"
AUCTIONATOR_SHPLIST_OKAY = "OKAY"
AUCTIONATOR_SHPLIST_NEW_NAME_TEXT = "New name for this list"
AUCTIONATOR_AUTOR_TEXT = "Author:  Borjamacare (US)"
AUCTIONATOR_ITEM_NAME = "Item Name"
AUCTIONATOR_ITEM_PRICE = "Item Price"
AUCTIONATOR_CURRENT_AUCTIONS = "Current Auctions"
AUCTIONATOR_SAVE_THIS_SHPLIST = "Save this Shopping List"
AUCTIONATOR_LOWEST_PRICE = "Lowest Price"
AUCTIONATOR_ITEM_NAME = "Item Name"
AUCTIONATOR_NEW = "New"
AUCTIONATOR_IMPORT = "Import"
AUCTIONATOR_EXPORT = "Export"
AUCTIONATOR_ARE_YOU_SURE = "Are you sure?"
AUCTIONATOR_CLEAR_IT = "Clear It"
AUCTIONATOR_ADD_ITEM = "Add Item"
AUCTIONATOR_REMOVE_ITEM = "Remove Item"
AUCTIONATOR_SEARCH_FOR_ALL_ITEMS = "Search for All Items"
AUCTIONATOR_MANAGE_SHOPPING_LISTS = "Manage Shopping Lists"
AUCTIONATOR_NEW_SHOPPING_LIST = "New Shopping List"
AUCTIONATOR_NEXT_SCAN_ALLOWED = "Next scan allowed:"
AUCTIONATOR_LAST_SCAN = "Last scan:"
AUCTIONATOR_ITEMS_IN_DB = "Items in database:"
AUCTIONATOR_START_SCANNING = "Start Scanning"
AUCTIONATOR_AUCTIONS_SCANNED = "Auctions scanned:"
AUCTIONATOR_ITEMS_ADDED = "Items added:"
AUCTIONATOR_ITEMS_UPDATED = "Items updated:"
AUCTIONATOR_ITEMS_IGNORED = "Items ignored:"
--- End Globals
AtrL["AH"] = ""
AtrL["%A, %B %d at %I:%M %p"] = "%d/%m/%Y alle %H:%M" -- Date and Time. Refer to https://www.lua.org/pil/22.1.html
AtrL["Date"] = ""
AtrL["Today"] = ""
AtrL["Yesterday"] = ""
AtrL["Slow scan"] = ""
AtrL["Level"] = ""
AtrL["Shopping list overwritten:"] = ""
AtrL["Shopping list created:"] = ""
AtrL["Paste text that was previously exported into the text area to the left."] = ""
AtrL["Create new shopping lists with new names"] = ""
AtrL["Create new shopping lists with new names."] = ""
AtrL["Overwrite the existing shopping lists with the imported lists."] = ""
AtrL["Abort the import.  You can hand-edit the import text to change the names and then try again."] = ""
AtrL["Click Select All, type Ctrl-C to copy the text and then paste into any text document."] = ""
AtrL["%6d items"] = "" -- AUCTIONATOR_ITEMS_IN_THE_DATABASE %6d items description
AtrL["Default Auction duration"] = ""
AtrL["Options..."] = ""
AtrL["More"] = ""
AtrL["Yes, cancel them"] = ""
AtrL["No, leave them"] = ""
AtrL["Basic Options"] = "Attiva scorciatoia tasto Alt"
AtrL["Show Starting Price on the Sell Tab"] = ""
AtrL["Enable debug mode"] = ""
AtrL["basic options saved"] = ""
AtrL["Reset to Default"] = ""
AtrL["Shopping Lists"] = ""
AtrL["New"] = ""
AtrL["Edit"] = ""
AtrL["Delete"] = ""
AtrL["Rename"] = ""
AtrL["Import"] = ""
AtrL["Export"] = ""
AtrL["Tooltips"] = ""
AtrL["Show vendor prices in tooltips"] = ""
AtrL["Show auction house prices in tooltips"] = ""
AtrL["Show disenchant prices in tooltips"] = ""
AtrL["Show auction house prices in mailbox tooltips"] = ""
AtrL["Undercutting"] = ""
AtrL["Selling"] = ""
AtrL["Configure how you typically like to sell the items listed below."] = ""
AtrL["Clears"] = "Pulizia"
AtrL["The features below will help you clear out data that Auctionator stores.  Typically you would only need this in the event that that data gets corrupted."] = ""
AtrL["Read the FAQ at"] = "Leggi le FAQ su"
AtrL["MoP disenchanting data courtesy of the Norganna's AddOns (the Auctioneer folks)"] = ""
AtrL["Subcategory"] = ""
AtrL["Search For"] = ""
AtrL["Level Range"] = LEVEL_RANGE.."."
AtrL["Advanced Search"] = ""
AtrL["Advanced"] = ADVANCED_LABEL
AtrL["Vendor"] = AUCTION_CREATOR
AtrL["Version"] = GAME_VERSION_LABEL
AtrL["items"] = ""
AtrL["Time:"] = ""
AtrL["auctions returned empty results (out of %d)"] = ""
AtrL["auctions returned null itemLinks (out of %d)"] = ""
AtrL["Blizzard server failed to return all items"] = ""
AtrL["You might want to try slow scanning."] = ""
AtrL["Buy Another"] = ""
AtrL["Buy One"] = ""
AtrL["Are you sure you want to clear the scanned prices database?"] = ""
AtrL["This will clear the pricing history for all items for all your characters - even characters on different servers."] = ""
AtrL["Pricing history cleared."] = ""
AtrL["Are you sure you want to clear the posting history?"] = ""
AtrL["This will clear the information that Auctionator keeps for all items that you've posted - as shown on the \"Other\" tab after you scan for an item that you've sold in the past."] = ""
AtrL["Posting history cleared."] = ""
AtrL["Are you sure you want to clear your stacking preferences?"] = ""
AtrL["Go ahead - this isn't a big deal.  Auctionator will figure it out again fairly quickly.  This is just some info Auctionator keeps to help it set the default stack size a bit more intelligently."] = ""
AtrL["Stacking preferences cleared."] = ""
AtrL["Are you sure you want to clear your shopping lists?"] = ""
AtrL["If you put a lot of time into constructing detailed shopping lists, this will require you to build them all over again."] = ""
AtrL["Shopping lists cleared."] = ""
AtrL["Memory went from"] = ""
AtrL["to"] = ""
AtrL["Disenchant data restored. Number of entries:"] = ""
AtrL["No data available to be restored."] = ""
AtrL["1 stack available"] = ""
AtrL["%d stacks available"] = ""
AtrL["none available"] = ""
AtrL["Waiting for auction data"] = ""
AtrL["Updating database"] = ""
AtrL["Scan complete"] = ""
AtrL["Analyzing data"] = ""
AtrL["out of"] = ""
AtrL["Page %s of %s"] = ""
AtrL["FULL SCAN:"] = ""
AtrL["AUCTIONATOR_FS_CHUNK:"] = ""
AtrL["Warning"] = ""
AtrL["Bad item scanned."] = ""
AtrL["Name:"] = ""
AtrL["Count:"] = ""
AtrL["badItemCount:"] = ""
AtrL["ignored"] = ""
AtrL["Scanning auctions: page %d of %d"] = ""
AtrL["Scanning auctions for %s%s"] = ""
AtrL["When the Auction House is open\nclicking this button tells Auctionator\nto scan for the item and all its reagents."] = ""
AtrL["%d bought so far"] = ""
AtrL["%d available"] = ""
AtrL["Italian translation courtesy of %s"] = ""
-- End New Vars

-- Old Vars

-- slash commands
AtrL["unrecognized command"] = "unbekannter Befehl"

-- error messages / informative popups
AtrL["Auctionator provided an auction module to LilSparky's Workshop."] = "Auctionator stellt ein Auktionsmodul für LilSparky's Workshop."
AtrL["Ignore any ERROR message to the contrary below."] = "Ignoriere jegliche Fehlermeldung in Bezug darauf, die folgt!"

AtrL["Wowecon global price"] = "WoWecon globaler Preis"
AtrL["Wowecon server price"] = "WoWecon Serverpreis"

AtrL["No current auctions with buyouts found"] = "Keine aktuellen Sofortkauf-Auktionen gefunden."
AtrL["Really delete the shopping list %s ?"] = "Einkaufsliste wirklich löschen?"
AtrL["Entry must not be blank"] = ""
AtrL["There is a more recent version of Auctionator: VERSION"] = "Es gibt eine neuere Version von Auctionator: VERSION"
AtrL["You can buy at most %d auctions"] = "Du kannst maximal %d Auktionen kaufen"            -- don't overspend!
AtrL["You can create at most %d auctions"] = "Du kannst maximal %d Auktionen erstellen"
AtrL["You can stack at most %d of these items"] = "Du kannst maximal %d davon pro Stack haben"
AtrL["You may have no more than\n\n%d items on a shopping list."] = "Du kannst nicht mehr als\n\n\%d Items auf einer Einkaufsliste haben"
AtrL["Create Multiple Auctions failed.\nYou need at least one empty slot in your bags."] = "Mehrere Auktionen konnten nicht erstellt werden.\nDu benötigst wenigstens einen freien Taschenplatz."

AtrL["You do not have enough gold\n\nto make any more purchases."] = "Du hast nicht genug Gold\n\num mehr zu kaufen."
AtrL["You may have at most 40 single-stack (x1)\nauctions posted for this item.\n\nYou already have %d such auctions and\nyou are trying to post %d more."] = "Du kannst maximal 40 Einzelstacks (x1)\nfür diesen Gegenstand haben.\n\nDu hast bereits %d dieser Auktionen und\nversuchst %d weitere einzustellen."


-- tooltip lines
AtrL["Vendor"] = "Händlerpreis"
AtrL["Auction"] = "Auktion"
AtrL["Disenchant"] = "Entzaubern"
AtrL["BOP"] = "BoP"                                -- bind on pickup items cannot be traded on the auction house
AtrL["Quest Item"] = "Questgegenstand"
AtrL["unknown"] = "unbekannt"                    -- used in tooltips when data is not available

-- buy pane texts
AtrL["Buy"] = "Kaufe"                            -- tab name
AtrL["Select an item from the list on the left\n or type a search term above to start a scan."] = "Wähle ein Item aus der Liste links\n oder gib deine Suchanfrage oben ein."
AtrL["Search"] = "Suche"
AtrL["available"] = "verfügbar"
AtrL["Recent Searches"] = "Kürzliche Suchen"
AtrL["Item Name"] = "Gegenstand"
AtrL["Item Price"] = "Itempreis"
AtrL["no buyout price"] = "kein Sofortkauf"

AtrL["Add Item To List"] = "Zur Liste hinzufügen"
AtrL["Remove Item From List"] = "Item von der Liste entfernen"
AtrL["Delete Shopping List"] = "Einkaufsliste löschen"
AtrL["New Shopping List"] = "Neue Einkaufsliste"

AtrL["Name for your new shopping list"] = "Name der neuen Einkaufsliste"

AtrL["stack for"] = "Stack für"            -- information on the shopping dialogue
AtrL["stacks for"] = "Stacks für"        -- e.g. "buy 3 stacks for 45g"

-- sell pane texts
AtrL["Sell"] = "Verkaufe"                        -- tab name
AtrL["Recommended Buyout Price"] = "Vorgeschlagener Sofortkaufpreis"
AtrL["for your stack of %d"] = "für deinen Stack von %d"
AtrL["per stack"] = "pro Stack"
AtrL["Per Item"] = "pro Item"
AtrL["Starting Price"] = "Startpreis"

AtrL["Cancel Auctions"] = "Auktionen abbrechen"
AtrL["Drag an item you want to sell to this area."] = "Zieh einen zu verkaufenden Gegenstand hierher"
AtrL["Create Auction"] = "Auktion erstellen"
AtrL["Create %d Auctions"] = "%d Auktionen erstellen"
AtrL["stack of"] = "stack à"                -- 1 stack of 20 Borean Leather
AtrL["stacks of"] = "stacks à"                -- 3 stacks of 20 Borean Leather
AtrL["max"] = "max"                                -- e.g. "max. 5"
AtrL["Duration"] = "Dauer"
AtrL["Deposit"] = "Anzahlung"
AtrL["Current"] = "Aktuell"                        -- the three sub-tabs
AtrL["History"] = "Verlauf"
AtrL["Past"] = "Alt"
AtrL["Other"] = "Andere"
AtrL["stack price"] = "Stackpreis"                -- column header
AtrL["per item price"] = "Preise pro Item"

AtrL["Auctionator scan data"] = "Auctionator Scan Daten"
AtrL["Auctionator has yet to record any auctions for this item"] = "Auctionator muss dieses Item erst als Auktion sehen"

AtrL["Processing"] = "Verarbeiten"
AtrL["Auction #%d created for %s"] = "Auktion #%d erstellt für %s."
AtrL["Auction created for %s"] = "Auktion erstellt für %s."
AtrL["Are you sure you want to create\nan auction with no buyout price?"] = "Bist du sicher, dass du eine Auktion ohne Sofortkaufpreis erstellen willst?"
AtrL["average of your auctions for"] = "Durchschnitt deiner Auktionen für"

AtrL["based on"] = "basierend auf"                -- detail shown for Recommended Buyout Price
AtrL["based on cheapest current auction"] = "basierend auf der z.Z. günstigsten Auktion"
AtrL["based on cheapest stack of the same size"] = "basierend auf dem biligsten Stack dieser Größe"
AtrL["based on selected auction"] = "basierend auf der ausgewählten Auktion"

-- other auction pane texts
AtrL["More"] = "Mehr"                            -- tab name
AtrL["Active Items"] = "Aktive Items"
AtrL["All Items"] = "Alle Items"
AtrL["Check for Undercuts"] = "Unterboten?"
AtrL["Just Check Auctions"] = "Nur prüfen"
AtrL["Check and Cancel Auctions"] = "Auktionen prüfen/abbrechen"

AtrL["Total Price"] = "Gesamtpreis"
AtrL["Lowest Price"] = "Günstigster Preis"
AtrL["Automatically cancel all of your auctions|n|nthat are not the lowest priced?"] = "Automatisch alle Auktionen abbrechen\n bei denen du unterboten wurdest?"

AtrL["your auction on"] = "deine Auktion für"
AtrL["your most recent posting"] = "dein aktuellstes Angebot"

AtrL["Current Auctions"] = "Aktuelle Auktionen"
AtrL["No current auctions found"] = "Keine aktuellen Auktionen gefunden"
AtrL["No current auctions found\n\n(related auctions shown)"] = "Keine aktuellen Auktionen gefunden (ähnliche werden angezeigt)"

AtrL["None"] = "Kein"
AtrL["Back"] = "Zurück"
AtrL["yours"] = "deins"                            -- to distinguish yours from others' auctions
AtrL["hours"] = "Stunden"                        -- used for setting up an auction's duration
AtrL["Source"] = "Quelle"

-- scan pane
AtrL["Full Scan..."] = "Scan..."        -- button to open this panel
AtrL["Full Scan"] = "Kompletter Scan"    -- header of the scan panel
AtrL["Scanning auctions: page %d"] = "Scanne Auktionen: Seite %d"

AtrL["Scanning is entirely optional."] = "Scannen ist optional"
AtrL["SCAN_EXPLANATION"] = "Scannen des Auktionshauses erstellt eine Datenbank, die Auctionator für zwei Zwecke nutzt: Als Preisvorschlag, "
                            .."wenn dieses Item gerade nicht als Auktion vorhanden ist und im Tooltip, wenn du gerade nicht am Auktionshaus bist."
                            .."<br/><br/>"
                            .."Das Scannen dauert meist um die 10 Sekunden, kann aber je nach Serverlast und anderen Auktionsaddons länger dauern. "
                            .."Achtung: Blizzard erlaubt Scans nur alle 15 Minuten."
                            .."<br/><br/>"
                            .."Warnung: Bei einer schwachen Internetleitung kann der Scan dich von WoW trennen!";

AtrL["Start Scanning"] = "Scan starten"
AtrL["Scanning"] = "Scannen"                -- shows "Scanning ......." during process
AtrL["Scan complete"] = "Scan erfolgreich"

AtrL["Next scan allowed:"] = "Nächstmöglich:"
AtrL["Last scan:"] = "Letzter Scan:"
AtrL["Items in database:"] = "Datenbankgröße:"
AtrL["in about %d minutes"] = "in ca. %d Minuten"
AtrL["in about one minute"] = "in ca. einer Minute"
AtrL["in less than a minute"] = "in weniger als einer Minute"
AtrL["Now"] = "Jetzt"

AtrL["Items added to database"] = "Gegenstände zur Datenbank hinzugefügt"
AtrL["Items added:"] = "Hinzugefügt:"
AtrL["Items ignored"] = "Gegenstände ignoriert"
AtrL["Items ignored:"] = "Ignoriert:"
AtrL["Items updated in database"] = "Gegenstände in der Datenbank aktualisiert"
AtrL["Items updated:"] = "Aktualisiert:"

-- blizzard config screen
--   Basic Options
AtrL["Basic Options for %s"] = "Grundeinstellungen für %s"
AtrL["Enable alt-key shortcut"] = "ALT-Shortcut nutzen"
AtrL["Show Starting Price on the Sell Tab"] = "Gebotspreis im Verkaufsfenster anzeigen"
AtrL["Set a default duration"] = "Standarddauer einstellen"
AtrL["Default Auctionator tab"] = "Standard-Tab"
AtrL["Select the Auctionator panel to be displayed first whenever you open the Auction House window."] = "Wähle, welches Auctionator-Tab zuerst gezeigt wird, wenn du am Auktionshaus bist."


--     descriptive texts
AtrL["If this option is checked, every time you initiate a new auction the auction duration will be reset to the default duration you've selected."] = "Wenn diese Option aktiviert ist, wird jede neue Auktion mit dieser Dauer gestartet."
AtrL["If this option is checked, holding the Alt key down while clicking an item in your bags will switch to the Auctionator panel, place the item in the Auction Item area, and start the scan."] = "Wenn diese Option aktiviert ist, kannst du mit alt-Klick auf ein Item dieses in den Verkaufsbereich legen und den Scan starten."
AtrL["If this option is checked, the Auctionator BUY panel will display first whenever you open the Auction House window."] = "Wenn diese Option aktiviert ist, startet das Auktionsfenster im KAUFEN-Tab."
AtrL["If this option is checked, the Auctionator SELL panel will display first whenever you open the Auction House window."] = "Wenn diese Option aktiviert ist, startet das Auktionsfenster im VERKAUFEN-Tab."
AtrL["Only include items in the scanning database that are this level or higher"] = "Betrachte nur Items, die diese Level oder ein höheres haben."


--   Tooltips
AtrL["Tooltips"] = "Tooltips"
AtrL["Show vendor prices in tooltips"] = "Zeige Händlerpreise im Tooltip"
AtrL["Show auction house prices in tooltips"] = "Zeige Auktionshauspreise im Tooltip"
AtrL["Show disenchant prices in tooltips"] = "Zeige Entzauberpreise im Tooltip"

AtrL["When SHIFT is down show"] = "Wenn SHIFT gedrückt ist, zeige"
AtrL["Show disenchanting details"] = "Zeige Entzauberdetails"
AtrL["never"] = "Nie"
AtrL["always"] = "Immer"
AtrL["when ALT is held down"] = "Wenn ALT gedrückt ist"
AtrL["when CONTROL is held down"] = "Wenn STRG gedrückt ist"
AtrL["when SHIFT is held down"] = "Wenn SHIFT gedrückt ist"

AtrL["tooltip configuration saved"] = "Tooltip-Einstellungen gespeichert"

--   Undercutting
AtrL["Undercutting"] = "Unterbieten"
AtrL["Buyout Price"] = "Sofortkauf"
AtrL["Undercut by"] = "Unterbieten um"
AtrL["over 1 gold"] = "über 1 Gold"
AtrL["over %d gold"] = "über %d Gold"
AtrL["over %d silver"] = "über %d Silber"
AtrL["Starting Price Discount"] = "Startpreis-Nachlass"
AtrL["Reset to Default"] = "Standardwerte"
AtrL["percent"] = "Prozent"            -- undercut by x percent

AtrL["undercutting configuration saved"] = "Unterbieten-Einstellungen gespeichert"

--   Scanning
AtrL["Minimum Quality Level"] = "Minimale Qualität"
AtrL["Minimum quality level:"] = "Minimale Qualität:"
AtrL["Poor (all)"] = "Schlecht (alle)"
AtrL["Poor items"] = "Schlechte Gegenstände"
AtrL["Common"] = "Gewöhnlich"
AtrL["Common items"] = "Gewöhnliche Gegenstände"
AtrL["Uncommon"] = "Ungewöhnlich"
AtrL["Uncommon items"] = "Ungewöhnliche Gegenstände"
AtrL["Rare"] = "Selten"
AtrL["Rare items"] = "Seltene Gegenstände"
AtrL["Epic"] = "Episch"
AtrL["Epic items"] = "Epische Gegenstände"

AtrL["scanning options saved"] = "Scaneinstellungen gespeichert"

--   Selling
AtrL["Selling"] = "Verkaufen"
AtrL["Configure how you typically like to sell the items listed below."] = "Stelle deine üblichen Verkaufsoptionen unten ein."
AtrL["Category"] = "Kategorie"
AtrL["Edit"] = "Bearbeiten"
AtrL["New"] = "Neu"
AtrL["Forget this Item"] = "Dieses Item ignorieren."
AtrL["default behavior"] = "Standardverhalten"
AtrL["1 stack"] = "1 Stack"
AtrL["As many as possible"] = "So viele wie möglich"

AtrL["Glyphs"] = "Glyphen"
AtrL["Gems - Cut"] = "Edelsteine (geschliffen)"
AtrL["Gems - Uncut"] = "Edelsteine (roh)"
AtrL["Item Enhancements"] = "Gegenstandsverbesserungen"
AtrL["Potions and Elixirs"] = "Tränke und Elixiere"
AtrL["Flasks"] = "Fläschchen"
AtrL["Herbs"] = "Kräuter"

--   About
AtrL["About"] = "Über"
AtrL["The latest information on Auctionator can be found at"] = "Die aktuellsten Informationen zu Auctionator kannst du hier finden:"
AtrL["For information on the latest version browse to"] = "Für Informationen über die aktuellste Version, geh zu"
AtrL["French translation courtesy of %s"] = "Französische Übersetzung von %s"
AtrL["German translation courtesy of %s"] = "Deutsche Übersetzung von %s"
AtrL["Swedish translation courtesy of %s"] = "Schwedische Lokalisierung von %s"
AtrL["Russian translation courtesy of %s"] = "Russische Übersetzung von %s"
AtrL["Auctionator"] = "Auctionator"
AtrL["Author:  Borjamacare"] = "Autor: Borjamacare"
AtrL["Version"] = "Version"


--   Misc
AtrL["%d of %d bought so far"] = "bisher %d von %d gekauft"
AtrL["Auction cancelled for "] = "Auktion abgebrochen für"
AtrL["Auction House timed out"] = "Zeitüberschreitung"
AtrL["Auctions scanned"] = "Auktionen gescannt"
AtrL["Auctions scanned:"] = "Auktionen gescannt:"
AtrL["Checking stopped"] = "Überprüfung abgebrochen"
AtrL["Cleaning up"] = "Aufräumen"
AtrL["Continue"] = "Forsetzen"
AtrL["full scan database cleared"] = "Gespeicherte Daten gelöscht"
AtrL["max. stacks of %d"] = "max. %der Stacks"
AtrL["pricing history cleared"] = "Preisverlauf geleert"
AtrL["removed from database"] = "aus der Datenbank entfernt"
AtrL["Required DE skill level"] = "Benötigt Verzauberkunst Fertigkeit"
AtrL["Scan in progress"] = "Scan wird ausgeführt"
AtrL["stack"] = "Stack"
AtrL["stacks for:"] = "Stacks für:"
AtrL["Stop Checking"] = "Überprüfung abbrechen"
AtrL["trade volume"] = "Handelsvolumen"


end
