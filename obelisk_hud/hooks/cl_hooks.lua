-- Obelisk HUD Client Hooks

if CLIENT then
    -- Hook to hide default Helix HUD bars
    hook.Add("ShouldHideBars", "ObeliskHUD_ShouldHideBars", function()
        return true
    end)
    
    -- Hook to handle screen resolution changes
    hook.Add("OnScreenSizeChanged", "ObeliskHUD_OnScreenSizeChanged", function()
        if IsValid(ObeliskDermaHUD) then
            ObeliskDermaHUD:SetSize(ScrW(), ScrH())
            ObeliskDermaHUD:SetPos(0, 0)
        end
    end)
    
    -- Блокировка стандартного +zoom на стандартном Obelisk HUD
    hook.Add("PlayerBindPress", "ObeliskHUD_BlockZoomOnStandard", function(ply, bind, pressed)
        if ix.option.Get("obelisk_hud_style", "standard") == "standard" then
            if string.find(bind, "+zoom") then
                return true -- блокируем стандартный zoom
            end
        end
    end)
end 