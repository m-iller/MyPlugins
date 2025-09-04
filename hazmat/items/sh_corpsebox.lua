ITEM.name = "Коробка с мешками"
ITEM.model = "models/hazmat_crate/hazmat_crate.mdl"
ITEM.description = "Ящик с плотно упакованными мешками для трупов"
ITEM.category = "Combine Professions"

ITEM.height = 2
ITEM.width = 4

local PLUGIN = PLUGIN

ITEM.functions.CleanCorpse = { 
	name = "Убрать",
	tip = "Упаковывает труп перед вами в мешок",
	icon = "icon16/emoticon_waii.png",
	OnRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		if not target:IsRagdoll() then
			client:Notify("Вы должны смотреть на труп.")
			return false 
		end
		if not target:GetNetVar("IsCorpse") then
			client:Notify("Это не труп.")
			return false
		end
		
		client:EmitSound(PLUGIN.StartCorpseBagSound)

		client:SetAction("Уборка...", PLUGIN.TimeToPackCorpse)
		client:DoStaredAction(target, function()
			local corpsebag = ents.Create("corpsebag")
			corpsebag:SetPos(target:GetPos())
			corpsebag:SetAngles(client:GetAngles())

			target:Remove()

			corpsebag:Spawn()

			corpsebag:EmitSound(PLUGIN.EndCorpseBagSound)
		end, PLUGIN.TimeToPackCorpse, function()
			if (IsValid(client)) then
				client:SetAction()
			end
		end)

		return false
	end
}
