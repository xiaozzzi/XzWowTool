CONFIG = {}

if XZ_CONFIG_DB == nil then
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

-- 默认配置项，集中管理
local DEFAULT_OPTIONS = {
  SHOW_WOOD = 'HIDE',                     -- 是否显示木材
  SHOW_CURRENCY = 'SHOW',                 -- 是否显示货币
  SHOW_BTN_MACRO_DELVE = 'HIDE',          -- 是否显示地下堡按钮
  SHOW_BTN_THE_GREAT_VAULT = 'HIDE',      -- 是否显示宏伟宝库
  SHOW_BTN_CRAFTING = 'HIDE',             -- 是否显示制作模拟
  SHOW_BTN_WAR_BAND_BANK = 'SHOW',        -- 是否显示战团银行
  SHOW_BTN_MAIL_BOX = 'SHOW',             -- 是否显示邮件
  SHOW_BTN_THE_ARCANTINA = 'SHOW',        -- 是否显示奥术秘社
  SHOW_BTN_HEARTH_STONE = 'SHOW',         -- 是否显示炉石
  HEARTH_STONE = 265100,                  -- 默认炉石
  SHOW_BTN_MOUNT_YAK = 'SHOW',            -- 是否显示炉石
  SHOW_BTN_MOUNT_FUNGAL_STRIDER = 'SHOW', -- 是否显示真菌行者
  SHOW_BTN_FLY_MODE = 'SHOW',             -- 是否显示飞行模式
  SHOW_BTN_PROF1 = 'SHOW',                -- 是否显示专业1
  SHOW_BTN_PROF2 = 'SHOW',                -- 是否显示专业2
  SHOW_BTN_DELVE7001 = 'SHOW',            -- 是否显示地下堡机器人7001型
}

--- 获取角色配置
--- @param unitGUID stringView 用户ID
--- @return table|nil
function CONFIG:GetByUnitGUID(unitGUID)
  return XZ_CONFIG_DB[unitGUID]
end

--- 获取指定配置
--- @param unitGUID stringView 用户ID
--- @param key string  配置键
--- @return string|nil 配置值
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
  local player = XZ_CONFIG_DB[unitGUID]
  if player then
    player[key] = value
  end
end

local function AddPlayerToDB()
  local unitGUID = UnitGUID("player")
  if unitGUID == nil then
    return
  end

  local player = XZ_CONFIG_DB[unitGUID] -- 已有配置（可能为 nil）
  local className, classFilename, classId = UnitClass("player")
  local unitName, realm = UnitFullName("player")

  -- 基础信息
  local config = {
    classFilename = classFilename,                                 -- 职业
    classFilenameSort = CLASS_FILENAME_SORT[classFilename] or 999, -- 职业排序
    unitName = unitName,                                           -- 角色名称
    realm = realm,                                                 -- 服务器
    unitGUID = unitGUID,                                           -- 用户ID
  }

  -- 合并默认配置与已有配置
  for key, defaultValue in pairs(DEFAULT_OPTIONS) do
    if player and player[key] ~= nil then
      config[key] = player[key]
    else
      config[key] = defaultValue
    end
  end

  XZ_CONFIG_DB[unitGUID] = config
end

function CONFIG:InitConfigDB()
  AddPlayerToDB()
end
