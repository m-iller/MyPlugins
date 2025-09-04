local PLUGIN = PLUGIN

-- Проверяем, был ли уже показан баннер при запуске сервера
if not OBELISK_HUD or not OBELISK_HUD._bannerShown then
    print([[
      ____   ____   ______  _       _____   _____  _  __
     / __ \ |  _ \ |  ____|| |     |_   _| / ____|| |/ /
    | |  | || |_) || |__   | |       | |  | (___  | ' /
    | |  | ||  _ < |  __|  | |       | |   \___ \ |  <
    | |__| || |_) || |____ | |____  _| |_  ____) || . \
     \____/ |____/ |______||______||_____||_____/ |_|\_\
     
                    HUD Plugin v1.0
                                                              
     Custom HUD for Obelisk RP server with multiple styles      
     Author: YoungV                                              
     Features: Standard, Visor, Helmet, Debugger modes          
]])
    
    -- Отмечаем, что баннер уже показан
    OBELISK_HUD = OBELISK_HUD or {}
    OBELISK_HUD._bannerShown = true
end


PLUGIN.name = "Obelisk RP HUD"
PLUGIN.description = "Custom HUD for Obelisk RP server with multiple styles"
PLUGIN.author = "YoungV"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 YoungV

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- Add options in shared area (works for both client and server)
ix.option.Add("obelisk_hud_style", ix.type.array, "standard", {
    category = "Obelisk HUD",
    populate = function()
        local styles = {
            standard = L("hud_style_standard") or "Standard HUD",
            visor = L("hud_style_visor") or "Visor",
            helmet = L("hud_style_helmet") or "Helmet",
            debugger = L("hud_style_debugger") or "Debugger"
        }
        -- Защита: если выбранный стиль не существует, сбрасываем на standard
        local value = ix.option.Get("obelisk_hud_style", "standard")
        if not styles[value] then
            ix.option.Set("obelisk_hud_style", "standard")
        end
        return styles
    end
})

ix.option.Add("obelisk_hud_crosshair", ix.type.bool, true, {
    category = "Obelisk HUD"
})

ix.option.Add("ocultarHUD", ix.type.bool, false, {
    category = "Obelisk HUD"
})

ix.option.Add("obelisk_compass_tick_align", ix.type.array, "center", {
    category = "Obelisk HUD | Compass",
    populate = function()
        return {
            ["top"] = "По верху",
            ["center"] = "По центру",
            ["bottom"] = "По низу"
        }
    end
})

ix.option.Add("obelisk_compass_font", ix.type.array, "ixMenuButtonFont", {
    category = "Obelisk HUD | Compass",
    populate = function()
        return {
            ["ixMenuButtonFont"] = "ixMenuButtonFont",
            ["ixMenuButtonFontSmall"] = "ixMenuButtonFontSmall",
            ["ix3D2DMediumFont"] = "ix3D2DMediumFont",
            ["ix3D2DFont"] = "ix3D2DFont",
            ["ixTitleFont"] = "ixTitleFont",
            ["ixMenuButtonLabelFont"] = "ixMenuButtonLabelFont",
            ["ixNoticeFont"] = "ixNoticeFont"
        }
    end
})

-- Серверные include и логика
ix.util.Include("net/sv_net.lua", "server")
ix.util.Include("hooks/sv_hooks.lua", "server")

-- Клиентские include и логика
ix.util.Include("cl_options.lua", "client") -- Загружаем настройки первыми
ix.util.Include("net/cl_net.lua", "client")
ix.util.Include("derma/cl_standard.lua", "client")
ix.util.Include("derma/cl_visor.lua", "client")
ix.util.Include("derma/cl_helmet.lua", "client")
ix.util.Include("derma/cl_debugger.lua", "client")
ix.util.Include("derma/cl_hud.lua", "client")
ix.util.Include("hooks/cl_hooks.lua", "client")

print("[Obelisk HUD] Loaded...") 