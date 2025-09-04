local PLUGIN = PLUGIN

if SERVER then
    function PLUGIN:EntityTakeDamage(client, dmgInfo)
        if dmgInfo:IsDamageType(DMG_SONIC) then
            return
        end

        if client:IsPlayer() then
            local hitGroup = client:LastHitGroup()
            local attacker = dmgInfo:GetAttacker()

            local damage = dmgInfo:GetDamage()
            local hppercent = damage / client:GetMaxHealth() * 100
            
            local char = client:GetCharacter()

            local traumaadded = {}

            if PLUGIN.HitgroupConfigTable[hitGroup] then
                dmgInfo:ScaleDamage(PLUGIN.HitgroupConfigTable[hitGroup].modifier)

                for k,v in pairs(PLUGIN.HitgroupConfigTable[hitGroup].effects) do
                    if hppercent >= v and not char:HasEffectOnLimb(k, hitGroup) then
                        traumaadded[k] = true
                    end
                end
            end

            local effectswhitelist = {}
            
            if dmgInfo:IsBulletDamage() then
                effectswhitelist = PLUGIN.DamageTypesConfigTable.bulletDmg.aveffects
            elseif dmgInfo:IsDamageType(DMG_BURN) then
                effectswhitelist = PLUGIN.DamageTypesConfigTable.burnDmg.aveffects
            elseif dmgInfo:IsFallDamage() then
                effectswhitelist = PLUGIN.DamageTypesConfigTable.fallDmg.aveffects
            elseif dmgInfo:IsExplosionDamage() then
                effectswhitelist = PLUGIN.DamageTypesConfigTable.explDmg.aveffects
            else
                effectswhitelist = PLUGIN.DamageTypesConfigTable.generic.aveffects
            end
            
            for k,v in pairs(traumaadded) do
                if effectswhitelist[k] then
                    char:AddTrauma(k, hitGroup)
                end
            end
        end
    end
end