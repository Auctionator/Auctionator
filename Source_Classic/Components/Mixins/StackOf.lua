AuctionatorStackOfInputMixin = CreateFromMixins(AuctionatorConfigTooltipMixin)

function AuctionatorStackOfInputMixin:OnLoad()
  self.maxStackSize = 0
  self.maxNumStacks = 0
end

function AuctionatorStackOfInputMixin:SetMaxNumStacks(max)
  self.maxNumStacks = max
end

function AuctionatorStackOfInputMixin:GetConfig()
  return {
    numStacks = self.NumStacks:GetNumber(),
    stackSize = self.StackSize:GetNumber(),
  }
end

function AuctionatorStackOfInputMixin:SetConfig(config)
  self.NumStacks:SetNumber(config.numStacks)
  self.StackSize:SetNumber(config.stackSize)
end

function AuctionatorStackOfInputMixin:SetMaxStackSize(max)
  self.maxStackSize = max
  self.MaxStackSize:SetText(AUCTIONATOR_L_MAX_COLON_X:format(max))
end

function AuctionatorStackOfInputMixin:SetMaxNumStacks(max)
  self.maxNumStacks = max
  self.MaxNumStacks:SetText(AUCTIONATOR_L_MAX_COLON_X:format(max))
end

function AuctionatorStackOfInputMixin:MaxNumStacksClicked()
  self.NumStacks:SetNumber(self.maxNumStacks)
end

function AuctionatorStackOfInputMixin:MaxStackSizeClicked()
  self.StackSize:SetNumber(self.maxStackSize)
end
