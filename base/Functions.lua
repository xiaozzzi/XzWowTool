-------------------------------------------------------------------------------------------------------------
-- Blizzard Lua Api
-- [Documentation](https://warcraft.wiki.gg/wiki/Lua_functions)
-------------------------------------------------------------------------------------------------------------

---====================================================================================
---当前用户是否 [获取] or [完成] 本周丰裕藏宝图
---@return boolean 是否完成
---====================================================================================
function IsCompletedDelveBountyMap()
  return C_QuestLog.IsQuestFlaggedCompleted(86371)
end

---====================================================================================
---从背包和仓库中获取物品数量
---@param itemID number 物品ID
---@return number 物品数量
---====================================================================================
function GetItemCountFromAll(itemID)
  return C_Item.GetItemCount(itemID, true, false)
end

function SecondsToHMS(seconds)
  -- 确保输入为整数
  seconds = math.floor(tonumber(seconds) or 0)
  -- 计算时分秒
  local hours = math.floor(seconds / 3600)
  local remainder = seconds % 3600
  local minutes = math.floor(remainder / 60)
  local seconds = remainder % 60
  -- 格式化为两位数
  return string.format("%02d:%02d", minutes, seconds)
end

-- 获取显示隐藏状态
function GetShowHide(value)
  return value and "SHOW" or "HIDE"
end
