if SERVER then
local PLUGIN = PLUGIN

function PLUGIN:CharacterLoaded(character)
    local traumaEffects = character:GetData("traumaEffects", {})

    for effectID, traumaData in pairs(traumaEffects) do
        local effect = ix.effects.GetByName(traumaData.effectType)
        if effect then
            local newEffect = table.Copy(effect)
            newEffect:StartEffect(character, traumaData.hitgroup)
        end
    end
end

function PLUGIN:PlayerSpawn(client)
    if not IsValid(client) then return end
    
    local char = client:GetCharacter()
    
    if not char then return end

    local traumatable = char:GetTrauma()

    char:KnockedOut(false)
    char:Stuned(false)

    for effectID, _ in pairs(traumatable) do
        char:RemoveTrauma(effectID)
    end

    char:SetData("traumaEffects", {})
end

function PLUGIN:ixHealItemEffect(client, target, itemName, healAmount, removeEffect, specialEffectTable)
    if not target == client then
        local target = client:GetEyeTraceNoCursor().Entity
    end

    local targetChar = target:GetCharacter()

    local newHealth = target:Health() + healAmount

    if (newHealth > target:GetMaxHealth()) then
        newHealth = target:GetMaxHealth()
    end

    target:SetHealth(newHealth)

    -- Обработка удаления эффектов
    if (removeEffect == "all") then
        -- Удаляем все эффекты со всех конечностей
        local allTrauma = targetChar:GetTrauma()
        for effectID, _ in pairs(allTrauma) do
            targetChar:RemoveTrauma(effectID)
        end
    elseif type(removeEffect) == "table" then
        -- Удаляем конкретные типы эффектов со всех конечностей
        for _, effectType in ipairs(removeEffect) do
            targetChar:RemoveEffectsByType(effectType)
        end
    end

    -- Обработка специальных эффектов
    for effect, _ in pairs(specialEffectTable) do
        if (effect == "stun") then
            targetChar:Stunned(false)
        end
        
        if (effect == "knockedout") then
            targetChar:KnockedOut(false)
        end
    end
end
end