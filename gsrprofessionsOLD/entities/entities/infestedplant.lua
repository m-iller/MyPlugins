ENT.Type = "anim"
ENT.PrintName = "Infested plant"
ENT.Category = "Singularity - Miller's Branch"
ENT.Spawnable = true
ENT.AdminOnly = true

local PLUGIN = PLUGIN 

local models = {
	[1] = "models/jq/hlvr/props/infestation/p1/rock_1.mdl",
	[2] = "models/jq/hlvr/props/infestation/p1/rock_2.mdl",
	[3] = "models/jq/hlvr/props/infestation/p1/rock_4.mdl"
}

function ENT:Initialize()
	if SERVER then
		local modint = math.random(1,3)
	local colint = math.random(155, 255)

		self:SetModel(models[modint])
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
		self:SetColor(Color(colint, colint, colint))
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
	
			physObj:EnableMotion(false)
			physObj:Sleep()
	
		end

		self.nextUseTime = CurTime()
	end
end

function ENT:ColorDown()
	local curcol = self:GetColor()
	
	if (curcol.r < 10 and curcol.g < 10 and curcol.b<10) then
		self:Harden()
		return
	else
		local r = curcol.r - 1
		local g = curcol.g - 1
		local b = curcol.b - 1

		local newcol = Vector(r/255,g/255,b/255):ToColor()
		
		self:SetColor(newcol)
	end
end

function ENT:Harden()
	local effectData = EffectData()
    	effectData:SetOrigin(self:GetPos()+Vector(0,0,5))
		effectData:SetScale(2.5)
    util.Effect("ElThumperDustectricSpark", effectData, true, true)

	self:EmitSound("player/footsteps/p2_fs_jump_land_tile_01.wav", 75, 80)

	self:Remove()
end
