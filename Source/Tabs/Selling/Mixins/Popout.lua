AuctionatorSelectionPopoutEntryMixin = {}
function AuctionatorSelectionPopoutEntryMixin:OnLoad()
  self.defaultWidth = 225
  self.selectionNamePadding = 20
end
function AuctionatorSelectionPopoutEntryMixin:Init(label, isSelected, isDisabled)
  self.label = label;

  self.SelectionName:Show();
  self.SelectionName:SetText(label);

  self.isSelected = isSelected
  self.isDisabled = isDisabled

  if isSelected ~= nil then
    local fontColor = nil;
    if isSelected then
      fontColor = NORMAL_FONT_COLOR;
    elseif isDisabled  then
      fontColor = DISABLED_FONT_COLOR;
    else
      fontColor = VERY_LIGHT_GRAY_COLOR;
    end
    self.SelectionName:SetTextColor(fontColor:GetRGB());
  end
  self:SetEnabled(not isDisabled)

  local maxNameWidth = 200;
  if self.SelectionName:GetWidth() > maxNameWidth then
    self.SelectionName:SetWidth(maxNameWidth);
  end

  self:AdjustWidth()
end

function AuctionatorSelectionPopoutEntryMixin:AdjustWidth()
  local nameWidth = self.SelectionName:GetUnboundedStringWidth() + self.selectionNamePadding;
  self:SetWidth(Round(math.max(nameWidth, self.defaultWidth)));
  self.SelectionName:SetWidth(nameWidth);
end

function AuctionatorSelectionPopoutEntryMixin:OnEnter()
  if self.isDisabled then
    return
  end
  self.HighlightBGTex:SetAlpha(0.15);

  if not self.isSelected then
    self.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
  end
end

function AuctionatorSelectionPopoutEntryMixin:OnLeave()
  self.HighlightBGTex:SetAlpha(0);

  if not self.isSelected then
    local fontColor = nil;
    if not self.isDisabled then
      fontColor = VERY_LIGHT_GRAY_COLOR;
    else
      fontColor = DISABLED_FONT_COLOR;
    end
    self.SelectionName:SetTextColor(fontColor:GetRGB());
  end
end

AuctionatorSelectionPopoutMixin = {}
function AuctionatorSelectionPopoutMixin:OnLoad()
  self.buttonPool = CreateFramePool("BUTTON", self, "AuctionatorSelectionPopoutEntryTemplate")
end

function AuctionatorSelectionPopoutMixin:Init(info)
  self:RegisterEvent("GLOBAL_MOUSE_DOWN")
  self.buttonPool:ReleaseAll()
  local entries = {}
  for index, rowInfo in ipairs(info) do
    local row = self.buttonPool:Acquire()
    table.insert(entries, row)
    row:Init(rowInfo.label, rowInfo.isSelected or false, rowInfo.isDisabled or false)
    row:SetScript("OnClick", function()
      rowInfo.callback()
      self:Hide()
    end)
    row:Show()
  end

  local stride = 10
  if stride ~= self.lastStride then
    self.layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, stride);
    self.lastStride = stride;
  end

  self.initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", 6, -12)
  AnchorUtil.GridLayout(entries, self.initialAnchor, self.layout)
  self:Layout()
end

function AuctionatorSelectionPopoutMixin:OnEvent()
  if not self:IsMouseOver() then
    self:Hide()
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
  end
end

local popup

function Auctionator.Selling.ShowPopup(options)
  if not popup then
    popup = CreateFrame("Frame", "AuctionatorSellingPopupFrame", UIParent, "AuctionatorSelectionPopoutTemplate")
  end
  local cursorX, cursorY = GetCursorPosition()
  local scale = UIParent:GetScale()
  popup:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
  popup:Show()

  popup.HasMouseover = false
  popup.timerout = nil

  if Auctionator.Constants.IsClassic then
    popup:SetScript("OnUpdate", function(_, interval)
      if not popup:IsMouseOver() then
        if popup.HasMouseover then
          if popup.timeout == nil then
            popup.timeout = UIDROPDOWNMENU_SHOW_TIME
          end
          popup.timeout = popup.timeout - interval
          if popup.timeout <= 0 then
            popup:Hide()
          end
        end
      else
        popup.HasMouseover = true
        popup.timerout = nil
      end
    end)
  end

  popup:Init(options)
end
