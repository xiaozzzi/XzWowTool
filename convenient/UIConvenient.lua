UI_Convenient = {}

function UI_Convenient:DrawSetting(container)
  local scroll = GUI:ScrollMain(container)

  GUI:Heading("货币背景/分割线", scroll, 0, 2)
  local currencyRow1 = GUI:SimpleGroup(scroll)
  GUI:Label(currencyRow1, "货币背景:", 120, "LEFT")
  local list = {}
  for k, v in pairs(MODE_CURRENCY.BACKGROUND) do
    list[k] = k
  end
  local currencyBgDropdown = GUI:Dropdown(list, nil, CONFIG_GLOBAL:GetValue("CURRENCY_BACKGROUND"), 300, currencyRow1)
  currencyBgDropdown:SetCallback("OnValueChanged", function(widget, event, value)
    CONFIG_GLOBAL:SaveValue("CURRENCY_BACKGROUND", value)
    MODE_CURRENCY:UpdBackground()
  end)


  --#region 热键字体

  GUI:Heading("热键字体", scroll, 2, 2)

  -- 字体
  local hotkeyRow1 = GUI:SimpleGroup(scroll)
  GUI:Label(hotkeyRow1, "热键字体:", 120, "LEFT")
  local dropdown = GUI:Dropdown({ ["DEFAULT"] = "默认" }, nil, "DEFAULT", 150, hotkeyRow1)

  -- 字体大小
  local hotkeyRow2 = GUI:SimpleGroup(scroll)
  GUI:Label(hotkeyRow2, "字体大小:", 120, "LEFT")
  local slider = GUI:Slider(200, 10, 30, 1, CONFIG_GLOBAL:GetValue("HOTKEY_FONT_SIZE"), hotkeyRow2)
  slider:SetCallback("OnValueChanged", function(widget, event, value)
    CONFIG_GLOBAL:SaveValue("HOTKEY_FONT_SIZE", value)
    HOT_KEY:UpdateHotkeyFontSize()
  end)

  --#endregion

  --#region 伤害列表增强
  GUI:Heading("伤害列表增强", scroll, 2, 2)

  -- 最大高度
  local dmRowH = GUI:SimpleGroup(scroll)
  GUI:Label(dmRowH, "最大高度:", 120, "LEFT")
  local dmHeightBox = GUI:EditBox(150, CONFIG_GLOBAL:GetValue("DAMAGE_METER_HIGHT_SIZE"), dmRowH)
  -- 中等高度
  local dmRowM = GUI:SimpleGroup(scroll)
  GUI:Label(dmRowM, "中等高度:", 120, "LEFT")
  local dmMediumBox = GUI:EditBox(150, CONFIG_GLOBAL:GetValue("DAMAGE_METER_MIDDLE_SIZE"), dmRowM)
  -- 最小高度
  local dmRowL = GUI:SimpleGroup(scroll)
  GUI:Label(dmRowL, "最小高度:", 120, "LEFT")
  local dmLowBox = GUI:EditBox(150, CONFIG_GLOBAL:GetValue("DAMAGE_METER_LOW_SIZE"), dmRowL)

  -- 全部回调
  dmHeightBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmHeightBox:SetText(CONFIG_GLOBAL:GetValue("DAMAGE_METER_HIGHT_SIZE"))
      return
    end
    CONFIG_GLOBAL:SaveValue("DAMAGE_METER_HIGHT_SIZE", value)
  end)
  dmMediumBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmMediumBox:SetText(CONFIG_GLOBAL:GetValue("DAMAGE_METER_MIDDLE_SIZE"))
      return
    end
    CONFIG_GLOBAL:SaveValue("DAMAGE_METER_MIDDLE_SIZE", value)
  end)
  dmLowBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmLowBox:SetText(CONFIG_GLOBAL:GetValue("DAMAGE_METER_LOW_SIZE"))
      return
    end
    CONFIG_GLOBAL:SaveValue("DAMAGE_METER_LOW_SIZE", value)
  end)

  --#endregion
end

--- 创建一个聊天背景层, 填充输入框与聊天框中间的缝隙
local function ChatBackground()
  local frame = CreateFrame("Frame", "CHAT_BACKGROUND")
  frame:SetWidth(400)
  frame:SetHeight(40)
  frame:SetFrameStrata("BACKGROUND") -- 背景层
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  -- 1A1A1A 和聊天背景色相同
  local r = 0.10196
  local g = 0.10196
  local b = 0.10196
  bg:SetColorTexture(r, g, b, 1)
end

ChatBackground()
