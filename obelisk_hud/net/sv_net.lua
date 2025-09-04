-- Obelisk HUD Server Network File

if SERVER then
    -- Create network strings for HUD communication
    util.AddNetworkString("ObeliskHUD_Update")
    util.AddNetworkString("ObeliskHUD_SetStyle")
    
    -- Function to send HUD style change to player
    function OBELISK_HUD:SendStyleToPlayer(ply, style)
        if not IsValid(ply) then return end
        
        net.Start("ObeliskHUD_SetStyle")
        net.WriteString(style)
        net.Send(ply)
    end
    
    -- Example function to send HUD update to all players
    function OBELISK_HUD:BroadcastUpdate(updateType, value)
        net.Start("ObeliskHUD_Update")
        net.WriteString(updateType)
        net.WriteInt(value, 32)
        net.Broadcast()
    end
    
    -- Example function to send HUD update to specific player
    function OBELISK_HUD:SendUpdateToPlayer(ply, updateType, value)
        if not IsValid(ply) then return end
        
        net.Start("ObeliskHUD_Update")
        net.WriteString(updateType)
        net.WriteInt(value, 32)
        net.Send(ply)
    end
end 