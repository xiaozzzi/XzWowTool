--·········································································································
--
-- 添加自定义按钮, 支持法术, 玩具, 游戏代码
--
--·········································································································

local ICON_SIZE = 25             -- 按钮图标大小
local BUTTON_OFFSET = 28         -- 按钮间距
local TEX_COORD_LR = 0.08        -- 按钮图标纹理坐标左上
local TEX_COORD_TB = 0.92        -- 按钮图标纹理坐标右下

local BTN_POSITION_Y_COL1 = 5    -- 第一列按钮初始Y坐标
local BTN_POSITION_Y_COL2 = 5    -- 第二列按钮初始Y坐标
local BTN_POSITION_X_COL1 = 725; -- 第一列按钮初始X坐标
local BTN_POSITION_X_COL2 = 754; -- 第二列按钮初始X坐标

local className, classFilename, classId = UnitClass("player")
local raceName, raceFile, raceID = UnitRace("player")

local COMMON_FRAME = CreateFrame("Frame", "COMMON_FRAME")

--#region ==================================== 公共配置 ====================================

--- 创建通用按钮, 不包含按钮位置
local function CreateButton(name)
  local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
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
  GUI:SolidBorder(button, 0, 0, 0, 1, 1.5)

  button:SetScript("OnEnter", function(self)
    -- border:SetColorTexture(1, 1, 1, 1)
    self:SetAlpha(1)
  end)
  button:SetScript("OnLeave", function(self)
    -- border:SetColorTexture(0, 0, 0, 1)
    self:SetAlpha(0.3)
  end)
  -- button:SetScript("OnEnter", function(self)
  --   GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  --   GameTooltip:SetToyByItemID(265100)
  --   GameTooltip:Show()
  -- end)
  -- button:SetScript("OnLeave", function(self)
  --   GameTooltip:Hide()
  -- end)
  return button
end

--- =====================================================================================
--- 设置按钮图标
--- @param button Frame 按钮
--- @param icon number|table 图标ID
--- =====================================================================================
local function CreateButtonTexture(button, icon)
  if type(icon) == "number" then
    local texture = UIParent:CreateTexture()
    texture:SetTexture(icon)
    texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
    button:SetNormalTexture(texture)
  end

  if type(icon) == "table" and icon.type and icon.type == 'atlas' then
    button:SetNormalAtlas(icon.atlas)
  end
end

--- =====================================================================================
--- 设置按钮位置
---@param button Frame 按钮
--- =====================================================================================
local function SetPosition(button, col)
  if col == 1 then
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", BTN_POSITION_X_COL1, BTN_POSITION_Y_COL1)
    BTN_POSITION_Y_COL1 = BTN_POSITION_Y_COL1 + BUTTON_OFFSET
  end
  if col == 2 then
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", BTN_POSITION_X_COL2, BTN_POSITION_Y_COL2)
    BTN_POSITION_Y_COL2 = BTN_POSITION_Y_COL2 + BUTTON_OFFSET
  end
  button:Show()
end

--- =====================================================================================
--- 设置按钮的冷却CD
---@param button Frame 按钮
--- =====================================================================================
local function CreateButtonCDText(button)
  -- 在框体上创建一个字体字符串
  local btnText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  btnText:SetPoint("CENTER", 0, 0)
  btnText:SetFont(ChatFontNormal:GetFont(), 17, "OUTLINE")
  btnText:SetText("")
  -- btnText:SetTextColor(1, 1, 1, 1)
  btnText:SetTextColor(0.015686, 1.0, 0.0, 1)
  return btnText
end

--- =====================================================================================
--- 设置按钮的充能
---@param button Frame 按钮
--- =====================================================================================
local function CreateButtonChargeText(button)
  -- 在框体上创建一个字体字符串
  local btnText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  btnText:SetPoint("BOTTOMRIGHT", 0, 0)
  btnText:SetFont(ChatFontNormal:GetFont(), 14, "OUTLINE")
  btnText:SetText("")
  -- btnText:SetTextColor(1, 1, 1, 1)
  btnText:SetTextColor(0.015, 1.0, 0.0, 1)
  return btnText
end

local FONT_SIZE = 10 -- 快捷键字体大小
local function CreateButtonHotKeyText(button, text)
  local btnText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  btnText:SetPoint("TOPRIGHT", 0, 0)
  btnText:SetFont(NumberFontNormalSmallGray:GetFont(), FONT_SIZE, "OUTLINE")
  btnText:SetText(text)
  btnText:SetTextColor(0.8, 0.8, 0.8, 1)
  return btnText
end

--#endregion 公共配置

--#region ==================================== 功能按钮 ====================================

-- 法术按钮
---@param button Frame 按钮
---@param iconId number|string 按钮的图标
---@param spellId number|string 法术ID
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

-- 坐骑按钮
local function MountButton(button, mountId)
  local _name, _spellID, icon = C_MountJournal.GetMountInfoByID(mountId)
  local texture = button:CreateTexture(nil, "ARTWORK")
  texture:SetTexture(icon)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)
  button:RegisterForClicks("AnyDown")
  button:SetScript("OnClick", function()
    C_MountJournal.SummonByID(mountId)
  end)
end

--- 制造业按钮
--- @param button Frame 按钮
--- @param icon number|table 按钮的图标
local function CraftingButton(button, icon)
  CreateButtonTexture(button, icon)
  button:SetScript("OnClick", function()
    ItemUtil.GetCraftingReagentCount = function(...) return 999 end
  end)
  button:RegisterForClicks("AnyUp")
  return button
end

local TheGreatVaultShow = false
--- 本周奖励按钮
--- @param button Frame 按钮
--- @param icon number|table 按钮的图标
local function TheGreatVaultButton(button, icon)
  CreateButtonTexture(button, icon)
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
---@param button Frame 按钮
---@param icon number|table 按钮的图标
---@param macroIds any[] 命令ID列表
local function AddonCmdButton(button, icon, macroIds)
  CreateButtonTexture(button, icon)

  button:SetScript("OnClick", function()
    for _, macroId in ipairs(macroIds) do
      local handler = SlashCmdList[macroId]
      if handler then handler("") end
    end
  end)
  button:RegisterForClicks("AnyUp")
  return button
end

--#endregion

--#region ==================================== 创建按钮 ====================================

local BUTTON_WAR_BAND_BANK = CreateButton("BUTTON_WAR_BAND_BANK")
local BUTTON_MAIL_BOX = CreateButton("BUTTON_MAIL_BOX")
local BUTTON_THE_ARCANTINA = CreateButton("BUTTON_THE_ARCANTINA")
local BUTTON_HEARTH_STONE = CreateButton("BUTTON_HEARTH_STONE")
local BUTTON_CRAFTING = CreateButton("BUTTON_CRAFTING")
local BUTTON_THE_GREAT_VAULT = CreateButton("BUTTON_THE_GREAT_VAULT")
local BUTTON_MACRO_DELVE = CreateButton("BUTTON_MACRO_DELVE")

local BUTTON_WAR_BAND_BANK_CD = CreateButtonCDText(BUTTON_WAR_BAND_BANK)
local BUTTON_MAIL_BOX_CD = CreateButtonCDText(BUTTON_MAIL_BOX)
local BUTTON_THE_ARCANTINA_CD = CreateButtonCDText(BUTTON_THE_ARCANTINA)
local BUTTON_HEARTH_STONE_CD = CreateButtonCDText(BUTTON_HEARTH_STONE)

-- 人类双炉石
local BUTTON_HUMAN_HS_CHARGE = nil
if raceFile == 'Human' then
  BUTTON_HUMAN_HS_CHARGE = CreateButtonChargeText(BUTTON_HEARTH_STONE)
end

-- 萨满星界传送(特殊职业技能)
local BUTTON_SHAMAN_HS = nil
local BUTTON_SHAMAN_HS_CD = nil

if classFilename and classFilename == "SHAMAN" then
  BUTTON_SHAMAN_HS = CreateButton()
  BUTTON_SHAMAN_HS_CD = CreateButtonCDText(BUTTON_SHAMAN_HS)
end

--- 战团银行:     图标ID:4914670; 法术ID:460905;
--- 邮箱:         物品ID:264695;
--- 奥术秘社:     物品ID:253629;
--- 炉石:         物品ID:6948; 法术ID:8690;
--- 萨满星界传送: 图标ID:136010; 法术ID:556;
--- 制造业:       图标ID:132326;
--- 宏伟宝库:     图标ID:651744;
--- 地下堡插件:   图标ID:656581;
function InitCommonButtonCol1(player)
  -- 重置按钮位置
  BTN_POSITION_Y_COL1 = 5

  -- 战团银行按钮
  if player['SHOW_BTN_WAR_BAND_BANK'] == 'SHOW' then
    SetPosition(BUTTON_WAR_BAND_BANK, 1)
    SpellButton(BUTTON_WAR_BAND_BANK, 4914670, 460905)
  else
    BUTTON_WAR_BAND_BANK:Hide()
  end
  -- 邮箱按钮
  if player['SHOW_BTN_MAIL_BOX'] == 'SHOW' then
    SetPosition(BUTTON_MAIL_BOX, 1)
    ToyButton(BUTTON_MAIL_BOX, 264695)
  else
    BUTTON_MAIL_BOX:Hide()
  end
  -- 奥术秘社
  if player['SHOW_BTN_THE_ARCANTINA'] == 'SHOW' then
    SetPosition(BUTTON_THE_ARCANTINA, 1)
    ToyButton(BUTTON_THE_ARCANTINA, 253629)
  else
    BUTTON_THE_ARCANTINA:Hide()
  end
  -- 炉石
  if player['SHOW_BTN_HEARTH_STONE'] == 'SHOW' then
    SetPosition(BUTTON_HEARTH_STONE, 1)
    ToyButton(BUTTON_HEARTH_STONE, tonumber(player['HEARTH_STONE']))
  else
    BUTTON_HEARTH_STONE:Hide()
  end
  -- 萨满星界传送(特殊职业技能)
  if BUTTON_SHAMAN_HS and player['SHOW_BTN_HEARTH_STONE'] == 'SHOW' then
    SetPosition(BUTTON_SHAMAN_HS, 1)
    SpellButton(BUTTON_SHAMAN_HS, 136010, 556)
  else
    if BUTTON_SHAMAN_HS and player['SHOW_BTN_HEARTH_STONE'] == 'HIDE' then
      BUTTON_SHAMAN_HS:Hide()
    end
  end
  -- 制造按钮
  if player['SHOW_BTN_CRAFTING'] == 'SHOW' then
    SetPosition(BUTTON_CRAFTING, 1)
    -- iconId: 132326
    CraftingButton(BUTTON_CRAFTING, { type = 'atlas', atlas = 'Professions-Icon-Quality-Tier5' })
  else
    BUTTON_CRAFTING:Hide()
  end
  -- 宏伟宝库
  if player['SHOW_BTN_THE_GREAT_VAULT'] == 'SHOW' then
    SetPosition(BUTTON_THE_GREAT_VAULT, 1)
    -- iconId: 651744
    TheGreatVaultButton(BUTTON_THE_GREAT_VAULT, { type = 'atlas', atlas = 'greatVault-whole-normal' })
  else
    BUTTON_THE_GREAT_VAULT:Hide()
  end
  -- 执行插件的 CMD 命令按钮
  if player['SHOW_BTN_MACRO_DELVE'] == 'SHOW' then
    SetPosition(BUTTON_MACRO_DELVE, 1)
    -- iconId: 656581
    AddonCmdButton(BUTTON_MACRO_DELVE, { type = 'atlas', atlas = 'majorfactions_icons_delve512' },
      { "DRT", "DFCN_DELVEHELPER" })
  else
    BUTTON_MACRO_DELVE:Hide()
  end
end

-- ---------------------------------------- 第二列 ------------------------------------------
local BUTTON_FLY_MODE = CreateButton("BUTTON_FLY_MODE")
local BUTTON_MOUNT_YAK = CreateButton("BUTTON_MOUNT_YAK")
local BUTTON_MOUNT_FUNGAL_STRIDER = CreateButton("BUTTON_MOUNT_FUNGAL_STRIDER")

local BUTTON_PROF1 = CreateButton("BUTTON_PROF1")
local BUTTON_PROF2 = CreateButton("BUTTON_PROF2")

function InitCommonButtonCol2(player)
  -- 重置按钮位置
  BTN_POSITION_Y_COL2 = 5

  local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
  print(prof1, prof2)
  if player['SHOW_BTN_PROF2'] == 'SHOW' and prof2 and prof2 ~= 0 then
    local name, icon = GetProfessionInfo(prof2)
    CreateButtonHotKeyText(BUTTON_PROF2, "SR")
    SetPosition(BUTTON_PROF2, 2)
    SpellButton(BUTTON_PROF2, icon, PRO_MAPPING[name].spellId)
    SetBinding("SHIFT-R", "CLICK BUTTON_PROF2:LeftButton")
  else
    BUTTON_PROF2:Hide()
  end

  if player['SHOW_BTN_PROF1'] == 'SHOW' and prof1 and prof1 ~= 0 then
    local name, icon = GetProfessionInfo(prof1)
    CreateButtonHotKeyText(BUTTON_PROF1, "CC")
    SetPosition(BUTTON_PROF1, 2)
    SpellButton(BUTTON_PROF1, icon, PRO_MAPPING[name].spellId)
    SetBinding("CTRL-C", "CLICK BUTTON_PROF1:LeftButton")
  else
    BUTTON_PROF1:Hide()
  end

  -- 更新飞行模式按钮
  if player['SHOW_BTN_FLY_MODE'] == 'SHOW' then
    SetPosition(BUTTON_FLY_MODE, 2)
    SpellButton(BUTTON_FLY_MODE, 5145511, 436854)
  else
    BUTTON_FLY_MODE:Hide()
  end

  -- 雷菌
  if player['SHOW_BTN_MOUNT_FUNGAL_STRIDER'] == 'SHOW' then
    CreateButtonHotKeyText(BUTTON_MOUNT_FUNGAL_STRIDER, "ST")
    SetPosition(BUTTON_MOUNT_FUNGAL_STRIDER, 2)
    MountButton(BUTTON_MOUNT_FUNGAL_STRIDER, 460)
    SetBinding("SHIFT-T", "CLICK BUTTON_MOUNT_FUNGAL_STRIDER:LeftButton")
  else
    BUTTON_MOUNT_FUNGAL_STRIDER:Hide()
  end

  -- 牦牛
  if player['SHOW_BTN_MOUNT_YAK'] == 'SHOW' then
    CreateButtonHotKeyText(BUTTON_MOUNT_YAK, "AT")
    SetPosition(BUTTON_MOUNT_YAK, 2)
    MountButton(BUTTON_MOUNT_YAK, 460)
    SetBinding("ALT-T", "CLICK BUTTON_MOUNT_YAK:LeftButton")
  else
    BUTTON_MOUNT_YAK:Hide()
  end
end

function InitCommonButton()
  local player = CONFIG:GetByUnitGUID(UnitGUID("player"))
  if not player then return end

  InitCommonButtonCol1(player)
  InitCommonButtonCol2(player)
end

--#endregion

--#region ==================================== 更新按钮文字 ====================================

local UPDATE_INTERVAL = 60     -- 更新间隔: 秒
local elapsedTime = 0          -- 上次更新时间:秒
local immediatelyUpdate = true -- 是否立即更新

local function SecondsToMinutesUp(seconds)
  if not seconds or seconds <= 0 then
    return 0
  end
  return math.ceil(seconds / 60)
end

local function handleSpellCDText(textWidget, cooldownInfo)
  if issecrettable(cooldownInfo) or issecretvalue(cooldownInfo.duration) or cooldownInfo.isOnGCD then
    textWidget:SetText("")
    return
  end
  if cooldownInfo and cooldownInfo.duration > 0 then
    local remainingTime = (cooldownInfo.startTime + cooldownInfo.duration) - GetTime()
    if remainingTime > 0 then
      textWidget:SetText(SecondsToMinutesUp(remainingTime))
    else
      textWidget:SetText("")
    end
  else
    textWidget:SetText("")
  end
end

local function handleItemCDText(textWidget, startTime, duration)
  if duration and duration > 0 then
    textWidget:SetText(SecondsToMinutesUp(duration - GetTime() + startTime))
  else
    textWidget:SetText("")
  end
end

COMMON_FRAME:SetScript("OnUpdate", function(self, elapsed)
  elapsedTime = elapsedTime + elapsed
  -- 如果是立即更新, 或达到了更新时间
  if immediatelyUpdate or elapsedTime >= UPDATE_INTERVAL then
    -- 战斗中不获取冷却, 因为会传回秘密值
    if InCombatLockdown() then
      elapsedTime = 0
      return
    end
    elapsedTime = 0
    immediatelyUpdate = false

    -- 战团银行冷却时间
    local cooldownInfo = C_Spell.GetSpellCooldown(460905)
    handleSpellCDText(BUTTON_WAR_BAND_BANK_CD, cooldownInfo)

    -- 邮箱冷却时间
    local startTime, duration = C_Item.GetItemCooldown(264695)
    handleItemCDText(BUTTON_MAIL_BOX_CD, startTime, duration)

    -- 奥术秘社冷却时间
    local startTime, duration = C_Item.GetItemCooldown(253629)
    handleItemCDText(BUTTON_THE_ARCANTINA_CD, startTime, duration)

    -- 炉石冷却时间
    local startTime, duration = C_Item.GetItemCooldown(6948)
    handleItemCDText(BUTTON_HEARTH_STONE_CD, startTime, duration)

    -- 萨满星界传送冷却时间(特殊职业技能)
    if BUTTON_SHAMAN_HS_CD then
      local cooldownInfo = C_Spell.GetSpellCooldown(556)
      handleSpellCDText(BUTTON_SHAMAN_HS_CD, cooldownInfo)
    end

    -- 人类炉石充能次数
    if BUTTON_HUMAN_HS_CHARGE then
      local chargs = C_Spell.GetSpellCharges(8690) -- 炉石的法术ID
      -- print(chargs.currentCharges, chargs.maxCharges)
      BUTTON_HUMAN_HS_CHARGE:SetText(chargs.currentCharges .. '')
    end
  end
end)

-- COMMON_FRAME:RegisterEvent("SPELL_UPDATE_COOLDOWN")
-- COMMON_FRAME:SetScript("OnEvent", function(self, event, spellID)
--   print(spellID)
-- end)
--#endregion
