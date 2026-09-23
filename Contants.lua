-- 木头的数量监控
WOOD_ID = {
  { ID = 256963, VERSION = '至暗' },
  { ID = 248012, VERSION = '地心' },
  { ID = 251773, VERSION = '巨龙' },
  { ID = 251772, VERSION = '暗影' },
  { ID = 251768, VERSION = '争霸' },
  { ID = 251767, VERSION = '军团' },
  { ID = 251766, VERSION = '德拉' },
  { ID = 251763, VERSION = '熊猫' },
  { ID = 251764, VERSION = '灾变' },
  { ID = 251762, VERSION = '北极' },
  { ID = 242691, VERSION = '外域' },
  { ID = 245586, VERSION = '旧世' },
}

-- 货币
CURRENCY_ID = {
  -- 12.1
  { ID = 3446, R = 1,    G = 0.82, B = 0 },    -- 神话
  { ID = 3445, R = 1,    G = 0.48, B = 0 },    -- 英雄
  { ID = 3444, R = 0.8,  G = 0.3,  B = 1 },    -- 勇士
  { ID = 3443, R = 0.11, G = 0.53, B = 0.89 }, -- 老兵
  { ID = 3442, R = 0.48, G = 0.7,  B = 0.25 }, -- 冒险家
  { ID = 3465, R = 0.48, G = 0.7,  B = 0.25 }, -- 套装

  -- 12.0
  -- { ID = 3347, R = 1,    G = 0.82, B = 0 },    -- 神话
  -- { ID = 3345, R = 0.5,  G = 0.5,  B = 1 },    -- 英雄
  -- { ID = 3343, R = 0.11, G = 0.53, B = 0.89 }, -- 勇士
  -- { ID = 3341, R = 0.48, G = 0.7,  B = 0.25 }, -- 老兵
  -- { ID = 3383, R = 1,    G = 1,    B = 1 },     -- 冒险家
  --
  -- { ID = 3290, R = 1,    G = 0.82, B = 0 },    -- 神话
  -- { ID = 3288, R = 0.5,  G = 0.5,  B = 1 },    -- 英雄
  -- { ID = 3286, R = 0.11, G = 0.53, B = 0.89 }, -- 勇士
  -- { ID = 3284, R = 0.48, G = 0.7,  B = 0.25 }, -- 老兵
  -- { ID = 2815, R = 1,    G = 1,    B = 1 },     -- 冒险家
}

-- https://www.wowhead.com/cn/search?q=%E7%82%89%E7%9F%B3
HEARTH_STONE = {
  { ID = 162973, ICON = "Inv_holiday_hearthstonewinterveil", TEXT = '冬天爷爷' },
  { ID = 163045, ICON = "Inv_holiday_hearthstonehallowsend", TEXT = '无头骑士' },
  { ID = 165802, ICON = "Inv_holiday_hearthstonenoblegarden", TEXT = '复活节' },
  { ID = 165670, ICON = "Inv_holiday_hearthstoneloveisintheair", TEXT = '情人节' },
  { ID = 165669, ICON = "Inv_holiday_hearthstonelunarfestival", TEXT = '春节' },
  { ID = 166747, ICON = "Inv_holiday_hearthstonebrewfest", TEXT = '美酒节' },
  { ID = 180290, ICON = "Inv_staff_2h_ardenwealdnpc_a_01", TEXT = '法夜' },
  { ID = 182773, ICON = "Inv_inscription_contract_maldraxxus01", TEXT = '通灵领主' },
  { ID = 183716, ICON = "Inv_cape_special_revendreth_d_03", TEXT = '温西尔罪碑' },
  { ID = 184353, ICON = "Ui_sigil_kyrian", TEXT = '格里恩炉石' },
  { ID = 209035, ICON = "Inv_holiday_hearthstonemidsummerfirefestival", TEXT = '烈焰炉石' },
  { ID = 228940, ICON = "Ui_majorfactions_web", TEXT = '恶名丝线' },
  { ID = 235016, ICON = "Inv_10_blacksmithing_craftedoptional_engineering_uprez", TEXT = '重部署模块' },
  { ID = 236687, ICON = "Inv_111_goldenbomb_goldblue", TEXT = '高爆炉石' },
  { ID = 245970, ICON = "Inv_letter_13", TEXT = 'POST总管' },
  { ID = 246565, ICON = "Spell_holy_circleofrenewal_shadow", TEXT = '星瀚炉石' },
  { ID = 257736, ICON = "Spell_holy_surgeoflight", TEXT = '圣光呼唤' },
  { ID = 263933, ICON = "Inv_enchanting_crystal_color1", TEXT = '巡猎者的炉石' },
  { ID = 265100, ICON = "Inv_cosmicvoid_groundsate", TEXT = '核心守卫' },
}

COMMON_BUTTON = {
  { TYPE = "\124cff7FFF00　宏\124r - ", KEY = "MACRO_DELVE", TEXT = "地下堡", ICON_ID = 656581 },
  { TYPE = "\124cff7FFF00　宏\124r - ", KEY = "THE_GREAT_VAULT", TEXT = "宏伟宝库", ICON_ID = 651744 },
  { TYPE = "\124cff7FFF00　宏\124r - ", KEY = "CRAFTING", TEXT = "制造业模拟", ICON_ID = 132326 },
  { TYPE = "\124cff00BFFF法术\124r - ", KEY = "WAR_BAND_BANK", TEXT = "战团仓库", ICON_ID = 4914670, SPELL = 460905 },
  { TYPE = "\124cffFFFF00玩具\124r - ", KEY = "MAIL_BOX", TEXT = "位面包裹信号器", ICON_ID = 264695 },
  { TYPE = "\124cffFFFF00玩具\124r - ", KEY = "THE_ARCANTINA", TEXT = "奥术秘社钥匙", ICON_ID = 253629 },
  { TYPE = "\124cffFFFF00玩具\124r - ", KEY = "HEARTH_STONE", TEXT = "炉石", ICON_ID = 265100 },
}

-- 种族和天赋
-- 1力量 2敏捷 4智力
CLASS_SPEC = {
  -- =============== 布
  -- 术士
  WARLOCK = { [1] = 4, [2] = 4, [3] = 4, },
  -- 法师
  MAGE = { [1] = 4, [2] = 4, [3] = 4, },
  -- 牧师
  PRIEST = { [1] = 4, [2] = 4, [3] = 4 },

  -- =============== 皮
  -- 盗贼
  ROGUE = { [1] = 2, [2] = 2, [3] = 2, },
  -- 德鲁伊
  DRUID = { [1] = 4, [2] = 2, [3] = 2, [4] = 4, },
  -- DH
  DEMONHUNTER = { [1] = 2, [2] = 2, [3] = 2 },
  -- 武僧
  MONK = { [1] = 2, [2] = 4, [3] = 2 },

  -- =============== 锁
  -- 萨满
  SHAMAN = { [1] = 4, [2] = 2, [3] = 4 },
  -- 猎人
  HUNTER = { [1] = 2, [2] = 2, [3] = 2, },
  -- 唤魔师
  EVOKER = { [1] = 4, [2] = 4, [3] = 4, },

  -- =============== 板
  -- 战士
  WARRIOR = { [1] = 1, [2] = 1, [3] = 1, },
  -- DK
  DEATHKNIGHT = { [1] = 1, [2] = 1, [3] = 1, },
  -- 圣骑士
  PALADIN = { [1] = 4, [2] = 1, [3] = 1, },
}
