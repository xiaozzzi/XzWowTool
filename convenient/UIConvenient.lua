UI_Convenient = {}

function UI_Convenient:DrawSetting(container)
  local SCROLL_FRAME = GUI:ScrollMain(container)

  GUI:Heading(SCROLL_FRAME, "货币背景/分割线", 0, 2)
  local currencyRow1 = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(currencyRow1, "货币背景:", 120, "LEFT")
  local list = {}
  for k, v in pairs(MODE_CURRENCY.BACKGROUND) do
    list[k] = k
  end
  local currencyBgDropdown = GUI:Dropdown(currencyRow1, list, nil, CFG_G:GetValue("CURRENCY_BACKGROUND"), 300)
  currencyBgDropdown:SetCallback("OnValueChanged", function(widget, event, value)
    CFG_G:SaveValue("CURRENCY_BACKGROUND", value)
    MODE_CURRENCY:UpdBackground()
  end)


  --#region 热键字体

  GUI:Heading(SCROLL_FRAME, "热键字体", 2, 2)

  -- 字体
  local hotkeyRow1 = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(hotkeyRow1, "热键字体:", 120, "LEFT")
  GUI:Dropdown(hotkeyRow1, { ["DEFAULT"] = "默认" }, nil, "DEFAULT", 150)

  -- 字体大小
  local hotkeyRow2 = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(hotkeyRow2, "字体大小:", 120, "LEFT")
  local slider = GUI:Slider(hotkeyRow2, 200, 10, 30, 1, CFG_G:GetValue("HOTKEY_FONT_SIZE"))
  slider:SetCallback("OnValueChanged", function(widget, event, value)
    CFG_G:SaveValue("HOTKEY_FONT_SIZE", value)
    HOT_KEY:UpdateHotkeyFontSize()
  end)

  --#endregion

  --#region 伤害列表增强
  GUI:Heading(SCROLL_FRAME, "伤害列表增强", 2, 2)

  -- 最大高度
  local dmRowH = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(dmRowH, "最大高度:", 120, "LEFT")
  local dmHeightBox = GUI:EditBox(dmRowH, 150, CFG_G:GetValue("DAMAGE_METER_HIGHT_SIZE"))
  -- 中等高度
  local dmRowM = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(dmRowM, "中等高度:", 120, "LEFT")
  local dmMediumBox = GUI:EditBox(dmRowM, 150, CFG_G:GetValue("DAMAGE_METER_MIDDLE_SIZE"))
  -- 最小高度
  local dmRowL = GUI:SimpleGroup(SCROLL_FRAME)
  GUI:Label(dmRowL, "最小高度:", 120, "LEFT")
  local dmLowBox = GUI:EditBox(dmRowL, 150, CFG_G:GetValue("DAMAGE_METER_LOW_SIZE"))

  -- 全部回调
  dmHeightBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmHeightBox:SetText(CFG_G:GetValue("DAMAGE_METER_HIGHT_SIZE"))
      return
    end
    CFG_G:SaveValue("DAMAGE_METER_HIGHT_SIZE", value)
  end)
  dmMediumBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmMediumBox:SetText(CFG_G:GetValue("DAMAGE_METER_MIDDLE_SIZE"))
      return
    end
    CFG_G:SaveValue("DAMAGE_METER_MIDDLE_SIZE", value)
  end)
  dmLowBox:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then
      dmLowBox:SetText(CFG_G:GetValue("DAMAGE_METER_LOW_SIZE"))
      return
    end
    CFG_G:SaveValue("DAMAGE_METER_LOW_SIZE", value)
  end)

  --#endregion
end

--- 创建一个聊天背景层, 填充输入框与聊天框中间的缝隙
local function ChatBackground()
  local frame = CreateFrame("Frame", "CHAT_BACKGROUND")
  frame:SetWidth(330)
  frame:SetHeight(25)
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

-- local function ButtonBackground()
--   local frame = CreateFrame("Frame", "BUTTON_BACKGROUND")
--   frame:SetWidth(43)
--   frame:SetHeight(146)
--   frame:SetFrameStrata("BACKGROUND") -- 背景层
--   frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 467, 0)
--   local bg = frame:CreateTexture(nil, "BACKGROUND")
--   bg:SetAllPoints()
--   -- 1A1A1A 和聊天背景色相同
--   local r = 0.10196
--   local g = 0.10196
--   local b = 0.10196
--   bg:SetColorTexture(r, g, b, 0.5)
-- end

-- ButtonBackground()

-- local function LeftBottomBackground()
--   local frame = CreateFrame("Frame", "LEFT_BOTTOM__BACKGROUND")
--   -- frame:SetWidth(510) -- 宽度延伸到按钮背景
--   -- frame:SetWidth(325) -- 宽度延伸到小地图
--   -- frame:SetHeight(162)
--   frame:SetFrameStrata("BACKGROUND") -- 背景层
--   frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
--   local bg = frame:CreateTexture(nil, "BACKGROUND")
--   bg:SetAllPoints()
--   -- 1A1A1A 和聊天背景色相同
--   local r = 0.10196
--   local g = 0.10196
--   local b = 0.10196
--   bg:SetColorTexture(r, g, b, 1)
-- end

-- LeftBottomBackground()
