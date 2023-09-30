local function ChangeEvent(widget)
  Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.PostingSettingChanged", widget.group.name, widget:GetState())
end

GroupsCustomiseDurationMixin = {}

function GroupsCustomiseDurationMixin:OnLoad()
  self.Short:SetText(Auctionator.Constants.Durations.Short)
  self.Medium:SetText(Auctionator.Constants.Durations.Medium)
  self.Long:SetText(Auctionator.Constants.Durations.Long)

  for _, option in ipairs(self.Options) do
    option:SetScript("OnClick", function()
      self:SetValue(option:GetID())
      ChangeEvent(self)
    end)
  end

  self:SetValue(0)
end

function GroupsCustomiseDurationMixin:SetCheckedColor(r, g, b)
  for _, option in ipairs(self.Options) do
    option:GetCheckedTexture():SetVertexColor(r, g, b)
  end
end

function GroupsCustomiseDurationMixin:SetValue(value)
  self.value = value
  for _, option in ipairs(self.Options) do
    option:SetChecked(option:GetID() == self.value)
  end
end

function GroupsCustomiseDurationMixin:SetGroup(name, isCustom)
  self.group = {name = name, isCustom = isCustom}
end

function GroupsCustomiseDurationMixin:GetState()
  return {
    duration = self.value
  }
end

function GroupsCustomiseDurationMixin:ApplyState(state)
  self:SetValue(state.duration or 0)
end

GroupsCustomiseQuantityMixin = {}

function GroupsCustomiseQuantityMixin:OnLoad()
  if Auctionator.Constants.IsClassic then
    self:SetHeight(22)
    self.NumStacks = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.NumStacks:SetNumeric(true)
    self.NumStacks:SetScript("OnTextChanged", function(_, isUserInput)
      if isUserInput then
        ChangeEvent(self)
      end
    end)
    self.NumStacks:SetSize(50, 22)
    self.NumStacks:SetPoint("TOPLEFT")
    self.NumStacks:SetAutoFocus(false)

    self.StackOfText = self:CreateFontString(nil, nil, "GameFontHighlight")
    self.StackOfText:SetText(AUCTIONATOR_L_STACK_OF)
    self.StackOfText:SetPoint("TOPLEFT", self.NumStacks, "TOPRIGHT", 8, -5)

    self.StackSize = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.StackSize:SetNumeric(true)
    self.StackSize:SetScript("OnTextChanged", function(_, isUserInput)
      if isUserInput then
        ChangeEvent(self)
      end
    end)
    self.StackSize:SetSize(50, 22)
    self.StackSize:SetPoint("TOPLEFT", self.StackOfText, "TOPRIGHT", 8, 5)
    self.StackSize:SetAutoFocus(false)

    self:SetWidth(self.StackSize:GetWidth() + self.NumStacks:GetWidth() + self.StackOfText:GetWidth() + 30)

    self.GetState = function()
      return {
        numStacks = math.max(0, tonumber(self.NumStacks:GetText()) or 0),
        stackSize = math.max(0, tonumber(self.StackSize:GetText()) or 0),
      }
    end
    self.ApplyState = function(_, state)
      self.NumStacks:SetText(state.numStacks or 0)
      self.StackSize:SetText(state.stackSize or 0)
    end
  else
    self:SetSize(100, 22)
    self.Quantity = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
    self.Quantity:SetNumeric(true)
    self.Quantity:SetScript("OnTextChanged", function(_, isUserInput)
      if isUserInput then
        ChangeEvent(self)
      end
    end)
    self.Quantity:SetSize(50, 22)
    self.Quantity:SetPoint("TOPLEFT")
    self.Quantity:SetAutoFocus(false)

    self.GetState = function()
      return {
        quantity = math.max(0, tonumber(self.Quantity:GetText()) or 0),
      }
    end
    self.ApplyState = function(_, state)
      self.Quantity:SetText(state.quantity or 0)
    end
  end
end

function GroupsCustomiseQuantityMixin:SetGroup(name, isCustom)
  self.group = {name = name, isCustom = isCustom}
end
