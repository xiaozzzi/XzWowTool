UIUnit = {}

function UIUnit:DrawSetting(container)
  local scroll = GUI:ScrollMain(container)

  --#region 宠物
  GUI:Heading("宠物框体", scroll, 0, 2)

  local petRow1 = GUI:SimpleGroup(scroll)
  GUI:Label(petRow1, GUI:ColorText("FFFFD500", "注意：") .. "锚点固定在主屏幕左下角, XY轴均需为正数。", 400, "LEFT")
  GUI:Label(petRow1,
    GUI:ColorText("FFFFD500", "默认值：") ..
    "X,Y = " .. GLOBAL_DEFAULT_OPTIONS.UNIT_PET_POINT_X .. "," .. GLOBAL_DEFAULT_OPTIONS.UNIT_PET_POINT_Y .. "",
    400, "LEFT")
  local petRow2 = GUI:SimpleGroup(scroll)

  -- X,Y
  GUI:Label(petRow2, GUI:ColorText("FF00B3FF", "X："), 20, "LEFT")
  local petX = GUI:EditBox(100, CONFIG_GLOBAL:GetValue("UNIT_PET_POINT_X"), petRow2)
  GUI:Spacing(petRow2, 20)
  GUI:Label(petRow2, GUI:ColorText("FF00FF26", "Y："), 20, "LEFT")
  local petY = GUI:EditBox(100, CONFIG_GLOBAL:GetValue("UNIT_PET_POINT_Y"), petRow2)

  petX:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      petX:SetText(CONFIG_GLOBAL:GetValue("UNIT_PET_POINT_X"))
      return
    end
    CONFIG_GLOBAL:SaveValue("UNIT_PET_POINT_X", value)
    UNIT_PET:UpdatePoint()
  end)
  petY:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      petY:SetText(CONFIG_GLOBAL:GetValue("UNIT_PET_POINT_Y"))
      return
    end
    CONFIG_GLOBAL:SaveValue("UNIT_PET_POINT_Y", value)
    UNIT_PET:UpdatePoint()
  end)

  --#endregion

  GUI:Heading("目标的目标", scroll, 2, 2)
end
