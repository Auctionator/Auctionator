local function InitializeCreateDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList] = {
    text = AUCTIONATOR_L_CREATE_LIST_DIALOG,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
    OnShow = function(self)
      Auctionator.EventBus:RegisterSource(self, "Create Shopping List Dialog")

      self.editBox:SetText("");
      self.editBox:SetFocus();
    end,
    OnHide = function(self)
      Auctionator.EventBus:UnregisterSource(self)
    end,
    OnAccept = function(self)
      Auctionator.EventBus:Fire(
        self,
        Auctionator.ShoppingLists.Events.CreateDialogOnAccept,
        self.editBox:GetText()
      )
    end,
    EditBoxOnEnterPressed = function(self)
      Auctionator.EventBus:Fire(
        self:GetParent(),
        Auctionator.ShoppingLists.Events.CreateDialogOnAccept,
        self:GetText()
      )
      self:GetParent():Hide()
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  }
end

local function InitializeDeleteDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList] = {
    text = "",
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function(self)
      Auctionator.EventBus:RegisterSource(self, "Delete Shopping List Dialog")
    end,
    OnHide = function(self)
      Auctionator.EventBus:UnregisterSource(self)
    end,
    OnAccept = function(self)
      Auctionator.EventBus:Fire(
        self,
        Auctionator.ShoppingLists.Events.DeleteDialogOnAccept
      )
    end
  };
end

local function InitializeRenameDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList] = {
    text = AUCTIONATOR_L_RENAME_LIST_DIALOG,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
    OnShow = function(self)
      Auctionator.EventBus:RegisterSource(self, "Rename Shopping List Dialog")

      self.editBox:SetText("");
      self.editBox:SetFocus();
    end,
    OnHide = function(self)
      Auctionator.EventBus:UnregisterSource(self)
    end,
    OnAccept = function(self)
      Auctionator.EventBus:Fire(
        self,
        Auctionator.ShoppingLists.Events.RenameDialogOnAccept,
        self.editBox:GetText()
      )
    end,
    EditBoxOnEnterPressed = function(self)
      Auctionator.EventBus:Fire(
        self:GetParent(),
        Auctionator.ShoppingLists.Events.RenameDialogOnAccept,
        self:GetText()
      )
      self:GetParent():Hide()
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  };
end

function Auctionator.ShoppingLists.InitializeDialogs()
  InitializeCreateDialog()
  InitializeDeleteDialog()
  InitializeRenameDialog()
end
