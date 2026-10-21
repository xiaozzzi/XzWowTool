local ADDON_NAME      = ...

-- ============================================================
-- 配置区
-- ============================================================
local BAR_WIDTH       = 181
local BAR_HEIGHT      = 14
local BAR_GAP         = 2

local POS_X           = 0
local POS_Y           = -160

local BAR_TEXTURE     = "Interface\\AddOns\\XzWowTool\\assets\\xz_satin.png"

local HEALTH_COLOR    = { 0.2, 0.8, 0.2 }
local ABSORB_COLOR    = { 0.6, 0.8, 1.0, 0.5 }
local POWER_COLOR     = { 0.2, 0.4, 1.0 }
local BG_COLOR        = { 0.08, 0.08, 0.08, 0.85 }

local EDGE_SIZE       = 1
local EDGE_COLOR      = { 0, 0, 0, 1 }

-- 分割线配置
local DIVIDER_WIDTH   = 1
local DIVIDER_COLOR   = { 0, 0, 0, 0.9 }

-- 魔法值固定显示法力（0）
local POWER_TYPE      = 0

-- ============================================================
-- 职业资源映射表
-- ============================================================
local CLASS_RESOURCES = {
  WARLOCK = {
    powerType = Enum.PowerType.SoulShards, -- 7
    max       = 5,
    color     = { 0.55, 0.35, 0.85 },
  },
  -- 后续加其他职业，在这里追加即可
}

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
-- 职业资源框架（位于魔法值条下方）
-- ============================================================
local resourceFrame = CreateBarFrame("HealthAbsorbBarResourceFrame")
resourceFrame:SetPoint("TOP", powerFrame, "BOTTOM", 0, -BAR_GAP)
resourceFrame:Hide()

local resourceBar = CreateStatusBar(resourceFrame, { 1, 1, 1 })

-- ============================================================
-- 职业资源分割线
--
-- 分割线数量 = 资源最大值 - 1，全部由配置表中硬编码的 max 计算。
-- 纹理直接创建在 resourceBar 上，放在 "OVERLAY" 层，
-- 确保覆盖在状态条填充纹理（"ARTWORK" 层）之上。
-- ============================================================
local resourceDividers = {}

local function ClearDividers()
  for _, tex in ipairs(resourceDividers) do
    tex:Hide()
  end
  wipe(resourceDividers)
end

local function CreateDividers(maxCount)
  ClearDividers()

  if not maxCount or maxCount <= 1 then return end

  local innerWidth = BAR_WIDTH - EDGE_SIZE * 2

  for i = 1, maxCount - 1 do
    local tex = resourceBar:CreateTexture(nil, "OVERLAY")
    tex:SetColorTexture(unpack(DIVIDER_COLOR))
    tex:SetWidth(DIVIDER_WIDTH)
    tex:SetPoint("TOPLEFT", resourceBar, "TOPLEFT",
      innerWidth * i / maxCount - DIVIDER_WIDTH / 2, 0)
    tex:SetPoint("BOTTOMLEFT", resourceBar, "BOTTOMLEFT",
      innerWidth * i / maxCount - DIVIDER_WIDTH / 2, 0)
    resourceDividers[#resourceDividers + 1] = tex
  end
end

-- ============================================================
-- 当前激活的职业资源类型
-- ============================================================
local activeResourceType = nil
local activeResourceMax  = nil

-- ============================================================
-- 更新函数（秘密值安全）
-- ============================================================
local function UpdateHealth()
  local health    = UnitHealth("player")
  local maxHealth = UnitHealthMax("player")

  healthBar:SetMinMaxValues(0, maxHealth)
  healthBar:SetValue(health)

  absorbBar:SetMinMaxValues(0, maxHealth)
end

local function UpdateAbsorb()
  local absorb = UnitGetTotalAbsorbs("player")
  absorbBar:SetValue(absorb)
end

local function UpdatePower()
  local power    = UnitPower("player", POWER_TYPE)
  local maxPower = UnitPowerMax("player", POWER_TYPE)

  powerBar:SetMinMaxValues(0, maxPower)
  powerBar:SetValue(power)
end

local function UpdateResource()
  if not activeResourceType then
    resourceFrame:Hide()
    return
  end

  local current = UnitPower("player", activeResourceType)
  resourceBar:SetMinMaxValues(0, activeResourceMax)
  resourceBar:SetValue(current)
  resourceFrame:Show()
end

local function RefreshResourceType()
  local _, class = UnitClass("player")
  local config = CLASS_RESOURCES[class]

  if config then
    activeResourceType = config.powerType
    activeResourceMax  = config.max
    resourceBar:SetStatusBarColor(unpack(config.color))
    CreateDividers(config.max)
    UpdateResource()
  else
    activeResourceType = nil
    activeResourceMax  = nil
    ClearDividers()
    resourceFrame:Hide()
  end
end

-- ============================================================
-- 事件
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_MAXHEALTH")
eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_MAXPOWER")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_ENTERING_WORLD" then
    UpdateHealth()
    UpdateAbsorb()
    UpdatePower()
    RefreshResourceType()
    return
  end

  if event == "PLAYER_SPECIALIZATION_CHANGED" then
    RefreshResourceType()
    return
  end

  if arg1 ~= "player" then return end

  if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
    UpdateHealth()
  elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
    UpdateAbsorb()
  elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
    UpdatePower()
    UpdateResource()
  end
end)
