-- Obelisk HUD Client Plugin

if CLIENT then
    print("[Obelisk HUD] Client plugin starting...")
    
    PLUGIN = PLUGIN or {}
    OBELISK_HUD = OBELISK_HUD or {}
    OBELISK_HUD.config = OBELISK_HUD.config or {}
    
    PLUGIN.hpBarAlpha = PLUGIN.hpBarAlpha or 255
    PLUGIN.lastHP = PLUGIN.lastHP or 0
    PLUGIN.lastArmor = PLUGIN.lastArmor or 0
    PLUGIN.hpBarShowTime = PLUGIN.hpBarShowTime or 0

    print("[Obelisk HUD] Client plugin loaded successfully")
end 