--·········································································································
--
-- 自定义目标的目标[暂时作废]
--
--·········································································································

if 1 == 1 then
  return
end

local FONT_PATH, FONT_SIZE = ChatFontNormal:GetFont()

-- ========== 创建框体 ==========
local frame = CreateFrame("Button", "UnitTargetTargetFrame", UIParent, "SecureUnitButtonTemplate,BackdropTemplate")
frame:SetSize(130, 25)
frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 1520, 345)
frame:EnableMouse(true)
frame:RegisterForClicks("AnyUp")

-- 单位属性
frame:SetAttribute("unit", "targettarget")
frame:SetAttribute("*type1", "target") -- 左键：设为目标
-- frame:SetAttribute("*type2", "togglemenu") -- 右键：原生菜单

-- 边框
frame:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, })
frame:SetBackdropBorderColor(0, 0, 0, 1)

-- 背景
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\Buttons\\WHITE8X8")
bg:SetVertexColor(0, 0, 0, 0.5)

-- ========== 血条 ==========
local healthBar = CreateFrame("StatusBar", "TARGETTARGET_HEALTH_BAR", frame)
healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
-- healthBar:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background") -- 纯色
-- healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar") -- 圆柱状的
-- healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8") -- 最亮的纯色
-- healthBar:SetAtlas("UI-HUD-UnitFrame-Player-Rest-Flipbook", true)
healthBar:SetStatusBarColor(0, 1, 0)

-- ========== 单位名称（血条内左侧） ==========
local nameText = frame:CreateFontString("TARGET_NAME", "OVERLAY")
nameText:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 2, 2)
nameText:SetFont(FONT_PATH, 14, "OUTLINE")
nameText:SetShadowOffset(0, 0)
nameText:SetJustifyH("LEFT")
nameText:SetText("")

-- ========== 更新函数 ==========
local function UpdateHealth()
  local current = UnitHealth("targettarget")
  local max = UnitHealthMax("targettarget")
  healthBar:SetMinMaxValues(0, max)
  healthBar:SetValue(current)
end

local function UpdateName()
  local unitName = UnitName("targettarget")
  if unitName then
    nameText:SetText(unitName)
  else
    nameText:SetText("")
  end
end

-- 按职业给血条着色
local function UpdateColor()
  local unit = "targettarget"

  -- 非玩家（NPC、宠物等）：回退到默认绿色
  if not UnitIsPlayer(unit) then
    healthBar:SetStatusBarColor(0, 1, 0)
    return
  end

  local classFilename, classId = UnitClassBase(unit)
  local color = classFilename and RAID_CLASS_COLORS[classFilename]

  if color then
    healthBar:SetStatusBarColor(color.r, color.g, color.b)
  else
    healthBar:SetStatusBarColor(0, 1, 0)
  end
end

-- 总入口
local function UpdateFrame()
  -- 没有目标的目标：什么都不做，StateDriver 会自动隐藏
  if not UnitExists("targettarget") then
    return
  end
  print("UpdateFrame" .. GetTime())
  -- 死亡状态
  if UnitIsDead("targettarget") then
    healthBar:SetMinMaxValues(0, 1)
    healthBar:SetValue(0)
    return
  end
  UpdateColor()
  UpdateHealth()
  UpdateName()
end

-- ========== 显示条件 ==========
-- 有目标的目标 且（有目标 或 战斗中）时显示
RegisterStateDriver(frame, "visibility", "[@targettarget,exists] show; hide")

-- ========== 事件注册 ==========
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED") -- 自己切换目标
frame:RegisterEvent("UNIT_TARGET")           -- 任意单位的目标变化
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MAXHEALTH")
frame:RegisterEvent("UNIT_NAME_UPDATE")

frame:SetScript("OnEvent", function(self, event, unit)
  if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED" then
    UpdateFrame()
  elseif event == "UNIT_TARGET" then
    -- 只有当“目标的目标”发生变化时才刷新
    if unit == "target" then
      UpdateFrame()
      -- C_Timer.After(0.05, UpdateFrame) -- 兜底，数据可能延迟一帧
    end
  elseif unit == "targettarget" then
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
      UpdateFrame()
    elseif event == "UNIT_NAME_UPDATE" then
      UpdateFrame()
    end
  end
end)
