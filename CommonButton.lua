local ICON_SIZE = 25      -- 按钮图标大小
local BUTTON_Y = 5        -- 按钮初始位置
local BUTTON_OFFSET = 28  -- 按钮间距
local TEX_COORD_LR = 0.08 -- 按钮图标纹理坐标左上
local TEX_COORD_TB = 0.92 -- 按钮图标纹理坐标右下


local COMMON_FRAME = CreateFrame("Frame")

local function AddSolidBorder(frame, r, g, b, a, thickness)
  thickness = thickness or 1
  r, g, b = r or 0, g or 0, b or 0
  a = a or 1

  -- 上边框
  local top = frame:CreateTexture(nil, "OVERLAY")
  top:SetColorTexture(r, g, b, a)
  top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  top:SetHeight(thickness)

  -- 下边框
  local bottom = frame:CreateTexture(nil, "OVERLAY")
  bottom:SetColorTexture(r, g, b, a)
  bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  bottom:SetHeight(thickness)

  -- 左边框
  local left = frame:CreateTexture(nil, "OVERLAY")
  left:SetColorTexture(r, g, b, a)
  left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  left:SetWidth(thickness)

  -- 右边框
  local right = frame:CreateTexture(nil, "OVERLAY")
  right:SetColorTexture(r, g, b, a)
  right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  right:SetWidth(thickness)
end

-- ===================================================================================
-- 创建按钮
-- ===================================================================================

--- 创建通用按钮, 不包含按钮位置
local function CreateButton()
  local button = CreateFrame("Button", "MyButton", UIParent, "SecureActionButtonTemplate")
  button:SetSize(ICON_SIZE, ICON_SIZE)
  button:SetAlpha(0.3)
  -- 背景纹理（类似 CreateTexture）
  -- local bg = button:CreateTexture(nil, "BACKGROUND")
  -- bg:SetAllPoints()
  -- bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
  -- 边框
  -- local border = button:CreateTexture(nil, "BORDER")
  -- border:SetAllPoints()
  -- border:SetColorTexture(0, 0, 0, 1)
  -- bg:SetPoint("TOPLEFT", 2, -2)
  -- bg:SetPoint("BOTTOMRIGHT", -2, 2)
  AddSolidBorder(button, 0, 0, 0, 1, 1.5)

  button:SetScript("OnEnter", function(self)
    -- border:SetColorTexture(1, 1, 1, 1)
    self:SetAlpha(1)
  end)
  button:SetScript("OnLeave", function(self)
    -- border:SetColorTexture(0, 0, 0, 1)
    self:SetAlpha(0.3)
  end)
  -- btn:SetScript("OnEnter", function(self)
  --   GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  --   GameTooltip:SetToyByItemID(265100)
  --   GameTooltip:Show()
  -- end)
  -- btn:SetScript("OnLeave", function(self)
  --   GameTooltip:Hide()
  -- end)
  return button
end

--- 设置按钮位置
---@param button Frame 按钮
local function SetPosition(button)
  button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 725, BUTTON_Y)
  button:Show()
  BUTTON_Y = BUTTON_Y + BUTTON_OFFSET
end


--- 设置按钮文字
---@param button Frame 按钮
local function CreateButtonText(button)
  -- 在框体上创建一个字体字符串
  local btnText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  btnText:SetPoint("CENTER", 0, 0)
  btnText:SetFont(ChatFontNormal:GetFont(), 17, "OUTLINE")
  btnText:SetText("")
  -- btnText:SetTextColor(1, 1, 1, 1)
  btnText:SetTextColor(0.015686, 1.0, 0.0, 1)
  return btnText
end

-- ===================================================================================
-- 功能按钮
-- ===================================================================================

-- 法术按钮
---@param button Frame 按钮
---@param iconId number 按钮的图标
---@param spellId number 法术ID
local function SpellButton(button, iconId, spellId)
  button:SetAttribute("type", "spell")
  button:SetAttribute("spell", spellId)
  local texture = UIParent:CreateTexture()
  texture:SetTexture(iconId)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)
  button:RegisterForClicks("AnyUp", "AnyDown")
end

-- 玩具按钮
local function ToyButton(button, toyId)
  button:SetAttribute("type", "toy")
  button:SetAttribute("*toy1", toyId)
  local icon = C_Item.GetItemIconByID(toyId) -- 按钮的纹理
  local texture = button:CreateTexture(nil, "ARTWORK")
  texture:SetTexture(icon)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)
  button:RegisterForClicks("AnyUp", "AnyDown")
  return button
end


--- 制造按钮
local function CraftingButton(button, iconId)
  local texture = UIParent:CreateTexture()
  texture:SetTexture(iconId)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)
  button:SetScript("OnClick", function()
    ItemUtil.GetCraftingReagentCount = function(...) return 999 end
  end)
  button:RegisterForClicks("AnyUp")
  return button
end

--- 本周奖励按钮
local TheGreatVaultShow = false
local function TheGreatVaultButton(button, iconId)
  local texture = UIParent:CreateTexture()
  texture:SetTexture(iconId)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)
  button:SetScript("OnClick", function()
    if not TheGreatVaultShow then
      C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
      table.insert(UISpecialFrames, "WeeklyRewardsFrame")
      WeeklyRewardsFrame:HookScript("OnHide", function(self)
        TheGreatVaultShow = false
      end)
      WeeklyRewardsFrame:Show()
      TheGreatVaultShow = true
    else
      WeeklyRewardsFrame:Hide()
    end
  end)
  button:RegisterForClicks("AnyUp")
  return button
end

-- 执行插件的 CMD 命令
local function AddonCmdButton(button, iconId, macroIds)
  local texture = UIParent:CreateTexture()
  texture:SetTexture(iconId)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)

  button:SetScript("OnClick", function()
    for _, macroId in ipairs(macroIds) do
      local handler = SlashCmdList[macroId]
      if handler then handler("") end
    end
  end)
  button:RegisterForClicks("AnyUp")
  return button
end

-- =======================================================
-- 初始化按钮
-- =======================================================

local BUTTON_WAR_BAND_BANK = CreateButton()
local BUTTON_MAIL_BOX = CreateButton()
local BUTTON_THE_ARCANTINA = CreateButton()
local BUTTON_HEARTH_STONE = CreateButton()
local BUTTON_CRAFTING = CreateButton()
local BUTTON_THE_GREAT_VAULT = CreateButton()
local BUTTON_MACRO_DELVE = CreateButton()

local BUTTON_WAR_BAND_BANK_TEXT = CreateButtonText(BUTTON_WAR_BAND_BANK)
local BUTTON_MAIL_BOX_TEXT = CreateButtonText(BUTTON_MAIL_BOX)
local BUTTON_THE_ARCANTINA_TEXT = CreateButtonText(BUTTON_THE_ARCANTINA)
local BUTTON_HEARTH_STONE_TEXT = CreateButtonText(BUTTON_HEARTH_STONE)


function InitCommonButton()
  -- 重置按钮位置
  BUTTON_Y = 5
  local player = CONFIG:GetByUnitGUID(UnitGUID("player"))
  if not player then return end

  -- 战团银行按钮
  if player['SHOW_BTN_WAR_BAND_BANK'] == 'SHOW' then
    SetPosition(BUTTON_WAR_BAND_BANK)
    SpellButton(BUTTON_WAR_BAND_BANK, 4914670, 460905)
  else
    BUTTON_WAR_BAND_BANK:Hide()
  end
  -- 邮件箱按钮
  if player['SHOW_BTN_MAIL_BOX'] == 'SHOW' then
    SetPosition(BUTTON_MAIL_BOX)
    ToyButton(BUTTON_MAIL_BOX, 264695)
  else
    BUTTON_MAIL_BOX:Hide()
  end
  -- 奥术秘社
  if player['SHOW_BTN_THE_ARCANTINA'] == 'SHOW' then
    SetPosition(BUTTON_THE_ARCANTINA)
    ToyButton(BUTTON_THE_ARCANTINA, 253629)
  else
    BUTTON_THE_ARCANTINA:Hide()
  end
  -- 炉石
  if player['SHOW_BTN_HEARTH_STONE'] == 'SHOW' then
    SetPosition(BUTTON_HEARTH_STONE)
    ToyButton(BUTTON_HEARTH_STONE, tonumber(player['HEARTH_STONE']))
  else
    BUTTON_HEARTH_STONE:Hide()
  end
  -- 制造按钮
  if player['SHOW_BTN_CRAFTING'] == 'SHOW' then
    SetPosition(BUTTON_CRAFTING)
    CraftingButton(BUTTON_CRAFTING, 132326)
  else
    BUTTON_CRAFTING:Hide()
  end
  -- 本周奖励按钮
  if player['SHOW_BTN_THE_GREAT_VAULT'] == 'SHOW' then
    SetPosition(BUTTON_THE_GREAT_VAULT)
    TheGreatVaultButton(BUTTON_THE_GREAT_VAULT, 651744)
  else
    BUTTON_THE_GREAT_VAULT:Hide()
  end
  -- 执行插件的 CMD 命令按钮
  if player['SHOW_BTN_MACRO_DELVE'] == 'SHOW' then
    SetPosition(BUTTON_MACRO_DELVE)
    AddonCmdButton(BUTTON_MACRO_DELVE, 656581, { "DRT", "DFCN_DELVEHELPER" })
  else
    BUTTON_MACRO_DELVE:Hide()
  end
end

--#region ==================================== 更新按钮文字 ====================================

local UPDATE_INTERVAL = 60    -- 更新间隔: 秒
local timeSinceLastUpdate = 0 -- 上次更新时间:秒
local firstUpdate = true

local function SecondsToMinutesUp(seconds)
  if not seconds or seconds <= 0 then
    return 0
  end
  return math.ceil(seconds / 60)
end

local function handleSpellCDText(text, cooldownInfo)
  if cooldownInfo and cooldownInfo.duration > 0 then
    local remainingTime = (cooldownInfo.startTime + cooldownInfo.duration) - GetTime()
    if remainingTime > 0 then
      text:SetText(SecondsToMinutesUp(remainingTime))
    else
      text:SetText("")
    end
  else
    text:SetText("")
  end
end

local function handleItemCDText(text, startTime, duration)
  if duration and duration > 0 then
    text:SetText(SecondsToMinutesUp(duration - GetTime() + startTime))
  else
    text:SetText("")
  end
end

COMMON_FRAME:SetScript("OnUpdate", function(self, elapsed)
  timeSinceLastUpdate = timeSinceLastUpdate + elapsed
  if firstUpdate or timeSinceLastUpdate >= UPDATE_INTERVAL then
    if InCombatLockdown() then
      timeSinceLastUpdate = 0
      return
    end
    timeSinceLastUpdate = 0
    firstUpdate = false

    -- 战团银行冷却时间
    local cooldownInfo = C_Spell.GetSpellCooldown(460905)
    handleSpellCDText(BUTTON_WAR_BAND_BANK_TEXT, cooldownInfo)

    -- 邮件箱冷却时间
    local startTime, duration = C_Item.GetItemCooldown(264695)
    handleItemCDText(BUTTON_MAIL_BOX_TEXT, startTime, duration)

    -- 奥术秘社冷却时间
    local startTime, duration = C_Item.GetItemCooldown(253629)
    handleItemCDText(BUTTON_THE_ARCANTINA_TEXT, startTime, duration)

    -- 炉石冷却时间
    local startTime, duration = C_Item.GetItemCooldown(6948)
    handleItemCDText(BUTTON_HEARTH_STONE_TEXT, startTime, duration)
  end
end)

--#endregion
