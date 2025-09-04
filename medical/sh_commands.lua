local PLUGIN = PLUGIN

if SERVER then
    -- Команда для установки эффекта кровотечения
    ix.command.Add("addtrauma", {
        description = "Установить эффект травмы для персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.string,
            ix.type.number
        },
        OnRun = function(self, client, target, effect, hitgroup)
            if not target then
                return "Персонаж не найден!"
            end
            
            local effectID = target:AddTrauma(effect, hitgroup or HITGROUP_GENERIC)
            if effectID then
                local hitgroupName = "общая область"
                if PLUGIN.HitgroupConfigTable[hitgroup] then
                    hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
                end
                return "Эффект " .. (effect) .. " установлен для " .. target:GetName() .. " в " .. hitgroupName .. " (" .. effectID .. ")"
            else
                return "Ошибка: эффект " .. (effect) .. " не найден!"
            end
        end
    })

    -- Команда для получения всех эффектов травм
    ix.command.Add("gettrauma", {
        description = "Получить все эффекты травм персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character,
        },
        OnRun = function(self, client, target)
            if not target then
                return "Персонаж не найден!"
            end
            
            local effects = target:GetTrauma()
            local effectList = {}
            
            if next(effects) == nil then
                return "У " .. target:GetName() .. " нет активных эффектов травм"
            end

            for effectID, traumaData in pairs(effects) do
                local effect = ix.effects.GetByName(traumaData.effectType)
                local hitgroupName = "общая область"
                if PLUGIN.HitgroupConfigTable[traumaData.hitgroup] then
                    hitgroupName = PLUGIN.HitgroupConfigTable[traumaData.hitgroup].name
                end
                table.insert(effectList, effect:GetName() .. " (" .. hitgroupName .. ")")
            end

            return "Эффекты травм " .. target:GetName() .. ": " .. table.concat(effectList, ", ")
        end
    })

    -- Команда для получения травм конкретной конечности
    ix.command.Add("gettraumabylimb", {
        description = "Получить травмы конкретной конечности",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, hitgroup)
            if not target then
                return "Персонаж не найден!"
            end
            
            local effects = target:GetTraumaByHitgroup(hitgroup)
            local effectList = {}
            
            if next(effects) == nil then
                local hitgroupName = "неизвестная область"
                if PLUGIN.HitgroupConfigTable[hitgroup] then
                    hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
                end
                return "У " .. target:GetName() .. " нет травм в " .. hitgroupName
            end

            local hitgroupName = "неизвестная область"
            if PLUGIN.HitgroupConfigTable[hitgroup] then
                hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
            end

            for effectID, traumaData in pairs(effects) do
                local effect = ix.effects.GetByName(traumaData.effectType)
                table.insert(effectList, effect:GetName())
            end

            return "Травмы " .. target:GetName() .. " в " .. hitgroupName .. ": " .. table.concat(effectList, ", ")
        end
    })

    -- Команда для очистки всех эффектов травм
    ix.command.Add("cleartrauma", {
        description = "Очистить все эффекты травм у персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character
        },
        OnRun = function(self, client, target)
            if not target then
                return "Персонаж не найден!"
            end
            
            for effectID, _ in pairs(target:GetTrauma()) do
                target:RemoveTrauma(effectID)
            end
            return "Эффекты травм очищены у " .. target:GetName()
        end
    })

    -- Команда для очистки травм конкретной конечности
    ix.command.Add("cleartraumabylimb", {
        description = "Очистить травмы конкретной конечности",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, hitgroup)
            if not target then
                return "Персонаж не найден!"
            end
            
            local effects = target:GetTraumaByHitgroup(hitgroup)
            local removedCount = 0
            
            for effectID, _ in pairs(effects) do
                target:RemoveTrauma(effectID)
                removedCount = removedCount + 1
            end

            local hitgroupName = "неизвестная область"
            if PLUGIN.HitgroupConfigTable[hitgroup] then
                hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
            end

            return "Удалено " .. removedCount .. " травм в " .. hitgroupName .. " у " .. target:GetName()
        end
    })

    -- Команда для удаления конкретного эффекта с конкретной конечности
    ix.command.Add("removetrauma", {
        description = "Удалить конкретный эффект с конкретной конечности",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.string,
            ix.type.number
        },
        OnRun = function(self, client, target, effectType, hitgroup)
            if not target then
                return "Персонаж не найден!"
            end
            
            if target:HasEffectOnLimb(effectType, hitgroup) then
                local effect = ix.effects.GetByName(effectType)
                if effect then
                    effect:EndEffect(target, hitgroup)
                    
                    local hitgroupName = "неизвестная область"
                    if PLUGIN.HitgroupConfigTable[hitgroup] then
                        hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
                    end
                    
                    return "Эффект " .. effectType .. " удален с " .. hitgroupName .. " у " .. target:GetName()
                end
            else
                local hitgroupName = "неизвестная область"
                if PLUGIN.HitgroupConfigTable[hitgroup] then
                    hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
                end
                return "У " .. target:GetName() .. " нет эффекта " .. effectType .. " на " .. hitgroupName
            end
        end
    })

    -- Команда для удаления всех эффектов определенного типа
    ix.command.Add("removeeffecttype", {
        description = "Удалить все эффекты определенного типа со всех конечностей",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.string
        },
        OnRun = function(self, client, target, effectType)
            if not target then
                return "Персонаж не найден!"
            end
            
            local removedCount = target:RemoveEffectsByType(effectType)
            
            if removedCount > 0 then
                return "Удалено " .. removedCount .. " эффектов типа " .. effectType .. " у " .. target:GetName()
            else
                return "У " .. target:GetName() .. " нет эффектов типа " .. effectType
            end
        end
    })

    -- Команда для проверки наличия эффекта на конечности
    ix.command.Add("haseffect", {
        description = "Проверить наличие эффекта на конечности",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.string,
            ix.type.number
        },
        OnRun = function(self, client, target, effectType, hitgroup)
            if not target then
                return "Персонаж не найден!"
            end
            
            local hasEffect = target:HasEffectOnLimb(effectType, hitgroup)
            local hitgroupName = "неизвестная область"
            if PLUGIN.HitgroupConfigTable[hitgroup] then
                hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
            end
            
            if hasEffect then
                return "У " .. target:GetName() .. " есть эффект " .. effectType .. " на " .. hitgroupName
            else
                return "У " .. target:GetName() .. " нет эффекта " .. effectType .. " на " .. hitgroupName
            end
        end
    })

    ix.command.Add("stun", {
        description = "Оглушить персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character,
            ix.type.number
        },
        OnRun = function(self, client, target, duration)
            if not target then
                return "Персонаж не найден!"
            end

            target:Stuned(true, duration)
        end
    })

    ix.command.Add("unstun", {
        description = "Разглушить персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character,
        },
        OnRun = function(self, client, target)
            if not target then
                return "Персонаж не найден!"
            end

            target:Stuned(false)
        end
    })  

    ix.command.Add("knockedout", {
        description = "Оглушить персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character,
        },
        OnRun = function(self, client, target)
            if not target then
                return "Персонаж не найден!"
            end

            target:KnockedOut(true)
        end
    })  

    ix.command.Add("unknockedout", {
        description = "Разбудить персонажа",
        adminOnly = true,
        arguments = {
            ix.type.character,
        },
        OnRun = function(self, client, target)
            if not target then
                return "Персонаж не найден!"
            end

            target:KnockedOut(false)
        end
    })
end 