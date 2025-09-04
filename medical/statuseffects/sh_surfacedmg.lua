local PLUGIN = PLUGIN

EFFECT.name = "Внешняя травма" 

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end
end