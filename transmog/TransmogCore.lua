local appearanceToSlot = {}

local function GetSlotFromAppearance(appearance)
  local sources = C_TransmogCollection.GetAppearanceSources(appearance.appearanceID)
  if not sources then
    print("未找到外观ID " .. appearance.appearanceID .. " 的来源信息。")
    return nil
  else
    DevTools_Dump(sources)
  end

  -- for i, value in pairs(itemModifiedAppearanceIDs) do
  --   print(i, value)
  --   if value then
  local info = C_TransmogCollection.GetAppearanceSourceInfo(value)
  --     print(info.category, info.itemAppearanceID, info.icon)
  --   end
  -- end
end

function CheckSetCollectionStatus(setID)
  local appearances = C_TransmogSets.GetSetPrimaryAppearances(setID)
  if not appearances then
    print("未找到该套装或该套装无外观信息。")
    return
  end

  print("开始检查套装 (ID: " .. setID .. ") 的收集情况：")
  for i, appearance in ipairs(appearances) do
    -- 直接使用返回数据中的 collected 字段
    local status = appearance.collected and "已收集" or "未收集"
    local info = C_TransmogCollection.GetAppearanceSourceInfo(appearance.appearanceID)
    print(string.format("%s | %d(%d) | %s | %s", TRANSMOG_SLOT_NAMES[info.category], appearance.appearanceID,
      info.itemAppearanceID,
      status, info.icon))
  end
end

local function debugSets()
  local setInfo = C_TransmogSets.GetAllSets()
  for index, value in ipairs(setInfo) do
    if value.label == '烈毒之渊' then
      print(value.setID, value.name, value.description, value.label, value.patchID, value.classMask)
    end
  end
end

function InitTransmog()
  -- for slot = 1, 19 do
  --   local sources = C_TransmogSets.GetSourcesForSlot(5884, slot)
  --   if sources then
  --     for _, source in ipairs(sources) do
  --       print(source.categoryID, source.visualID, source.isCollected, source.name)
  --       if source.visualID then
  --         appearanceToSlot[source.visualID] = SLOT_NAMES[source.categoryID] or ("槽位" .. slot)
  --       end
  --     end
  --   end
  -- end

  CheckSetCollectionStatus(5884)
end
