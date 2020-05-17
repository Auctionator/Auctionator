SEARCH_PROVIDER_LAYOUT = {

}

SearchProviderMixin = CreateFromMixins(DataProviderMixin)

function SearchProviderMixin:OnLoad()
  DataProviderMixin.OnLoad(self)

end

function SearchProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end
