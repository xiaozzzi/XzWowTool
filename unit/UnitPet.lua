-- 只在允许宠物的职业上执行，其他职业直接跳过整个脚本
local PET_CLASSES = {
  HUNTER = true,      -- 猎人
  WARLOCK = true,     -- 术士
  DEATHKNIGHT = true, -- 死亡骑士
}

RegisterStateDriver(PetFrame, "visibility", "hide")

local _, playerClass = UnitClass("player")
if not PET_CLASSES[playerClass] then
  return
end

local function PixelPerfect(value)
  return math.floor(value + 0.5)
end

-- 创建一个简单的框架作为父级
local frame = CreateFrame("Button", "UnitPetFrame", UIParent, "SecureUnitButtonTemplate,BackdropTemplate")
frame:SetSize(200, 30)                                         -- 设置血条大小
frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 585, 345) -- 设置
frame:EnableMouse(true)
frame:SetAttribute("unit", "pet")                              -- 设置单位属性为宠物
frame:RegisterForClicks("AnyUp")                               -- 注册左键和右键的点击事件
frame:SetAttribute("*type1", "target")                         -- 左键：设为目标
frame:SetAttribute("*type2", "togglemenu")                     -- 右键：由安全代码打开菜单
-- frame:SetMovable(true)                                         -- 可拖动
-- frame:RegisterForDrag("LeftButton")                            -- 注册左键拖动
-- frame:SetScript("OnDragStart", frame.StartMoving)              -- 开始拖动
-- frame:SetScript("OnDragStop", frame.StopMovingOrSizing)        -- 停止拖动
-- 注册拖拽回调
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

frame:SetBackdrop({
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,   -- 先设为1，如果UI缩放合适，就是1物理像素
})
frame:SetBackdropBorderColor(0, 0, 0, 1)

-- 宠物存在 且（有目标 或 处于战斗中）时显示，其他情况隐藏
RegisterStateDriver(frame, "visibility", "[pet,@target,exists][pet,combat] show; hide")

-- 创建血条（StatusBar）
local healthBar = CreateFrame("StatusBar", nil, frame)
-- healthBar:SetAllPoints()                                                -- 填满父框架
healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill") -- 使用默认材质
healthBar:SetStatusBarColor(0, 1, 0)                                    -- 绿色

-- 添加背景
local bg = healthBar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\Buttons\\WHITE8X8")
bg:SetVertexColor(0, 0, 0, 0.8)

-- 添加黑色边框
local borderSize = 1               -- 边框粗细，可改为 2 更明显
local borderColor = { 0, 0, 0, 1 } -- 黑色
local function CreateBorder()
  -- 计算当前框架对应的一个物理像素等于多少 UI 单位
  local scale = frame:GetEffectiveScale()
  local pixel = 1 / scale

  -- 想让边框更粗就把这里改成 2 * pixel
  local borderSize = pixel

  local top = frame:CreateTexture(nil, "OVERLAY")
  top:SetTexture("Interface\\Buttons\\WHITE8X8")
  top:SetVertexColor(unpack(borderColor))
  top:SetPoint("TOPLEFT", frame, "TOPLEFT", -borderSize, borderSize)
  top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", borderSize, borderSize)
  top:SetHeight(borderSize)

  local bottom = frame:CreateTexture(nil, "OVERLAY")
  bottom:SetTexture("Interface\\Buttons\\WHITE8X8")
  bottom:SetVertexColor(unpack(borderColor))
  bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -borderSize, -borderSize)
  bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", borderSize, -borderSize)
  bottom:SetHeight(borderSize)

  local left = frame:CreateTexture(nil, "OVERLAY")
  left:SetTexture("Interface\\Buttons\\WHITE8X8")
  left:SetVertexColor(unpack(borderColor))
  -- 上下各内缩一个 borderSize，避免和 top / bottom 在四角重叠
  left:SetPoint("TOPLEFT", frame, "TOPLEFT", -borderSize, 0)
  left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -borderSize, 0)
  left:SetWidth(borderSize)

  local right = frame:CreateTexture(nil, "OVERLAY")
  right:SetTexture("Interface\\Buttons\\WHITE8X8")
  right:SetVertexColor(unpack(borderColor))
  right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", borderSize, 0)
  right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", borderSize, 0)
  right:SetWidth(borderSize)
end
-- CreateBorder()

-- 添加文本显示血量数值
local HP_Number = healthBar:CreateFontString("HP_Number", "OVERLAY", "GameFontHighlight")
local fontPath, fontSize = NumberFontNormalSmallGray:GetFont()
HP_Number:SetPoint("RIGHT", healthBar, "RIGHT", -5, 0)
HP_Number:SetFont(fontPath, 14, "OUTLINE")
healthBar.Text = HP_Number

-- 核心更新函数
local function UpdatePetHealth()
  local current = UnitHealth("pet")
  local max = UnitHealthMax("pet")
  healthBar:SetMinMaxValues(0, max)
  healthBar:SetValue(current)
  HP_Number:SetText(current .. "")
end

-- 创建宠物名称文本
local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightOutline")
nameText:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 0, 2) -- 定位在血条左上角外部
nameText:SetJustifyH("LEFT")
nameText:SetText("")

local function UpdatePetName()
  local petName = UnitName("pet")
  if petName then
    nameText:SetText(petName)
  else
    nameText:SetText("")
  end
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
    -- CreateBorder()
    UpdatePetHealth()
    UpdatePetName()
  elseif event == "UNIT_PET" and unit == "player" then
    -- UNIT_PET 的 unit 参数是 "player"，表示玩家自己的宠物变化
    UpdatePetName()
    UpdatePetHealth()
    -- 宠物刚召唤时数据可能未就绪，延迟 0.1 秒再刷新一次兜底
    C_Timer.After(0.1, function()
      UpdatePetHealth()
      UpdatePetName()
    end)
  elseif unit == "pet" then
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
      UpdatePetHealth()
    elseif event == "UNIT_NAME_UPDATE" or event == "UNIT_PET" then
      UpdatePetName()
    end
  end
end)
