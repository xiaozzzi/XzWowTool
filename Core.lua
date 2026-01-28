local _, ns = ...

AceGUI = LibStub("AceGUI-3.0")

local XzFrame = CreateFrame("Frame", "XzFrame", UIParent, "DialogBoxFrame")
XzFrame:RegisterEvent("ADDON_LOADED")
XzFrame:RegisterEvent("BAG_UPDATE_DELAYED")
XzFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
XzFrame:Show()

local classFileName = UnitClass("player")

local function isDruid()
    return classFileName == "DRUID"
end

XzFrame:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "ADDON_LOADED" and unit == 'XzWowTool' then
        if isDruid() then
            InitWoodTrack()
        end
        InitCurrencyTrack()
    elseif event == "BAG_UPDATE_DELAYED" and isDruid() then
        UpdWoodTrack()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        UpdCurrencyTrack(unit)
    end
end)
