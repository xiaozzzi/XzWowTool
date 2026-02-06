local _, ns = ...

-- AceGUI = LibStub("AceGUI-3.0")

local updateInterval = 1 -- 每1秒更新一次
local timeSinceLastUpdate = 0

local XzFrame = CreateFrame("Frame", "XzFrame", UIParent, "DialogBoxFrame")
XzFrame:RegisterEvent("ADDON_LOADED")
XzFrame:RegisterEvent("BAG_UPDATE_DELAYED")
XzFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE") -- 货币变更
XzFrame:RegisterEvent("PLAYER_LOGIN")            -- 角色登录
XzFrame:Show()

local _, classFileName, _ = UnitClass("player")

local function isDruid()
    return classFileName == "DRUID"
end

XzFrame:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "ADDON_LOADED" and unit == 'XzWowTool' then
        if isDruid() then
            InitWoodTrack()
        end
    elseif event == 'PLAYER_LOGIN' then
        self:UnregisterEvent("PLAYER_LOGIN")
        InitCurrencyTrack()
    elseif event == "BAG_UPDATE_DELAYED" and isDruid() then
        UpdWoodTrack()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        UpdCurrencyTrack(unit)
    end

    -- 每帧更新
    self:SetScript("OnUpdate", function(self, elapsed)
        timeSinceLastUpdate = timeSinceLastUpdate + elapsed

        if timeSinceLastUpdate >= updateInterval then
            InitStat()
            timeSinceLastUpdate = 0
        end
    end)
end)
