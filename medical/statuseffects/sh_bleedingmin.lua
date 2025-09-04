local PLUGIN = PLUGIN

EFFECT.name = "Легкое кровотечение" 

EFFECT.tickInterval = 5
EFFECT.damagePerTick = ix.config.Get("BleedingMinDmg")
EFFECT.maxTicks = 0

-- Внутренние переменные
EFFECT._timerID = nil
EFFECT._ticksDone = 0

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()
    if not IsValid(ply) then return end

    self._ticksDone = 0

    -- Генерируем уникальный ID для таймера с учетом конечности
    self._timerID = "bleedingmin_" .. tostring(ply:SteamID64()) .. "_" .. tostring(self.uniqueID) .. "_" .. tostring(hitgroup)

    timer.Create(self._timerID, self.tickInterval, self.maxTicks, function()
        if not IsValid(ply) or not self.isActive then
            timer.Remove(self._timerID)
            return
        end

        -- Проверяем, что эффект все еще активен на этой конечности
        if not character:HasEffectOnLimb(self.uniqueID, hitgroup) then
            timer.Remove(self._timerID)
            return
        end

        -- Наносим урон
        local dmg = DamageInfo()
        dmg:SetDamage(self.damagePerTick)
        dmg:SetDamageType(self.DamageType)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        ply:TakeDamageInfo(dmg)

        self._ticksDone = self._ticksDone + 1

        -- Если достигли максимального количества тиков, завершаем эффект
        if self._ticksDone >= self.maxTicks and self.maxTicks ~= 0 or not self.isActive then
            self:EndEffect(character, hitgroup)
        end
    end)
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()

    -- Используем тот же ID таймера, что и при создании
    self._timerID = "bleedingmin_" .. tostring(ply:SteamID64()) .. "_" .. tostring(self.uniqueID) .. "_" .. tostring(hitgroup)

    timer.Remove(self._timerID)

    self._timerID = nil

    -- Добавляем эффект потери крови только если это не общая область
    if hitgroup ~= HITGROUP_GENERIC then
        character:AddTrauma("bloodloss", HITGROUP_GENERIC)
    end
end