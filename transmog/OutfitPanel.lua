--·········································································································
--
-- 快捷幻化方案 (屏幕上的第三列按钮)
--
-- convenient/CommonButton.lua 第二列中的"幻化方案"按钮会打开这里的第三列,
-- 第三列显示当前角色已创建的所有幻化方案, 点击某个方案即切换对应幻化, 并收起第三列.
--
-- 切换幻化:
--   方案按钮使用 SecureActionButtonTemplate, 点击时由游戏在"安全环境"里执行切换,
--   靠的是安全属性 type="outfit" + outfit-index(方案在界面里的序号).
--   原因: C_TransmogOutfitInfo 的切换接口对插件代码是保护函数(直接调用会报 ADDON_ACTION_FORBIDDEN).
--
--·········································································································
UI_OutfitPanel = {}

local ICON_SIZE = 24       -- 按钮图标大小(与 convenient/CommonButton.lua 保持一致)
local BUTTON_OFFSET = 27   -- 按钮间距(与 convenient/CommonButton.lua 保持一致)
local TEX_COORD_LR = 0.08  -- 按钮图标纹理坐标左上
local TEX_COORD_TB = 0.92  -- 按钮图标纹理坐标右下

local PANEL_X = 780        -- 第三列X坐标: 第二列 753 + 按钮间距 27
local PANEL_Y = 5          -- 第三列初始Y坐标(与其它列一致)
local PANEL_WIDTH = 150    -- 宽度只用于显示提示文字, 按钮本身仍按 ICON_SIZE 排列

local PANEL_NAME = "XZ_TRANSMOG_OUTFIT_PANEL"

local PANEL        -- 第三列容器
local HINT_TEXT    -- 没有方案时的提示文字
local BUTTONS = {} -- 方案按钮, 按下标复用

--#region ==================================== 公共方法 ====================================

--- 是否支持幻化方案接口
--- @return boolean
local function IsSupported()
  return C_TransmogOutfitInfo ~= nil and C_TransmogOutfitInfo.GetOutfitsInfo ~= nil
end

--- 获取当前角色已创建的所有幻化方案
--- @return table
local function GetOutfits()
  local result = {}
  -- 战斗中读到的是秘密值, 直接返回空列表
  if not IsSupported() or InCombatLockdown() then
    return result
  end

  local ok, outfits = pcall(C_TransmogOutfitInfo.GetOutfitsInfo)
  if not ok or type(outfits) ~= "table" then
    return result
  end

  for _, outfit in ipairs(outfits) do
    if type(outfit) == "table" and outfit.outfitID ~= nil and outfit.name ~= nil then
      -- 过滤掉不可用的方案(例如活动专属方案)
      if not outfit.isDisabled then
        table.insert(result, outfit)
      end
    end
  end
  return result
end

--#endregion

--#region ==================================== 切换幻化 ====================================

-- 切换幻化必须由游戏自己在"安全环境"里完成:
--   * C_TransmogOutfitInfo.ChangeToOutfit 对插件代码是保护函数, 直接调用会报 ADDON_ACTION_FORBIDDEN;
--   * 但 12.x 的 SecureTemplates.lua 新增了 type="outfit" 这个安全动作, 正是给我们用的:
--       SECURE_ACTIONS.outfit = function(self, _unit, button)
--         local action = SecureButton_GetModifiedAttribute(self, "action", button) or "toggle"
--         local index = tonumber(SecureButton_GetModifiedAttribute(self, "outfit-index", button))
--         if action == "clear" then C_TransmogOutfitInfo.ClearOutfit()
--         elseif action == "change" or action == "toggle" then
--           if index ~= nil then
--             C_TransmogOutfitInfo.ChangeToOutfit(index, action == "toggle")
--           end
--         end
--       end
--     (来源: Gethe/wow-ui-source@live 12.1.5.70688, Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua)
--   * 所以方案按钮只要用 SecureActionButtonTemplate 设好两个安全属性即可, 插件代码不用调任何 API:
--       type         = "outfit"
--       action       = "change"   -- change: 只切换; toggle: 再点一次会取消幻化
--       outfit-index = 方案序号(playerFacingOutfitIndex)

--- 取方案序号(安全属性 outfit-index 用的就是这个)
--- @param outfit table 方案信息
--- @param fallback number 接口没给序号时的备用值(按钮排列位置)
--- @return number 方案序号
local function GetOutfitIndex(outfit, fallback)
  return outfit.playerFacingOutfitIndex or fallback
end

--#endregion

--#region ==================================== 按钮 ====================================

--- 显示方案提示
--- @param button Frame 按钮
--- @param outfit table 方案信息
local function ShowOutfitTooltip(button, outfit)
  GameTooltip:SetOwner(button, "ANCHOR_RIGHT")

  -- 优先使用游戏自带的方案提示(含方案内的各个部位)
  local shown = false
  if GameTooltip.SetOutfit then
    shown = pcall(GameTooltip.SetOutfit, GameTooltip, outfit.outfitID)
  end

  if not shown or GameTooltip:NumLines() == 0 then
    GameTooltip:ClearLines()
    GameTooltip:AddLine(outfit.name or "")
  end

  GameTooltip:Show()
end

--- 创建(或复用)一个方案按钮
--- @param index number 按钮下标
--- @return Frame 按钮
local function AcquireButton(index)
  local button = BUTTONS[index]
  if button then
    return button
  end

  -- 幻化切换是受保护操作, 用 SecureActionButtonTemplate + 安全属性交给游戏执行
  button = CreateFrame("Button", PANEL_NAME .. "Button" .. index, PANEL, "SecureActionButtonTemplate")
  button:SetSize(ICON_SIZE, ICON_SIZE)
  -- 必须同时注册按下和松开: 只注册 AnyUp 时, 如果玩家开了"按下时施法"相关设置,
  -- SecureActionButton_OnClick 会认为这次点击应该由"按下"触发, 于是松开时什么都不做(静默失效)
  button:RegisterForClicks("AnyDown", "AnyUp")
  button:SetAttribute("useOnKeyDown", true) -- 固定为按下即执行, 不受上面那个设置影响
  button:SetAlpha(0.3)
  GUI:SolidBorder(button, 0, 0, 0, 1, 1)

  -- 图标
  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetPoint("TOPLEFT", 1, -1)
  icon:SetPoint("BOTTOMRIGHT", -1, 1)
  icon:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button.icon = icon

  button:SetScript("OnEnter", function(self)
    self:SetAlpha(1)
    if self.outfit then
      ShowOutfitTooltip(self, self.outfit)
    end
  end)

  button:SetScript("OnLeave", function(self)
    self:SetAlpha(0.3)
    GameTooltip:Hide()
  end)

  -- 注意: 不能用 SetScript 覆盖 OnClick, 否则会顶掉安全按钮自带的 SecureActionButton_OnClick,
  -- 安全属性(type=outfit)就不会执行了; 这里用 HookScript 在安全切换之后收起第三列
  button:HookScript("OnClick", function(self)
    UI_OutfitPanel:OnOutfitClick(self)
  end)

  BUTTONS[index] = button
  return button
end

--#endregion

--#region ==================================== 第三列 ====================================

--- 创建第三列容器
local function CreatePanel()
  if PANEL then
    return
  end

  PANEL = CreateFrame("Frame", PANEL_NAME, UIParent)
  PANEL:SetSize(PANEL_WIDTH, BUTTON_OFFSET)
  PANEL:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", PANEL_X, PANEL_Y)
  PANEL:Hide()

  -- ESC 关闭
  table.insert(UISpecialFrames, PANEL_NAME)

  HINT_TEXT = PANEL:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  HINT_TEXT:SetPoint("BOTTOMLEFT", 0, 0)
  HINT_TEXT:SetFont(ChatFontNormal:GetFont(), 12, "OUTLINE")
  HINT_TEXT:SetTextColor(1, 1, 1, 1)
  HINT_TEXT:SetText("")
  HINT_TEXT:Hide()
end

--- 刷新第三列内容
--- @return number 方案数量
local function Refresh()
  local outfits = GetOutfits()
  local count = #outfits

  for index = 1, count do
    local outfit = outfits[index]
    local button = AcquireButton(index)
    button.outfit = outfit
    button.icon:SetTexture(outfit.icon or 134400)
    -- 切换幻化的核心: 安全属性, 由游戏在安全环境中执行
    local outfitIndex = GetOutfitIndex(outfit, index)
    button:SetAttribute("type", "outfit")
    button:SetAttribute("action", "change")
    button:SetAttribute("outfit-index", outfitIndex)
    button:ClearAllPoints()
    -- 与其它两列一致: 第一个按钮在最下方, 依次向上
    button:SetPoint("BOTTOMLEFT", PANEL, "BOTTOMLEFT", 0, (index - 1) * BUTTON_OFFSET)
    button:Show()
  end

  -- 隐藏多余的按钮
  for index = count + 1, #BUTTONS do
    BUTTONS[index].outfit = nil
    BUTTONS[index]:Hide()
  end

  PANEL:SetHeight(math.max(count, 1) * BUTTON_OFFSET)
  return count
end

--- 点击方案按钮: 切换幻化由安全属性(type=outfit)完成, 这里只负责收起第三列
--- @param button Frame 方案按钮
function UI_OutfitPanel:OnOutfitClick(button)
  if not (button and button.outfit) then
    return
  end
  self:Hide()
end

--- 显示第三列
function UI_OutfitPanel:Show()
  if InCombatLockdown() then
    print("战斗中无法打开幻化方案列表")
    return
  end
  if not IsSupported() then
    print("当前版本不支持幻化方案接口")
    return
  end

  CreatePanel()

  local count = Refresh()
  HINT_TEXT:SetText(count == 0 and "没有幻化方案" or "")
  if count == 0 then
    HINT_TEXT:Show()
  else
    HINT_TEXT:Hide()
  end

  PANEL:Show()
end

--- 隐藏第三列
function UI_OutfitPanel:Hide()
  -- 方案按钮是安全按钮, 第三列在战斗中不能显示/隐藏
  if InCombatLockdown() then
    return
  end
  if PANEL then
    PANEL:Hide()
  end
  GameTooltip:Hide()
end

--- 显示/隐藏第三列
function UI_OutfitPanel:Toggle()
  if PANEL and PANEL:IsShown() then
    self:Hide()
  else
    self:Show()
  end
end

--#endregion
