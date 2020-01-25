
-- Cause a search in the AH UI.
-- searchTerm: string
function Auctionator.Search.Simple(searchTerm)
  Auctionator.Search._Perform({searchString = searchTerm,
      sorts = {sortOrder = 0,reverseSort = false}});
end
