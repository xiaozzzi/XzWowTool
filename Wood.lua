-- 木头监控

WOOD_UI_LIST = {}
local LEFT = 10
local TOP = -200
local HEIGHT = 70

function InitWoodTrack()
    for index, wood in pairs(WOOD_ID) do
        local icon = C_Item.GetItemIconByID(wood.ID)
        local tex = UIParent:CreateTexture()
        tex:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LEFT, TOP - (index * HEIGHT))
        tex:SetScale(0.6)
        tex:SetTexture(icon)

        -- 名称
        local verLabel = UIParent:CreateFontString("XzWoodLabel", "OVERLAY", "GameFontNormal")
        verLabel:SetFont(ChatFontNormal:GetFont(), 14, 'OUTLINE')
        verLabel:SetText(wood.VERSION)
        verLabel:SetPoint("LEFT", tex, "RIGHT", 0, 0)
        verLabel:SetTextColor(1, 1, 1)

        -- 木头数量
        local count = C_Item.GetItemCount(wood.ID, true, true, true, true)
        local countLabel = UIParent:CreateFontString("XzWoodLabel_" .. wood.ID, "OVERLAY", "GameFontNormal")
        countLabel:SetFont(ChatFontNormal:GetFont(), 18, 'OUTLINE')
        countLabel:SetText("" .. count)
        countLabel:SetPoint("TOP", tex, "CENTER", 0, 5)
        countLabel:SetTextColor(1, 1, 1)
        WOOD_UI_LIST[wood.ID] = countLabel
    end
end

function UpdWoodTrack()
    for index, wood in pairs(WOOD_ID) do
        if WOOD_UI_LIST == nil or WOOD_UI_LIST[wood.ID] == nil then
            InitWoodTrack()
        end

        local countLabel = WOOD_UI_LIST[wood.ID]
        local count = C_Item.GetItemCount(wood.ID, true, true, true, true)
        countLabel:SetText("" .. count)
    end
end
