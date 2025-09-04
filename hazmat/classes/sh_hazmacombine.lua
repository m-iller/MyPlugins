CLASS.name = "Hazmat"
CLASS.description = ""
CLASS.faction = FACTION_COMBINEWORKERS

local model

function CLASS:CanSwitchTo(client)
	if SERVER then
		local char = client:GetCharacter()
		local inv = char:GetInventory()

		local a,_ = inv:Add("toxic_ballon", 1, nil)
		if not a then
			client:Notify("Недостаточно места в инвентаре.")
			return false
		else
			return true  
		end
	end
end

function CLASS:OnSet(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	model = client:GetModel()

	client:SetModel("models/hlvr/characters/hazmat_worker/hazmat_worker_player.mdl")

	client:Give("applicator")
end

function CLASS:OnLeave(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	client:SetModel(model)

	client:StripWeapon("applicator")

	for k,_ in inv:Iter() do
		if (k.uniqueID == "toxic_ballon" and k:GetID() ~= 0  and ix.item.instances[k:GetID()]) then 
			k:Remove()
		end
	end
end

function PLUGIN:PlayerDisconnected(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	for k,_ in inv:Iter() do
		if (k.uniqueID == "toxic_ballon" and k:GetID() ~= 0  and ix.item.instances[k:GetID()]) then 
			k:Remove()
		end
	end
end

CLASS_HAZMAT = CLASS.index