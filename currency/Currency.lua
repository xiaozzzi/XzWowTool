--·········································································································
--
-- 监控货币数量
--
--·········································································································
MODE_CURRENCY = {}
MODE_CURRENCY.BACKGROUND = {
  ["housing-bulletinboard-list-header-decorative-line"] = { width = 568, height = 9, X = -20, Y = -28 },
  ["communities-chat-date-line-orange"] = { width = 547, height = 10, X = 0, Y = -28 },
  ["communities-chat-date-line"] = { width = 547, height = 10, X = 0, Y = -28 },
  ["UI-Frame-DastardlyDuos-Line-bottom"] = { width = 481, height = 16, X = 0, Y = -28 },
  ["UI-Journeys-Renown-divider"] = { width = 733, height = 16, X = -150, Y = -28 },
}
local MAIN_FRAME = CreateFrame("Frame", "CURRNECY_MAIN_FRAME", UIParent)
local CURRENCY_BG_BG = MAIN_FRAME:CreateTexture(nil, "BACKGROUND")
MAIN_FRAME:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
MAIN_FRAME:SetWidth(10)
MAIN_FRAME:SetHeight(10)
MAIN_FRAME:SetFrameStrata("BACKGROUND") -- 背景层

local CURRENCY_UI_LIST = {}
local OFFSET_LEFT = 10
local OFFSET_TOP = -20
local CURRENCY_DISTANCE = 45

---是否显示货币监控
---@return boolean
local function isShowCurrency()
  local SHOW_CURRENCY = CFG:GetValue(UnitGUID("player"), 'SHOW_CURRENCY')
  return (SHOW_CURRENCY == 'SHOW')
end

--#region 货币背景

---更新货币背景
function MODE_CURRENCY:UpdBackground()
  local bgName = CFG_G:GetValue("CURRENCY_BACKGROUND")
  local config = MODE_CURRENCY.BACKGROUND[bgName]
  if config == nil then
    config = MODE_CURRENCY.BACKGROUND[1]
  end
  CURRENCY_BG_BG:SetAtlas(bgName)
  CURRENCY_BG_BG:SetWidth(config.width)
  CURRENCY_BG_BG:SetHeight(config.height)
  CURRENCY_BG_BG:ClearAllPoints()
  CURRENCY_BG_BG:SetPoint("TOPLEFT", MAIN_FRAME, "TOPLEFT", config.X, config.Y)
end

--#endregion 货币背景

---初始化货币监控
---为每个货币创建一个UI元素，用于显示货币数量, 并将UI元素存储在CURRENCY_UI_LIST中, 便于更新数值
function MODE_CURRENCY:InitCurrencyTrack()
  if not isShowCurrency() or not IsMaxPlayerLevel() then
    MAIN_FRAME:Hide()
    return
  else
    MAIN_FRAME:Show()
  end


  -- 记录上一个UI, 用于设置锚点
  local lastCurrnecyFrame = nil

  for index, currency in ipairs(CURRENCY_ID) do
    -- 获取货币信息
    local info = C_CurrencyInfo.GetCurrencyInfo(currency.ID)

    -- 可获取的数量
    local notEarned = info.maxQuantity - info.totalEarned

    -- 货币图标
    local icon = MAIN_FRAME:CreateTexture()
    icon:SetScale(0.3)
    icon:SetTexture(info.iconFileID)
    if index == 1 then
      icon:SetPoint("TOPLEFT", MAIN_FRAME, "TOPLEFT", OFFSET_LEFT, OFFSET_TOP)
    elseif lastCurrnecyFrame then
      icon:SetPoint("LEFT", lastCurrnecyFrame, "RIGHT", CURRENCY_DISTANCE, 0)
    end

    -- 货币数量
    local countLabel = MAIN_FRAME:CreateFontString("XzCurrencyLabel_" .. currency.ID, "OVERLAY", "GameFontNormal")
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

-- 更新货币信息
function MODE_CURRENCY:UpdCurrencyTrack(currencyId)
  if not isShowCurrency() or not IsMaxPlayerLevel() then
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
