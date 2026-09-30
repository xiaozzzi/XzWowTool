--·········································································································
--
-- 为团队列表添加团长图标和目标标记
-- 参考插件 RaidLeaderMarker
--
--·········································································································
local _, addon = ...

-- 仅用在正式服
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  return
end

local LEADER_ICON_TEXTURE = "Interface\\GroupFrame\\UI-Group-LeaderIcon" -- 老版团长图标
local LEADER_ICON_ATLAS = "plunderstorm-glues-icon-leader"               -- 清晰的团长图标 atlas 图标

LEADER_ICON_CONFIG = {
  enabled = true,
  anchor = "TOPRIGHT",
  offsetX = -5,
  offsetY = 0,
  size = 18,
}

TARGET_MARKER_CONFIG = {
  enabled = true,
  anchor = "TOPRIGHT",
  offsetX = -25,
  offsetY = 0,
  size = 16,
}

local RLFrame = CreateFrame("Frame")

local leaderIcons = {}
local markerIcons = {}

--- 更新图标位置
--- @param icon Texture 图标
--- @param frame Frame  图标所属的玩家框架
--- @param config table 图标配置
local function UpdateIcon(icon, frame, config)
  if not icon or not frame then
    return
  end
  local anchor = config.anchor or "CENTER"
  local size = config.size or 16
  local offsetX = config.offsetX or 0
  local offsetY = config.offsetY or 0

  icon:SetSize(size, size)
  icon:ClearAllPoints()
  icon:SetPoint("CENTER", frame, anchor, offsetX, offsetY)
end

--- 创建图标
--- @param frame Frame 图标所属框架
--- @param iconTable table 图标缓存
--- @param texture string|nil 图标纹理
--- @param atlas string|nil atlas 图标(优先使用)
--- @return Texture|nil
local function CreateIcon(frame, iconTable, texture, atlas)
  if not frame then
    return nil
  end

  if iconTable[frame] then
    return iconTable[frame]
  end

  local icon = frame:CreateTexture(nil, "OVERLAY")
  if atlas then
    icon:SetAtlas(atlas)
  elseif texture then
    icon:SetTexture(texture)
  end
  icon:Hide()

  iconTable[frame] = icon
  return icon
end

--- 隐藏所有图标
local function ClearAllIcons()
  for _, icon in pairs(leaderIcons) do
    icon:Hide()
  end
  for _, icon in pairs(markerIcons) do
    icon:Hide()
  end
end

--- 收集所有图标所属框架
local function CollectFrames()
  local frames = {}

  -- 小队成员
  -- 8个小队, 每个小队5个成员
  for groupIndex = 1, 8 do
    for memberIndex = 1, 5 do
      local frame = _G["CompactRaidGroup" .. groupIndex .. "Member" .. memberIndex]
      if frame then
        frames[#frames + 1] = frame
      end
    end
  end

  -- Compact Raid Frames
  for i = 1, 40 do
    local frame = _G["CompactRaidFrame" .. i]
    if frame then
      frames[#frames + 1] = frame
    end
  end

  -- Compact Party Frames
  for i = 1, 5 do
    local frame = _G["CompactPartyFrameMember" .. i]
    if frame then
      frames[#frames + 1] = frame
    end
  end

  return frames
end

--- 更新UI
local function UpdateRaidMarker()
  ClearAllIcons()

  -- if not IsInGroup() then
  --   return
  -- end

  local frames = CollectFrames()

  -- 遍历所有玩家框架
  for _, frame in ipairs(frames) do
    local unit = frame.unit

    -- 检查单位是否存在且是否在团队中
    if unit and UnitExists(unit) then
      -- 如果单位是队长/团长
      if LEADER_ICON_CONFIG.enabled and UnitIsGroupLeader(unit) then
        local leaderIcon = CreateIcon(frame, leaderIcons, nil, LEADER_ICON_ATLAS)
        if leaderIcon then
          leaderIcon:Show()
          UpdateIcon(leaderIcon, frame, LEADER_ICON_CONFIG)
        end
      end

      -- Target marker icon
      -- 创建团队标记图标
      if TARGET_MARKER_CONFIG.enabled then
        local markerIcon = CreateIcon(frame, markerIcons, nil, nil)
        if markerIcon then
          -- 返回某个单位的图标
          -- https://warcraft.wiki.gg/wiki/API:GetRaidTargetIndex
          local markerIndex = GetRaidTargetIndex(unit)
          if markerIndex then
            markerIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
            SetRaidTargetIconTexture(markerIcon, markerIndex);
            markerIcon:Show()
            UpdateIcon(markerIcon, frame, TARGET_MARKER_CONFIG)
          else
            markerIcon:Hide()
          end
        end
      end
    end
  end
end

addon.UpdateRaidMarker = UpdateRaidMarker

RLFrame:RegisterEvent("ADDON_LOADED")
RLFrame:RegisterEvent("PLAYER_LOGIN")
RLFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
RLFrame:RegisterEvent("PARTY_LEADER_CHANGED")
RLFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RLFrame:RegisterEvent("RAID_TARGET_UPDATE") -- 玩家的标记变化时触发

RLFrame:SetScript("OnEvent", function(self, event, ...)
  UpdateRaidMarker()
end)
