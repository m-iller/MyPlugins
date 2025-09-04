local PLUGIN = PLUGIN

--Adding buttons to interaction menu

PLUGIN.whitelistedEntities = {
    ["infestedplant"] = true,
    ["buyingbarrel"] = true,
    ["mechaniccabinet"] = true
}
PLUGIN.InteractionButtons = {
    -- Hazmat entities
	["infestedplant"] = {
        {
            text = "Осмотреть",
            action = function(ent)
                LocalPlayer():Notify("Какая-то мерзкая дрянь")
            end,
            check = function(ent)
                return true
            end
        },
        {
            text = "Собрать",
            action = function(ent)
                net.Start("ixCollectInfestedPlant")
                net.WriteEntity(ent)
                net.SendToServer()
                surface.PlaySound(PLUGIN.PickUpPlantSound)
            end,
            check = function(ent)
                return (LocalPlayer():GetCharacter():GetClass() == CLASS_HAZMAT and LocalPlayer():GetActiveWeapon():GetClass() == "applicator")
            end
        }
    },
    ["buyingbarrel"] = {
        {
            text = "Осмотреть",
            action = function(ent)
                LocalPlayer():Notify("Ну и вонь")
            end,
            check = function(ent)
                return true
            end
        },
        {
            text = "Слить",
            action = function(ent)
                net.Start("ixPourOutInBarrel")
                net.WriteEntity(ent)
                net.SendToServer()
                surface.PlaySound(PLUGIN.BarrelPourSound)
            end,
            check = function(ent)
                return LocalPlayer():GetCharacter():GetClass() == CLASS_HAZMAT
            end
        }
    },
    ["mechaniccabinet"] = {
        {
            text = "Осмотреть",
            action = function(ent)
                LocalPlayer():Notify("Похоже, что тут есть запчасти")
            end,
            check = function(ent)
                return true
            end
        },
        {
            text = "Пополнить сумку",
            action = function(ent)
                LocalPlayer():Notify("Вы пополняете сумку...")
                net.Start("ixFillMechPack")
                net.WriteEntity(ent)
                net.SendToServer()
            end,
            check = function(ent)
                return LocalPlayer():GetCharacter():GetClass() == CLASS_MECHANIC
            end
        }
    },

    -- Mechanic entities
    ["testmechentity"] = {
        {
            text = "Использовать",
            action = function(ent)
                net.Start("ixTestUseEntBreak")
                net.WriteEntity(ent)
                net.SendToServer()
                if not ent:GetNetVar("broken") then
                    LocalPlayer():Notify("Не сломан")
                end
            end,
            check = function(ent)
                return true
            end
        },
    }
}

PLUGIN.DefaultMechanicButtons = {
    {
        text = "Проверить",
        action = function(ent)
            net.Start("ixMechanicCheckEntity")
            net.WriteEntity(ent)
            net.SendToServer()
        end,   
        check = function(ent)
            local client = LocalPlayer()
            local char = client:GetCharacter()
            local inv = char:GetInventory()

            return client:GetCharacter():GetClass() == CLASS_MECHANIC
        end
    },
    {
        text = "Починить ",
        text2 = function(ent)
            if ent:GetNetVar("breakType1") ~= "none" then
                return PLUGIN.BreakageParams[ent:GetNetVar("breakType1")].nameRUSSIA
            else
                return ""
            end
        end,
        action = function(ent)
            net.Start("ixMechanicFixEntity")
            net.WriteEntity(ent)
            net.WriteString("1")
            net.SendToServer()
        end,
        check = function(ent)
            local client = LocalPlayer()
            local char = client:GetCharacter()
            local inv = char:GetInventory()

            local break1 = ent:GetNetVar("breakType1") ~= "none"
            local checked = ent:GetNetVar("checked")

            return client:GetCharacter():GetClass() == CLASS_MECHANIC and break1 and checked
        end
    },
    {
        text = "Починить ",
        text2 = function(ent)
            if ent:GetNetVar("breakType2") ~= "none" then
                return PLUGIN.BreakageParams[ent:GetNetVar("breakType2")].nameRUSSIA
            else
                return ""
            end
        end,
        action = function(ent)
            net.Start("ixMechanicFixEntity")
            net.WriteEntity(ent)
            net.WriteString("2")
            net.SendToServer()
        end,
        check = function(ent)
            local client = LocalPlayer()
            local char = client:GetCharacter()
            local inv = char:GetInventory()

            local break2 = ent:GetNetVar("breakType2") ~= "none"
            local checked = ent:GetNetVar("checked")

            return client:GetCharacter():GetClass() == CLASS_MECHANIC and break2 and checked
        end
    },
    {
        text = "Починить ",
        text2 = function(ent)
            if ent:GetNetVar("breakType3") ~= "none" then
                return PLUGIN.BreakageParams[ent:GetNetVar("breakType3")].nameRUSSIA
            else
                return ""
            end
        end,
        action = function(ent)
            net.Start("ixMechanicFixEntity")
            net.WriteEntity(ent)
            net.WriteString("3")
            net.SendToServer()
        end,
        check = function(ent)
            local client = LocalPlayer()
            local char = client:GetCharacter()
            local inv = char:GetInventory()

            local break3 = ent:GetNetVar("breakType3") ~= "none"
            local checked = ent:GetNetVar("checked")

            return client:GetCharacter():GetClass() == CLASS_MECHANIC and break3 and checked
        end
    }
}

for k,v in pairs(PLUGIN.MechanicEntities) do
    PLUGIN.whitelistedEntities[k] = true
    
    PLUGIN.InteractionButtons[k] = PLUGIN.InteractionButtons[k] or {}
    
    for _,v in pairs(PLUGIN.DefaultMechanicButtons) do
        table.insert(PLUGIN.InteractionButtons[k], v)
    end
end

local INTERACTENTSPLUGIN = ix.plugin.Get("entityinteractions")
INTERACTENTSPLUGIN.entityButtons = table.Merge(INTERACTENTSPLUGIN.entityButtons, PLUGIN.InteractionButtons)
INTERACTENTSPLUGIN.whitelistedEntities = table.Merge(INTERACTENTSPLUGIN.whitelistedEntities, PLUGIN.whitelistedEntities)