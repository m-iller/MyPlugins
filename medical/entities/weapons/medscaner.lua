local PLUGIN = PLUGIN

if ( SERVER ) then
	SWEP.HoldType = "slam"
end

if ( CLIENT ) then
	SWEP.PrintName = "Медицинский сканер"
	SWEP.Author = "Miller"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false					 
end

SWEP.Category = "[OBL] Roleplay Sweps"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 50
SWEP.ViewModel = "models/swcw_items/sw_datapad_v.mdl" 
SWEP.WorldModel = "models/swcw_items/sw_datapad.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.UseHands = true

SWEP.HoldType = "slam" 

SWEP.FiresUnderwater = true

SWEP.DrawCrosshair = true

SWEP.DrawAmmo = false

SWEP.Base = "weapon_base"

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1 
SWEP.Primary.Delay = 0
SWEP.Primary.DefaultClip = -1 
SWEP.Primary.Automatic = false 
SWEP.Primary.Ammo = "none" 

SWEP.Secondary.ClipSize = -1 
SWEP.Secondary.DefaultClip = -1 
SWEP.Secondary.Damage = 0 
SWEP.Secondary.Automatic = false 	 
SWEP.Secondary.Ammo = "none" 

function SWEP:Initialize() 
    self:SetWeaponHoldType( "slam" )
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    self.useTime = CurTime() + 0.5

    if (self._lastScanTime or 0) > CurTime() then
        return
    end
    self._lastScanTime = CurTime() + ix.config.Get("MedicalScannerCooldown")

    if not IsFirstTimePredicted() then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local tr = owner:GetEyeTrace()
    local target = tr.Entity

    if not IsValid(target) or not target:IsPlayer() or owner:GetPos():DistToSqr(target:GetPos()) > ix.config.Get("MedicalScannerRange") * ix.config.Get("MedicalScannerRange") then
        owner:Notify("Нет игрока для сканирования поблизости.")
        return
    end

    local char = target:GetCharacter()
    if not char then
        owner:Notify("Не удалось получить данные о цели.")
        return
    end

    owner:SetAction("Сканирует " .. target:Name() .. "...", ix.config.Get("ScanningTime"))
    owner:DoStaredAction(target, function()
        self:ScanPlayer(owner, target, char)
    end, ix.config.Get("ScanningTime"), function()
        owner:Notify("Вы должны смотреть на игрока")
        if (IsValid(owner)) then
            owner:SetAction()
        end
    end)
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local char = owner:GetCharacter()
    if not char then
        owner:Notify("Не удалось получить данные о себе.")
        return
    end

    if (self._lastSelfScanTime or 0) > CurTime() then
        owner:Notify("Сканер перезаряжается.")
        return
    end
    self._lastSelfScanTime = CurTime() + ix.config.Get("MedicalScannerCooldown")

    owner:SetAction("Сканирует себя...", ix.config.Get("ScanningTime"), function()
        self:ScanPlayer(owner, owner, char)
    end)
end
	
function SWEP:Reload()
end

function SWEP:ScanPlayer(owner, target, char)
    -- Отправляем сообщение только на сервере
    if not SERVER then return end
    
    local hp = target:Health()
    local maxhp = target:GetMaxHealth() or 100
    local hpPercent = math.Round((hp / maxhp) * 100)

    -- Получаем все травмы персонажа
    local traumaTable = char:GetTrauma()
    
    -- Собираем травмы по hitgroup'ам
    local traumasByLimb = {}
    local anyTrauma = false
    local totalTraumas = 0
    
    -- Инициализируем таблицу для всех hitgroup'ов
    for hitgroup, config in pairs(PLUGIN.HitgroupConfigTable) do
        traumasByLimb[hitgroup] = {}
    end
    
    -- Распределяем травмы по hitgroup'ам
    for effectID, traumaData in pairs(traumaTable) do
        if traumaData.active then
            local hitgroup = traumaData.hitgroup or HITGROUP_GENERIC
            if traumasByLimb[hitgroup] then
                table.insert(traumasByLimb[hitgroup], effectID)
                anyTrauma = true
                totalTraumas = totalTraumas + 1
            end
        end
    end

    -- Формируем строку отчёта
    local report = string.format("Сканирует %s: [Здоровье: %d%%]", target:Name(), hpPercent)
    
    if anyTrauma then
        local traumaParts = {}
        
        -- Проходим по всем hitgroup'ам в порядке конфигурации
        for hitgroup, config in pairs(PLUGIN.HitgroupConfigTable) do
            local traumas = traumasByLimb[hitgroup]
            if traumas and #traumas > 0 then
                -- Получаем названия эффектов
                local effectNames = {}
                for _, effectID in ipairs(traumas) do
                    -- Извлекаем базовое имя эффекта из полного идентификатора
                    local baseEffectName = string.match(effectID, "^([^_]+)")
                    local effect = ix.effects.GetByName(baseEffectName)
                    if effect and effect.name then
                        table.insert(effectNames, effect.name)
                    else
                        table.insert(effectNames, baseEffectName or effectID)
                    end
                end
                
                table.insert(traumaParts, string.format("%s: %s", config.name, table.concat(effectNames, ", ")))
            end
        end
        
        if #traumaParts > 0 then
            report = report .. string.format(" | Травмы (%d): %s", totalTraumas, table.concat(traumaParts, " | "))
        end
    else
        report = report .. " | Нет травм"
    end 

    -- Отправляем в /me
    ix.chat.Send(owner, "me", report, false)
end