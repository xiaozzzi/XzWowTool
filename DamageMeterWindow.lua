local currentDamageMeterHeight = 0

--- 设置伤害表窗口高度
function SetDamageMeterHeight(height)
  if (height == currentDamageMeterHeight) then
    return
  end
  if InCombatLockdown() then
    return
  end
  currentDamageMeterHeight = height
  for i = 1, 10 do
    local win = _G["DamageMeterSessionWindow" .. i]
    if win then
      local point, relativeTo, relativePoint, x, y = win:GetPoint(1)
      win:ClearAllPoints()
      win:SetHeight(height)
      if point then
        win:SetPoint('BOTTOMRIGHT', relativeTo, 'BOTTOMRIGHT', x, y)
      end
    end
  end
end

function HandleDamageMeterWindow()
  local isInGroup = IsInGroup()
  if isInGroup then
    SetDamageMeterHeight(300)
  elseif not isInGroup then
    SetDamageMeterHeight(150)
  end
end
