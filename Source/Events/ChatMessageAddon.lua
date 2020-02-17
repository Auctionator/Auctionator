-- CHAT_MSG_ADDON: "prefix", "text", "channel", "sender", "target", zoneChannelID, localID, "name", instanceID
-- prefix            string
-- text              string
-- channel           string
-- sender            string
-- target            string
-- zoneChannelID     number
-- localID           number
-- name              string
-- instanceID        number

function Auctionator.Events.ChatMessageAddon(...)
  Auctionator.Debug.Message("Auctionator.Events.ChatMessageAddon")

end

-----------------------------------------

function Atr_OnChatMsgAddon (...)
  local prefix, msg, distribution, sender = ...

  if prefix == "ATR" then
    Auctionator.Debug.Message( 'Atr_OnChatMsgAddon', ... )

    local s = string.format(
      "%s %s |cff88ffff %s |cffffffaa %s|r", prefix, distribution, sender, msg
    )

    if zc.StringStartsWith( msg, "VREQ_" ) then
      C_ChatInfo.SendAddonMessage( "ATR", "V_"..AuctionatorVersion, "WHISPER", sender )
    end

    if zc.StringStartsWith (msg, "IREQ_") then
      collectgarbage( "collect" )
      UpdateAddOnMemoryUsage()
      local mem  = math.floor( GetAddOnMemoryUsage("Auctionator") )
      C_ChatInfo.SendAddonMessage( "ATR", "I_" .. Atr_GetDBsize() .. "_" .. mem .. "_" .. #AUCTIONATOR_SHOPPING_LISTS.."_"..GetRealmFacInfoString(), "WHISPER", sender)
    end

    if zc.StringStartsWith( msg, "V_" ) and time() - VREQ_sent < 5 then

      local herVerString = string.sub( msg, 3 )
      local outOfDate = CheckVersion( herVerString )

      if outOfDate then
        zc.AddDeferredCall( 3, "Atr_VersionReminder", nil, nil, "VR" )
      end
    end
  end

  Atr_OnChatMsgAddon_ShoppingListCmds( prefix, msg, distribution, sender )
end

-----------------------------------------

function Atr_OnChatMsgAddon_ShoppingListCmds (prefix, msg, distribution, sender)

--zz (prefix, msg, distribution, sender)


  if (zc.StringStartsWith (msg, "SLPERM_REQ_")) then

    gSLpermittedUser    = nil
    gShpListShareRequester  = sender

    C_ChatInfo.SendAddonMessage ("ATR", "SLREQACK_", "WHISPER", gShpListShareRequester)

    StaticPopup_Show ("ATR_SL_REQUEST_SHARING")
  end

  if (zc.StringStartsWith (msg, "SLREQACK_")) then
    gRequestSentTime = 0
  end

  if (zc.StringStartsWith (msg, "SLPERM_DENIED_")) then
    StaticPopup_Show("ATR_SL_REQUEST_DENIED")
  end

  if (zc.StringStartsWith (msg, "SLREQ_") and gSLpermittedUser and sender == gSLpermittedUser) then
    Atr_Send_ShoppingListData (gSLpermittedUser)
  end

  if (zc.StringStartsWith (msg, "SLSTART_")) then
    gSLgather = ""
  end

  if (zc.StringStartsWith (msg, "SLDATA_")) then
    local line = string.sub(msg, 8)
    if (zc.StringStartsWith (line, "***")) then
      local slistName = strtrim (string.sub (line, 4))
      gSuspendGathering = (Atr_SList.FindByName (slistName) ~= nil)
      zc.msg_anm ("You already have a list called|cffffbb00", slistName, "|r")
      line = "\n"..line
    end
    if (not gSuspendGathering) then
      gSLgather = gSLgather..line.."\n"
    end
  end

  if (zc.StringStartsWith (msg, "SLEND_")) then
    Atr_OnClick_ShpList_Import()
    Atr_ShpList_Edit_Text:SetText(gSLgather)
  end

end