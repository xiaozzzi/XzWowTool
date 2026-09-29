-- 属性监控

local STAT_UI_LIST = {}

local Stat = {}


local function GetUnitStatType(unitStatIndex, statValue)
    if unitStatIndex == 1 then
        return GetColorText("C79C6E", "力量 " .. statValue)
    elseif unitStatIndex == 2 then
        return GetColorText("FFF569", "敏捷" .. statValue)
    elseif unitStatIndex == 3 then
        return GetColorText("FF0000", "体质" .. statValue)
    elseif unitStatIndex == 4 then
        return GetColorText("69CCF0", "智力" .. statValue)
    end
end

-- 初始化
-- print(UnitStat("player", 1))  -- 力量
-- print(UnitStat("player", 2))  -- 敏捷
-- print(UnitStat("player", 3))  -- 体质
-- print(UnitStat("player", 4))  -- 智力
function InitStat()
    local _, classFileName, _ = UnitClass("player")
    local specIndex = GetSpecialization() -- 当前专精的索引
    if (specIndex == nil) then
        return
    end

    -- 判断是智力还是力量
    local unitStatIndex = CLASS_SPEC[classFileName][specIndex]
    -- local _, specName = GetSpecializationInfo(specIndex) -- 专精名称
    -- 当前属性
    local statValue = UnitStat('player', unitStatIndex)
    local statName = GetUnitStatType(unitStatIndex, statValue)
    -- 暴击
    local crit = GetCritChance()
    -- 急速
    -- local haste = GetHaste()
    local haste = UnitSpellHaste("player")
    -- 精通
    local mastery, _ = GetMasteryEffect()
    -- 全能
    -- 全能数值 GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
    local versatility = GetVersatilityBonus(29) + GetCombatRatingBonus(29)

    Stat[5] = statName
    Stat[4] = string.format("暴 %.1f%%", crit)
    Stat[3] = string.format("急 %.1f%%", haste)
    Stat[2] = string.format("精 %.1f%%", mastery)
    Stat[1] = string.format("全 %.1f%%", versatility)
    Draw()
end

function Draw()
    for index, value in pairs(Stat) do
        -- print(value)
        local statLabel
        if STAT_UI_LIST[index] == nil then
            statLabel = UIParent:CreateFontString("XzStatLabel_" .. index, "OVERLAY", "GameFontNormal")
            statLabel:SetFont(ChatFontNormal:GetFont(), 16, 'OUTLINE')
            statLabel:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -230 - (index * 70), -5)
            STAT_UI_LIST[index] = statLabel
        else
            statLabel = STAT_UI_LIST[index]
        end
        statLabel:SetText(value)
    end
end
