ENT.Type = "anim"
ENT.PrintName = "Corpse Bag"
ENT.Category = "[SING] Hazmat"
ENT.Spawnable = true
ENT.AdminOnly = true

local PLUGIN = PLUGIN 

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/bodybags/bodybag_01.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Sleep()
		end
	end
end

function ENT:Use(activator)
    if self:IsPlayerHolding() then
		activator:DropObject()
    else
        activator:PickupObject(self)
    end
end

function ENT:BurnCorpseDown(client)
	local char = client:GetCharacter()

	self:Ignite(PLUGIN.CorpseBurningTime)

	timer.Simple(PLUGIN.CorpseBurningTime, function() 
		local loyalty = PLUGIN.RewardForCorpse
		client:Notify("Вы получили "..tostring(loyalty).." лояльности")

		char:AddLoyalty(loyalty)
		self:Remove()
	end)
end