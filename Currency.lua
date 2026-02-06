-- 货币监控

CURRENCY_UI_LIST = {}
local LEFT = 10
local TOP = -20
local WEIGHT = 250

function InitCurrencyTrack()
    for index, currency in pairs(CURRENCY_ID) do
        -- 获取货币信息
        local info = C_CurrencyInfo.GetCurrencyInfo(currency.ID)

        -- 货币图标
        local tex = UIParent:CreateTexture()
        tex:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LEFT + ((index - 1) * WEIGHT), TOP)
        tex:SetScale(0.3)
        tex:SetTexture(info.iconFileID)

        -- 货币数量
        local countLabel = UIParent:CreateFontString("XzCurrencyLabel_" .. currency.ID, "OVERLAY", "GameFontNormal")
        countLabel:SetFont(ChatFontNormal:GetFont(), 18, 'OUTLINE')
        countLabel:SetText("" .. info.quantity .. '/' .. info.maxQuantity)
        countLabel:SetPoint("LEFT", tex, "RIGHT", 0, 0)
        countLabel:SetTextColor(currency.R, currency.G, currency.B)
        CURRENCY_UI_LIST[currency.ID] = countLabel
    end
end

-- 更新货币信息
function UpdCurrencyTrack(currencyId)
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
        InitCurrencyTrack()
    end

    if CURRENCY_UI_LIST[currencyId] == nil then
        return
    end

    local countLabel = CURRENCY_UI_LIST[currencyId]
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyId)
    countLabel:SetText("" .. info.quantity .. '/' .. info.maxQuantity)
end
