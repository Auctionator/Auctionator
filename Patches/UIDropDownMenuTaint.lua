if (UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
  UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
  hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
    if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
      return
    end
    for i=1, UIDROPDOWNMENU_MAXLEVELS do
      for j=1, UIDROPDOWNMENU_MAXBUTTONS do
        local b = _G["DropDownList" .. i .. "Button" .. j]
        if not (issecurevariable(b, "value") or b:IsShown()) then
          b.value = nil
          repeat
            j, b["fx" .. j] = j+1
          until issecurevariable(b, "value")
        end
      end
    end
  end)
end