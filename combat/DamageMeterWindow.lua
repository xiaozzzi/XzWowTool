--·········································································································
--
-- 修改伤害监控窗口高度
-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_DamageMeter/DamageMeterSessionWindow.lua
--
--·········································································································

AceGUI = LibStub("AceGUI-3.0")

DM = {}

local currentDamageMeterHeight = 0

local function GetFirstDamageMeterWindow()
  for i = 1, 10 do
    local win = _G["DamageMeterSessionWindow" .. i]
    if win then
      return win
    end
  end
end

--- 设置伤害表窗口高度
local function SetDamageMeterHeight(height)
  if (height == currentDamageMeterHeight) then
    return
  end
  if InCombatLockdown() then
    return
  end
  currentDamageMeterHeight = height
  for i = 1, 10 do
    local win = _G["DamageMeterSessionWindow" .. i]
    if win then
      local point, relativeTo, relativePoint, x, y = win:GetPoint(1)
      win:ClearAllPoints()
      win:SetHeight(height)
      if point then
        win:SetPoint('BOTTOMRIGHT', relativeTo, 'BOTTOMRIGHT', 0, 0)
      end
    end
  end
end

--- 根据是否在队伍中设置伤害表窗口高度
function DM:SetWindowHeightByRaid()
  local isInRaid = IsInRaid()
  if isInRaid then
    SetDamageMeterHeight(300)
  elseif not isInRaid then
    SetDamageMeterHeight(150)
  end
end

-- 创建快速切换伤害列表类型的按钮
function DM:CreateWindowHeightButton()
  local win = GetFirstDamageMeterWindow()
  if not win then
    return
  end

  -- 不能修改 win 中的配置, 会污染源框架代码, 造成秘密值报错
  -- local dpsButton = GUI:SimpleButton(25, "DPS_BUTTON", nil, false)
  -- dpsButton:SetNormalAtlas("GO-icon-role-Header-DPS")
  -- dpsButton:SetPoint("BOTTOMLEFT", win, "TOPLEFT", 0, 0)
  -- dpsButton:SetScript("OnClick", function()
  --   -- win:SetDamageMeterType(Enum.DamageMeterType.Dps)
  --   win:GetDamageMeterOwner():SetSessionWindowDamageMeterType(win, Enum.DamageMeterType.Dps)
  -- end)

  -- local hpsButton = GUI:SimpleButton(25, "HPS_BUTTON", nil, false)
  -- hpsButton:SetNormalAtlas("GO-icon-role-Header-Healer")
  -- hpsButton:SetPoint("TOPLEFT", dpsButton, "TOPRIGHT", 0, 0)
  -- hpsButton:SetScript("OnClick", function()
  --   -- win:SetDamageMeterType(Enum.DamageMeterType.Hps)
  --   win:GetDamageMeterOwner():SetSessionWindowDamageMeterType(win, Enum.DamageMeterType.Hps)
  -- end)

  -- 最小窗口
  local lowButton = GUI:SimpleButton(25, "LOW_BUTTON", nil, false)
  lowButton:SetPoint("BOTTOMRIGHT", win, "BOTTOMLEFT", 0, 0)
  lowButton:SetNormalAtlas("128-RedButton-ArrowDown")
  lowButton:SetScript("OnClick", function()
    SetDamageMeterHeight(GLOBAL_CONFIG:GetValue("DAMAGE_METER_LOW_SIZE"))
  end)

  local midButton = GUI:SimpleButton(25, "MID_BUTTON", nil, false)
  midButton:SetPoint("BOTTOMLEFT", lowButton, "TOPLEFT", 0, 0)
  midButton:SetNormalAtlas("128-RedButton-Minus")
  midButton:SetScript("OnClick", function()
    SetDamageMeterHeight(GLOBAL_CONFIG:GetValue("DAMAGE_METER_MIDDLE_SIZE"))
  end)

  local highButton = GUI:SimpleButton(25, "HIGH_BUTTON", nil, false)
  highButton:SetPoint("BOTTOMLEFT", midButton, "TOPLEFT", 0, 0)
  highButton:SetNormalAtlas("128-RedButton-ArrowUpGlow")
  highButton:SetScript("OnClick", function()
    SetDamageMeterHeight(GLOBAL_CONFIG:GetValue("DAMAGE_METER_HIGHT_SIZE"))
  end)
end
