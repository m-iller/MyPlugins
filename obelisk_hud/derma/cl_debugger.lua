-- Obelisk HUD Debugger Style Renderer

if CLIENT then
    -- Ensure OBELISK_HUD.renderers is initialized
    OBELISK_HUD = OBELISK_HUD or {}
    OBELISK_HUD.renderers = OBELISK_HUD.renderers or {}
    
    -- Настройки смещений для текста информации о сущности
    local ENTITY_INFO_OFFSET_X = 200
    local ENTITY_INFO_OFFSET_Y = 9
    local ENTITY_INFO_LINE_HEIGHT = 18
    local ENTITY_INFO_MIN_Y = 10

    -- Кэш для helixCharacters
    local helixCharacters = {}
    local helixCharactersCacheTime = 0
    local helixCharactersCacheDuration = 1 -- секунда
    local function GetHelixCharactersCached()
        if CurTime() > helixCharactersCacheTime then
            helixCharacters = {}
            if ix and ix.util and ix.util.GetCharacters then
                for client, character in ix.util.GetCharacters() do
                    helixCharacters[client] = character
                end
            end
            helixCharactersCacheTime = CurTime() + helixCharactersCacheDuration
        end
        return helixCharacters
    end
    
    -- Debugger HUD renderer
    OBELISK_HUD.renderers.debugger = function(self, w, h, data)
        local stamina = data.stamina
        local maxStamina = data.maxStamina
        local hp = data.hp
        local maxHP = data.maxHP
        local armor = data.armor
        local maxArmor = data.maxArmor
        
        local ply = LocalPlayer()
        
        -- Draw Stamina bar with debugger style
        self._animatedStamina = self._animatedStamina or stamina
        self._animatedStamina = Lerp(0.08, self._animatedStamina, stamina)
        self._staminaBarAlpha = self._staminaBarAlpha or 0
        self._staminaBarLastUsed = self._staminaBarLastUsed or 0
        
        local staminaVisible = false
        if stamina < maxStamina then
            self._staminaBarLastUsed = CurTime()
            staminaVisible = true
        elseif CurTime() - self._staminaBarLastUsed < 3 then
            staminaVisible = true
        end
        
        local targetAlpha = staminaVisible and 255 or 0
        self._staminaBarAlpha = Lerp(0.15, self._staminaBarAlpha, targetAlpha)
        
        local staminaBarWidth = math.max(w * 0.18, 220)
        local staminaBarHeight = math.max(h * 0.025, 10)
        local staminaBarY = h - staminaBarHeight - math.max(h * 0.01, 8)
        local staminaBarX = (w - staminaBarWidth) / 2
        local staminaFillWidth = math.Clamp(self._animatedStamina, 0, maxStamina) / maxStamina * staminaBarWidth
        local centerX = staminaBarX + staminaBarWidth / 2
        
        -- Debugger style stamina color (pink theme)
        local staminaColor = (stamina < 30) and Color(220, 20, 60) or Color(255, 80, 180)
        
        if self._staminaBarAlpha > 5 then
            -- Draw stamina background with blur
            local blurAlpha = math.Clamp(self._staminaBarAlpha * 0.5, 0, 120)
            ix.util.DrawBlurAt(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight, 5, 0.2, blurAlpha)
            
            -- Draw stamina fill
            surface.SetDrawColor(staminaColor.r, staminaColor.g, staminaColor.b, math.Clamp(self._staminaBarAlpha, 0, 255))
            surface.DrawRect(centerX - staminaFillWidth/2, staminaBarY, staminaFillWidth, staminaBarHeight)
            
            -- Draw stamina border with debugger style color
            local borderAlpha = math.Clamp(self._staminaBarAlpha * 0.7, 0, 180)
            surface.SetDrawColor(135, 139, 147, borderAlpha) -- #878b93 с прозрачностью
            surface.DrawOutlinedRect(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight, 3)
        end
        
        -- Debugger overlay for admins
        if ply:IsAdmin() then
            -- Player coordinates
            local pos = ply:GetPos()
            local coordText = string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.x, pos.y, pos.z)
            draw.SimpleTextOutlined(coordText, "ix3D2DSmallFont", w/2, h/2 - 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 180))
            
            -- Trace under crosshair
            local tr = ply:GetEyeTrace()
            local ent = tr.Entity
            
            -- Additional debug info
            local debugInfo = {
                "FPS: " .. math.floor(1 / FrameTime()),
                "Ping: " .. ply:Ping(),
                "Health: " .. hp .. "/" .. maxHP,
                "Armor: " .. armor .. "/" .. maxArmor,
                "Stamina: " .. stamina .. "/" .. maxStamina
            }
            
            for i, info in ipairs(debugInfo) do
                draw.SimpleTextOutlined(info, "ix3D2DSmallFont", 10, 10 + (i-1) * 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 180))
            end

            -- Функция для поиска всех игроков в радиусе
            local function GetPlayersInRadiusList(radius)
                local plyPos = ply:GetPos()
                local players = {}
                for _, v in ipairs(player.GetAll()) do
                    if v ~= ply and v:Alive() and v:GetPos():DistToSqr(plyPos) <= radius * radius then
                        table.insert(players, v)
                    end
                end
                return players
            end

            local playersInRadius = GetPlayersInRadiusList(2000)
            local nearbyText = "Player's Nearly: " .. #playersInRadius
            draw.SimpleTextOutlined(nearbyText, "ix3D2DSmallFont", 10, 10 + #debugInfo * 20 + 10, Color(255, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 180))

            -- Сохраняем список для halo
            _G.obelisk_playersInRadius = playersInRadius

            -- Получаем таблицу client->character через Helix
            local helixCharacters = GetHelixCharactersCached()

            -- Рисуем линии до всех игроков в радиусе и текст над головой
            surface.SetDrawColor(255,255,255,255)
            local startX, startY = w/2, h-10
            for _, v in ipairs(playersInRadius) do
                local headPos = v:EyePos()
                local screenPos = headPos:ToScreen()
                surface.DrawLine(startX, startY, screenPos.x, screenPos.y)

                -- Имя персонажа через Helix
                local charName = helixCharacters[v] and helixCharacters[v]:GetName() or "Unknown"
                local dist = math.floor(ply:GetPos():Distance(v:GetPos()))
                local text = charName .. " | " .. dist .. "u"
                draw.SimpleTextOutlined(text, "ix3D2DSmallFont", screenPos.x, screenPos.y - 30, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,180))
            end

            -- Отображение информации о сущности под прицелом
            if IsValid(ent) then
                local entDist = ply:GetPos():Distance(ent:GetPos())
                if entDist <= 300 then
                    local infoLines = {}
                    table.insert(infoLines, "Class: " .. (ent:GetClass() or "Unknown"))
                    if ent.GetModel then
                        table.insert(infoLines, "Model: " .. (ent:GetModel() or "Unknown"))
                    end
                    if ent:Health() > 0 then
                        table.insert(infoLines, "Health: " .. ent:Health())
                    end
                    table.insert(infoLines, string.format("Pos: %.1f %.1f %.1f", ent:GetPos().x, ent:GetPos().y, ent:GetPos().z))
                    table.insert(infoLines, string.format("Ang: %.1f %.1f %.1f", ent:GetAngles().p, ent:GetAngles().y, ent:GetAngles().r))
                    if ent.EntIndex then
                        table.insert(infoLines, "EntID: " .. ent:EntIndex())
                    end

                    if ent:IsPlayer() then
                        table.insert(infoLines, "SteamID: " .. (ent:SteamID() or "Unknown"))
                        -- Helix character info
                        local char = helixCharacters[ent]
                        if char then
                            table.insert(infoLines, "Name: " .. (char:GetName() or "Unknown"))
                            local faction = char:GetFaction() or "Unknown"
                            local factionName = tostring(faction)
                            if ix and ix.faction and ix.faction.Get and faction ~= "Unknown" then
                                local fct = ix.faction.Get(faction)
                                if fct and fct.name then
                                    factionName = fct.name
                                end
                            end
                            table.insert(infoLines, "Faction: " .. factionName)
                            local rank = "N/A"
                            if char.GetRank then
                                rank = char:GetRank() or "N/A"
                            end
                            table.insert(infoLines, "Rank: " .. rank)
                        end
                    end

                    -- Привязываем инфо к позиции сущности
                    local attachPos = ent:IsPlayer() and ent:EyePos() or ent:GetPos() + Vector(0,0,40)
                    local screen = attachPos:ToScreen()
                    local textWidth = surface.GetTextSize(infoLines[1] or "")
                    local baseX = math.Clamp(screen.x - ENTITY_INFO_OFFSET_X, 0, ScrW() - textWidth - 10)
                    local baseY = math.Clamp(screen.y - (#infoLines * ENTITY_INFO_OFFSET_Y), ENTITY_INFO_MIN_Y, ScrH() - #infoLines * ENTITY_INFO_LINE_HEIGHT)
                    for i, line in ipairs(infoLines) do
                        local lineY = math.Clamp(baseY + (i-1)*ENTITY_INFO_LINE_HEIGHT, ENTITY_INFO_MIN_Y, ScrH() - ENTITY_INFO_LINE_HEIGHT)
                        draw.SimpleTextOutlined(line, "ix3D2DSmallFont", baseX, lineY, Color(0,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0,0,0,180))
                    end
                end
            end
        end
    end

    -- Подсветка всех игроков в радиусе через halo
    hook.Add("PreDrawHalos", "Obelisk_Debugger_NearbyPlayersHalo", function()
        if not _G.obelisk_playersInRadius then return end
        if #_G.obelisk_playersInRadius == 0 then return end
        halo.Add(_G.obelisk_playersInRadius, Color(255,255,255), 5, 5, 2, true, true)
    end)

    -- Bounding box вокруг сущности под прицелом
    hook.Add("PostDrawTranslucentRenderables", "Obelisk_Debugger_DrawBoundingBox", function()
        local ply = LocalPlayer()
        if not (ply and ply:IsAdmin()) then return end
        if not OBELISK_HUD or not OBELISK_HUD._lastEnt then return end
        local ent = OBELISK_HUD._lastEnt
        if not (IsValid(ent) and ply:GetPos():Distance(ent:GetPos()) <= 300) then return end
        local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
        local pos, ang = ent:GetPos(), ent:GetAngles()
        render.SetColorMaterial()
        render.DrawWireframeBox(pos, ang, mins, maxs, Color(0,255,255), true)
    end)

    -- Сохраняем последнюю сущность под прицелом для отрисовки bounding box
    local oldDebugger = OBELISK_HUD.renderers.debugger
    OBELISK_HUD.renderers.debugger = function(self, w, h, data)
        oldDebugger(self, w, h, data)
        local ply = LocalPlayer()
        if not ply:IsAdmin() then return end
        local tr = ply:GetEyeTrace()
        OBELISK_HUD._lastEnt = tr.Entity
    end
end 