ENT.Type = "anim"
ENT.PrintName = "Test Mechanic Entity"
ENT.Category = "[SING] Mechanic"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
    if SERVER then
		self:SetModel("models/props_interiors/VendingMachineSoda01a.mdl")
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