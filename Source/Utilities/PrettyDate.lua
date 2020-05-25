function Auctionator.Utilities.PrettyDate(when)
  details = date("*t", when)

  return
    Auctionator.Locales.Apply("DAY_"..tostring(details.wday)) ..
    ", " ..
    Auctionator.Locales.Apply("MONTH_"..tostring(details.month)) ..
    " " .. details.day
end
