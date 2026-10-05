--·········································································································
--
-- 监控货币数量
--
--·········································································································
MODE_CURRENCY = {}
MODE_CURRENCY.BACKGROUND = {
  ["housing-bulletinboard-list-header-decorative-line"] = { width = 568, height = 9, X = -200, Y = -15 },
  ["communities-chat-date-line-orange"] = { width = 456, height = 8, X = 0, Y = -15 },
  ["communities-chat-date-line"] = { width = 456, height = 8, X = 0, Y = -15 },
  ["UI-Frame-DastardlyDuos-Line-bottom"] = { width = 370, height = 12, X = 0, Y = -15 },
  ["UI-Journeys-Renown-divider"] = { width = 366, height = 8, X = 0, Y = -15 },
}
local CURRENCY_UI_LIST = {}
local OFFSET_LEFT = 10
local OFFSET_TOP = -20
local CURRENCY_DISTANCE = 45

---是否显示货币监控
---@return boolean
local function isShowCurrency()
  local SHOW_CURRENCY = CONFIG:GetValue(UnitGUID("player"), 'SHOW_CURRENCY')
  return (SHOW_CURRENCY == 'SHOW')
end

---初始化货币监控
---为每个货币创建一个UI元素，用于显示货币数量, 并将UI元素存储在CURRENCY_UI_LIST中, 便于更新数值
function MODE_CURRENCY:InitCurrencyTrack()
  if not isShowCurrency() or not IsMaxPlayerLevel() then
    return
  end

  -- 记录上一个UI, 用于设置锚点
  local lastCurrnecyFrame = nil

  for index, currency in ipairs(CURRENCY_ID) do
    -- 获取货币信息
    local info = C_CurrencyInfo.GetCurrencyInfo(currency.ID)

    -- 可获取的数量
    local notEarned = info.maxQuantity - info.totalEarned

    -- 货币图标
    local icon = UIParent:CreateTexture()
    icon:SetScale(0.3)
    icon:SetTexture(info.iconFileID)
    if index == 1 then
      icon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", OFFSET_LEFT, OFFSET_TOP)
    elseif lastCurrnecyFrame then
      icon:SetPoint("LEFT", lastCurrnecyFrame, "RIGHT", CURRENCY_DISTANCE, 0)
    end

    -- 货币数量
    local countLabel = UIParent:CreateFontString("XzCurrencyLabel_" .. currency.ID, "OVERLAY", "GameFontNormal")
    countLabel:SetFont(ChatFontNormal:GetFont(), 18, 'OUTLINE')
    countLabel:SetPoint("LEFT", icon, "RIGHT", 0, 0)
    countLabel:SetTextColor(currency.R, currency.G, currency.B)
    -- countLabel:SetText("" .. info.quantity .. '/' .. info.maxQuantity .. "(" .. notEarned .. ")")
    countLabel:SetText("" .. info.quantity .. '/' .. notEarned)
    countLabel:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetCurrencyByID(currency.ID)
      GameTooltip:Show()
    end)
    countLabel:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
    end)
    lastCurrnecyFrame = countLabel
    CURRENCY_UI_LIST[currency.ID] = countLabel
  end
end

--#region 货币背景

local CURRENCY_BG_FRAME = CreateFrame("Frame", "CURRENCY_BACKGROUND_FRAME")
local CURRENCY_BG_BG = CURRENCY_BG_FRAME:CreateTexture(nil, "BACKGROUND")
CURRENCY_BG_FRAME:SetWidth(330)
CURRENCY_BG_FRAME:SetFrameStrata("BACKGROUND") -- 背景层
CURRENCY_BG_BG:SetAllPoints()

---更新货币背景
function MODE_CURRENCY:UpdBackground()
  if not isShowCurrency() or not IsMaxPlayerLevel() then
    return
  end
  local bgName = CONFIG_GLOBAL:GetValue("CURRENCY_BACKGROUND")
  local config = MODE_CURRENCY.BACKGROUND[bgName]
  if config == nil then
    config = MODE_CURRENCY.BACKGROUND[1]
  end
  CURRENCY_BG_BG:SetAtlas(bgName)
  CURRENCY_BG_FRAME:SetWidth(config.width)
  CURRENCY_BG_FRAME:SetHeight(config.height)
  CURRENCY_BG_FRAME:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.X, config.Y)
end

--#endregion 货币背景

-- 更新货币信息
function MODE_CURRENCY:UpdCurrencyTrack(currencyId)
  if not isShowCurrency() then
    return
  end
  if currencyId == nil then
    return
  end

  local isUpd = false
  for _, currency in pairs(CURRENCY_ID) do
    if currency.ID == currencyId then
      isUpd = true
      break
    end
  end

  if not isUpd then
    return
  end

  if next(CURRENCY_UI_LIST) == nil or CURRENCY_UI_LIST[currencyId] == nil then
    MODE_CURRENCY:InitCurrencyTrack()
  end

  if CURRENCY_UI_LIST[currencyId] == nil then
    return
  end

  local countLabel = CURRENCY_UI_LIST[currencyId]
  local info = C_CurrencyInfo.GetCurrencyInfo(currencyId)
  -- countLabel:SetText("" .. info.quantity .. '/' .. info.maxQuantity)
  -- 可获取的数量
  local notEarned = info.maxQuantity - info.totalEarned
  countLabel:SetText("" .. info.quantity .. '/' .. notEarned)
end
