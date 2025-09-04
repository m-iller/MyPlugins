local PLUGIN = PLUGIN

EFFECT.name = "Потеря крови"    

EFFECT.SpeedMultiplier = 0.8

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    ply:SetRunSpeed(ply:GetRunSpeed() * self.SpeedMultiplier)
    ply:SetWalkSpeed(ply:GetWalkSpeed() * self.SpeedMultiplier)

    net.Start("ixBloodLossEffect")
    net.WriteBool(true)
    net.Send(ply)
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    ply:SetRunSpeed(ix.config.Get("runSpeed"))
    ply:SetWalkSpeed(ix.config.Get("walkSpeed"))

    net.Start("ixBloodLossEffect")
    net.WriteBool(false)
    net.Send(ply)
end