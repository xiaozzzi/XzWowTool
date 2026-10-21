local ADDON_NAME   = ...

-- ============================================================
-- 配置区
-- ============================================================
local BAR_WIDTH    = 181
local BAR_HEIGHT   = 14
local BAR_GAP      = 2

local POS_X        = 0
local POS_Y        = -160

local BAR_TEXTURE  = "Interface\\AddOns\\XzWowTool\\assets\\xz_satin.png"

local HEALTH_COLOR = { 0.2, 0.8, 0.2 }
local ABSORB_COLOR = { 0.6, 0.8, 1.0, 0.5 }
local POWER_COLOR  = { 0.2, 0.4, 1.0 }
local BG_COLOR     = { 0.08, 0.08, 0.08, 0.85 }

local EDGE_SIZE    = 1
local EDGE_COLOR   = { 0, 0, 0, 1 }

local POWER_TYPE   = 0

-- ============================================================
-- 工厂函数
-- ============================================================
local function CreateBarFrame(name)
  local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
  f:SetSize(BAR_WIDTH, BAR_HEIGHT)
  f:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = EDGE_SIZE,
  })
  f:SetBackdropColor(unpack(BG_COLOR))
  f:SetBackdropBorderColor(unpack(EDGE_COLOR))
  return f
end

local function CreateStatusBar(parent, color)
  local bar = CreateFrame("StatusBar", nil, parent)
  bar:SetPoint("TOPLEFT", EDGE_SIZE, -EDGE_SIZE)
  bar:SetPoint("BOTTOMRIGHT", -EDGE_SIZE, EDGE_SIZE)
  bar:SetStatusBarTexture(BAR_TEXTURE)
  bar:SetStatusBarColor(unpack(color))
  bar:SetMinMaxValues(0, 100)
  bar:SetValue(100)
  return bar
end

-- ============================================================
-- 生命值框架
-- ============================================================
local healthFrame = CreateBarFrame("HealthAbsorbBarFrame")
healthFrame:SetPoint("CENTER", UIParent, "CENTER", POS_X, POS_Y)

local healthBar = CreateStatusBar(healthFrame, HEALTH_COLOR)

local absorbBar = CreateFrame("StatusBar", nil, healthFrame)
absorbBar:SetAllPoints(healthBar)
absorbBar:SetStatusBarTexture(BAR_TEXTURE)
absorbBar:SetStatusBarColor(unpack(ABSORB_COLOR))
absorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 2)
absorbBar:SetMinMaxValues(0, 100)
absorbBar:SetValue(0)
absorbBar:SetReverseFill(true)

-- ============================================================
-- 魔法值框架
-- ============================================================
local powerFrame = CreateBarFrame("HealthAbsorbBarPowerFrame")
powerFrame:SetPoint("TOP", healthFrame, "BOTTOM", 0, -BAR_GAP)

local powerBar = CreateStatusBar(powerFrame, POWER_COLOR)

-- ============================================================
-- 三个独立的更新函数（秘密值安全：只传给控件，不做运算或比较）
-- ============================================================

-- 生命值：同时负责设置吸收条的 MinMax，
-- 因为吸收条的填充比例依赖“最大生命值”，这不算对吸收值的运算。
local function UpdateHealth()
  local health    = UnitHealth("player")
  local maxHealth = UnitHealthMax("player")

  healthBar:SetMinMaxValues(0, maxHealth)
  healthBar:SetValue(health)

  absorbBar:SetMinMaxValues(0, maxHealth)
end

-- 吸收值：只取吸收量，直接交给 StatusBar
local function UpdateAbsorb()
  local absorb = UnitGetTotalAbsorbs("player")
  absorbBar:SetValue(absorb)
end

-- 魔法值：只取当前魔法值和最大魔法值
local function UpdatePower()
  local power    = UnitPower("player", POWER_TYPE)
  local maxPower = UnitPowerMax("player", POWER_TYPE)

  powerBar:SetMinMaxValues(0, maxPower)
  powerBar:SetValue(power)
end

-- ============================================================
-- 事件：每个事件只更新自己对应的那个值
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_MAXHEALTH")
eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_MAXPOWER")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_ENTERING_WORLD" then
    -- 全量刷新一次；先 Health 以设置吸收条的 MinMax，再 Absorb
    UpdateHealth()
    UpdateAbsorb()
    UpdatePower()
    return
  end

  if arg1 ~= "player" then return end

  if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
    UpdateHealth()
  elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
    UpdateAbsorb()
  elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
    UpdatePower()
  end
end)
