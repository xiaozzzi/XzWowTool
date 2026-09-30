--·········································································································
--
-- 为未绑定快捷键的按钮添加自定义文本
--
--·········································································································

local FONT_SIZE = 14 -- 快捷键字体大小

-- 需要修改的动作栏
local CustomTextActionBars = { 'MultiBar5', 'MultiBar6' }

-- 按钮文本映射
local CustomTextButtonMapping = {
  ['MultiBar5Button3'] = "1",
  ['MultiBar5Button4'] = "2",
  ['MultiBar5Button5'] = "3",
  ['MultiBar5Button6'] = "4",
  ['MultiBar5Button7'] = "R",
  ['MultiBar5Button8'] = "F",
  ['MultiBar5Button9'] = "A4",
  --
  ['MultiBar6Button3'] = "A1",
  ['MultiBar6Button4'] = "A2",
  ['MultiBar6Button5'] = "C2",
  ['MultiBar6Button6'] = "AR",
  ['MultiBar6Button7'] = "AF",
  ['MultiBar6Button8'] = "C",
  ['MultiBar6Button9'] = "CR",
  ['MultiBar6Button10'] = "C4",
}

-- 更新单个按钮
local function UpdateButtonCustomText(button)
  if not button then return end

  -- local hotkeyText = button.HotKey and button.HotKey:GetText() or ""
  local buttonName = button:GetName()                          -- 按钮的名称
  local customText = CustomTextButtonMapping[buttonName] or "" -- 自定义文本

  if (customText == "") then
    return
  end

  local fs = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  -- 位置：按钮底部中央，可自行调整
  fs:SetText(customText)
  fs:SetFont(NumberFontNormalSmallGray:GetFont(), FONT_SIZE, "OUTLINE")
  fs:SetTextColor(0.8, 0.8, 0.8, 1)
  fs:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -4)
  button.customText = fs

  -- print(buttonName)
  -- print(button.customText:GetText())
end

-- 遍历所有按钮
local function UpdateAllButtons()
  for _, barName in ipairs(CustomTextActionBars) do
    for i = 1, 12 do
      local button = _G[barName .. 'Button' .. i]
      if button then
        UpdateButtonCustomText(button)
      end
    end
  end
end

local function UpdateHotkeyFontSize()
  local ActionBars = {
    'MultiBarBottomLeft',
    'MultiBarBottomRight',
    'MultiBarRight',
    'MultiBarLeft',
    'Action',
    'MultiBar1',
    'MultiBar2',
    'MultiBar3',
    'MultiBar4',
    'MultiBar5',
    'MultiBar6',
    'MultiBar7'
  }

  for _, barName in pairs(ActionBars) do
    for i = 1, 12 do
      local button = _G[barName .. 'Button' .. i]
      if button and button.HotKey then
        local font, _, flags = button.HotKey:GetFont()
        button.HotKey:SetFont(font, FONT_SIZE, flags)
      end
    end
  end
end

local HotKeyFrame = CreateFrame("Frame")
HotKeyFrame:RegisterEvent("PLAYER_LOGIN")

HotKeyFrame:SetScript("OnEvent", function(self, event, unit, ...)
  if event == "PLAYER_LOGIN" then
    self:UnregisterEvent("PLAYER_LOGIN")
  end
  -- UpdateAllButtons()
  UpdateHotkeyFontSize()
end)
