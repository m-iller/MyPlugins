ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Шкаф с запчастями"
ENT.Author = "Miller"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "[SING] Mechanic"
ENT.Model = "models/props_c17/furnituredresser001a.mdl"

function ENT:Initialize()
    if SERVER then
		local modint = math.random(1,3)
		local colint = math.random(155, 255)

		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
	
			physObj:EnableMotion(false)
			physObj:Sleep()
	
		end
	end
end