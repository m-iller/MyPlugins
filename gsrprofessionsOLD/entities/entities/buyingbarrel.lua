ENT.Type = "anim"
ENT.PrintName = "Toxic Waste Disposal"
ENT.Category = "Singularity - Miller's Branch"
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
		self:SetColor(Color(colint, colint, colint))
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
	
			physObj:EnableMotion(false)
			physObj:Sleep()
	
		end

		self.nextUseTime = CurTime()
	end
end

function ENT:Use(activator)
	local char = activator:GetCharacter()
	local inv = char:GetInventory()

	self:EmitSound("tetopear/tetopear.ogg")

	activator:SetAction("СЛИВ ГОВНА", 4, function()
		activator:Freeze(false)
		
		local container = inv:HasItem("toxic_ballon")
		local volume = container:GetVolume()
		
		if container then
			if volume > 0 then
				local loyalty = volume*0.0005
				activator:Notify("Вот тебе твои "..tostring(loyalty).." лояльности")

				char:AddLoyalty(loyalty)

				self:EmitSound("tetopear/tetopear.ogg")

				container:SetVolume(0)
			else
				activator:Notify("НИХУЯ НЕТУ ПИДОРАС")	
			end
		end

		activator:Notify("Спасибо за работу")		
	end)
	activator:Freeze(true)
end