local ICON_SIZE = 25

local TEX_COORD_LR = 0.08
local TEX_COORD_TB = 0.92

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

-- =======================================================
-- 创建按钮
-- =======================================================
local function CreateButton(marginButton)
  local button = CreateFrame("Button", "MyButton", UIParent, "SecureActionButtonTemplate")
  button:SetSize(ICON_SIZE, ICON_SIZE)
  button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 725, marginButton)
  button:SetAlpha(0.1)
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
    self:SetAlpha(0.1)
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

-- =======================================================
-- 法术按钮
-- =======================================================
local function SpellButton(offset, iconId, spellId)
  local button = CreateButton(offset)
  button:SetAttribute("type", "spell")
  button:SetAttribute("spell", spellId)
  local texture = UIParent:CreateTexture()
  texture:SetTexture(iconId)
  texture:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
  button:SetNormalTexture(texture)
  button:RegisterForClicks("AnyUp", "AnyDown")
end

-- =======================================================
-- 玩具按钮
-- =======================================================
local function ToyButton(offset, toyId)
  local button = CreateButton(offset)
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

-- =======================================================
-- 执行插件的 CMD 命令
-- =======================================================
local function AddonCmdButton(offset, iconId, macroIds)
  local button = CreateButton(offset)
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

--- =======================================================
--- 制造按钮
--- =======================================================
local function CraftingButton(offset, iconId)
  local button = CreateButton(offset)
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

--- =======================================================
--- 本周奖励按钮
--- =======================================================
local TheGreatVaultShow = false
local function TheGreatVaultButton(offset, iconId)
  local button = CreateButton(offset)
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

function InitCommonButton()
  local cur = 5
  local offset = 28
  local player = CONFIG:GetByUnitGUID(UnitGUID("player"))
  local btns = {
    "WAR_BAND_BANK",
    "MAIL_BOX",
    "THE_ARCANTINA", -- 奥术秘社
    "HEARTH_STONE",
    "MACRO_DELVE",
    "CRAFTING",
    "THE_GREAT_VAULT",
  }
  if player['SHOW_BTN_WAR_BAND_BANK'] == 'SHOW' then
    SpellButton(cur, 4914670, 460905)
    cur = cur + offset
  end
  if player['SHOW_BTN_MAIL_BOX'] == 'SHOW' then
    ToyButton(cur, 264695)
    cur = cur + offset
  end
  if player['SHOW_BTN_THE_ARCANTINA'] == 'SHOW' then
    ToyButton(cur, 253629)
    cur = cur + offset
  end
  if player['SHOW_BTN_HEARTH_STONE'] == 'SHOW' then
    ToyButton(cur, tonumber(player['HEARTH_STONE']))
    cur = cur + offset
  end
  if player['SHOW_BTN_CRAFTING'] == 'SHOW' then
    CraftingButton(cur, 132326)
    cur = cur + offset
  end
  if player['SHOW_BTN_THE_GREAT_VAULT'] == 'SHOW' then
    TheGreatVaultButton(cur, 651744)
    cur = cur + offset
  end
  if player['SHOW_BTN_MACRO_DELVE'] == 'SHOW' then
    AddonCmdButton(cur, 656581, { "DRT", "DFCN_DELVEHELPER" })
    cur = cur + offset
  end
end
