AceGUI = LibStub("AceGUI-3.0")
local isMainFrameVisible = false
local XZWTMainFrame        -- 主页面
local XZWTTabFrame         -- tab 页面
local ShowCurrencyDropdown -- 显示货币
local WoodDropdown         -- 显示木材
local StoneDropdown        -- 选择炉石

-------------------------------------------------------------------------------------------------------------
-- 设置页面
-------------------------------------------------------------------------------------------------------------
local function DrawSetting(container)
  local unitGUID = UnitGUID("player")

  --#region ==================================== 角色选择 ====================================

  local settingContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
  settingContainer:SetFullWidth(true)                   -- 最大宽度
  settingContainer:SetFullHeight(true)                  -- 最大高度
  settingContainer:SetLayout("Fill")                    -- important!
  container:AddChild(settingContainer)

  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetLayout("Flow")
  settingContainer:AddChild(scroll)

  local playerHead = AceGUI:Create("Heading")
  playerHead:SetText("选择角色")
  playerHead:SetFullWidth(true)
  scroll:AddChild(playerHead)

  GUI:EmptyLine(scroll, 2) --创建空行

  local playerIcon = AceGUI:Create("Icon")
  playerIcon:SetImage(236439)
  playerIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  playerIcon:SetWidth(35)
  scroll:AddChild(playerIcon)

  GUI:Label(scroll, "全部角色:", 90, "LEFT")

  local playerList = {}
  local playerListOrder = {}

  -- 遍历所有用户
  for _, player in pairs(CONFIG:GetAllPlayers()) do
    table.insert(playerListOrder, player.unitGUID)
    playerList[player.unitGUID] = format("|c%s%s-%s|r",
      C_ClassColor.GetClassColor(player.classFilename):GenerateHexColor(), player.unitName, player.realm)
  end

  local clickPlayer = CONFIG:GetByUnitGUID(unitGUID)

  local playerDropdown = AceGUI:Create("Dropdown")
  playerDropdown:SetList(playerList, playerListOrder)
  playerDropdown:SetValue(unitGUID)
  playerDropdown:SetWidth(220)
  playerDropdown:SetCallback("OnValueChanged", function(a, b, key)
    clickPlayer = CONFIG:GetByUnitGUID(key)
    ShowCurrencyDropdown:SetValue(clickPlayer['SHOW_CURRENCY'])
    WoodDropdown:SetValue(clickPlayer['SHOW_WOOD'])
    StoneDropdown:SetValue(tonumber(clickPlayer['HEARTH_STONE']))
  end)
  scroll:AddChild(playerDropdown)
  GUI:Spacing(scroll, 20)

  --#endregion

  --#region ==================================== 货币监控 ====================================

  GUI:EmptyLine(scroll, 2) --创建空行
  local settingHead = AceGUI:Create("Heading")
  settingHead:SetText("货币监控")
  settingHead:SetFullWidth(true)
  scroll:AddChild(settingHead)
  GUI:EmptyLine(scroll, 2) --创建空行

  -- ------------ 显示纹章 ------------
  local currencyIcon = AceGUI:Create("Icon")
  currencyIcon:SetImage(C_CurrencyInfo.GetCurrencyInfo(CURRENCY_ID[1].ID).iconFileID)
  currencyIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  currencyIcon:SetWidth(35)
  scroll:AddChild(currencyIcon)

  GUI:Label(scroll, "显示纹章:", 90, "LEFT")
  ShowCurrencyDropdown = AceGUI:Create("Dropdown")
  ShowCurrencyDropdown:SetList({ ['SHOW'] = "|cFF7DDA58显示|r", ['HIDE'] = "|cFFE4080A隐藏|r", })
  ShowCurrencyDropdown:SetValue(clickPlayer['SHOW_CURRENCY'])
  ShowCurrencyDropdown:SetWidth(130)
  ShowCurrencyDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_CURRENCY', key)
  end)
  scroll:AddChild(ShowCurrencyDropdown)
  GUI:Spacing(scroll, 20)

  -- ------------ 显示木材 ------------
  local woodContainer = AceGUI:Create("SimpleGroup")
  woodContainer:SetLayout("Flow")
  scroll:AddChild(woodContainer)

  local woodIcon = AceGUI:Create("Icon")
  woodIcon:SetImage(C_Item.GetItemIconByID(WOOD_ID[1].ID))
  woodIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  woodIcon:SetWidth(35)
  woodContainer:AddChild(woodIcon)
  GUI:Label(woodContainer, "显示木材:", 90, "LEFT")
  WoodDropdown = AceGUI:Create("Dropdown")
  WoodDropdown:SetList({ ['SHOW'] = "|cFF7DDA58显示|r", ['HIDE'] = "|cFFE4080A隐藏|r", })
  WoodDropdown:SetValue(clickPlayer['SHOW_WOOD'])
  WoodDropdown:SetWidth(130)
  WoodDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_WOOD', key)
  end)
  woodContainer:AddChild(WoodDropdown)
  GUI:Spacing(woodContainer, 20)

  --#endregion

  --#region ==================================== 其他拓展 ==================================== --
  -- ------------ 炉石 ------------
  local stoneContainer = AceGUI:Create("SimpleGroup")
  stoneContainer:SetLayout("Flow")
  stoneContainer:SetFullWidth(true)
  scroll:AddChild(stoneContainer)

  local stoneList = {}
  local stoneListOrder = {}

  -- 遍历所有炉石
  for _, stone in pairs(HEARTH_STONE) do
    table.insert(stoneListOrder, stone.ID)
    stoneList[stone.ID] = '|TInterface\\Icons\\' .. stone.ICON .. ':0|t ' .. stone.NAME
  end

  local stoneIcon = AceGUI:Create("Icon")
  stoneIcon:SetImage(C_Item.GetItemIconByID(6948))
  stoneIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  stoneIcon:SetWidth(35)
  stoneContainer:AddChild(stoneIcon)
  GUI:Label(stoneContainer, "选择炉石:", 90, "LEFT")
  StoneDropdown = AceGUI:Create("Dropdown")
  StoneDropdown:SetList(stoneList, stoneListOrder)
  StoneDropdown:SetValue(tonumber(clickPlayer['HEARTH_STONE']))
  StoneDropdown:SetWidth(220)
  StoneDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'HEARTH_STONE', key)
    InitCommonButton()
  end)
  stoneContainer:AddChild(StoneDropdown)
  GUI:Spacing(stoneContainer, 20)

  --#endregion

  --#region ==================================== 按钮拓展 ==================================== --

  GUI:EmptyLine(scroll, 2) --创建空行
  local buttonHead = AceGUI:Create("Heading")
  buttonHead:SetText("按钮拓展")
  buttonHead:SetFullWidth(true)
  scroll:AddChild(buttonHead)

  local col1Container = AceGUI:Create("InlineGroup") -- 第一列
  col1Container:SetLayout("Flow")
  col1Container:SetFullWidth(false)
  col1Container:SetWidth(230)
  scroll:AddChild(col1Container)

  local col2Container = AceGUI:Create("InlineGroup") -- 第二列
  col2Container:SetLayout("Flow")
  col2Container:SetFullWidth(false)
  col2Container:SetWidth(230)
  scroll:AddChild(col2Container)

  for _, button in pairs(COMMON_BUTTON) do
    local cb = AceGUI:Create("CheckBox")
    cb:SetLabel(button.TYPE .. button.TEXT)
    cb:SetValue(clickPlayer['SHOW_BTN_' .. button.KEY] == 'SHOW')
    cb:SetWidth(200)
    cb:SetCallback("OnValueChanged", function(widget, event, value)
      CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_' .. button.KEY, GetShowHide(value))
      InitCommonButton()
    end)
    col1Container:AddChild(cb)
  end

  -- 牦牛
  local cbYak = AceGUI:Create("CheckBox")
  cbYak:SetLabel("|TInterface\\Icons\\Ability_mount_travellersyakmount:0|t 雄壮远足牦牛")
  cbYak:SetValue(clickPlayer['SHOW_BTN_MOUNT_YAK'] == 'SHOW')
  cbYak:SetWidth(200)
  cbYak:SetCallback("OnValueChanged", function(widget, event, value)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_MOUNT_YAK', GetShowHide(value))
    InitCommonButton()
  end)
  col2Container:AddChild(cbYak)

  -- 真菌行者
  local cbFungalStrider = AceGUI:Create("CheckBox")
  cbFungalStrider:SetLabel("真菌行者")
  cbFungalStrider:SetValue(clickPlayer['SHOW_BTN_MOUNT_FUNGAL_STRIDER'] == 'SHOW')
  cbFungalStrider:SetWidth(200)
  cbFungalStrider:SetCallback("OnValueChanged", function(widget, event, value)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_MOUNT_FUNGAL_STRIDER', GetShowHide(value))
    InitCommonButton()
  end)
  col2Container:AddChild(cbFungalStrider)

  -- 切换飞行模式
  local cbFlyMode = AceGUI:Create("CheckBox")
  cbFlyMode:SetLabel("|TInterface\\Icons\\Ability_dragonriding_swapflightstyles01:0|t 切换飞行模式")
  cbFlyMode:SetValue(clickPlayer['SHOW_BTN_FLY_MODE'] == 'SHOW')
  cbFlyMode:SetWidth(200)
  cbFlyMode:SetCallback("OnValueChanged", function(widget, event, value)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_FLY_MODE', GetShowHide(value))
    InitCommonButton()
  end)
  col2Container:AddChild(cbFlyMode)

  local prof1, prof2 = GetProfessions()
  if prof1 and prof1 ~= 0 then
    local name = GetProfessionInfo(prof1)
    local cbProf1 = AceGUI:Create("CheckBox")
    cbProf1:SetLabel("|TInterface\\Icons\\" .. PRO_MAPPING[name].icon .. ":0|t " .. name)
    cbProf1:SetValue(clickPlayer['SHOW_BTN_PROF1'] == 'SHOW')
    cbProf1:SetWidth(200)
    cbProf1:SetCallback("OnValueChanged", function(widget, event, value)
      CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_PROF1', GetShowHide(value))
      InitCommonButton()
    end)
    col2Container:AddChild(cbProf1)
  end

  if prof2 and prof2 ~= 0 then
    local name = GetProfessionInfo(prof2)
    local cbProf2 = AceGUI:Create("CheckBox")
    cbProf2:SetLabel("|TInterface\\Icons\\" .. PRO_MAPPING[name].icon .. ":0|t " .. name)
    cbProf2:SetValue(clickPlayer['SHOW_BTN_PROF2'] == 'SHOW')
    cbProf2:SetWidth(200)
    cbProf2:SetCallback("OnValueChanged", function(widget, event, value)
      CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_PROF2', GetShowHide(value))
      InitCommonButton()
    end)
    col2Container:AddChild(cbProf2)
  end
  --#endregion
end

-- 显示主页面
local function showUI()
  local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "setting" then
      DrawSetting(container)
    elseif group == "convenient" then
      UIConvenient:DrawSetting(container)
    elseif group == "unit" then
      UIUnit:DrawSetting(container)
    end
  end

  if XZWTMainFrame then
    XZWTMainFrame:Show()
    XZWTTabFrame:SelectTab("setting")
  else
    -- 创建主页面
    XZWTMainFrame = AceGUI:Create("Frame")
    XZWTMainFrame:EnableResize(false) -- 允许改变窗口大小
    XZWTMainFrame:SetTitle("自用工具箱" .. CONSTANTS.VERSION)
    XZWTMainFrame:SetCallback("OnClose", function(widget)
      isMainFrameVisible = false
    end)
    XZWTMainFrame:SetWidth(518)
    XZWTMainFrame:SetHeight(610)
    XZWTMainFrame:SetPoint("CENTER", UIParent, "CENTER", -250, 0)
    XZWTMainFrame:SetLayout("Fill")

    XZWTTabFrame = AceGUI:Create("TabGroup")
    XZWTTabFrame:SetLayout("Flow")
    XZWTTabFrame:SetTabs({
      { text = "设置", value = "setting" },
      { text = "界面拓展", value = "convenient" },
      { text = "单位框体", value = "unit" },
    })
    XZWTTabFrame:SetCallback("OnGroupSelected", SelectGroup)
    XZWTTabFrame:SelectTab("setting")

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
