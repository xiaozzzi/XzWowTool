AceGUI = LibStub("AceGUI-3.0")
local isMainFrameVisible = false
local XZWTMainFrame        -- 主页面
local XZWTTabFrame         -- tab 页面
local ShowCurrencyDropdown -- 显示货币
local WoodDropdown         -- 显示木材
local StoneDropdown        -- 选择炉石

local UI_SIZE = {
  NORMAL_WIDTH = 518,
  NORMAL_HEIGHT = 610,
  TRANSMOG_WIDTH = 890,
  TRANSMOG_HEIGHT = 630,
}

-------------------------------------------------------------------------------------------------------------
-- 设置页面
-------------------------------------------------------------------------------------------------------------
local function DrawSetting(container)
  local unitGUID = UnitGUID("player")

  --#region ==================================== 角色选择 ====================================
  local SCROLL_FRAME = GUI:ScrollMain(container)
  GUI:Heading(SCROLL_FRAME, "选择角色", 0, 2)
  GUI:Icon(SCROLL_FRAME, 236439, 20, 20, 35)
  GUI:Label(SCROLL_FRAME, "当前角色:", 90, "LEFT")

  local playerList = {}
  local playerListOrder = {}

  -- 遍历所有用户
  for _, player in pairs(CFG:GetAllPlayers()) do
    table.insert(playerListOrder, player.unitGUID)
    playerList[player.unitGUID] = format("|c%s%s-%s|r",
      C_ClassColor.GetClassColor(player.classFilename):GenerateHexColor(), player.unitName, player.realm)
  end

  local playerCFG = CFG:GetByUnitGUID(unitGUID)
  if not playerCFG then
    return
  end

  local playerDropdown = GUI:Dropdown(SCROLL_FRAME, playerList, playerListOrder, unitGUID, 220)
  playerDropdown:SetDisabled(true)
  -- playerDropdown:SetCallback("OnValueChanged", function(a, b, key)
  --   playerCFG = CFG:GetByUnitGUID(key)
  --   ShowCurrencyDropdown:SetValue(CFG:GetValue(key, 'SHOW_CURRENCY'))
  --   WoodDropdown:SetValue(CFG:GetValue(key, 'SHOW_WOOD'))
  --   StoneDropdown:SetValue(tonumber(CFG:GetValue(key, 'HEARTH_STONE')))
  -- end)
  GUI:Spacing(SCROLL_FRAME, 20)

  --#endregion

  --#region ==================================== 货币和木材 ====================================

  GUI:Heading(SCROLL_FRAME, "货币监控", 2, 2)
  local SHOW_HIDE = { ['SHOW'] = "|cFF7DDA58显示|r", ['HIDE'] = "|cFFE4080A隐藏|r", }

  -- ------------ 显示纹章 ------------
  GUI:Icon(SCROLL_FRAME, C_CurrencyInfo.GetCurrencyInfo(CURRENCY_ID[1].ID).iconFileID, 20, 20, 35)
  GUI:Label(SCROLL_FRAME, "显示纹章:", 90, "LEFT")
  ShowCurrencyDropdown = GUI:Dropdown(SCROLL_FRAME, SHOW_HIDE, nil, CFG:GetValue(unitGUID, 'SHOW_CURRENCY'), 130)
  ShowCurrencyDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CFG:SaveConfigValue(unitGUID, 'SHOW_CURRENCY', key)
    MODE_CURRENCY:InitCurrencyTrack()
  end)

  -- ------------ 显示木材 ------------
  local woodContainer = GUI:SimpleGroup(SCROLL_FRAME, true)
  GUI:Icon(woodContainer, C_Item.GetItemIconByID(WOOD_ID[1].ID), 20, 20, 35)
  GUI:Label(woodContainer, "显示木材:", 90, "LEFT")
  WoodDropdown = GUI:Dropdown(woodContainer, SHOW_HIDE, nil, playerCFG['SHOW_WOOD'], 130)
  WoodDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_WOOD', key)
  end)

  --#endregion

  --#region ==================================== 炉石 ==================================== --
  local stoneContainer = GUI:SimpleGroup(SCROLL_FRAME, true)
  local stoneList = {}
  local stoneListOrder = {}

  -- 遍历所有炉石
  for _, stone in pairs(HEARTH_STONE) do
    table.insert(stoneListOrder, stone.ID)
    stoneList[stone.ID] = '|TInterface\\Icons\\' .. stone.ICON .. ':0|t ' .. stone.NAME
  end

  GUI:Icon(stoneContainer, C_Item.GetItemIconByID(6948), 20, 20, 35)
  GUI:Label(stoneContainer, "选择炉石:", 90, "LEFT")
  StoneDropdown = GUI:Dropdown(stoneContainer, stoneList, stoneListOrder, tonumber(playerCFG['HEARTH_STONE']), 240)
  StoneDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CFG:SaveConfigValue(playerCFG.unitGUID, 'HEARTH_STONE', key)
    InitCommonButton()
  end)

  GUI:Label(stoneContainer, "  共:" .. #HEARTH_STONE .. "", 60, "LEFT")

  --#endregion

  --#region ==================================== 按钮拓展 ==================================== --
  local COL_WIDTH = 200
  local MACRO = GUI:ColorText("FF478E00", "宏 - ")
  local SPEEL = GUI:ColorText("FF006789", "(法)")
  local ITEMS = GUI:ColorText("FF8E8E00", "(玩)")
  local MOUNT = GUI:ColorText("FF8E4C00", "(骑)")
  GUI:Heading(SCROLL_FRAME, "按钮拓展", 2, 0)
  local col1Container = GUI:InlineGroup(SCROLL_FRAME, false, false, 230)
  local col2Container = GUI:InlineGroup(SCROLL_FRAME, false, false, 230)
  local COL1_CFG = {
    { KEY = "MACRO_DELVE", TEXT = MACRO .. "地下堡" },
    { KEY = "THE_GREAT_VAULT", TEXT = MACRO .. "宏伟宝库" },
    { KEY = "CRAFTING", TEXT = MACRO .. "制造业模拟" },
    { KEY = "HEARTH_STONE", TEXT = "炉石" .. ITEMS, ICON = "inv_misc_rune_01", },
    { KEY = "THE_ARCANTINA", TEXT = "奥术秘社钥匙" .. ITEMS, ICON = "inv_12_ arcantina_key", },
    { KEY = "MAIL_BOX", TEXT = "位面包裹信号器" .. ITEMS, ICON = "Inv_112_raidtrinkets_blobofswirlingvoid_purple" },
    { KEY = "WAR_BAND_BANK", TEXT = "战团仓库" .. SPEEL, ICON = "inv_cosmicvoid_orb" },
  }

  for _, button in pairs(COL1_CFG) do
    local label = button.ICON and " |TInterface\\Icons\\" .. button.ICON .. ":0|t " .. button.TEXT or button.TEXT
    local cb = GUI:CheckBox(col1Container, label, playerCFG['SHOW_BTN_' .. button.KEY] == 'SHOW', COL_WIDTH)
    cb:SetCallback("OnValueChanged", function(widget, event, value)
      CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_' .. button.KEY, GetShowHide(value))
      InitCommonButton()
    end)
  end

  local COL2_CFG = {
    YAK = { LABEL = "|TInterface\\Icons\\Ability_mount_travellersyakmount:0|t 雄壮远足驼牛" .. MOUNT, DEFAULT_VALUE = playerCFG['SHOW_BTN_MOUNT_YAK'] == 'SHOW' },
    FUNGALSTRIDER = { LABEL = "|TInterface\\Icons\\inv_fungalstridermount:0|t 孢囊真菌行者" .. MOUNT, DEFAULT_VALUE = playerCFG['SHOW_BTN_MOUNT_FUNGAL_STRIDER'] == 'SHOW' },
    FLY_MODE = { LABEL = "|TInterface\\Icons\\Ability_dragonriding_swapflightstyles01:0|t 切换飞行模式" .. SPEEL, DEFAULT_VALUE = playerCFG['SHOW_BTN_FLY_MODE'] == 'SHOW' },
    DELVE_ROBOT = { LABEL = "|TInterface\\Icons\\Inv_111_robocopter_robocopter:0|t 地下堡机器人7001型" .. ITEMS, DEFAULT_VALUE = playerCFG['SHOW_BTN_DELVE7001'] == 'SHOW' }
  }

  -- 牦牛
  local cbYak = GUI:CheckBox(col2Container, COL2_CFG.YAK.LABEL, COL2_CFG.YAK.DEFAULT_VALUE, COL_WIDTH)
  cbYak:SetCallback("OnValueChanged", function(widget, event, value)
    CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_MOUNT_YAK', GetShowHide(value))
    InitCommonButton()
  end)

  -- 真菌行者
  local cbFS = GUI:CheckBox(col2Container, COL2_CFG.FUNGALSTRIDER.LABEL, COL2_CFG.FUNGALSTRIDER.DEFAULT_VALUE, COL_WIDTH)
  cbFS:SetCallback("OnValueChanged", function(widget, event, value)
    CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_MOUNT_FUNGAL_STRIDER', GetShowHide(value))
    InitCommonButton()
  end)

  -- 切换飞行模式
  local cbFlyMode = GUI:CheckBox(col2Container, COL2_CFG.FLY_MODE.LABEL, COL2_CFG.FLY_MODE.DEFAULT_VALUE, COL_WIDTH)
  cbFlyMode:SetCallback("OnValueChanged", function(widget, event, value)
    CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_FLY_MODE', GetShowHide(value))
    InitCommonButton()
  end)

  -- 专业
  local prof1, prof2 = GetProfessions()
  if prof1 and prof1 ~= 0 then
    local name = GetProfessionInfo(prof1)
    local cbProf1 = GUI:CheckBox(col2Container, "|TInterface\\Icons\\" .. PRO_MAPPING[name].icon .. ":0|t " .. name,
      playerCFG['SHOW_BTN_PROF1'] == 'SHOW', COL_WIDTH)
    cbProf1:SetCallback("OnValueChanged", function(widget, event, value)
      CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_PROF1', GetShowHide(value))
      InitCommonButton()
    end)
  end

  if prof2 and prof2 ~= 0 then
    local name = GetProfessionInfo(prof2)
    local cbProf2 = GUI:CheckBox(col2Container, "|TInterface\\Icons\\" .. PRO_MAPPING[name].icon .. ":0|t " .. name,
      playerCFG['SHOW_BTN_PROF2'] == 'SHOW', COL_WIDTH)
    cbProf2:SetCallback("OnValueChanged", function(widget, event, value)
      CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_PROF2', GetShowHide(value))
      InitCommonButton()
    end)
  end

  -- 地下堡机器人
  local cbDR = GUI:CheckBox(col2Container, COL2_CFG.DELVE_ROBOT.LABEL, COL2_CFG.DELVE_ROBOT.DEFAULT_VALUE, COL_WIDTH)
  cbDR:SetCallback("OnValueChanged", function(widget, event, value)
    CFG:SaveConfigValue(playerCFG.unitGUID, 'SHOW_BTN_DELVE7001', GetShowHide(value))
    InitCommonButton()
  end)
  --#endregion
end

-- 增加背景颜色
local blackBg = UIParent:CreateTexture(nil, "BACKGROUND", nil, -8)
blackBg:SetColorTexture(0, 0, 0, 0.8)
blackBg:Hide()

-- 显示主页面
local function showUI()
  local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if (group == "transmog") then
      XZWTMainFrame:SetWidth(UI_SIZE.TRANSMOG_WIDTH)
      XZWTMainFrame:SetHeight(UI_SIZE.TRANSMOG_HEIGHT)
    else
      XZWTMainFrame:SetWidth(UI_SIZE.NORMAL_WIDTH)
      XZWTMainFrame:SetHeight(UI_SIZE.NORMAL_HEIGHT)
    end

    if group == "setting" then
      DrawSetting(container)
    elseif group == "convenient" then
      UI_Convenient:DrawSetting(container)
    elseif group == "unit" then
      UI_Unit:DrawSetting(container)
    elseif group == "currency_caluator" then
      UI_CurrencyCaluator:DrawSetting(container)
    elseif group == "transmog" then
      UI_Transmog:Draw(container)
    end
  end

  if XZWTMainFrame then
    XZWTMainFrame:Show()
    blackBg:Show()
    XZWTTabFrame:SelectTab("setting")
  else
    -- 创建主页面
    XZWTMainFrame = AceGUI:Create("Frame")
    XZWTMainFrame:EnableResize(false) -- 允许改变窗口大小
    XZWTMainFrame:SetTitle(GUI:ColorText("FFF9F9F9", "自用工具箱 XzWowTool - xzzz  (版本: " .. CONSTANTS.VERSION .. ")"))
    XZWTMainFrame:SetStatusText("各项常用功能轻量级拓展。")
    XZWTMainFrame:SetCallback("OnClose", function(widget)
      isMainFrameVisible = false
      blackBg:Hide()
    end)
    XZWTMainFrame:SetWidth(UI_SIZE.NORMAL_WIDTH)
    XZWTMainFrame:SetHeight(UI_SIZE.NORMAL_HEIGHT)
    XZWTMainFrame:SetPoint("CENTER", UIParent, "CENTER", -400, 100)
    XZWTMainFrame:SetLayout("Fill")

    XZWTTabFrame = AceGUI:Create("TabGroup")
    XZWTTabFrame:SetLayout("Flow")
    XZWTTabFrame:SetTabs({
      { text = "设置", value = "setting" },
      { text = "界面拓展", value = "convenient" },
      { text = "单位框体", value = "unit" },
      { text = "货币计算", value = "currency_caluator" },
      { text = "套装收集", value = "transmog" },
    })
    XZWTTabFrame:SetCallback("OnGroupSelected", SelectGroup)
    XZWTTabFrame:SelectTab("setting")

    blackBg:Show()
    blackBg:ClearAllPoints()
    blackBg:SetPoint("TOPLEFT", XZWTTabFrame.frame, "TOPLEFT", -8, 17)
    blackBg:SetPoint("BOTTOMRIGHT", XZWTTabFrame.frame, "BOTTOMRIGHT", 8, -28)

    XZWTMainFrame:AddChild(XZWTTabFrame)

    -- 设置全局变量, 允许按下 esc 时关闭页面
    _G["XZWTGlobalFrame"] = XZWTMainFrame.frame
    tinsert(UISpecialFrames, "XZWTGlobalFrame")
  end
  XZWTTabFrame:SelectTab("setting")
end

--- show and hide XZWTMainFrame
function OpenXZWTMainFrame()
  if not isMainFrameVisible then
    showUI()
    isMainFrameVisible = true
  else
    XZWTMainFrame:Hide()
    isMainFrameVisible = false
  end
end
