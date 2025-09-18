local CategoryLookup = {}

local function SaveCategory(categories, prefix)
  prefix = prefix or ""

  for _, c in ipairs(categories) do
    local currentName = prefix .. c.name
    CategoryLookup[currentName] = c.filters

    if c.subCategories ~= nil then
      SaveCategory(c.subCategories, currentName .. "/")
    end
  end
end

function Auctionator.Search.InitializeCategories()
  Auctionator.Search.InitializeOldCategories()

  SaveCategory(AuctionCategories)
end

function Auctionator.Search.GetItemClassCategories(categoryKey)
  local lookup = CategoryLookup[categoryKey]
  if lookup ~= nil then
    return lookup
  elseif categoryKey ~= "" then
    -- Compatibility with old category format
    return Auctionator.Search.GetItemClassOldCategories(categoryKey)
  end
end
