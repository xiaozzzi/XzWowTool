GLOBAL_CONFIG = {}

if not XZ_GLOBAL_DB or XZ_GLOBAL_DB == nil then
  XZ_GLOBAL_DB = {}
end

GLOBAL_DEFAULT_OPTIONS = {
  HOTKEY_FONT_SIZE = 18,
  DAMAGE_METER_HIGHT_SIZE = 450,
  DAMAGE_METER_MIDDLE_SIZE = 300,
  DAMAGE_METER_LOW_SIZE = 150,
  UNIT_PET_SIZE_X = 200,
  UNIT_PET_SIZE_Y = 30,
  UNIT_PET_POINT_X = 578,
  UNIT_PET_POINT_Y = 348,
}

--- 获取指定配置
--- @param key string  配置键
--- @return string|nil 配置值
function GLOBAL_CONFIG:GetValue(key)
  local value = XZ_GLOBAL_DB[key]
  if value == nil then
    return nil
  end
  return value
end

--- 保存配置
--- @param key stringView 配置键
--- @param value stringView 配置值
function GLOBAL_CONFIG:SaveValue(key, value)
  XZ_GLOBAL_DB[key] = value
end

local function AddPlayerToDB()
  -- 合并默认配置与已有配置
  for key, defaultValue in pairs(GLOBAL_DEFAULT_OPTIONS) do
    if XZ_GLOBAL_DB[key] == nil then
      XZ_GLOBAL_DB[key] = defaultValue
    end
  end
end

function GLOBAL_CONFIG:InitConfigDB()
  -- 初始化数据表
  if not XZ_GLOBAL_DB or XZ_GLOBAL_DB == nil then
    XZ_GLOBAL_DB = {}
  end
  AddPlayerToDB()
end
