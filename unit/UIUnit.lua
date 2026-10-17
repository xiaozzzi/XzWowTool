UIUnit = {}

function UIUnit:DrawSetting(container)
  local SCROLL_FRAME = GUI:ScrollMain(container)

  --#region 宠物
  GUI:Heading(SCROLL_FRAME, "宠物框体", 0, 2)

  local petRow1 = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(petRow1, GUI:ColorText("FFFFD500", "注意：") .. "锚点固定在主屏幕左下角, XY轴均需为正数。", 400, "LEFT")
  GUI:Label(petRow1,
    GUI:ColorText("FFFFD500", "默认值：") ..
    "X,Y = " .. GLOBAL_DEFAULT_OPTIONS.UNIT_PET_POINT_X .. "," .. GLOBAL_DEFAULT_OPTIONS.UNIT_PET_POINT_Y .. "",
    400, "LEFT")
  local petRow2 = GUI:SimpleGroup(SCROLL_FRAME)

  -- X,Y
  GUI:Label(petRow2, GUI:ColorText("FF00B3FF", "X："), 20, "LEFT")
  local petX = GUI:EditBox(petRow2, 100, CFG_G:GetValue("UNIT_PET_POINT_X"))
  GUI:Spacing(petRow2, 20)
  GUI:Label(petRow2, GUI:ColorText("FF00FF26", "Y："), 20, "LEFT")
  local petY = GUI:EditBox(petRow2, 100, CFG_G:GetValue("UNIT_PET_POINT_Y"))

  petX:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      petX:SetText(CFG_G:GetValue("UNIT_PET_POINT_X"))
      return
    end
    CFG_G:SaveValue("UNIT_PET_POINT_X", value)
    UNIT_PET:UpdatePoint()
  end)
  petY:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      petY:SetText(CFG_G:GetValue("UNIT_PET_POINT_Y"))
      return
    end
    CFG_G:SaveValue("UNIT_PET_POINT_Y", value)
    UNIT_PET:UpdatePoint()
  end)

  --#endregion

  GUI:Heading(SCROLL_FRAME, "目标的目标", 2, 2)
end
