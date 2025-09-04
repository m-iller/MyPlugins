ENT.Type = "anim"
ENT.PrintName = "Extraction Point"
ENT.Category = "Loot Extraction"
ENT.Spawnable = true
ENT.AdminOnly = true

local PLUGIN = PLUGIN 
if SERVER then

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_c17/FurnitureFridge001a.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)

		self.Vars = {}
		self.Vars.CurrentItem = PLUGIN.defaultitem
		self.Vars.Owner = ""
		self.Vars.LootAmount = 0
	
		local physObj = self:GetPhysicsObject()
	
		if (IsValid(physObj)) then
	
			physObj:EnableMotion(false)
			physObj:Sleep()
	
		end

		self.nextUseTime = CurTime()
	end
end

function ENT:Use(activator)
	if (CurTime() < (activator.ixNextOpen or 0)) then
		return
	end

	if self.Vars.Owner == activator:SteamID64() then

		activator:SetAction("Interacting...", 1)
		activator:DoStaredAction(self, function()
			if (IsValid(activator) and activator:Alive()) then
				net.Start("ixOpenLootExtractionMenu")
            		net.WriteEntity(self)
					net.WriteString(self.Vars.CurrentItem)
					net.WriteUInt(self.Vars.LootAmount, 8)
    			net.Send(activator)
			end
		end, 1, function()
			if (IsValid(activator)) then
				activator:SetAction()
			end
		end)

	else
		local oldplayer = player.GetBySteamID64(self.Vars.Owner)

		if IsValid(oldplayer) then
			oldplayer:Notify("Your extractor is being captured...")
		end

		activator:SetAction("Capturing...", PLUGIN.capturetime)
		activator:DoStaredAction(self, function()
			self.Vars.Owner = activator:SteamID64()
			activator:Notify("You have captured an extraction point!")
		end, PLUGIN.capturetime, function()
			if (IsValid(activator)) then
				activator:SetAction()
			end
		end)
		
		if IsValid(oldplayer) then
			oldplayer:Notify("You have lost an extractor!")
		end
	end

	activator.ixNextOpen = CurTime() + 1
end

else

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local title = tooltip:AddRow("name")
	title:SetImportant()
	title:SetText(self.PrintName)
	title:SetBackgroundColor(ix.config.Get("color"))
	title:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("A machine that extractes items.")
	description:SizeToContents()
end

end