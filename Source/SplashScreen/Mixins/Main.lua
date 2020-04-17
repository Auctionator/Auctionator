-- TODO All this needs Localization
-- We should probably move this into another file too
local MESSAGES = {
  {
    Version = "8.3.0",
    Description = "Auctionator 8.3.0 is a complete re-write of Auctionator to work with the changes that Blizzard made to the Auction House in their 8.3 release. Please note that many of the features you may be used to from previous versions of Auctionator may not be implemented yet or may be in a different location! Please read the notes below for details.",
    Sections = {
      {
        Title = "Communication and Bug Reports",
        Entries = {
          "Please join us in the Auctionator Discord server https://discord.gg/xgz75Pp (TODO Make this a link?)",
          "Please report bugs on Github https://github.com/Auctionator/Auctionator/issues/new (TODO Make this a link?)",
          "We are most active on Discord, and do not take bug reports on curseforge or Auctionator forums",
          "For the roadmap of upcoming features, visit https://github.com/Auctionator/Auctionator/wiki/The-8.3-Release (TODO Make this a link?)"
        }
      },
      {
        Title = "Implemented Features",
        Entries = {
          "Automatic scanning of the Auction House when opened (limited by Blizzard to every 15 minutes)",
          "Manual scanning of the Auction House from the 'Auctionator' tab in the Auction House",
          "Shopping Lists with advanced search terms from the 'Shopping' tab in the Auction House"
        }
      },
      {
        Title = "Not Yet Implemented (But Coming Soon!)",
        Entries = {
          "Undercut Scanning",
          "Price Histories",
          "Advanced Selling Functionality"
        }
      }
    }
  }
}

local NEW_MESSAGE_FONTS = {
  entry = GameFontHighlight,
  title = GameFontNormal,
  description = GameFontHighlight,
  version = GameFontNormalHuge
}

local VIEWED_MESSAGE_FONTS = {
  entry = GameFontDisable,
  title = GameFontDisable,
  description = GameFontDisable,
  version = GameFontDisableHuge
}

local STRING_WIDTH = 550

AuctionatorSplashScreenMixin = {}

function AuctionatorSplashScreenMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorSplashScreenMixin:OnLoad()")

  self:ReformatCheckbox()
  self:CreateMessagesText()
end

function AuctionatorSplashScreenMixin:OnShow()
  Auctionator.Config.Set(Auctionator.Config.Options.SPLASH_SCREEN_VERSION, MESSAGES[1].Version)
end

function AuctionatorSplashScreenMixin:ReformatCheckbox()
  self.HideCheckbox.CheckBox:SetSize(28, 28)
  self.HideCheckbox.CheckBox:SetScript("OnClick", function()
    Auctionator.Config.Set(
      Auctionator.Config.Options.HIDE_SPLASH_SCREEN,
      self.HideCheckbox.CheckBox:GetChecked()
    )
  end)

  self.HideCheckbox.CheckBox.Label:SetPoint("TOPLEFT", self.HideCheckbox.CheckBox, "TOPRIGHT", 3, -7 )
end

function AuctionatorSplashScreenMixin:GetMostRecentVersion()
  return MESSAGES[1].Version
end

function AuctionatorSplashScreenMixin:CreateMessagesText()
  local lastVersion = Auctionator.Config.Get(Auctionator.Config.Options.SPLASH_SCREEN_VERSION)
  local fonts = NEW_MESSAGE_FONTS

  local previous
  local current
  local height = 0

  for _, messageSpec in ipairs(MESSAGES) do
    -- Gray out previously viewed versions
    if lastVersion == messageSpec.Version then
      fonts = VIEWED_MESSAGE_FONTS
    end

    -- Add version string
    current = self:CreateString(messageSpec.Version, fonts.version, previous, -30)
    height = height + current:GetStringHeight()
    previous = current

    -- Add description string
    current = self:CreateString(messageSpec.Description, fonts.description, previous)
    height = height + current:GetStringHeight()
    previous = current

    -- Add sections
    for _, section in ipairs(messageSpec.Sections or {}) do
      current = self:CreateString(section.Title, fonts.title, previous, -8)
      height = height + current:GetStringHeight()
      previous = current

      for _, entry in ipairs(section.Entries) do
        current = self:CreateBulletedString(entry, fonts.entry, previous)
        height = height + current:GetStringHeight()
        previous = current
      end
    end
  end

  self.ScrollFrame.Content:SetSize(600, height)
end

function AuctionatorSplashScreenMixin:CreateString(text, font, previousElement, offset)
  local entry = self.ScrollFrame.Content:CreateFontString(nil, "ARTWORK")

  if offset == nil then
    offset = -5
  end

  entry:SetFontObject(font)
  entry:SetText(text)
  entry:SetJustifyH("LEFT")
  entry:SetWidth(STRING_WIDTH)

  if previousElement ~= nil then
    entry:SetPoint("TOPLEFT", previousElement, "BOTTOMLEFT", 0, offset)
  else
    entry:SetPoint("TOPLEFT", self.ScrollFrame.Content, "TOPLEFT", -5)
  end

  return entry
end

-- Did this just to get nice alignment on the bulleted entries (otherwise the text wrapped below the bullet)
function AuctionatorSplashScreenMixin:CreateBulletedString(text, font, previousElement, offset)
  local bullet = self:CreateString("* ", font, previousElement, offset)
  bullet:SetWidth(20)
  bullet:SetJustifyV("TOP")

  local entry = self:CreateString(text, font, previousElement, offset)
  entry:SetPoint("TOPLEFT", bullet, "TOPRIGHT")
  entry:SetWidth(STRING_WIDTH - 20)

  bullet:SetHeight(entry:GetStringHeight())

  return bullet
end
