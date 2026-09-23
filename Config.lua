CONFIG = {}

if not XZ_CONFIG_DB or XZ_CONFIG_DB == nil then
  XZ_CONFIG_DB = {}
end

local CLASS_FILENAME_SORT = {
  ['WARLOCK'] = 11,
  ['PRIEST'] = 12,
  ['MAGE'] = 13,
  -- 皮
  ['ROGUE'] = 21,
  ['DEMONHUNTER'] = 22,
  ['MONK'] = 23,
  ['DRUID'] = 23,
  -- 锁
  ['HUNTER'] = 31,
  ['SHAMAN'] = 32,
  ['EVOKER'] = 33,
  -- 板
  ['WARRIOR'] = 41,
  ['DEATHKNIGHT'] = 42,
  ['PALADIN'] = 43,
}

--- 获取角色配置
--- @param unitGUID stringView 用户ID
--- @return table
function CONFIG:GetByUnitGUID(unitGUID)
  return XZ_CONFIG_DB[unitGUID]
end

--- 获取指定配置
--- @param unitGUID stringView 用户ID
--- @param key stringView 配置键
--- @return stringView 配置值
function CONFIG:GetValue(unitGUID, key)
  local player = CONFIG:GetByUnitGUID(unitGUID)
  if player == nil then
    return nil
  end
  return player[key]
end

--- 获取全部角色配置, 按 classFilenameSort 升序排序
--- @return table
function CONFIG:GetAllPlayers()
  local sortedList = {}
  for guid, charData in pairs(XZ_CONFIG_DB) do
    table.insert(sortedList, charData)
  end
  table.sort(sortedList, function(a, b)
    return a.classFilenameSort < b.classFilenameSort
  end)
  return sortedList
end

--- 保存角色配置
--- @param player table 角色配置
function CONFIG:SaveConfig(player)
  XZ_CONFIG_DB[player.unitGUID] = player
end

--- 保存指定配置
--- @param unitGUID stringView 用户ID
--- @param key stringView 配置键
--- @param value stringView 配置值
function CONFIG:SaveConfigValue(unitGUID, key, value)
  XZ_CONFIG_DB[unitGUID][key] = value
end

function AddPlayerToDB()
  local unitGUID = UnitGUID("player")
  if unitGUID == nil then
    return
  end
  local player = CONFIG:GetByUnitGUID(unitGUID)
  local className, classFilename, classId = UnitClass("player")
  local unitName, realm = UnitFullName("player")

  local showWood = 'HIDE'
  if player ~= nil then
    showWood = player.showWood
  end
  local showCurrency = 'SHOW'
  if player then
    showCurrency = player.showCurrency
  end

  local config = {
    classFilename = classFilename, -- 职业
    classFilenameSort = CLASS_FILENAME_SORT[classFilename] or 999,
    unitName = unitName,           -- 角色名
    realm = realm,                 -- 服务器
    unitGUID = unitGUID,           -- 用户ID
    showWood = showWood,           -- 是否显示木材
    showCurrency = showCurrency,   -- 是否显示纹章
  }

  XZ_CONFIG_DB[unitGUID] = config
end

function InitConfigDB()
  -- 初始化数据表
  if not XZ_CONFIG_DB or XZ_CONFIG_DB == nil then
    XZ_CONFIG_DB = {}
  end
  AddPlayerToDB()
end
