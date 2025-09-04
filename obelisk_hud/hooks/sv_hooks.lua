-- Obelisk HUD Server Hooks

if SERVER then
    -- Server-side hooks can be added here if needed
    -- For now, this is mostly a client-side plugin
    
    util.AddNetworkString("Obelisk_PoliceDeath")
    
    -- Hook to handle player initial spawn
    hook.Add("PlayerInitialSpawn", "ObeliskHUD_PlayerInitialSpawn", function(ply)
        -- Send initial HUD configuration to client
        -- This can be used to sync server-side settings with client
    end)
    
    -- Hook to handle player spawn
    hook.Add("PlayerSpawn", "ObeliskHUD_PlayerSpawn", function(ply)
        -- Reset any server-side HUD variables if needed
    end)
    
    -- Hook to handle player death
    hook.Add("PlayerDeath", "ObeliskHUD_PlayerDeath", function(ply, inflictor, attacker)
        local char = ply.GetCharacter and ply:GetCharacter()
        local FACTION_POLICE = FACTION_POLICE or _G.FACTION_POLICE
        if char and char.GetFaction and char:GetFaction() == FACTION_POLICE then
            net.Start("Obelisk_PoliceDeath")
                net.WriteVector(ply:GetPos())
                net.WriteString(ply:Nick() or "")
                net.WriteInt(ply:EntIndex(), 16)
            net.Broadcast()
        end
    end)
    
    -- Hook to handle player damage
    hook.Add("EntityTakeDamage", "ObeliskHUD_EntityTakeDamage", function(target, dmginfo)
        if target:IsPlayer() then
            -- Handle any server-side HUD logic on damage
        end
    end)

    function PLUGIN:ObeliskVisorEquipped(client, equipped, item)
        if equipped then
            net.Start("ObeliskHUD_SetStyle")
			net.WriteString("visor")
			net.Send(client)
        else
            net.Start("ObeliskHUD_SetStyle")
            net.WriteString("standard")
            net.Send(client)
        end
    end
end 