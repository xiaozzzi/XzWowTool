--·········································································································
--
-- 套装幻化总览
--
--·········································································································
UI_Transmog = {}

local COL_WIDTH = 188
local COL_ALIGN = "CENTER"
local IMAGE_SIZE = 18
local ICON_SIZE = 18

--#region 打印团本套装

local DEBUG_DESC_ORDER = {
  ["随机团队"] = 1,
  ["普通"] = 2,
  ["英雄"] = 3,
  ["史诗"] = 4,
}

local DEBUG_RAID_NAME = "恐惧之心"

local function DescRank(desc)
  return DEBUG_DESC_ORDER[desc] or 999
end

local function DebugSets()
  local setInfo = C_TransmogSets.GetAllSets()
  -- 对结果进行排序
  table.sort(setInfo, function(a, b)
    -- 1. 先按 classMask
    if a.classMask ~= b.classMask then
      return a.classMask < b.classMask
    end
    -- 2. classMask 相同，按 description 的枚举顺序
    return DescRank(a.description) < DescRank(b.description)
  end)

  for index, value in ipairs(setInfo) do
    if value.label == DEBUG_RAID_NAME then
      local str = string.format(
        "{LABEL = \"%s\", SET_ID = %s, NAME = \"%s\", DESCRIPTION = \"%s\", CLASS_MASK = %s},",
        value.label, value.setID, value.name, value.description, value.classMask)
      print(str)
    end
  end
end

-- DebugSets()
-- #endregion

local function GetByClassMask(data, mask)
  local out = {}
  for _, entry in ipairs(data) do
    if entry.CLASS_MASK == mask then
      out[#out + 1] = entry
    end
  end
  return out
end

-- 检查套装收集情况
local function CheckSetCollectionStatus(setID)
  local appearances = C_TransmogSets.GetSetPrimaryAppearances(setID)
  if not appearances then
    return
  end

  local result = {}

  for i, appearance in ipairs(appearances) do
    local info = C_TransmogCollection.GetAppearanceSourceInfo(appearance.appearanceID)
    --
    -- local status = appearance.collected and "已收集" or "未收集"
    -- print(string.format("%s | %d(%d) | %s | %s", TRANSMOG_SLOT_NAMES[info.category], appearance.appearanceID,
    --   info.itemAppearanceID,
    --   status, info.icon))
    --
    table.insert(result, {
      category = info.category,               -- 部位
      appearanceID = appearance.appearanceID, -- 外观ID
      itemAppearanceID = info.itemAppearanceID,
      collected = appearance.collected,       -- 收集
      icon = info.icon,                       -- 图标
      itemLink = info.itemLink,
      transmoglink = info.transmoglink,       -- 外观中的链接, 使用该链接可以在外观页面中查看
    })
    table.sort(result, function(a, b)
      return a.category < b.category -- 数字直接比大小
    end)
  end
  return result
end

local RAID_DROPDOWN                                -- 团本下拉列表
local RAID_DROPDOWN_VALUE = TRANSMOG_SETS[1].LABEL -- 团本下拉列表默认值
local CB_SHOWTIP                                   -- 显示鼠标提示
local CB_CLICKTRYON                                -- 单击试穿
local SCROLL_FRAME                                 -- 滚动框架

-- 试穿外观
local function DressTryOn(itemLink)
  if InCombatLockdown() then return end
  if not CB_CLICKTRYON:GetValue() then return end
  if not itemLink then return end
  DressUpItemLink(itemLink)
end

-- 创建试穿全部图标
local function DressTryOnAllIcon(simpleGroup, itemLinks, appearanceCount)
  local icon = AceGUI:Create("Icon")
  icon:SetImageByAtlas("lootroll-toast-icon-transmog-up")
  icon:SetImageSize(IMAGE_SIZE, IMAGE_SIZE)
  icon:SetWidth(ICON_SIZE)
  icon:SetHeight(ICON_SIZE)
  icon.image:ClearAllPoints()
  icon.image:SetPoint("CENTER", icon.frame, "CENTER", 4, 0)
  icon.image:SetAlpha(0.2)
  icon:SetCallback("OnEnter", function(widget)
    icon.image:SetAlpha(1)
  end)
  icon:SetCallback("OnLeave", function(widget)
    icon.image:SetAlpha(0.2)
  end)
  icon:SetCallback("OnClick", function(widget, button)
    if InCombatLockdown() then return end
    -- print("试穿全部: ")
    for i, itemLink in ipairs(itemLinks) do
      if itemLink == '[]' then
        -- print("套装外观正在加载中, 尝试切换副本后重试")
      else
        -- print(" - " .. itemLink)
      end
      DressTryOn(itemLink)
    end
  end)
  simpleGroup:AddChild(icon)
  -- 如果套装数量不足9个, 在末尾添加占位符以换行
  if appearanceCount < 9 then
    for i = 1, 9 - appearanceCount, 1 do
      GUI:Spacing(simpleGroup, ICON_SIZE)
    end
  end
end

local function DrawSet()
  GUI:EmptyLine(SCROLL_FRAME, 1)
  for index, sets in ipairs(TRANSMOG_SETS) do
    -- 只显示选中的团本套装
    if (RAID_DROPDOWN_VALUE == sets.LABEL) then
      if not sets.SETS then
        return
      end

      local order = sets.BY_ARMOR and TRANSMOG_ARMOR_MASK_MASK_ORDER or TRANSMOG_CLASS_MASK_ORDER

      -- 职业
      for _, classMask in ipairs(order) do
        local classSets = GetByClassMask(sets.SETS, classMask) -- 获取套装
        local class = TRANSMOG_CLASS_MASK[classMask]           -- 职业或护甲类型

        -- 同甲同模型
        -- if sets.BY_ARMOR then
        -- else
        -- 按职业
        if class.CLASS_FILE_NAME == "WARLOCK" or class.CLASS_FILE_NAME == "CLOTH" then
          GUI:Label(SCROLL_FRAME, "布", 40, "CENTER")
        elseif class.CLASS_FILE_NAME == "ROGUE" or class.CLASS_FILE_NAME == "LEATHERED" then
          GUI:EmptyLine(SCROLL_FRAME, 3)
          GUI:Label(SCROLL_FRAME, "皮", 40, "CENTER")
        elseif class.CLASS_FILE_NAME == "HUNTER" or class.CLASS_FILE_NAME == "MAIL" then
          GUI:EmptyLine(SCROLL_FRAME, 3)
          GUI:Label(SCROLL_FRAME, "锁", 40, "CENTER")
        elseif class.CLASS_FILE_NAME == "WARRIOR" or class.CLASS_FILE_NAME == "PLATE" then
          GUI:EmptyLine(SCROLL_FRAME, 3)
          GUI:Label(SCROLL_FRAME, "板", 40, "CENTER")
        end
        -- end
        GUI:Spacing(SCROLL_FRAME, 8)

        -- 套装 group
        local simpleGroup = GUI:SimpleGroup(SCROLL_FRAME, false)
        simpleGroup:SetWidth(COL_WIDTH)

        -- 不是同甲同模型的套装, 显示职业名称
        if not sets.BY_ARMOR then
          GUI:Label(simpleGroup, format("|c%s%s|r",
              C_ClassColor.GetClassColor(class.CLASS_FILE_NAME):GenerateHexColor(), class.NAME), COL_WIDTH,
            "CENTER")
        end

        -- 套装级别: 随机/普通/英雄/史诗
        for index, set in ipairs(classSets) do
          local appearances = CheckSetCollectionStatus(set.SET_ID)
          local appearanceCount = set.COUNT or 9
          -- 如果有外观
          if appearances then
            local sjItemLink = {}
            local ptItemLink = {}
            local yxItemLink = {}
            local ssItemLink = {}
            for index, appearance in ipairs(appearances) do
              -- 创建部位图标
              local icon = AceGUI:Create("Icon")
              icon:SetImage(appearance.icon)
              icon:SetImageSize(IMAGE_SIZE, IMAGE_SIZE) -- 设置图标显示尺寸
              icon:SetWidth(ICON_SIZE)
              icon:SetHeight(ICON_SIZE)
              icon.image:ClearAllPoints()
              icon.image:SetPoint("CENTER", icon.frame, "CENTER", 0, 0)
              icon:SetCallback("OnEnter", function(widget)
                if not CB_SHOWTIP:GetValue() then return end
                GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(appearance.itemLink)
                GameTooltip:Show()
              end)
              icon:SetCallback("OnLeave", function(widget)
                GameTooltip:Hide()
              end)
              icon:SetCallback("OnClick", function(widget, button)
                DressTryOn(appearance.itemLink)
              end)
              if not appearance.collected then
                icon.image:SetVertexColor(0, 0, 0, 1)
              end
              simpleGroup:AddChild(icon)

              -- 记录套装链接
              if (math.floor((index - 1) / appearanceCount) + 1 == 1) then
                table.insert(sjItemLink, appearance.itemLink)
              elseif (math.floor((index - 1) / appearanceCount) + 1 == 2) then
                table.insert(ptItemLink, appearance.itemLink)
              elseif (math.floor((index - 1) / appearanceCount) + 1 == 3) then
                table.insert(yxItemLink, appearance.itemLink)
              elseif (math.floor((index - 1) / appearanceCount) + 1 == 4) then
                table.insert(ssItemLink, appearance.itemLink)
              end

              -- 创建试穿全部的按钮
              if (index == appearanceCount) then
                DressTryOnAllIcon(simpleGroup, sjItemLink, appearanceCount)
              elseif index == appearanceCount * 2 then
                DressTryOnAllIcon(simpleGroup, ptItemLink, appearanceCount)
              elseif index == appearanceCount * 3 then
                DressTryOnAllIcon(simpleGroup, yxItemLink, appearanceCount)
              elseif index == appearanceCount * 4 then
                DressTryOnAllIcon(simpleGroup, ssItemLink, appearanceCount)
              end
            end
          end
        end
        GUI:Spacing(SCROLL_FRAME, 1)
      end
    end
  end
end

function UI_Transmog:Draw(container)
  GUI:Label(container, "团本：", 40, "LEFT")

  -- 团本下拉列表
  local raids = {}
  local raidsOrder = {}
  for _, sets in ipairs(TRANSMOG_SETS) do
    raids[sets.LABEL] = sets.LABEL
    table.insert(raidsOrder, sets.LABEL)
  end
  RAID_DROPDOWN = GUI:Dropdown(container, raids, raidsOrder, TRANSMOG_SETS[1].LABEL, 250)
  RAID_DROPDOWN:SetCallback("OnValueChanged", function(a, b, key)
    RAID_DROPDOWN_VALUE = key
    SCROLL_FRAME:ReleaseChildren()
    DrawSet()
  end)

  -- 显示装备提示
  GUI:Spacing(container, 10)
  CB_SHOWTIP = GUI:CheckBox(container, "鼠标提示", false, 90)
  GUI:Spacing(container, 10)
  CB_CLICKTRYON = GUI:CheckBox(container, "单击试穿", true, 90)
  GUI:Spacing(container, 10)

  GUI:Heading(container, "", 0, 0)

  SCROLL_FRAME = GUI:ScrollMain(container)
  DrawSet()
end
