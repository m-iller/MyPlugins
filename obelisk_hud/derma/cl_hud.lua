-- Obelisk HUD Main Derma Panel

if CLIENT then
    -- Ensure PLUGIN is available
    PLUGIN = PLUGIN or {}
    PLUGIN.hpBarAlpha = PLUGIN.hpBarAlpha or 255
    
    -- Remove existing HUD if it exists
    if IsValid(ObeliskDermaHUD) then 
        ObeliskDermaHUD:Remove() 
    end

    -- Create main HUD panel
    ObeliskDermaHUD = vgui.Create("DPanel")
    ObeliskDermaHUD:SetSize(ScrW(), ScrH())
    ObeliskDermaHUD:SetPos(0, 0)
    ObeliskDermaHUD:SetPaintedManually(false)
    ObeliskDermaHUD:SetMouseInputEnabled(false)
    ObeliskDermaHUD:SetKeyboardInputEnabled(false)
    ObeliskDermaHUD:SetDrawOnTop(false) -- Render behind menus

    -- Main paint function that delegates to style-specific renderers
    function ObeliskDermaHUD:Paint(w, h)
        -- Ensure PLUGIN is available in Paint function
        PLUGIN = PLUGIN or {}
        PLUGIN.hpBarAlpha = PLUGIN.hpBarAlpha or 255
        
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        
        -- Check if HUD is hidden via option
        if ix.option.Get("ocultarHUD", false) then 
            return 
        end
        
        -- Get current HUD style
        local style = ix.option.Get("obelisk_hud_style", "standard")
        
        -- Draw crosshair if enabled
        if ix.option.Get("obelisk_hud_crosshair", true) then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(w/2 - 1, h/2 - 1, 2, 2)
        end
        
        -- Get player stats
        local hp = ply:Health()
        local maxHP = ply:GetMaxHealth() or 100
        local armor = ply:Armor() or 0
        local maxArmor = 100
        local stamina = ply:GetLocalVar("stm", 0)
        local maxStamina = 100
        
        -- Call style-specific renderer
        if OBELISK_HUD.renderers and OBELISK_HUD.renderers[style] then
            OBELISK_HUD.renderers[style](self, w, h, {
                hp = hp, maxHP = maxHP,
                armor = armor, maxArmor = maxArmor,
                stamina = stamina, maxStamina = maxStamina,
                shouldShowHP = true, hpAlpha = 255,
                shakeX = 0, shakeY = 0
            })
        else
            -- Fallback to standard renderer
            if OBELISK_HUD.renderers and OBELISK_HUD.renderers.standard then
                OBELISK_HUD.renderers.standard(self, w, h, {
                    hp = hp, maxHP = maxHP,
                    armor = armor, maxArmor = maxArmor,
                    stamina = stamina, maxStamina = maxStamina,
                    shouldShowHP = true, hpAlpha = 255,
                    shakeX = 0, shakeY = 0
                })
            end
        end
    end
end 