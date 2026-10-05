UI_CurrencyCaluator = {}
local COL_W = 50 -- 每一列的宽度

--- 获取货币数量
--- @param currencyId number 货币ID
local function GetCruuencyQuantity(currencyId)
  local info = C_CurrencyInfo.GetCurrencyInfo(currencyId)
  return info.quantity
end

local function FloorAndTenTime(number)
  return math.floor(number) * 10
end

local function ColorStr(level, quantity)
  if level == "SH" then
    return GUI:ColorText(CURRENCY_ID[1].COLOR, quantity)
  elseif level == "YX" then
    return GUI:ColorText(CURRENCY_ID[2].COLOR, quantity)
  elseif level == "YS" then
    return GUI:ColorText(CURRENCY_ID[3].COLOR, quantity)
  elseif level == "LB" then
    return GUI:ColorText(CURRENCY_ID[4].COLOR, quantity)
  elseif level == "MX" then
    return GUI:ColorText(CURRENCY_ID[5].COLOR, quantity)
  end
end

local Target = {
  TARGET_SH = 0,
  TARGET_YX = 0,
  TARGET_YS = 0,
  TARGET_LB = 0,
  SH_LABEL = nil,
  YX_LABEL = nil,
  YS_LABEL = nil,
  LB_LABEL = nil,
}

local Quantitys = {
  SH = 0,
  YX = 0,
  YX2SH = 0,
  YS = 0,
  YS2YX = 0,
  YS2SH = 0,
  LB = 0,
  LB2YS = 0,
  LB2YX = 0,
  LB2SH = 0,
  MX = 0,
  MX2LB = 0,
  MX2YS = 0,
  MX2YX = 0,
  MX2SH = 0,
  --
  ALL_SH = 0,
  ALL_YX = 0,
  ALL_YS = 0,
  ALL_LB = 0,
}

local function GetAllCurrencyQuantity()
  Quantitys.SH = GetCruuencyQuantity(CURRENCY_ID[1].ID)
  -- 英雄
  Quantitys.YX = GetCruuencyQuantity(CURRENCY_ID[2].ID)
  Quantitys.YX2SH = FloorAndTenTime(Quantitys.YX / 30)
  -- 勇士
  Quantitys.YS = GetCruuencyQuantity(CURRENCY_ID[3].ID)
  Quantitys.YS2YX = FloorAndTenTime(Quantitys.YS / 30)
  Quantitys.YS2SH = FloorAndTenTime(Quantitys.YS / 90)
  -- 老兵
  Quantitys.LB = GetCruuencyQuantity(CURRENCY_ID[4].ID)
  Quantitys.LB2YS = FloorAndTenTime(Quantitys.LB / 30)
  Quantitys.LB2YX = FloorAndTenTime(Quantitys.LB / 90)
  Quantitys.LB2SH = FloorAndTenTime(Quantitys.LB / 270)
  -- 冒险家
  Quantitys.MX = GetCruuencyQuantity(CURRENCY_ID[5].ID)
  Quantitys.MX2LB = FloorAndTenTime(Quantitys.MX / 30)
  Quantitys.MX2YS = FloorAndTenTime(Quantitys.MX / 90)
  Quantitys.MX2YX = FloorAndTenTime(Quantitys.MX / 270)
  Quantitys.MX2SH = FloorAndTenTime(Quantitys.MX / 810)

  Quantitys.ALL_SH = Quantitys.SH + Quantitys.YX2SH + Quantitys.YS2SH + Quantitys.LB2SH + Quantitys.MX2SH
  Quantitys.ALL_YX = Quantitys.YX + Quantitys.YS2YX + Quantitys.LB2YX + Quantitys.MX2YX
  Quantitys.ALL_YS = Quantitys.YS + Quantitys.LB2YS + Quantitys.MX2YS
  Quantitys.ALL_LB = Quantitys.LB + Quantitys.MX2LB
end

local function CalculateTarget(type)
  if type == "YX" then
    local needShCount = 80 - Quantitys.SH
    local needYxCount = Target.TARGET_YX - Quantitys.ALL_YX
    Target.SH_LABEL:SetText(ColorStr("SH", needShCount))
    Target.YX_LABEL:SetText(ColorStr("YX", needYxCount))
  end
end

-- 绘制页面
function UI_CurrencyCaluator:DrawSetting(container)
  local scroll = GUI:ScrollMain(container)
  GUI:Label(scroll, "填入需要的" .. "英雄" .. "纹章数量:", 200, "LEFT")
  local targetYX = GUI:EditBox(100, 0, scroll)
  targetYX:SetCallback("OnEnterPressed", function(widget, event, value)
    if not IsNumber(value) then return end
    Target.TARGET_YX = tonumber(value)
  end)
  GUI:Spacing(scroll, 20)
  local button = GUI:Button(scroll, "计算", 80)
  button:SetCallback("OnClick", function(widget, btn) CalculateTarget("YX") end)

  GetAllCurrencyQuantity()

  -- head
  GUI:EmptyLine(scroll, 4)
  local headRow = GUI:SimpleGroup(scroll)
  GUI:Label(headRow, "类型", COL_W, "CENTER")
  GUI:Label(headRow, ColorStr("SH", "神话"), COL_W, "RIGHT")
  GUI:Label(headRow, ColorStr("YX", "英雄"), COL_W, "RIGHT")
  GUI:Label(headRow, ColorStr("YS", "勇士"), COL_W, "RIGHT")
  GUI:Label(headRow, ColorStr("LB", "老兵"), COL_W, "RIGHT")
  GUI:Label(headRow, ColorStr("MX", "冒险"), COL_W, "RIGHT")

  GUI:Heading("", scroll, 0, 0)

  -- 神话
  local shRow = GUI:SimpleGroup(scroll)
  GUI:Label(shRow, ColorStr("SH", "神话:"), COL_W, "CENTER")
  local shCount = GUI:Label(shRow, ColorStr("SH", Quantitys.SH), 50, "RIGHT")

  -- 英雄
  GUI:EmptyLine(scroll, 1)
  local yxRow = GUI:SimpleGroup(scroll)
  GUI:Label(yxRow, ColorStr("YX", "英雄:"), COL_W, "CENTER")
  GUI:Label(yxRow, ColorStr("SH", Quantitys.YX2SH), COL_W, "RIGHT") -- 转神话
  GUI:Label(yxRow, ColorStr("YX", Quantitys.YX), COL_W, "RIGHT")    -- 英雄本身

  -- 勇士
  GUI:EmptyLine(scroll, 1)
  local ysRow = GUI:SimpleGroup(scroll)
  GUI:Label(ysRow, ColorStr("YS", "勇士:"), COL_W, "CENTER")
  GUI:Label(ysRow, ColorStr("SH", Quantitys.YS2SH), COL_W, "RIGHT") -- 转神话
  GUI:Label(ysRow, ColorStr("YX", Quantitys.YS2YX), COL_W, "RIGHT") -- 转英雄
  GUI:Label(ysRow, ColorStr("YS", Quantitys.YS), COL_W, "RIGHT")    -- 勇士本身

  -- 老兵
  GUI:EmptyLine(scroll, 1)
  local lbRow = GUI:SimpleGroup(scroll)
  GUI:Label(lbRow, ColorStr("LB", "老兵:"), COL_W, "CENTER")
  GUI:Label(lbRow, ColorStr("SH", Quantitys.LB2SH), COL_W, "RIGHT") -- 转神话
  GUI:Label(lbRow, ColorStr("YX", Quantitys.LB2YX), COL_W, "RIGHT") -- 转英雄
  GUI:Label(lbRow, ColorStr("YS", Quantitys.LB2YS), COL_W, "RIGHT") -- 转勇士
  GUI:Label(lbRow, ColorStr("LB", Quantitys.LB), COL_W, "RIGHT")    -- 老兵本身

  -- 冒险者
  GUI:EmptyLine(scroll, 1)
  local mxzRow = GUI:SimpleGroup(scroll)
  GUI:Label(mxzRow, ColorStr("MX", "冒险:"), COL_W, "CENTER")
  GUI:Label(mxzRow, ColorStr("SH", Quantitys.MX2SH), COL_W, "RIGHT") -- 转神话
  GUI:Label(mxzRow, ColorStr("YX", Quantitys.MX2YX), COL_W, "RIGHT") -- 转英雄
  GUI:Label(mxzRow, ColorStr("YS", Quantitys.MX2YS), COL_W, "RIGHT") -- 转勇士
  GUI:Label(mxzRow, ColorStr("LB", Quantitys.MX2LB), COL_W, "RIGHT") -- 转老兵
  GUI:Label(mxzRow, ColorStr("MX", Quantitys.MX), COL_W, "RIGHT")    -- 冒险者本身

  GUI:Heading("", scroll, 0, 0)

  -- 总数
  local footRow = GUI:SimpleGroup(scroll)
  GUI:Label(footRow, "已有:", COL_W, "CENTER")
  GUI:Label(footRow, ColorStr("SH", Quantitys.ALL_SH), COL_W, "RIGHT")
  GUI:Label(footRow, ColorStr("YX", Quantitys.ALL_YX), COL_W, "RIGHT")
  GUI:Label(footRow, ColorStr("YS", Quantitys.ALL_YS), COL_W, "RIGHT")
  GUI:Label(footRow, ColorStr("LB", Quantitys.ALL_LB), COL_W, "RIGHT")

  -- 距离目标
  GUI:Heading("", scroll, 0, 0)
  local targetRow = GUI:SimpleGroup(scroll)
  GUI:Label(targetRow, "距目标:", COL_W, "CENTER")
  Target.SH_LABEL = GUI:Label(targetRow, " ", COL_W, "RIGHT")
  Target.YX_LABEL = GUI:Label(targetRow, " ", COL_W, "RIGHT")
  Target.YS_LABEL = GUI:Label(targetRow, " ", COL_W, "RIGHT")
  Target.LB_LABEL = GUI:Label(targetRow, " ", COL_W, "RIGHT")
end
