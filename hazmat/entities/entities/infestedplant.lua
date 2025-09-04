ENT.Type = "anim"
ENT.PrintName = "Infested plant"
ENT.Category = "[SING] Hazmat"
ENT.Spawnable = true
ENT.AdminOnly = true

local PLUGIN = PLUGIN 

function ENT:Initialize()
	if SERVER then
		local modint = math.random(1,3)
		local colint = math.random(155, 255)

		self:SetModel(PLUGIN.PlantModels[modint])
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		self:SetColor(Color(colint, colint, colint))
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
	
			physObj:EnableMotion(false)
			physObj:Sleep()
	
		end
	end
end

function ENT:Use(activator)

end

function ENT:Destroy()
	local effectData = EffectData()
    	effectData:SetOrigin(self:GetPos()+Vector(0,0,5))
		effectData:SetScale(2.5)
    util.Effect("ElThumperDustectricSpark", effectData, true, true)

	self:EmitSound(PLUGIN.PlantDestructionSound, 75, 80)

	self:Remove()
end
