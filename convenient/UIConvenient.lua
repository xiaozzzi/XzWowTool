UIConvenient = {}

function UIConvenient:DrawSetting(container)
  local scroll = GUI:ScrollMain(container)

  GUI:Heading("热键字体", scroll, 0, 2)

  -- 字体
  local row1 = GUI:SimpleGroup(scroll)
  GUI:Label(row1, "热键字体:", 120, "LEFT")
  local dropdown = GUI:Dropdown({ ["DEFAULT"] = "默认" }, nil, "DEFAULT", 150, row1)

  -- 字体大小
  local row2 = GUI:SimpleGroup(scroll)
  GUI:Label(row2, "字体大小:", 120, "LEFT")
  local slider = GUI:Slider(200, 10, 30, 1, GLOBAL_CONFIG:GetValue("HOTKEY_FONT_SIZE"), row2)
  slider:SetCallback("OnValueChanged", function(widget, event, value)
    GLOBAL_CONFIG:SaveValue("HOTKEY_FONT_SIZE", value)
    HOT_KEY:UpdateHotkeyFontSize()
  end)

  --#region 伤害列表增强
  GUI:Heading("伤害列表增强", scroll, 2, 2)

  -- 最大高度
  local dmRowH = GUI:SimpleGroup(scroll)
  GUI:Label(dmRowH, "最大高度:", 120, "LEFT")
  local dmHeightBox = GUI:EditBox(150, GLOBAL_CONFIG:GetValue("DAMAGE_METER_HIGHT_SIZE"), dmRowH)
  -- 中等高度
  local dmRowM = GUI:SimpleGroup(scroll)
  GUI:Label(dmRowM, "中等高度:", 120, "LEFT")
  local dmMediumBox = GUI:EditBox(150, GLOBAL_CONFIG:GetValue("DAMAGE_METER_MIDDLE_SIZE"), dmRowM)
  -- 最小高度
  local dmRowL = GUI:SimpleGroup(scroll)
  GUI:Label(dmRowL, "最小高度:", 120, "LEFT")
  local dmLowBox = GUI:EditBox(150, GLOBAL_CONFIG:GetValue("DAMAGE_METER_LOW_SIZE"), dmRowL)

  -- 全部回调
  dmHeightBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmHeightBox:SetText(GLOBAL_CONFIG:GetValue("DAMAGE_METER_HIGHT_SIZE"))
      return
    end
    GLOBAL_CONFIG:SaveValue("DAMAGE_METER_HIGHT_SIZE", value)
  end)
  dmMediumBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmMediumBox:SetText(GLOBAL_CONFIG:GetValue("DAMAGE_METER_MIDDLE_SIZE"))
      return
    end
    GLOBAL_CONFIG:SaveValue("DAMAGE_METER_MIDDLE_SIZE", value)
  end)
  dmLowBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmLowBox:SetText(GLOBAL_CONFIG:GetValue("DAMAGE_METER_LOW_SIZE"))
      return
    end
    GLOBAL_CONFIG:SaveValue("DAMAGE_METER_LOW_SIZE", value)
  end)

  --#endregion
end
