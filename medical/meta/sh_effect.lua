local PLUGIN = PLUGIN
ix.meta = ix.meta or {}

local EFFECT = ix.meta.effect or {}

EFFECT.__index = EFFECT
EFFECT.name = 'undefined'   
EFFECT.uniqueID = 'undefined'
EFFECT.healItems = {}
EFFECT.isActive = false
EFFECT.hitgroup = HITGROUP_GENERIC
EFFECT.DamageType = DMG_SONIC -- better not change it, because in damage processing, to not add any other effects

function EFFECT:GetName()
    return self.name
end

function EFFECT:GetUniqueID()
    return self.uniqueID
end

-- Генерирует уникальный ID для эффекта на конкретной конечности
function EFFECT:GenerateLimbEffectID(hitgroup)
    return self.uniqueID .. "_" .. tostring(hitgroup)
end

function EFFECT:StartEffect(character, hitgroup)
    local currentEffects = character:GetData("traumaEffects", {})
    local limbEffectID = self:GenerateLimbEffectID(hitgroup)
    
    -- Проверяем, есть ли уже такой эффект на этой конечности
    if currentEffects[limbEffectID] then
        return limbEffectID
    end

    self.hitgroup = hitgroup or self.hitgroup
    currentEffects[limbEffectID] = {
        active = true,
        hitgroup = self.hitgroup,
        effectType = self.uniqueID,
        startTime = os.time(),
    }
    character:SetData("traumaEffects", currentEffects)
    self.isActive = true

    self:OnStart(character, hitgroup)
    return limbEffectID
end

function EFFECT:OnStart(character, hitgroup)
    return
end

function EFFECT:EndEffect(character, hitgroup)
    local currentEffects = character:GetData("traumaEffects", {})
    local limbEffectID = self:GenerateLimbEffectID(hitgroup)
    
    if currentEffects[limbEffectID] then
        currentEffects[limbEffectID] = nil
        character:SetData("traumaEffects", currentEffects)
        self.isActive = false
        self:OnEnd(character, hitgroup)
        return true
    end
    
    return false
end

function EFFECT:OnEnd(character, hitgroup)
    return
end

function EFFECT:GetEffect()
    return self
end

ix.meta.effect = EFFECT

local CHAR = ix.meta.character

if SERVER then
    function CHAR:GetTrauma()
        return self:GetData("traumaEffects", {})
    end

    function CHAR:AddTrauma(effectName, hitgroup)
        local effect = ix.effects.GetByName(effectName)

        if effect then
            local newEffect = table.Copy(effect)
            newEffect.uniqueID = effect.uniqueID -- Убеждаемся, что uniqueID скопирован
            local effectID = newEffect:StartEffect(self, hitgroup)
            
            return effectID
        end
        return nil
    end

    function CHAR:RemoveTrauma(effectID)
        local currentEffects = self:GetTrauma()
        if not currentEffects[effectID] then return false end
        
        local effectType = currentEffects[effectID].effectType
        local hitgroup = currentEffects[effectID].hitgroup
        local effect = ix.effects.GetByName(effectType)
        
        if effect then
            local newEffect = table.Copy(effect)
            newEffect:EndEffect(self, hitgroup)
            return true
        end
        return false
    end

    -- Получение травм конкретной конечности
    function CHAR:GetTraumaByHitgroup(hitgroup)
        local allTrauma = self:GetTrauma()
        local hitgroupTrauma = {}
        
        for effectID, traumaData in pairs(allTrauma) do
            if traumaData.hitgroup == hitgroup then
                hitgroupTrauma[effectID] = traumaData
            end
        end
        
        return hitgroupTrauma
    end

    -- Проверка наличия эффекта на конкретной конечности
    function CHAR:HasEffectOnLimb(effectName, hitgroup)
        local allTrauma = self:GetTrauma()
        local limbEffectID = effectName .. "_" .. tostring(hitgroup)
        
        return allTrauma[limbEffectID] and allTrauma[limbEffectID].active
    end

    -- Проверка наличия любого эффекта
    function CHAR:HasEffect(effectID)
        local effects = self:GetTrauma()
        return effects[effectID] and effects[effectID].active
    end

    -- Получение всех эффектов определенного типа
    function CHAR:GetEffectsByType(effectType)
        local allTrauma = self:GetTrauma()
        local typeEffects = {}
        
        for effectID, traumaData in pairs(allTrauma) do
            if traumaData.effectType == effectType then
                typeEffects[effectID] = traumaData
            end
        end
        
        return typeEffects
    end

    -- Удаление всех эффектов определенного типа
    function CHAR:RemoveEffectsByType(effectType)
        local typeEffects = self:GetEffectsByType(effectType)
        local removedCount = 0
        
        for effectID, traumaData in pairs(typeEffects) do
            local effect = ix.effects.GetByName(effectType)
            if effect then
                local newEffect = table.Copy(effect)
                newEffect:EndEffect(self, traumaData.hitgroup)
                removedCount = removedCount + 1
            end
        end
        
        return removedCount
    end
else    
    function CHAR:GetTrauma()
        return self:GetData("traumaEffects", {})
    end 

    -- Клиентские версии функций
    function CHAR:GetTraumaByHitgroup(hitgroup)
        local allTrauma = self:GetTrauma()
        local hitgroupTrauma = {}
        
        for effectID, traumaData in pairs(allTrauma) do
            if traumaData.hitgroup == hitgroup then
                hitgroupTrauma[effectID] = traumaData
            end
        end
        
        return hitgroupTrauma
    end

    function CHAR:HasEffectOnLimb(effectName, hitgroup)
        local allTrauma = self:GetTrauma()
        local limbEffectID = effectName .. "_" .. tostring(hitgroup)
        
        return allTrauma[limbEffectID] and allTrauma[limbEffectID].active
    end

    function CHAR:HasEffect(effectID)
        local effects = self:GetTrauma()
        return effects[effectID] and effects[effectID].active
    end

    function CHAR:GetEffectsByType(effectType)
        local allTrauma = self:GetTrauma()
        local typeEffects = {}
        
        for effectID, traumaData in pairs(allTrauma) do
            if traumaData.effectType == effectType then
                typeEffects[effectID] = traumaData
            end
        end
        
        return typeEffects
    end
end