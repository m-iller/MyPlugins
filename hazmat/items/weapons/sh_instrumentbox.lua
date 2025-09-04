local PLUGIN = PLUGIN

ITEM.name = "Ящик с инструментами"
ITEM.model = "models/weapons/w_suitcase_passenger.mdl"
ITEM.description = "Ящик для хранения инструментов и частей"
ITEM.category = "Combine Professions"
ITEM.width = 2
ITEM.height = 2
ITEM.noBusiness = true
ITEM.class = "instrumentcase"
ITEM.weaponCategory = "Instruments"

function ITEM:OnInstanced(invID, x, y)
    for k,v in pairs(PLUGIN.BreakageParams) do
        self:SetData(v.fixitem, 0)
    end
end

ITEM.functions.drop = {
    OnCanRun = function(item)
        return false
    end
}

function ITEM:PopulateTooltip(tooltip)
    local data = tooltip:AddRow("data")
    local itemlist = {}

    for k,v in pairs(PLUGIN.BreakageParams) do
        table.insert(itemlist, v.fixitem .. ": " .. self:GetData(v.fixitem, 0).."\n")
    end
    
    data:SetText(table.concat(itemlist, ""))

    data:SetFont("ixGenericFont")
    data:SizeToContents()
end
