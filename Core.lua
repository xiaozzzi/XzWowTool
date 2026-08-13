local _, ns = ...

-- AceGUI = LibStub("AceGUI-3.0")

local updateInterval = 3 -- 每1秒更新一次
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

        local children = { _G["EssentialCooldownViewer"].children }

        for _, child in ipairs(children) do
            -- BuffIconCooldownViewer has Applications.Applications and other views have ChargeCount.Current
            local fs = child and child.Applications and child.Applications.Applications
                or child.ChargeCount and child.ChargeCount.Current

            if child.Applications and child.Applications.SetFrameLevel then
                child.Applications:SetFrameLevel(20)
            end
            if child.ChargeCount and child.ChargeCount.SetFrameLevel then
                child.ChargeCount:SetFrameLevel(20)
            end
            print(child.Applications)
            print(child.ChargeCount)
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
    -- self:SetScript("OnUpdate", function(self, elapsed)
    --     timeSinceLastUpdate = timeSinceLastUpdate + elapsed

    --     if timeSinceLastUpdate >= updateInterval then
    --         InitStat()
    --         timeSinceLastUpdate = 0
    --     end
    -- end)
end)
