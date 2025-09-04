CLASS.name = "Hazmat"
CLASS.description = ""
CLASS.faction = FACTION_COMBINEWORKERS

function CLASS:CanSwitchTo(client)
	return true
end

function CLASS:OnSet(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	client:Give("applicator", false)

	local a,_ = inv:Add("toxic_ballon", 1, nil)
	if not a then
		client:Notify("Недостаточно места в инвертаре")
		
		char:JoinClass(CLASS_COMBINEWORKDEFAULT)
	else
		client:Notify("Здарова заебал")
	end

end

function CLASS:OnLeave(client)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	client:StripWeapon("applicator")

	for k,_ in inv:Iter() do
		if (k.uniqueID == "toxic_ballon" and k:GetID() != 0  and ix.item.instances[k:GetID()]) then 
			k:Remove()

			break
		end
	end
end

--TEMPORARY BEFORE USING WITH JOBSELECTOR

function PLUGIN:PlayerDisconnected(ply)
	local char = client:GetCharacter()
	local inv = char:GetInventory()

	client:StripWeapon("applicator")

	for k,_ in inv:Iter() do
		if (k.uniqueID == "toxic_ballon" and k:GetID() != 0  and ix.item.instances[k:GetID()]) then 
			k:Remove()

			break
		end
	end
end

CLASS_HAZMAT = CLASS.index