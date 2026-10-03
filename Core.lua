local addonName, ns = ...

-- 初始化通用命令
local function InitCommonCmd()
  -- 隐藏玩家信息框
  PlayerFrame:Hide()
  -- 显示套装标签
  EventUtil.ContinueOnAddOnLoaded("Blizzard_EncounterJournal",
    function()
      EncounterJournal:HookScript("OnShow",
        function(self)
          PanelTemplates_SetAllTabsShown(self, true)
          PanelTemplates_SetNumTabs(self, #self.Tabs)
        end)
    end)
  -- 放大任务追踪器
  ObjectiveTrackerFrame:SetScale(1.2)
end

-------------------------------------------------------------------------------------------------------------
-- 监听
-------------------------------------------------------------------------------------------------------------
local XzFrame = CreateFrame("Frame", "XzFrame", UIParent, "DialogBoxFrame")
XzFrame:RegisterEvent("ADDON_LOADED")            -- 加载插件
XzFrame:RegisterEvent("BAG_UPDATE_DELAYED")      -- 背包更新
XzFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE") -- 货币变更
XzFrame:RegisterEvent("PLAYER_LOGIN")            -- 角色登录
XzFrame:RegisterEvent("GROUP_ROSTER_UPDATE")     -- 群组成员变更

XzFrame:SetScript("OnEvent", function(self, event, unit, ...)
  if event == "ADDON_LOADED" and unit == 'XzWowTool' then
    GLOBAL_CONFIG:InitConfigDB()  -- 初始化公共配置表
    CONFIG:InitConfigDB()         -- 初始化配置表
    InitWoodTrack()               -- 初始化木材监控
    DM:CreateWindowHeightButton() -- 创建快速切换伤害列表类型的按钮
  elseif event == 'PLAYER_LOGIN' then
    self:UnregisterEvent("PLAYER_LOGIN")
    GLOBAL_CONFIG:InitConfigDB() -- 初始化公共配置表
    CONFIG:InitConfigDB()        -- 初始化配置数据库
    InitCurrencyTrack()          -- 初始化货币跟踪
    InitCommonCmd()              -- 初始化通用命令
    InitCommonButton()           -- 初始化通用按钮
    DM:SetWindowHeightByRaid()   -- 初始化伤害列表窗口位置
  elseif event == "BAG_UPDATE_DELAYED" then
    UpdWoodTrack()
  elseif event == "CURRENCY_DISPLAY_UPDATE" then
    UpdCurrencyTrack(unit)
  end

  if event == "GROUP_ROSTER_UPDATE" then
    DM:SetWindowHeightByRaid()
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
  OpenXZWTMainFrame()
end
