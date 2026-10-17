--·········································································································
--
-- 反向排列团队
-- [暂时作废]
--
--·········································································································
-- 极简反向排列：固定容器锚点 + 编辑模式保护 + 仅治疗
local container = CompactRaidFrameContainer

local CUR_LAYOUT_NAME = nil -- 当前布局名称

-- 布局是否是以 "奶妈" 或 "治疗" 开头
local function IsHealerLayout()
  if not CUR_LAYOUT_NAME then return false end
  local isHealer = CUR_LAYOUT_NAME:sub(1, #"奶妈") == "奶妈" or CUR_LAYOUT_NAME:sub(1, #"治疗") == "治疗"
  return isHealer
end

-- 固定整个团队框架的位置
local function SetContainerPosition()
  if InCombatLockdown() or not container then return end
  if not IsHealerLayout() then return end
  container:ClearAllPoints()
  container:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -1200, -600)
end

-- 核心排序与排列
local function UpdateRaidFrames()
  if InCombatLockdown() or not container then return end
  if not IsHealerLayout() then return end

  local groups = {}
  for i = 1, 8 do
    local group = _G["CompactRaidGroup" .. i]
    if group and group:IsShown() then
      groups[#groups + 1] = group
    end
  end

  table.sort(groups, function(a, b)
    local numA = tonumber(a:GetName():match("%d+$")) or 0
    local numB = tonumber(b:GetName():match("%d+$")) or 0
    return numA < numB
  end)

  local currentX = 0
  for _, group in ipairs(groups) do
    group:ClearAllPoints()
    group:SetPoint("TOPRIGHT", container, "TOPRIGHT", -currentX, 0)
    currentX = currentX + group:GetWidth()
  end
end

local function HookLayout()
  if CompactRaidFrameContainer_LayoutFrames then
    hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", UpdateRaidFrames)
  end
  if container and container.Layout then
    hooksecurefunc(container, "Layout", UpdateRaidFrames)
  end
end

-- 编辑模式开启时执行
EventRegistry:RegisterCallback("EditMode.Enter", function()
  print("编辑模式已开启")
  SetContainerPosition()
end, "XzWowTool")

-- 编辑模式关闭时执行
EventRegistry:RegisterCallback("EditMode.Exit", function()
  print("编辑模式已关闭")
  SetContainerPosition()
end, "XzWowTool")

-- 事件驱动
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
-- f:RegisterEvent("GROUP_ROSTER_UPDATE")    -- 团队成员变更
-- f:RegisterEvent("PLAYER_REGEN_ENABLED")   -- 玩家离开战斗
f:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED") -- 应用或者更改布局

f:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
  if event == "EDIT_MODE_LAYOUTS_UPDATED" then
    -- 布局的名称, 从 2 开始，1为现代(预设), 2为经典(预设)
    CUR_LAYOUT_NAME = arg1.layouts[arg1.activeLayout - 2].layoutName
    -- print(GUI:ColorText("FF00FF00", "当前布局为: " .. CUR_LAYOUT_NAME))
  end

  C_Timer.After(1.5, function()
    SetContainerPosition()
    UpdateRaidFrames()
  end)
end)

-- 初始化
C_Timer.After(1, function()
  SetContainerPosition()
  HookLayout()
  UpdateRaidFrames()
end)
