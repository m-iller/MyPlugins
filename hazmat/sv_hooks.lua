local PLUGIN = PLUGIN

-- Furnace area
local minVecFurnace = {
	x = math.min(PLUGIN.FurnaceArea["Start"].x, PLUGIN.FurnaceArea["End"].x),
	y = math.min(PLUGIN.FurnaceArea["Start"].y, PLUGIN.FurnaceArea["End"].y),
	z = math.min(PLUGIN.FurnaceArea["Start"].z, PLUGIN.FurnaceArea["End"].z)
}
local maxVecFurnace = {
	x = math.max(PLUGIN.FurnaceArea["Start"].x, PLUGIN.FurnaceArea["End"].x),
	y = math.max(PLUGIN.FurnaceArea["Start"].y, PLUGIN.FurnaceArea["End"].y),
	z = math.max(PLUGIN.FurnaceArea["Start"].z, PLUGIN.FurnaceArea["End"].z)
}

if SERVER then
    function PLUGIN:PlayerDeath(client) --creating a corpse after death
        local corpse = ents.Create('prop_ragdoll')
        corpse:SetModel(client:GetModel())
        corpse:SetPos(client:GetPos())
        
        for _, v in pairs(client:GetBodyGroups()) do
            corpse:SetBodygroup(v.id, client:GetBodygroup(v.id))
        end
        
        corpse:Spawn()
        corpse:SetNetVar("IsCorpse", true)
        corpse:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end

    function PLUGIN:OnPlayerPhysicsDrop(client, ent) --checking a corpsebag when it is dropped using +use 
	    if ent:GetClass() == "corpsebag" then
            local cpos = ent:GetPos()

            print(cpos)

		    if (cpos.x >= minVecFurnace.x and cpos.x <= maxVecFurnace.x) and (cpos.y >= minVecFurnace.y and cpos.y <= maxVecFurnace.y) and (cpos.z+50 >= minVecFurnace.z and cpos.z+50 <= maxVecFurnace.z) then
		    	ent:BurnCorpseDown(client)
		    end
        end
    end

    function PLUGIN:OnEntityCreated(ent) --setting up mechanic entities parameters + AREA
        if PLUGIN.MechanicEntities[ent:GetClass()] or PLUGIN.UtilityEnts[ent:GetClass()] then
            ent.ixAreaEntity = true
            ent:SetNetVar("broken", false)
            ent:SetNetVar("breakUseChance", PLUGIN.MechanicEntities[ent:GetClass()].breakUseChance)
            ent:SetNetVar("breakType1", "none")
            ent:SetNetVar("breakType2", "none")
            ent:SetNetVar("breakType3", "none")
            ent:SetNetVar("checked", false)

            ent:SetHealth(PLUGIN.MechanicEntities[ent:GetClass()].hp)
        end
    end

    function PLUGIN:EntityTakeDamage(ent, dmginfo) --damage breakage
        if (PLUGIN.MechanicEntities[ent:GetClass()] or PLUGIN.UtilityEnts[ent:GetClass()]) and not ent:GetNetVar("broken") then
            hp = ent:Health() - dmginfo:GetDamage()
            local client = dmginfo:GetAttacker()

            if hp <= 0 then
                PLUGIN:IxEntityBreak(client, ent)
                client:Notify("Похоже вы что-то сломали")
            end

            ent:SetHealth(hp)
        end
    end
end