-- Group items by database key for use with Auctiontator.Database:ProcessScan
function Auctionator.Search.GroupResultsForDB(results)
  Auctionator.Debug.Message("Auctionator.Search.GroupResults", #results)

  local waiting = #results
  local doneComplete = false
  local groups = {}

  local function OnComplete()
    doneComplete = true
    Auctionator.Database:ProcessScan(groups)
    Auctionator.EventBus
      :RegisterSource(Auctionator.Search.GroupResultsForDB, "Classic GroupResultsForDB")
      :Fire(Auctionator.Search.GroupResultsForDB, Auctionator.Search.Events.PricesProcessed)
      :UnregisterSource(Auctionator.Search.GroupResultsForDB)
  end

  for _, entry in ipairs(results) do
    if entry.info[3] ~= 0 and entry.info[10] ~= 0 then
      Auctionator.Utilities.DBKeyFromLink(entry.itemLink, function(keys)
        local unitPrice = math.ceil(entry.info[10] / entry.info[3])
        waiting = waiting - 1
        for _, key in ipairs(keys) do
          if groups[key] == nil then
            groups[key] = {}
          end
          table.insert(groups[key], {
            price = unitPrice,
            available = entry.info[3],
          })
        end
        if waiting == 0 then
          OnComplete()
        end
      end)
    else
      waiting = waiting - 1
    end
  end

  if waiting == 0 and not doneComplete then
    OnComplete()
  end
end
