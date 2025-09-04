local PLUGIN = PLUGIN

if SERVER then
    util.AddNetworkString("ixTestUseEntBreak")
    util.AddNetworkString("ixMechanicCheckEntity")
    util.AddNetworkString("ixFillMechPack")
    util.AddNetworkString("ixMechanicFixEntity")

    net.Receive("ixTestUseEntBreak", function(_,ply) --Общая функция для поломки
        local ent = net.ReadEntity()

        PLUGIN:PlayerUseRandomBreak(ply, ent)
    end)

    net.Receive("ixMechanicCheckEntity", function(_,ply) --Проверка на наличие инструмента
        local ent = net.ReadEntity()
        
        ply:SetAction("Проверка...", PLUGIN.MechCheckupTime)
        ply:DoStaredAction(ent, function()
            PLUGIN:PlayerCheckEntity(ply, ent)
        end, PLUGIN.MechCheckupTime, function()
            ply:Notify("Вы должны смотреть на мехинизм")
            if (IsValid(ply)) then
				ply:SetAction()
			end
        end)

        
    end)

    net.Receive("ixFillMechPack", function(_,ply) --Пополнение сумки
        local ent = net.ReadEntity()
        local box = ply:GetCharacter():GetInventory():HasItem("instrumentbox")

        if not box then
            ply:Notify("У вас нет ящика с инструментами!")
            return
        end

        ply:SetAction("Пополнение...", PLUGIN.TimeToFillMechBox)
        ply:DoStaredAction(ent, function()
            for k,v in pairs(PLUGIN.BreakageParams) do
                if box:GetData(v.fixitem, 0) <= PLUGIN.MaxItemsMechBox then
                    box:SetData(v.fixitem, PLUGIN.MaxItemsMechBox)
                end
            end
            ply:SendLua([[surface.PlaySound("]]..PLUGIN.FillUpMechBoxSound..[[")]])
            ply:Notify("Вы пополнили сумку")
        end, PLUGIN.TimeToFillMechBox, function()
            ply:Notify("Вы должны смотреть на ящик!")
            if (IsValid(ply)) then
                ply:SetAction()
            end
        end)        
    end)

    net.Receive("ixMechanicFixEntity", function(_,ply) --Починка
        local ent = net.ReadEntity()
        local breakType = net.ReadString()
        local box = ply:GetCharacter():GetInventory():HasItem("instrumentbox")
        local itemsneeded = ent:GetNetVar("break"..breakType.."ItemsNeeded")
        local type = ent:GetNetVar("breakType"..breakType)

        if (box:GetData(PLUGIN.BreakageParams[type].fixitem) < itemsneeded) then
            ply:Notify("Вам не хватает "..itemsneeded-box:GetData(PLUGIN.BreakageParams[type].fixitem).." "..PLUGIN.BreakageParams[type].fixitem.." для починки")
            return
        end

        local fixTime = PLUGIN.BreakageParams[ent:GetNetVar("breakType"..breakType)].difficulty[ent:GetNetVar("break"..breakType.."Difficulty")].time

        ply:SendLua([[surface.PlaySound("]]..PLUGIN.MechFixupSound..[[")]])
        ply:ForceSequence(PLUGIN.MechFixingAnimation)
        
        ply:SetAction("Починка...", fixTime)
        ply:DoStaredAction(ent, function()
            PLUGIN:PlayerFixEntity(ply, ent, breakType)
        end, fixTime, function()
            ply:Notify("Вы должны смотреть на мехинизм")
            if (IsValid(ply)) then
                ply:SetAction()
            end
        end)
    end)
end