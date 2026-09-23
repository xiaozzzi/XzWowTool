AceGUI = LibStub("AceGUI-3.0")
local isMainFrameVisible = false
local XZWTMainFrame        -- 主页面
local XZWTTabFrame         -- tab 页面
local ShowCurrencyDropdown -- 显示货币
local ShowWoodDropdown     -- 显示木材

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
  GuiCreateChatLabel(scroll, GetColorText("FFFFFF", "全部角色:"), 100, "LEFT")

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
  playerDropdown:SetWidth(250)
  playerDropdown:SetCallback("OnValueChanged", function(a, b, key)
    clickPlayer = CONFIG:GetByUnitGUID(key)
    print(clickPlayer['unitName'])
    print(clickPlayer['showCurrency'])
    print(clickPlayer['showWood'])
    ShowCurrencyDropdown:SetValue(clickPlayer['showCurrency'])
    ShowWoodDropdown:SetValue(clickPlayer['showWood'])
  end)
  scroll:AddChild(playerDropdown)
  GuiCreateSpacing(scroll, 20)

  -- ==================================== 具体配置 ==================================== --

  GuiCreateEmptyLine(scroll, 2) --创建空行
  local settingHead = AceGUI:Create("Heading")
  settingHead:SetText("角色配置")
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
  ShowCurrencyDropdown:SetValue(clickPlayer['showCurrency'])
  ShowCurrencyDropdown:SetWidth(130)
  ShowCurrencyDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'showCurrency', key)
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
  ShowWoodDropdown = AceGUI:Create("Dropdown")
  ShowWoodDropdown:SetList({ ['SHOW'] = "|cFF7DDA58显示|r", ['HIDE'] = "|cFFE4080A隐藏|r", })
  ShowWoodDropdown:SetValue(clickPlayer['showWood'])
  ShowWoodDropdown:SetWidth(130)
  ShowWoodDropdown:SetCallback("OnValueChanged", function(a, b, key)
    CONFIG:SaveConfigValue(clickPlayer.unitGUID, 'showWood', key)
  end)
  woodContainer:AddChild(ShowWoodDropdown)
  GuiCreateSpacing(woodContainer, 20)
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
    XZWTMainFrame:EnableResize(true) -- 允许改变窗口大小
    XZWTMainFrame:SetTitle("自用工具箱")
    XZWTMainFrame:SetCallback("OnClose", function(widget)
      isMainFrameVisible = false
    end)
    XZWTMainFrame:SetWidth(450)
    XZWTMainFrame:SetHeight(300)
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
function TriggerFrame()
  if not isMainFrameVisible then
    showUI()
    isMainFrameVisible = true
  else
    XZWTMainFrame:Hide()
    isMainFrameVisible = false
  end
end
