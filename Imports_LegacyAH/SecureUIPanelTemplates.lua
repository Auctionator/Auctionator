function AuctionatorRetailImportEditBox_OnTabPressed(self)
	if ( self.previousEditBox and IsShiftKeyDown() ) then
		self.previousEditBox:SetFocus();
	elseif ( self.nextEditBox ) then
		self.nextEditBox:SetFocus();
	end
end
