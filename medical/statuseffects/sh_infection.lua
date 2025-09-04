local PLUGIN = PLUGIN

EFFECT.name = "Инфекция"    

EFFECT.ConsequenceTime = ix.config.Get("InfectionTime")
EFFECT.Damage = ix.config.Get("InfectionDmg")

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    ply:Notify("Вам нездоровиться, найдите лекарство")

    timer.Create(ply:SteamID64().."Infection", self.ConsequenceTime, 1, function()
        ply:TakeDamage(self.Damage)
        character:AddTrauma("blurred", HITGROUP_HEAD)
    end)
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    ply = character:GetPlayer()
    if not IsValid(ply) then return end

    if timer.Exists(ply:SteamID64().."Infection") then
        timer.Remove(ply:SteamID64().."Infection")
    end
end