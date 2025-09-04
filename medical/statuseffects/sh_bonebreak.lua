local PLUGIN = PLUGIN

EFFECT.name = "Перелом кости"   

EFFECT.SpeedMultiplier = 0.5

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    if hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_LEFTLEG then
        ply:SetRunSpeed(ply:GetRunSpeed() * self.SpeedMultiplier)
        ply:SetWalkSpeed(ply:GetWalkSpeed() * self.SpeedMultiplier)
    end
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    if hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_LEFTLEG then
        ply:SetRunSpeed(ix.config.Get("runSpeed"))
        ply:SetWalkSpeed(ix.config.Get("walkSpeed"))
    end
end