GUI = {}

local TEX_COORD_LR = 0.08 -- 按钮图标纹理坐标左上
local TEX_COORD_TB = 0.92 -- 按钮图标纹理坐标右下

---为文本添加颜色, 文本以 |cFF 开头, |r 结尾
---@param color string 颜色, 格式为 RRGGBB
---@param text string 内容
---@return string 文本
function GUI:ColorText(color, text)
  if color:sub(1, 1) == "#" then
    color = color:sub(2) -- 从第 2 个字符截取到末尾
  end
  return "\124c" .. color .. text .. "\124r"
end

---comment
---@param container any 容器
---@param text string 按钮文本
---@param width number 按钮宽度
function GUI:Button(container, text, width)
  local button = AceGUI:Create("Button")
  button:SetText(text)
  button:SetWidth(width)
  container:AddChild(button)
  return button
end

---创建空行
---@param container AceGUIWidget 容器
---@param count number 空行数
function GUI:EmptyLine(container, count)
  local lineCount = count or 1
  for index = 1, lineCount do
    local newline = AceGUI:Create("Label")
    newline:SetFullWidth(true)
    container:AddChild(newline)
  end
end

---创建 label
---@param container AceGUIWidget 容器
---@param text string|number 文本内容
---@param width number 文本宽度
---@param justifyH string 水平对齐方式
---@return AceGUIWidget 标签
function GUI:Label(container, text, width, justifyH)
  local label = AceGUI:Create("Label")
  label:SetText(text)
  label:SetFont(ChatFontNormal:GetFont())
  label:SetWidth(width)
  if justifyH ~= nil then
    label:SetJustifyH(justifyH)
  end
  container:AddChild(label)
  return label
end

---在容器中创建空的 label
---@param container AceGUIWidget 容器
---@param width number 间隔宽度
function GUI:Spacing(container, width)
  local spacing = AceGUI:Create("Label")
  spacing:SetWidth(width)
  container:AddChild(spacing)
end

---定义确认对话框（只需定义一次）
---@param message string 提示信息
---@param callback function 回调函数
function GUI:SimpleConfirm(message, callback)
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
    dialog = StaticPopup_Show("XZWT_SIMPLE_CONFIRM")
  else
    dialog.text:SetText(message)
    dialog.data = callback
  end
end

---创建一个简单的按钮
---@param iconSize table | number 按钮图标大小
---@param buttonName string 按钮名称
---@param iconId number | string | nil 按钮图标纹理ID
---@param border boolean 是否添加边框
---@return Frame 按钮
function GUI:SimpleButton(iconSize, buttonName, iconId, border)
  local button = CreateFrame("Button", buttonName, UIParent)
  if type(iconSize) == "table" then
    button:SetSize(iconSize.x, iconSize.y)
  else
    button:SetSize(iconSize, iconSize)
  end
  if border then
    GUI:SolidBorder(button, 0, 0, 0, 1, 1)
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

---创建分割线
---@param text string 分割线文本
---@param container AceGUIWidget 容器
---@param buttomEmptyLine number|nil 是否添加底部空行间距
---@return AceGUIWidget 分割线
function GUI:Heading(text, container, topEmptyLine, buttomEmptyLine)
  -- 添加顶部空行
  if (topEmptyLine ~= nil) then
    GUI:EmptyLine(container, topEmptyLine)
  end

  local heading = AceGUI:Create("Heading")
  heading:SetText(text)
  heading:SetFullWidth(true)
  container:AddChild(heading)

  -- 添加底部空行
  if (buttomEmptyLine ~= nil) then
    GUI:EmptyLine(container, buttomEmptyLine)
  end

  return heading
end

---创建复选框
---@param label string 复选框文本
---@param value boolean 复选框是否选中
---@param width number 复选框宽度
---@param container AceGUIWidget 容器
---@return AceGUIWidget 复选框
function GUI:CheckBox(label, value, width, container)
  if not value then
    value = false
  end
  local checkbox = AceGUI:Create("CheckBox")
  checkbox:SetLabel(label)
  checkbox:SetWidth(width)
  checkbox:SetValue(value)
  container:AddChild(checkbox)
  return checkbox
end

---下拉列表
---@param option any 下拉列表选项
---@param optionOrder any 下拉列表选项排序
---@param value any 下拉列表默认值
---@param width number 下拉列表宽度
---@param container any 容器
---@return AceGUIWidget
function GUI:Dropdown(option, optionOrder, value, width, container)
  local dropdown = AceGUI:Create("Dropdown")
  dropdown:SetList(option, optionOrder)
  dropdown:SetValue(value)
  dropdown:SetWidth(width)
  container:AddChild(dropdown)
  return dropdown
end

---文本框
---@param width number 文本框宽度
---@param defaultValue string 文本框默认值
---@param container AceGUIWidget 容器
---@return AceGUIWidget
function GUI:EditBox(width, defaultValue, container)
  local editBox = AceGUI:Create("EditBox")
  editBox:SetWidth(width)
  if defaultValue ~= nil and defaultValue ~= "" then
    editBox:SetText(defaultValue)
  end
  container:AddChild(editBox)
  return editBox
end

--- 滑块
--- @param width number 滑块宽度
--- @param min number 滑块最小值
--- @param max number 滑块最大值
--- @param step number 滑块步长
--- @param value number 滑块默认值
--- @param container AceGUIWidget 容器
--- @return AceGUIWidget
function GUI:Slider(width, min, max, step, value, container)
  local slider = AceGUI:Create("Slider")
  slider:SetWidth(width)
  slider:SetSliderValues(min, max, step)
  slider:SetValue(value)
  container:AddChild(slider)
  return slider
end

-- 创建滚动主容器
---@param container AceGUIWidget tab 页容器
function GUI:ScrollMain(container)
  local settingContainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
  settingContainer:SetFullWidth(true)                   -- 最大宽度
  settingContainer:SetFullHeight(true)                  -- 最大高度
  settingContainer:SetLayout("Fill")                    -- important!
  container:AddChild(settingContainer)

  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetLayout("Flow")
  settingContainer:AddChild(scroll)
  return scroll
end

---comment
---@param container any
---@param full boolean|nil 是否全宽
---@return AceGUIWidget
function GUI:SimpleGroup(container, full)
  if full == nil or full == "" then
    full = true
  end
  local group = AceGUI:Create("SimpleGroup")
  group:SetLayout("Flow")
  group:SetFullWidth(full)
  container:AddChild(group)
  return group
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
function GUI:SolidBorder(frame, r, g, b, a, thickness)
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
