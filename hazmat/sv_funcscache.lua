local PLUGIN = PLUGIN

if SERVER then
    function PLUGIN:PlayerUseRandomBreak(client, ent) --рандомная поломка при использовании
        if PLUGIN.MechanicEntities[ent:GetClass()] and not ent:GetNetVar("broken") then
            local breakUseChance = ent:GetNetVar("breakUseChance")
            if math.random(1, 100) <= breakUseChance then
                self:IxEntityBreak(client, ent)
            end
        elseif PLUGIN.MechanicEntities[ent:GetClass()] and ent:GetNetVar("broken") then
            ent:EmitSound("physics/metal/metal_box_impact_hard"..math.random(1, 4)..".wav")
            client:Notify("Ничего не произошло")
            return false
        end
    end

    function PLUGIN:IxEntityBreak(client, ent) --общая функция для поломки
        ent:SetNetVar("broken", true)
        ent:EmitSound(PLUGIN.MechanicEntities[ent:GetClass()].breakSound)

        local _, breakType1 = table.Random(PLUGIN.BreakageParams)
        local _, breakDifficulty1 = table.Random(PLUGIN.BreakageParams[breakType1].difficulty)

        ent:SetNetVar("breakType1", breakType1)
        ent:SetNetVar("break1Difficulty", breakDifficulty1)
        ent:SetNetVar("break1ItemsNeeded", math.random(PLUGIN.BreakageParams[breakType1].difficulty[breakDifficulty1].minitmes, PLUGIN.BreakageParams[breakType1].difficulty[breakDifficulty1].maxitmes))

        if math.random(1, 100) <= PLUGIN.MechanicEntities[ent:GetClass()].secondBreakChance then
            local _, breakType2 = table.Random(PLUGIN.BreakageParams)
            local _, breakDifficulty2 = table.Random(PLUGIN.BreakageParams[breakType2].difficulty)

            ent:SetNetVar("breakType2", breakType2)
            ent:SetNetVar("break2Difficulty", breakDifficulty2)
            ent:SetNetVar("break2ItemsNeeded", math.random(PLUGIN.BreakageParams[breakType2].difficulty[breakDifficulty2].minitmes, PLUGIN.BreakageParams[breakType2].difficulty[breakDifficulty2].maxitmes))

            if math.random(1, 100) <= PLUGIN.MechanicEntities[ent:GetClass()].thirdBreakChance then
                local _, breakType3 = table.Random(PLUGIN.BreakageParams)
                local _, breakDifficulty3 = table.Random(PLUGIN.BreakageParams[breakType3].difficulty)

                ent:SetNetVar("breakType3", breakType3)
                ent:SetNetVar("break3Difficulty", breakDifficulty3)
                ent:SetNetVar("break3ItemsNeeded", math.random(PLUGIN.BreakageParams[breakType3].difficulty[breakDifficulty3].minitmes, PLUGIN.BreakageParams[breakType3].difficulty[breakDifficulty3].maxitmes))
            end
        end

        PLUGIN:RegularSparks(ent)
        
        for _, v in pairs(player.GetAll()) do
            if v:GetCharacter():GetClass() == CLASS_MECHANIC then
                local area = ent.ixArea or "Неизвестно"

                v:SendLua([[chat.AddText(Color(255, 40, 40), "[AN.TOOL-O.13]<<КРИТИЧЕСКАЯ ПОЛОМКА :: ОБЪЕКТ/]]..PLUGIN.MechanicEntities[ent:GetClass()].name..[[ :: МЕСТО/]]..area..[[>>")]])
                v:SendLua([[surface.PlaySound("]]..PLUGIN.MechChatNotifySound..[[")]])
            end
        end

        if IsValid(client) then
            hook.Run("IxOnEntityBroken", client, ent) --theoretically we can call it for unique breaking callback
        end
    end

    function PLUGIN:PlayerCheckEntity(client, ent) --Проверка энтити на поломки
        if PLUGIN.MechanicEntities[ent:GetClass()] and not ent:GetNetVar("broken") then
            client:SendLua([[chat.AddText(Color(255, 150, 150), "РЕЗУЛЬТАТ::ОБЪЕКТ_]]..PLUGIN.MechanicEntities[ent:GetClass()].name..[[::СТАТУС//НЕ_ПОВРЕЖДЁН")]])
        else
            local breakType1 = ent:GetNetVar("breakType1")
            local breakType2 = ent:GetNetVar("breakType2")
            local breakType3 = ent:GetNetVar("breakType3")

            if breakType1 ~= "none" then
                client:SendLua([[chat.AddText(Color(255, 150, 150), "РЕЗУЛЬТАТ::ОБЪЕКТ_]]..PLUGIN.MechanicEntities[ent:GetClass()].name..[[::НЕИСПРАВНОСТЬ::]]..PLUGIN.BreakageParams[breakType1].name..[[::Тяжесть::]]..PLUGIN.BreakageParams[breakType1].difficulty[ent:GetNetVar("break1Difficulty")].name..[[")]])
            end
            if breakType2 ~= "none" then
                timer.Simple(0.5, function()
                    client:SendLua([[chat.AddText(Color(255, 150, 150), "РЕЗУЛЬТАТ::ОБЪЕКТ_]]..PLUGIN.MechanicEntities[ent:GetClass()].name..[[::НЕИСПРАВНОСТЬ::]]..PLUGIN.BreakageParams[breakType2].name..[[::Тяжесть::]]..PLUGIN.BreakageParams[breakType2].difficulty[ent:GetNetVar("break2Difficulty")].name..[[")]])
                end)
            end
            if breakType3 ~= "none" then
                timer.Simple(1, function()
                    client:SendLua([[chat.AddText(Color(255, 150, 150), "РЕЗУЛЬТАТ::ОБЪЕКТ_]]..PLUGIN.MechanicEntities[ent:GetClass()].name..[[::НЕИСПРАВНОСТЬ::]]..PLUGIN.BreakageParams[breakType3].name..[[::Тяжесть::]]..PLUGIN.BreakageParams[breakType3].difficulty[ent:GetNetVar("break3Difficulty")].name..[[")]])
                end)
            end

            ent:SetNetVar("checked", true)
        end
    end

    function PLUGIN:PlayerFixEntity(client, ent, breakType) --Починка
        local box = client:GetCharacter():GetInventory():HasItem("instrumentbox")

        if not box then
            client:Notify("У вас нет ящика с инструментами!")
            return
        end

        local Type = ent:GetNetVar("breakType"..breakType)
        local Difficulty = ent:GetNetVar("break"..breakType.."Difficulty")

        local itemsneeded = ent:GetNetVar("break"..breakType.."ItemsNeeded")

        if box:GetData(PLUGIN.BreakageParams[Type].fixitem) >= itemsneeded then
            box:SetData(PLUGIN.BreakageParams[Type].fixitem, box:GetData(PLUGIN.BreakageParams[Type].fixitem) - itemsneeded)
            ent:SetNetVar("breakType"..breakType, "none")
            ent:SetNetVar("break"..breakType.."Difficulty", "none")
            if ent:GetNetVar("breakType1") == "none" and ent:GetNetVar("breakType2") == "none" and ent:GetNetVar("breakType3") == "none" then
                ent:SetNetVar("broken", false)
                ent:SetNetVar("checked", false)
                if timer.Exists("RegularSparks"..ent:EntIndex()) then
                    timer.Remove("RegularSparks"..ent:EntIndex())
                end
                client:Notify("Вы починили "..PLUGIN.MechanicEntities[ent:GetClass()].name)
            end
            client:Notify("Вы починили "..PLUGIN.BreakageParams[Type].nameRUSSIA)
        else
            client:Notify("Вам не хватает "..itemsneeded-box:GetData(PLUGIN.BreakageParams[Type].fixitem).." "..PLUGIN.BreakageParams[Type].fixitem.." для починки")
        end
    end

    function PLUGIN:RegularSparks(ent)
        timer.Create("RegularSparks"..ent:EntIndex(), PLUGIN.SparksTimer, 0, function()
            local vPoint = ent:LocalToWorld(ent:OBBCenter()) + ent:GetForward()*20
            local effectdata = EffectData()
            effectdata:SetOrigin(vPoint)
            effectdata:SetMagnitude(1.5)
            effectdata:SetScale(1.5)
            util.Effect("ElectricSpark", effectdata, true, true)

            ent:EmitSound(PLUGIN.RegularSparksSound, 100, 100)

            PLUGIN:RegularSparks(ent)
        end)
    end
end