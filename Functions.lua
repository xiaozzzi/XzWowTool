GUI = {}

---====================================================================================
---获取指定颜色的文本, 文本以 |cFF 开头, |r 结尾
---@param color string 颜色
---@param text string 内容
---@return string 文本
---====================================================================================
function GetColorText(color, text)
  return "\124cff" .. color .. text .. "\124r"
end

---====================================================================================
---在容器中创建空行
---@param container AceGUIWidget 容器
---@param count number 行数
---====================================================================================
function GuiCreateEmptyLine(container, count)
  local lineCount = count or 1
  for index = 1, lineCount do
    local newline = AceGUI:Create("Label")
    newline:SetFullWidth(true)
    container:AddChild(newline)
  end
end

---====================================================================================
---在容器中创建消息字体的 label
---@param container AceGUIWidget 容器
---@param text string 文本内容
---@param width number 文本宽度
---@param justifyH string 水平对齐方式
---@return AceGUIWidget 标签
---====================================================================================
function GuiCreateChatLabel(container, text, width, justifyH)
  local label = AceGUI:Create("Label")
  label:SetText(text)
  label:SetFont(ChatFontNormal:GetFont())
  label:SetWidth(width)
  if justify ~= nil then
    label:SetJustifyH(justifyH)
  end
  container:AddChild(label)
  return label
end

---====================================================================================
---在容器中创建间隔
---@param container AceGUIWidget 容器
---@param width number 间隔宽度
---====================================================================================
function GuiCreateSpacing(container, width)
  local spacing = AceGUI:Create("Label")
  spacing:SetWidth(width)
  container:AddChild(spacing)
end

---====================================================================================
---将字符串按指定模式分割为多个字符串
---@param pString string 待分割字符串
---@param pPattern string 分割模式
---@return table<string, string 要分割的字符串>
---====================================================================================
function Split(pString, pPattern)
  local Table = {} -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table, cap)
    end
    last_end = e + 1
    s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

local TEX_COORD_LR = 0.08 -- 按钮图标纹理坐标左上
local TEX_COORD_TB = 0.92 -- 按钮图标纹理坐标右下
---====================================================================================
---创建一个简单的按钮
---@param iconSize table | number 按钮图标大小
---@param buttonName string 按钮名称
---@param iconId number | string | nil 按钮图标纹理ID
---@param border boolean 是否添加边框
---@return Frame 按钮
---====================================================================================
function GUI:SimpleButton(iconSize, buttonName, iconId, border)
  local button = CreateFrame("Button", buttonName, UIParent)
  if type(iconSize) == "table" then
    button:SetSize(iconSize.x, iconSize.y)
  else
    button:SetSize(iconSize, iconSize)
  end
  if border then
    AddSolidBorder(button, 0, 0, 0, 1, 1)
  end
  if iconId then
    -- 背景纹理（类似
    local tex = UIParent:CreateTexture()
    tex:SetTexture(iconId)
    tex:SetTexCoord(TEX_COORD_LR, TEX_COORD_TB, TEX_COORD_LR, TEX_COORD_TB)
    button:SetNormalTexture(tex)
  end
  return button
end

---====================================================================================
--- 为框架添加边框
---@param frame Frame 框架
---@param r number 边框颜色 R
---@param g number 边框颜色 G
---@param b number 边框颜色 B
---@param a number 边框颜色 A
---@param thickness number 边框宽度
---====================================================================================
function AddSolidBorder(frame, r, g, b, a, thickness)
  thickness = thickness or 1
  r, g, b = r or 0, g or 0, b or 0
  a = a or 1

  -- 上边框
  local top = frame:CreateTexture(nil, "OVERLAY")
  top:SetColorTexture(r, g, b, a)
  top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  top:SetHeight(thickness)

  -- 下边框
  local bottom = frame:CreateTexture(nil, "OVERLAY")
  bottom:SetColorTexture(r, g, b, a)
  bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  bottom:SetHeight(thickness)

  -- 左边框
  local left = frame:CreateTexture(nil, "OVERLAY")
  left:SetColorTexture(r, g, b, a)
  left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  left:SetWidth(thickness)

  -- 右边框
  local right = frame:CreateTexture(nil, "OVERLAY")
  right:SetColorTexture(r, g, b, a)
  right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  right:SetWidth(thickness)
end

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

---====================================================================================
---定义确认对话框（只需定义一次）
---@param message string 提示信息
---@param callback function 回调函数
---====================================================================================
function SimpleConfirm(message, callback)
  local dialog = nil --StaticPopup_Show("DRT_SIMPLE_CONFIRM")
  if not dialog then
    StaticPopupDialogs["DRT_SIMPLE_CONFIRM"] = {
      text = message,
      button1 = "确定",
      button2 = "取消",
      OnAccept = callback,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
    }
    dialog = StaticPopup_Show("DRT_SIMPLE_CONFIRM")
  else
    dialog.text:SetText(message)
    dialog.data = callback
  end
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
