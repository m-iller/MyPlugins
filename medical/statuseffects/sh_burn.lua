local PLUGIN = PLUGIN

EFFECT.name = "Ожог"

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    local levelBurn = math.random(1, 10)

    if levelBurn <=4 then
        character:AddTrauma("bleedingmed", hitgroup)
    elseif levelBurn <=8 then
        character:AddTrauma("bleedingmin", hitgroup)
    else
        character:AddTrauma("infection", hitgroup)
    end
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end
end