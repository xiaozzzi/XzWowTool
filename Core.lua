local _, ns = ...


-- 更新间隔, 监听玩家属性
local updateInterval = 3 -- 每1秒更新一次
local timeSinceLastUpdate = 0

-- 初始化通用命令
local function InitCommonCmd()
  -- 显示套装标签
  EventUtil.ContinueOnAddOnLoaded("Blizzard_EncounterJournal",
    function()
      EncounterJournal:HookScript("OnShow",
        function(self)
          PanelTemplates_SetAllTabsShown(self, true)
          PanelTemplates_SetNumTabs(self, #self.Tabs)
        end)
    end)
end

-------------------------------------------------------------------------------------------------------------
-- 监听
-------------------------------------------------------------------------------------------------------------
local XzFrame = CreateFrame("Frame", "XzFrame", UIParent, "DialogBoxFrame")
XzFrame:RegisterEvent("ADDON_LOADED")            -- 加载插件
XzFrame:RegisterEvent("BAG_UPDATE_DELAYED")      -- 背包更新
XzFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE") -- 货币变更
XzFrame:RegisterEvent("PLAYER_LOGIN")            -- 角色登录
XzFrame:Show()

XzFrame:SetScript("OnEvent", function(self, event, unit, ...)
  if event == "ADDON_LOADED" and unit == 'XzWowTool' then
    InitConfigDB()
    InitWoodTrack()
  elseif event == 'PLAYER_LOGIN' then
    self:UnregisterEvent("PLAYER_LOGIN")
    InitConfigDB()
    InitCurrencyTrack()
    InitCommonCmd()
  elseif event == "BAG_UPDATE_DELAYED" then
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

-- 命令开启
SLASH_XZWT1 = "/xzwt"
SlashCmdList["XZWT"] = function(arg1)
  TriggerFrame()
end
