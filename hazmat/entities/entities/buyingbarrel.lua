ENT.Type = "anim"
ENT.PrintName = "Toxic Waste Disposal"
ENT.Category = "[SING] Hazmat"
ENT.Spawnable = true
ENT.AdminOnly = true

local PLUGIN = PLUGIN 

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/barrel_plastic_1/barrel_plastic_1.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
	
			physObj:EnableMotion(false)
			physObj:Sleep()
	
		end
	end
end