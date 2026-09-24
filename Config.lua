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

  local SHOW_WOOD = 'HIDE'
  if player ~= nil and player.SHOW_WOOD ~= nil then
    SHOW_WOOD = player.SHOW_WOOD
  end
  local SHOW_CURRENCY = 'SHOW'
  if player ~= nil and player.SHOW_CURRENCY ~= nil then
    SHOW_CURRENCY = player.SHOW_CURRENCY
  end
  local SHOW_BTN_MACRO_DELVE = 'HIDE'
  if player ~= nil and player.SHOW_BTN_MACRO_DELVE ~= nil then
    SHOW_BTN_MACRO_DELVE = player.SHOW_BTN_MACRO_DELVE
  end
  local SHOW_BTN_THE_GREAT_VAULT = 'HIDE'
  if player ~= nil and player.SHOW_BTN_THE_GREAT_VAULT ~= nil then
    SHOW_BTN_THE_GREAT_VAULT = player.SHOW_BTN_THE_GREAT_VAULT
  end
  local SHOW_BTN_CRAFTING = 'HIDE'
  if player ~= nil and player.SHOW_BTN_CRAFTING ~= nil then
    SHOW_BTN_CRAFTING = player.SHOW_BTN_CRAFTING
  end
  local SHOW_BTN_WAR_BAND_BANK = 'SHOW'
  if player ~= nil and player.SHOW_BTN_WAR_BAND_BANK ~= nil then
    SHOW_BTN_WAR_BAND_BANK = player.SHOW_BTN_WAR_BAND_BANK
  end
  local SHOW_BTN_MAIL_BOX = 'SHOW'
  if player ~= nil and player.SHOW_BTN_MAIL_BOX ~= nil then
    SHOW_BTN_MAIL_BOX = player.SHOW_BTN_MAIL_BOX
  end
  local SHOW_BTN_THE_ARCANTINA = 'SHOW'
  if player ~= nil and player.SHOW_BTN_THE_ARCANTINA ~= nil then
    SHOW_BTN_THE_ARCANTINA = player.SHOW_BTN_THE_ARCANTINA
  end
  local SHOW_BTN_HEARTH_STONE = 'SHOW'
  if player ~= nil and player.SHOW_BTN_HEARTH_STONE ~= nil then
    SHOW_BTN_HEARTH_STONE = player.SHOW_BTN_HEARTH_STONE
  end
  -- 炉石
  local HEARTH_STONE = 265100
  if player ~= nil and player.HEARTH_STONE ~= nil then
    HEARTH_STONE = player.HEARTH_STONE
  end

  local config = {
    classFilename = classFilename,                       -- 职业
    classFilenameSort = CLASS_FILENAME_SORT[classFilename] or 999,
    unitName = unitName,                                 -- 角色名
    realm = realm,                                       -- 服务器
    unitGUID = unitGUID,                                 -- 用户ID
    HEARTH_STONE = HEARTH_STONE,                         -- 炉石
    SHOW_WOOD = SHOW_WOOD,                               -- 是否显示木材
    SHOW_CURRENCY = SHOW_CURRENCY,                       -- 是否显示纹章
    SHOW_BTN_MACRO_DELVE = SHOW_BTN_MACRO_DELVE,         -- 是否显示地下堡宏
    SHOW_BTN_THE_GREAT_VAULT = SHOW_BTN_THE_GREAT_VAULT, -- 是否显示宏伟宝库
    SHOW_BTN_CRAFTING = SHOW_BTN_CRAFTING,               -- 是否显示制造业模拟
    SHOW_BTN_WAR_BAND_BANK = SHOW_BTN_WAR_BAND_BANK,     -- 是否显示战团银行
    SHOW_BTN_MAIL_BOX = SHOW_BTN_MAIL_BOX,               -- 是否显示邮件
    SHOW_BTN_THE_ARCANTINA = SHOW_BTN_THE_ARCANTINA,     -- 是否显示奥术秘社
    SHOW_BTN_HEARTH_STONE = SHOW_BTN_HEARTH_STONE,       -- 是否显示炉石
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
