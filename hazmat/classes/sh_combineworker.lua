CLASS.name = "Механик"
CLASS.description = ""
CLASS.faction = FACTION_COMBINEWORKERS

local model

function CLASS:CanSwitchTo(client)
	if SERVER then
		local char = client:GetCharacter()
		local inv = char:GetInventory()

		local a,_ = inv:Add("instrumentbox", 1, nil)
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

	client:SetModel("models/hlvr/characters/worker/worker_player.mdl")
end

function CLASS:OnLeave(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	client:SetModel(model)

	for k,_ in inv:Iter() do
		if (k.uniqueID == "instrumentbox" and k:GetID() ~= 0  and ix.item.instances[k:GetID()]) then 
			k:Remove()
		end
	end
end

function PLUGIN:PlayerDisconnected(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	for k,_ in inv:Iter() do
		if (k.uniqueID == "instrumentbox" and k:GetID() ~= 0  and ix.item.instances[k:GetID()]) then 
			k:Remove()
		end
	end
end

CLASS_MECHANIC = CLASS.index