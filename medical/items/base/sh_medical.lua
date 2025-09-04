ITEM.name = "MedicalItem"
ITEM.model = Model("models/healthvial.mdl")
ITEM.description = "Base"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "MedicalItems"
ITEM.noBusiness = true

ITEM.UseTime = 1
ITEM.HealAmount = 10
ITEM.KOGetUp = false
ITEM.StunGetUp = false
ITEM.RemoveEffect = {} --set to "all" to remove all effects
ITEM.IsSingleUse = false

ITEM.functions.HealTarget = {
    name = "Лечить цель",
	icon = "icon16/heart_add.png",
	OnRun = function(item)
        local client = item.player

        local target = item.player:GetEyeTraceNoCursor().Entity

        local specialEffectTable = {}
        if (target:GetNetVar("Stunned", false) and item.StunGetUp) then
            specialEffectTable = {["stun"] = true}
        end

        if (target:GetNetVar("KnockedOut", false) and item.KOGetUp) then
            specialEffectTable = {["knockedout"] = true}
        end

        client:SetAction("Applying...", item.UseTime)
        client:DoStaredAction(target, function()           
            hook.Run("ixHealItemEffect", client, target, item.name, item.HealAmount, item.RemoveEffect, specialEffectTable)
            client:Notify(string.format("Вы использовали %s на %s", item.name, target:Name()))
        end, item.UseTime, function()
            client:Notify("Вы должны смотреть на игрока!")
            client:SetAction()
        end)

        return item.IsSingleUse
	end,
	OnCanRun =  function(item)
		local ent = item.player:GetEyeTraceNoCursor().Entity
		
		return ent:IsPlayer()
	end
}

ITEM.functions.HealSelf = {
    name = "Лечить себя",
	icon = "icon16/heart.png",
	OnRun = function(item)
        local client = item.player

        client:SetAction("Applying...", item.UseTime, function()
            hook.Run("ixHealItemEffect", client, client, item.name, item.HealAmount, item.RemoveEffect, {})
            client:Notify(string.format("Вы использовали %s на себе", item.name))
        end)

        return item.IsSingleUse
    end,
    OnCanRun = function(item)
        local client = item.player
        if (client:GetNetVar("KnockedOut", false) or client:GetNetVar("Stunned", false)) then
            return false
        end

        return true
    end
}