AUCTIONATOR_LOCALES.deDE = function()
  local L = {}

  --@debug@
  L["CONFIG_BASIC_OPTIONS_CATEGORY"] = "Grundlegende Optionen"
  L["CONFIG_BASIC_OPTIONS_TEXT"] = "Grundlegende Optionen zum Aktivieren von Funktionen in Auctionator."
  L["CONFIG_SHOPPING_LIST"] = "Einkaufslisteneinstellungen"
  L["CONFIG_AUTOSCAN"] = "Starte Autoscan wenn das Auktionshaus geöffnet wird."
  L["CONFIG_AUTOSCAN_TOOLTIP_HEADER"] = "Autoscan"
  L["CONFIG_AUTOSCAN_TOOLTIP_TEXT"] = "Führt einen vollständigen Scan durch, wenn das Auktionshaus geöffnet wird. Wenn nicht ausgewählt, kann ein vollständiger Scan ausgeführt werden, indem im Auktionshaus die Schaltfläche 'Vollständiger Scan' geklickt wird."
  L["CONFIG_AUTO_LIST_SEARCH"] = "Automatisch nach Gegenständen aus Einkaufslisten suchen."
  L["CONFIG_AUTO_LIST_SEARCH_TOOLTIP_HEADER"] = "Automatische Einkaufslistensuche"
  L["CONFIG_AUTO_LIST_SEARCH_TOOLTIP_TEXT"] = "Wenn eine Liste ausgewählt ist, wird das Auktionshaus automatisch nach Einträgen aus der ausgewählten Liste durchsucht. Wenn diese Option deaktiviert ist, kann nach der gesamten Liste gesucht, indem in der Einkaufsliste die Schaltfläche 'Suchen' geklickt wird."
  L["CONFIG_CHAT_LOG"] = "Zeige neu ertellte Auktionen im Chat"
  L["CONFIG_CHAT_LOG_TOOLTIP_HEADER"] = "Auktions Chat Log"
  L["CONFIG_CHAT_LOG_TOOLTIP_TEXT"] = "Wenn diese Option dekativiert ist, werden keine Informationen für neu erstelle Auktionen im Chat angezeigt."
  L["CONFIG_DEVELOPER"] = "Entwickleroptionen"
  L["CONFIG_DEBUG"] = "Zeige Debugmeldungen."
  L["CONFIG_DEBUG_TOOLTIP_HEADER"] = "Auctionator Debug"
  L["CONFIG_DEBUG_TOOLTIP_TEXT"] = "Wird von den Entwicklern verwendet, um Debugmeldungen im Chat auszugeben."
  

  L["CONFIG_TOOLTIPS_CATEGORY"] = "Tooltips"
  L["CONFIG_TOOLTIPS_TEXT"] = "Optionen zum Anzeigen verschiedener auktionsbezogener Informationen in Tooltips."
  L["CONFIG_MAIL_TOOLTIP"] = "Zeige Infos in Mailbox."
  L["MAIL_TOOLTIP_TOOLTIP_HEADER"] = "Mailbox Tooltip Infos"
  L["MAIL_TOOLTIP_TOOLTIP_TEXT"] = "Zeigt Auctionator-Informationen zu Gegenständen in der Mailbox an."
  L["CONFIG_VENDOR_TOOLTIP"] = "Zeige Händler Infos."
  L["VENDOR_TOOLTIP_TOOLTIP_HEADER"] = "Händler Tooltip Infos"
  L["VENDOR_TOOLTIP_TOOLTIP_TEXT"] = "Zeigt den Händlerpreis im Tooltip an."
  L["CONFIG_AUCTION_TOOLTIP"] = "Zeige Auktions Infos."
  L["AUCTION_TOOLTIP_TOOLTIP_HEADER"] = "Auktion Tooltip Infos"
  L["AUCTION_TOOLTIP_TOOLTIP_TEXT"] = "Zeigt den Auktionspreis im Tooltip an."
  L["CONFIG_ENCHANT_TOOLTIP"] = "Zeige entzaubern Infos (nur WoD, Legion & BfA)."
  L["ENCHANT_TOOLTIP_TOOLTIP_HEADER"] = "Entzaubern Tooltip Infos"
  L["ENCHANT_TOOLTIP_TOOLTIP_TEXT"] = "Zeigt entzaubern Infos im Tooltip an."
  L["CONFIG_STACK_TOOLTIP"] = "Zeige Stapelpreis während Shift gedrückt wird."
  L["STACK_TOOLTIP_TOOLTIP_HEADER"] = "Stapelpreise"
  L["STACK_TOOLTIP_TOOLTIP_TEXT"] = "Wenn ausgewählt, muss die Shift Taste gehalten werden, um den Stapelpreis anzuzeigen. Wenn nicht ausgewählt, werden immer die Stapelpreise angezeigt."

  L["CONFIG_LIFO_CATEGORY"] = "Verkaufen"
  L["CONFIG_NOT_LIFO_CATEGORY"] = "Ausrüstung/Haustiere"
  L["CONFIG_SELLING_LIFO_HEADER"] = "Verkaufen"
  L["CONFIG_SELLING_NOT_LIFO_HEADER"] = "Ausrüstung/Haustiere verkaufen"
  L["CONFIG_SELLING_LIFO_TEXT"] = "Optionen zum Einstellen der Dauer und des prozentualen oder fixen unterbietens von den meisten Gegenständen."
  L["CONFIG_SELLING_NOT_LIFO_TEXT"] = "Optionen zum Einstellen der Dauer und des prozentualen oder fixen unterbietens von Gegenständen und Haustierkäfigen."
  L["DEFAULT_AUCTION_DURATION"] = "Standarddauer für Auktionen"
  L["AUCTION_DURATION_12"] = "12 Stunden"
  L["AUCTION_DURATION_24"] = "24 Stunden"
  L["AUCTION_DURATION_48"] = "48 Stunden"

  L["SALES_PREFERENCE"] = "Verkaufseinstellungen"
  L["PERCENTAGE"] = "Prozentual"
  L["SET_VALUE"] = "Fixer Betrag"

  L["PERCENTAGE_SUFFIX"] = "% unterbieten"
  L["SET_VALUE_SUFFIX"] = "unterbieten"

  L["PERCENTAGE_TOOLTIP_HEADER"] = "Prozentual unterbieten"
  L["PERCENTAGE_TOOLTIP_TEXT"] = "Der zu unterbietende Prozentsatz wird zur Berechnung des Verkaufspreises verwendet. Ein Wert von 5 bedeutet beispielsweise, dass Gegenstände mit 5% weniger als dem aktuell niedrigsten Preis eingestellt werden."

  L["UNDERCUT_TOOLTIP_HEADER"] = "Fixer unterbieten Betrag"
  L["UNDERCUT_TOOLTIP_TEXT"] = "Der fixe unterbieten Betrag wird zur Berechnung der Verkaufspreises verwendet."

  L["AUTHOR_HEADER"] = "Author"
  L["CONTRIBUTORS_HEADER"] = "Mitwirkende"
  L["VERSION_HEADER"] = "Version"
  L["OPEN_ADDON_OPTIONS"] = "Optionen"

  L["STACK_AUCTION_INFO"] = "%s für %s (jedes zu %s)"
  L["BIDDING_AUCTION_INFO"] = "%s Versteigerung für %s"
  L["BUYOUT_AUCTION_INFO"] = "%s Sofortkauf für %s"
  L["VERSION_MESSAGE"] = "Version %s"
  L["DATABASE_LOADED"] = "Datenbank mit %s Einträgen geladen."
  L["LIMITED_FUNCTIONALITY_MESSAGE"] = "Limited functionality due to 8.3 AH updates."

  L["STARTING_FULL_SCAN"] = "Starte vollständigen Scan."
  L["NEXT_SCAN_MESSAGE"] = "Der nächste vollständige Scan ist erst in %s Minuten and %s Sekunden möglich."
  L["FULL_SCAN_FAILED"] = "Vollständiger Scan fehlgeschlagen."
  L["FINISHED_PROCESSING"] = "%s Gegenstände verarbeitet."
  L["STOPPED_PROCESSING"] = "Verarbeitung bei %s von %s Gegenständen gestoppt."

  L["TOO_MANY_SEARCH_RESULTS"] = "Zu viele Suchergebnisse. Es werden nicht alle Ergebnisse angezeigt." 
  L["LIST_DELETE_ERROR"] = "Beim Löschen einer Liste ist ein fehler aufgetreten."
  L["LIST_ADD_ERROR"] = "Beim Hinzufügen eines Gegenstandes in eine Liste ist ein Fehler aufgetreten."

  L["TOO_SMALL_PERCENTAGE"] = "%% muss >= 0 (eingegeben wurde %s)"
  L["TOO_BIG_PERCENTAGE"] = "%% muss <= 100 (eingegeben wurde %s)"

  L["AUCTION"] = "Auktion"
  L["CANNOT_AUCTION"] = "Kann nicht versteigert werden"
  L["UNKNOWN"] = "unbekannt"
  L["VENDOR"] = "Händler"
  L["DISENCHANT"] = "Entzaubern"
  L["TOTAL_ITEMS_COLORED"] = "|cFFAAAAFF %s Gegenstände|r gesamt"

  L["DELETE_LIST_NONE_SELECTED"] = "Zum Löschen muss eine Liste ausgewählt sein."
  L["DELETE_LIST_CONFIRM"] = "Sicher, das '%s' gelöscht werden soll?"
  L["CREATE_LIST_DIALOG"] = "Name der neuen Einkaufsliste eingeben:"
  L["RENAME_LIST_DIALOG"] = "Neuen Name der Einkaufsliste eingeben:"
  L["ADD_TERM_TO_LIST_DIALOG"] = "Begriff nach dem gesucht werden soll:"

  L["RENAME"] = "Umbenennen"
  L["DELETE"] = "Löschen"
  L["CREATE"] = "Neu"
  L["ADD_ITEM"] = "Hinzufügen"
  L["SEARCH"] = "Suchen"

  L["SHOPPING_TAB"] = "Einkaufen"
  L["SHOPPING_TAB_HEADER"] = "Auctionator - Einkaufslisten"
  L["INFO_TAB_HEADER"] = "Auctionator - Info"

  L["FETCHING_ITEM_INFO"] = "Rufe Gegenstandsinformationen ab..."
  L["LIST_SEARCH_START"] = "Suche nach Gegenständen in %s..."
  L["LIST_SEARCH_STATUS"] = "Suche nach Gegenstand %s/%s in\n %s"
  L["RESULTS_PRICE_COLUMN"] = "Preis"
  L["RESULTS_NAME_COLUMN"] = "Name"
  L["RESULTS_AVAILABLE_COLUMN"] = "Verfügbar"
  L["FULL_SCAN_BUTTON"] = "Vollständiger Scan"
  --@end-debug@

  --@localization(locale="deDE", format="lua_additive_table")@

  return L
end
