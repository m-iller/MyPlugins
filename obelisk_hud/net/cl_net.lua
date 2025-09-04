-- Obelisk HUD Client Network File

if CLIENT then
    -- Example network receiver for HUD updates
    -- This can be used for server-side HUD modifications
    
    net.Receive("ObeliskHUD_Update", function()
        local updateType = net.ReadString()
        local value = net.ReadInt(32)
        
        if updateType == "shake_intensity" then
            -- Update shake intensity from server
            OBELISK_HUD.config.shakeMoveAmpX = value
            OBELISK_HUD.config.shakeMoveAmpY = value
        elseif updateType == "color_theme" then
            -- Update color theme from server
            -- Implementation can be added here
        end
    end)
    
    -- Network receiver for HUD style changes (for visor item)
    net.Receive("ObeliskHUD_SetStyle", function()
        local style = net.ReadString()
        
        if style and style ~= "" then
            -- Сохраняем предыдущий стиль если это visor
            if style == "visor" then
                PLUGIN._previousHUDStyle = PLUGIN._previousHUDStyle or ix.option.Get("obelisk_hud_style", "standard")
            elseif style == "standard" then
                PLUGIN._previousHUDStyle = PLUGIN._previousHUDStyle or ix.option.Get("obelisk_hud_style", "visor")
            end
            
            -- Устанавливаем новый стиль
            ix.option.Set("obelisk_hud_style", style)
            
            -- Уведомляем игрока
            local client = LocalPlayer()
            if IsValid(client) then
                if style == "visor" then
                    client:Notify("HUD switched to visor mode!")
                else
                    client:Notify("HUD returned to " .. style .. " mode!")
                end
            end
        end
    end)
end 