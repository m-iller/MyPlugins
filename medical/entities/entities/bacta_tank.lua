local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Miller"
ENT.Category = "[OBL] Roleplay Ents"
ENT.Spawnable = true
ENT.AdminSpawnable = true

    ENT.PrintName = "Бакта-танк"


function ENT:Initialize()
    if SERVER then
        self:SetModel("models/lordtrilobite/starwars/props/bactatank.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.bacta = ents.Create("prop_physics")
        self.bacta:SetModel("models/lordtrilobite/starwars/props/bactatankb.mdl")
        self.bacta:SetSolid(SOLID_NONE)
        self.bacta:SetPos(self:GetPos())
        self.bacta:SetAngles(self:GetAngles())
        self.bacta:SetParent(self)
        self.bacta:Spawn()

        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    end
end

function ENT:Use(client)
    if not IsValid(client) or not client:IsPlayer() then return end

    if self._lastUse and CurTime() - self._lastUse < 5 then
        return
    end

    self._lastUse = CurTime()

    client:SetAction("Getting In", 5)
    client:DoStaredAction(self, function()
        local oldPos = client:GetPos()
        local oldAngles = client:GetAngles()

        client:SetPos(self:GetPos() + Vector(0, 0, 30))
        client:SetAngles(self:GetAngles())
        client:Freeze(true)
        client:DoAnimationEvent(PLAYERANIMEVENT_SWIM)

        local char = client:GetCharacter()

        client:Notify(string.format("Вы лечитесь %s секунд", ix.config.Get("BactaHealTime")))

        client:SetAction("Healing", ix.config.Get("BactaHealTime"))

        timer.Simple(ix.config.Get("BactaHealTime"), function()
            for effectID, _ in pairs(char:GetTrauma()) do
                char:RemoveTrauma(effectID)
            end
            
            if client:GetNetVar("KnockedOut", false) then 
                char:KnockedOut(false)
            end
            if client:GetNetVar("Stunned", false) then
                char:Stuned(false)
            end

            client:SetHealth(client:GetMaxHealth())

            client:Freeze(false)
            client:SetPos(oldPos)
            client:SetAngles(oldAngles)

            client:Notify("Вы были вылечены бакта-танком.")
            client:SetAction()
        end)
    end, 5, function()
        client:Notify("Вы должны смотреть на бакта-танк!")
        client:SetAction()
    end)
end

function ENT:OnPopulateEntityInfo(tooltip)
	local title = tooltip:AddRow("name")
	title:SetImportant()
	title:SetText(self.PrintName)
	title:SetBackgroundColor(ix.config.Get("color"))
	title:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("Машина, которая лечит вас.")
	description:SizeToContents()
end