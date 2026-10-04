--·········································································································
--
-- 自定义宠物单位框体
--
--·········································································································

UNIT_PET = {}

-- 只在允许宠物的职业上执行，其他职业直接跳过整个脚本
local PET_CLASSES = {
  HUNTER = true,      -- 猎人
  WARLOCK = true,     -- 术士
  DEATHKNIGHT = true, -- 死亡骑士
}

local _, playerClass = UnitClass("player")
if not PET_CLASSES[playerClass] then
  return
end

RegisterStateDriver(PetFrame, "visibility", "hide")
local FONT_PATH, FONT_SIZE = ChatFontNormal:GetFont()

-- 创建一个简单的框架作为父级
local frame = CreateFrame("Button", "UnitPetFrame", UIParent, "SecureUnitButtonTemplate,BackdropTemplate")
frame:SetSize(200, 30) -- 设置血条大小
-- frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 578, 348) -- 设置
frame:EnableMouse(true)
frame:SetAttribute("unit", "pet")          -- 设置单位属性为宠物
frame:RegisterForClicks("AnyUp")           -- 注册左键和右键的点击事件
frame:SetAttribute("*type1", "target")     -- 左键：设为目标
frame:SetAttribute("*type2", "togglemenu") -- 右键：由安全代码打开菜单
frame:Hide()
-- frame:SetMovable(true)                                         -- 可拖动
-- frame:RegisterForDrag("LeftButton")                            -- 注册左键拖动
-- 开始拖动
-- frame:SetScript("OnDragStart", function(self)
--   if not self:IsMovable() then
--     return
--   end
--   frame:StartMoving()
-- end)
-- -- 停止拖动
-- frame:SetScript("OnDragStop", function(self)
--   self:StopMovingOrSizing()
-- end)
-- 注册拖拽回调, 拖拽会使锚点重置为 (CENTER,UIParent,CENTER)
-- frame:SetScript("OnDragStop", function(self)
--   self:StopMovingOrSizing()
--   -- 获取当前锚点、相对框架、相对锚点、X 偏移、Y 偏移
--   local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
--   -- relativeTo 打印出来是框架对象，转成名字更直观
--   local relativeName = relativeTo and relativeTo.GetName and relativeTo:GetName() or tostring(relativeTo)
--   print(string.format("SetPoint(\"%s\", %s, \"%s\", %d, %d)", point, relativeName, relativePoint, math.floor(xOfs + 0.5),
--     math.floor(yOfs + 0.5)
--   ))
-- end)

-- 如果UI缩放合适，就是1物理像素
frame:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
frame:SetBackdropBorderColor(0, 0, 0, 1)

-- 宠物存在 且（有目标 或 处于战斗中）时显示，其他情况隐藏
RegisterStateDriver(frame, "visibility", "[pet,@target,exists][pet,combat] show; hide")

-- 创建血条（StatusBar）
local healthBar = CreateFrame("StatusBar", "PET_HEALTH_BAR", frame)
-- healthBar:SetAllPoints()                                             -- 填满父框架
healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill") -- 使用默认材质
healthBar:SetStatusBarColor(0, 1, 0)                                    -- 绿色

-- 添加背景
local bg = healthBar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\Buttons\\WHITE8X8")
bg:SetVertexColor(0, 0, 0, 0.8)

function UNIT_PET:UpdatePoint()
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
    tonumber(CONFIG_GLOBAL:GetValue("UNIT_PET_POINT_X")),
    tonumber(CONFIG_GLOBAL:GetValue("UNIT_PET_POINT_Y")))
  frame:Show()
end

--#region ================================================== 血量显示 ==================================================

-- 添加文本显示血量数值
local HP_Number = healthBar:CreateFontString("HP_NUMBER", "OVERLAY", "GameFontHighlight")
HP_Number:SetPoint("RIGHT", healthBar, "RIGHT", -5, 0)
HP_Number:SetFont(FONT_PATH, 14, "OUTLINE")
HP_Number:SetShadowOffset(0, 0)
healthBar.Text = HP_Number

-- 更新血量显示
local function UpdatePetHealth()
  local current = UnitHealth("pet")
  local max = UnitHealthMax("pet")
  healthBar:SetMinMaxValues(0, max)
  healthBar:SetValue(current)
  HP_Number:SetText(AbbreviateNumbers(current))
end

--#endregion

--#region ================================================== 宠物名称显示 ==================================================

-- 创建宠物名称文本
local nameText = healthBar:CreateFontString("PET_NAME", "OVERLAY", "GameFontHighlightOutline")
nameText:SetPoint("LEFT", healthBar, "LEFT", 3, 0) -- 定位在血条左上角外部
nameText:SetJustifyH("LEFT")
nameText:SetFont(FONT_PATH, 14, "OUTLINE")
nameText:SetShadowOffset(0, 0)
nameText:SetText("")

local function UpdatePetName()
  local petName = UnitName("pet")
  if petName then
    nameText:SetText(petName)
  else
    nameText:SetText("")
  end
end

--#endregion

-- 总更新入口：只负责内容，不负责 Show/Hide（显示隐藏交给 StateDriver）
local function UpdatePetFrame()
  -- 无宠物：什么都不做，StateDriver 会自动隐藏框架
  if not UnitExists("pet") then
    return
  end

  -- 宠物死亡：血条清空，文字显示“死亡”
  if UnitIsDead("pet") then
    healthBar:SetMinMaxValues(0, 1)
    healthBar:SetValue(0)
    nameText:SetText("死亡")
    return
  end

  -- 宠物存活：正常刷新血量和名称
  UpdatePetHealth()
  UpdatePetName()
end

-- 注册事件
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MAXHEALTH")        -- 宠物升级或更换时最大血量会变
frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- 进入游戏时初始化
frame:RegisterEvent("UNIT_NAME_UPDATE")      -- 单位名称变化（包括宠物召唤/更换）
frame:RegisterEvent("UNIT_PET")              -- 宠物单位信息变化

-- 首次进入游戏时，即使没有血量变化事件，也主动更新一次
frame:SetScript("OnEvent", function(self, event, unit)
  if event == "PLAYER_ENTERING_WORLD" then
    UpdatePetFrame()
    UNIT_PET:UpdatePoint()
  elseif event == "UNIT_PET" and unit == "player" then
    UpdatePetFrame()
    C_Timer.After(0.1, UpdatePetFrame)
  elseif unit == "pet" then
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
      UpdatePetFrame()
    elseif event == "UNIT_NAME_UPDATE" or event == "UNIT_PET" then
      UpdatePetFrame()
    end
  end
end)
