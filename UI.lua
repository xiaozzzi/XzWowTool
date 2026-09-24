AceGUI = LibStub("AceGUI-3.0")
local isMainFrameVisible = false
local XZWTMainFrame        -- 主页面
local XZWTTabFrame         -- tab 页面
local ShowCurrencyDropdown -- 显示货币
local StoneDropdown        -- 显示木材

-------------------------------------------------------------------------------------------------------------
-- 设置页面
-------------------------------------------------------------------------------------------------------------
local function DrawSetting(container)
  local unitGUID = UnitGUID("player")

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

  GuiCreateEmptyLine(scroll, 2) --创建空行

  local currencyIcon = AceGUI:Create("Icon")
  currencyIcon:SetImage(236439)
  currencyIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  currencyIcon:SetWidth(35)
  scroll:AddChild(currencyIcon)

  GuiCreateChatLabel(scroll, GetColorText("FFFFFF", "全部角色:"), 90, "LEFT")

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
    StoneDropdown:SetValue(clickPlayer['SHOW_WOOD'])
  end)
  scroll:AddChild(playerDropdown)
  GuiCreateSpacing(scroll, 20)

  -- ==================================== 货币监控 ==================================== --

  GuiCreateEmptyLine(scroll, 2) --创建空行
  local settingHead = AceGUI:Create("Heading")
  settingHead:SetText("货币监控")
  settingHead:SetFullWidth(true)
  scroll:AddChild(settingHead)
  GuiCreateEmptyLine(scroll, 2) --创建空行

  -- =============== 显示纹章 ===============
  local currencyIcon = AceGUI:Create("Icon")
  currencyIcon:SetImage(C_CurrencyInfo.GetCurrencyInfo(CURRENCY_ID[1].ID).iconFileID)
  currencyIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  currencyIcon:SetWidth(35)
  scroll:AddChild(currencyIcon)

  GuiCreateChatLabel(scroll, GetColorText("FFFFFF", "显示纹章:"), 90, "LEFT")
  ShowCurrencyDropdown = AceGUI:Create("Dropdown")
  ShowCurrencyDropdown:SetList({ ['SHOW'] = "|cFF7DDA58显示|r", ['HIDE'] = "|cFFE4080A隐藏|r", })
  ShowCurrencyDropdown:SetValue(clickPlayer['SHOW_CURRENCY'])
  ShowCurrencyDropdown:SetWidth(130)
  ShowCurrencyDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_CURRENCY', key)
  end)
  scroll:AddChild(ShowCurrencyDropdown)
  GuiCreateSpacing(scroll, 20)

  -- =============== 显示木材 ===============
  local woodContainer = AceGUI:Create("SimpleGroup")
  woodContainer:SetLayout("Flow")
  scroll:AddChild(woodContainer)

  local woodIcon = AceGUI:Create("Icon")
  woodIcon:SetImage(C_Item.GetItemIconByID(WOOD_ID[1].ID))
  woodIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  woodIcon:SetWidth(35)
  woodContainer:AddChild(woodIcon)
  GuiCreateChatLabel(woodContainer, GetColorText("FFFFFF", "显示木材:"), 90, "LEFT")
  StoneDropdown = AceGUI:Create("Dropdown")
  StoneDropdown:SetList({ ['SHOW'] = "|cFF7DDA58显示|r", ['HIDE'] = "|cFFE4080A隐藏|r", })
  StoneDropdown:SetValue(clickPlayer['SHOW_WOOD'])
  StoneDropdown:SetWidth(130)
  StoneDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_WOOD', key)
  end)
  woodContainer:AddChild(StoneDropdown)
  GuiCreateSpacing(woodContainer, 20)




  -- ==================================== 其他拓展 ==================================== --
  -- =============== 炉石 ===============
  local stoneContainer = AceGUI:Create("SimpleGroup")
  stoneContainer:SetLayout("Flow")
  stoneContainer:SetFullWidth(true)
  scroll:AddChild(stoneContainer)

  local stoneList = {}
  local stoneListOrder = {}

  -- 遍历所有炉石
  for _, stone in pairs(HEARTH_STONE) do
    local itemName, icon = C_Item.GetItemInfo(stone.ID)
    if itemName then
      -- print(stone.ID, itemName, icon)
      table.insert(stoneListOrder, stone.ID)
      stoneList[stone.ID] = '|TInterface\\Icons\\' .. stone.ICON .. ':0|t ' .. itemName
    end
  end

  local stoneIcon = AceGUI:Create("Icon")
  stoneIcon:SetImage(C_Item.GetItemIconByID(6948))
  stoneIcon:SetImageSize(20, 20) -- 设置图标显示尺寸
  stoneIcon:SetWidth(35)
  stoneContainer:AddChild(stoneIcon)
  GuiCreateChatLabel(stoneContainer, GetColorText("FFFFFF", "选择炉石:"), 90, "LEFT")
  StoneDropdown = AceGUI:Create("Dropdown")
  StoneDropdown:SetList(stoneList, stoneListOrder)
  StoneDropdown:SetValue(clickPlayer['HEARTH_STONE'])
  StoneDropdown:SetWidth(220)
  StoneDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'HEARTH_STONE', key)
  end)
  stoneContainer:AddChild(StoneDropdown)
  GuiCreateSpacing(stoneContainer, 20)


  -- ==================================== 按钮拓展 ==================================== --

  GuiCreateEmptyLine(scroll, 2) --创建空行
  local buttonHead = AceGUI:Create("Heading")
  buttonHead:SetText("按钮拓展")
  buttonHead:SetFullWidth(true)
  scroll:AddChild(buttonHead)
  GuiCreateEmptyLine(scroll, 2) --创建空行

  for _, button in pairs(COMMON_BUTTON) do
    local cb = AceGUI:Create("CheckBox")
    cb:SetLabel(button.TYPE .. button.TEXT)
    cb:SetValue(clickPlayer['SHOW_BTN_' .. button.KEY] == 'SHOW')
    cb:SetWidth(200)
    cb:SetCallback("OnValueChanged", function(widget, event, value)
      -- print('SHOW_BTN_' .. button.key, ' : ', value)
      if value then
        CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_' .. button.KEY, 'SHOW')
      else
        CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'SHOW_BTN_' .. button.KEY, 'HIDE')
      end
    end)
    scroll:AddChild(cb)
  end
end

-- 显示主页面
local function showUI()
  local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "setting" then
      DrawSetting(container)
    end
  end

  if XZWTMainFrame then
    XZWTMainFrame:Show()
    XZWTTabFrame:SelectTab("record")
  else
    -- 创建主页面
    XZWTMainFrame = AceGUI:Create("Frame")
    XZWTMainFrame:EnableResize(false) -- 允许改变窗口大小
    XZWTMainFrame:SetTitle("自用工具箱")
    XZWTMainFrame:SetCallback("OnClose", function(widget)
      isMainFrameVisible = false
    end)
    XZWTMainFrame:SetWidth(420)
    XZWTMainFrame:SetHeight(630)
    XZWTMainFrame:SetPoint("CENTER", UIParent, "CENTER", -250, 0)
    XZWTMainFrame:SetLayout("Fill")

    XZWTTabFrame = AceGUI:Create("TabGroup")
    XZWTTabFrame:SetLayout("Flow")
    XZWTTabFrame:SetTabs({
      { text = "设置", value = "setting" },
    })
    XZWTTabFrame:SetCallback("OnGroupSelected", SelectGroup)
    XZWTTabFrame:SelectTab("setting")

    XZWTMainFrame:AddChild(XZWTTabFrame)

    -- 设置全局变量, 允许按下 esc 时关闭页面
    _G["DRTGlobalFrame"] = XZWTMainFrame.frame
    tinsert(UISpecialFrames, "DRTGlobalFrame")
  end
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
