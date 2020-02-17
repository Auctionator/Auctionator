if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
  UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
  hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
    if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
      return
    end
    if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame
       and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
      UIDROPDOWNMENU_OPEN_MENU = nil
      local t, f, prefix, i = _G, issecurevariable, " \0", 1
      repeat
        i, t[prefix .. i] = i + 1
      until f("UIDROPDOWNMENU_OPEN_MENU")
    end
  end)
end