-- Obelisk HUD Visor Style Renderer

if CLIENT then
    OBELISK_HUD = OBELISK_HUD or {}
    OBELISK_HUD.renderers = OBELISK_HUD.renderers or {}
    
    -- Загрузка иконки стамины
    local staminaIcon = Material("icons/stamina.png", "smooth")
    
    -- Visor HUD renderer
    OBELISK_HUD.renderers.visor = function(self, w, h, data)
        local ply = LocalPlayer()
        local stamina = data.stamina
        local maxStamina = data.maxStamina
        
        -- Draw Stamina bar with visor style
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
        local staminaBarHeight = math.max(h * 0.015, 6)
        local staminaBarY = h - staminaBarHeight - math.max(h * 0.01, 8)
        local staminaBarX = (w - staminaBarWidth) / 2
        local staminaFillWidth = math.Clamp(self._animatedStamina, 0, maxStamina) / maxStamina * staminaBarWidth
        local centerX = staminaBarX + staminaBarWidth / 2
        
        -- Visor style stamina color (green theme, но плавное мигание при низкой стамине)
        local staminaColor
        if stamina < 30 then
            local pulse = (math.sin(CurTime() * 6) + 1) / 2 -- 0..1
            local r = Lerp(pulse, 255, 220)
            local g = Lerp(pulse, 255, 20)
            local b = Lerp(pulse, 255, 60)
            staminaColor = Color(r, g, b)
        else
            staminaColor = Color(248, 255, 252, 57)
        end
        
        -- Эффект размытия экрана при очень низкой стамине (только если < 40%)
        local blurThreshold = maxStamina * 0.4
        self._staminaBlur = self._staminaBlur or 0
        if stamina < blurThreshold then
            local blurStrength
            if stamina < 5 then
                blurStrength = 5
            elseif stamina <= 5 then
                blurStrength = 1
            else
                blurStrength = Lerp((stamina - 5) / (blurThreshold - 5), 1, 0)
            end
            self._staminaBlur = Lerp(0.01, self._staminaBlur, blurStrength)
            ix.util.DrawBlur(self, self._staminaBlur, 2, 255)
        else
            self._staminaBlur = Lerp(0.05, self._staminaBlur or 0, 0)
            if self._staminaBlur > 0.01 then
                ix.util.DrawBlur(self, self._staminaBlur, 2, 255)
            end
        end
        
        if self._staminaBarAlpha > 5 then
            -- Тёмный полупрозрачный фон вместо блюра
            surface.SetDrawColor(20, 20, 20, math.Clamp(self._staminaBarAlpha * 0.5, 0, 120))
            surface.DrawRect(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight)
            
            -- Draw stamina fill
            surface.SetDrawColor(staminaColor.r, staminaColor.g, staminaColor.b, 90)
            surface.DrawRect(centerX - staminaFillWidth/2, staminaBarY, staminaFillWidth, staminaBarHeight)
            
            -- Удаляю рамку вокруг полоски
            -- surface.SetDrawColor(135, 139, 147, borderAlpha)
            -- surface.DrawOutlinedRect(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight, 3)

            -- Тонкая белая полоска под стаминой
            surface.SetDrawColor(255,255,255,180)
            surface.DrawRect(staminaBarX, staminaBarY + staminaBarHeight + 2, staminaBarWidth, 2)

            -- Рисуем иконку стамины над полоской только если стамина < 30 или альфа иконки ещё не ушла
            self._staminaIconAlpha = self._staminaIconAlpha or 0
            self._staminaIconScale = self._staminaIconScale or 1.0
            local iconShouldShow = stamina < 30
            if iconShouldShow then
                -- Плавное появление и возврат к обычному размеру
                self._staminaIconAlpha = Lerp(0.05, self._staminaIconAlpha, 255)
                self._staminaIconScale = Lerp(0.15, self._staminaIconScale, 1.0)
            else
                -- Более резкое исчезновение и увеличение размера
                self._staminaIconAlpha = Lerp(0.15, self._staminaIconAlpha, 0)
                self._staminaIconScale = Lerp(0.08, self._staminaIconScale, 1.5)
            end
            if self._staminaIconAlpha > 5 then
                -- Размер иконки увеличивается при исчезновении
                local iconSize = staminaBarHeight * 3.2 * self._staminaIconScale
                local iconX = centerX - iconSize / 2
                local iconY = staminaBarY - iconSize - 10
                local shake = 0
                if stamina < 30 then
                    shake = math.sin(CurTime() * 12) * 2
                end
                -- Плавное мигание цвета (от зелёного к красному)
                local pulse = (math.sin(CurTime() * 6) + 1) / 2 -- 0..1
                local r = Lerp(pulse, 80, 220)
                local g = Lerp(pulse, 255, 20)
                local b = Lerp(pulse, 180, 60)
                local iconAlpha = math.Clamp(self._staminaIconAlpha, 0, 255)
                surface.SetMaterial(staminaIcon)
                surface.SetDrawColor(r, g, b, iconAlpha)
                surface.DrawTexturedRect(iconX + shake, iconY + shake, iconSize, iconSize)
            end
        end

        -- === Плавное затухание компаса ===
        self._compassFade = self._compassFade or 1
        self._lastYaw = self._lastYaw or nil
        self._lastMoveTime = self._lastMoveTime or CurTime()
        local fadeSpeed = FrameTime() * 3 -- скорость появления/затухания
        if not IsValid(ply) then return end
        local yaw = ply:EyeAngles().y
        if self._lastYaw == nil then self._lastYaw = yaw end
        if math.abs(math.AngleDifference(self._lastYaw, yaw)) > 0.1 then
            self._lastMoveTime = CurTime()
            self._lastYaw = yaw
        end
        if CurTime() - self._lastMoveTime > 2 then
            self._compassFade = math.max(0, self._compassFade - fadeSpeed)
        else
            self._compassFade = math.min(1, self._compassFade + fadeSpeed)
        end
        -- === КОМПАС В СТИЛЕ mcompass (движение ленты, выравнивание по центру) ===
        local compassWidth = w * 0.7
        local compassHeight = h * 0.06
        local centerX = w / 2
        local baseY = h * 0.11 - 80
        local fov = 120
        local pxPerDeg = compassWidth / fov
        local adv_compass_tbl = {
            [0] = "E", [45] = "SE", [90] = "S", [135] = "SW", [180] = "W", [225] = "NW", [270] = "N", [315] = "NE", [360] = "E"
        }
        for deg = 0, 359, 1 do
            local rel = ((deg - yaw + 360) % 360)
            if rel > 180 then rel = rel - 360 end
            if math.abs(rel) > fov/2 then continue end
            local x = centerX + rel * pxPerDeg
            local isCardinal = adv_compass_tbl[deg] ~= nil
            local is15 = deg % 15 == 0 and not isCardinal
            local is5 = deg % 5 == 0 and not isCardinal and not is15
            local lineHeight
            if isCardinal then
                lineHeight = compassHeight * 0.95 * 0.8
            elseif is15 then
                lineHeight = compassHeight * 0.65
            elseif is5 then
                lineHeight = compassHeight * 0.38
            else
                lineHeight = compassHeight * 0.22
            end
            -- Увеличиваем главную и соседние штрихи
            if math.abs(rel) < 0.5 then
                lineHeight = lineHeight * 1.5
            elseif math.abs(rel) < 1.5 then
                lineHeight = lineHeight * 1.2
            end
            local dist = math.abs(x - centerX)
            local fade = 1 - math.Clamp(dist / (compassWidth/2), 0, 1)
            local alpha = math.floor(255 * (fade^2) * self._compassFade)
            surface.SetDrawColor(255,255,255,alpha)
            local y = baseY + compassHeight/2 - lineHeight/2
            surface.DrawRect(x-1, y, 2, lineHeight)
            if isCardinal then
                draw.SimpleText(adv_compass_tbl[deg], "ixMenuButtonFont", x, y + lineHeight + 2, Color(255,255,255,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            elseif is15 then
                draw.SimpleText(tostring(deg), "ixMenuButtonFont", x, y + lineHeight + 2, Color(255,255,255,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end
        -- Центральный маркер (треугольник)
        local markerX = centerX
        local markerY = baseY + compassHeight + 10
        local markerSize = 10
        local markerAlpha = math.floor(255 * self._compassFade)
        surface.SetDrawColor(255,255,255,markerAlpha)
        draw.NoTexture()
        surface.DrawPoly({
            {x = markerX, y = markerY},
            {x = markerX - markerSize/2, y = markerY + markerSize},
            {x = markerX + markerSize/2, y = markerY + markerSize}
        })
        -- === КОНЕЦ КОМПАСА ===

        -- === МИНИКАРТА (серый круглый фон, белая рамка, стрелка) ===
        do
            local minimapSize = 180
            local minimapMargin = 24
            local x = w - minimapSize - minimapMargin - 60 -- ещё левее
            local y = h * 0.35 -- ниже
            local cx, cy = x + minimapSize/2, y + minimapSize/2
            local radius = minimapSize/2
            -- Серый круглый фон (ещё более прозрачный)
            draw.NoTexture()
            surface.SetDrawColor(65, 65, 65, 107)
            local circle = {}
            for i = 0, 360, 6 do
                local a = math.rad(i)
                table.insert(circle, {x = cx + math.cos(a)*radius, y = cy + math.sin(a)*radius})
            end
            surface.DrawPoly(circle)
            -- Белая рамка (ещё более прозрачная)
            surface.SetDrawColor(230,230,240,110)
            surface.DrawCircle(cx, cy, radius-1, 230,230,240,110)
            -- Стрелка игрока по центру
            local arrowSize = 22
            local yaw = -ply:EyeAngles().y
            surface.SetDrawColor(255,255,255,255)
            draw.NoTexture()
            local arrow = {
                {x = cx + math.cos(math.rad(yaw)) * arrowSize, y = cy + math.sin(math.rad(yaw)) * arrowSize},
                {x = cx + math.cos(math.rad(yaw+130)) * (arrowSize*0.6), y = cy + math.sin(math.rad(yaw+130)) * (arrowSize*0.6)},
                {x = cx + math.cos(math.rad(yaw-130)) * (arrowSize*0.6), y = cy + math.sin(math.rad(yaw-130)) * (arrowSize*0.6)}
            }
            surface.DrawPoly(arrow)
        end
        -- === КОНЕЦ МИНИКАРТЫ ===

        -- === ОБВОДКА И КВАДРАТ ВОКРУГ ЛИЦА ПРИ НАВЕДЕНИИ ===
        do
            if IsValid(ply) and ply:Alive() then
                local tr = ply:GetEyeTrace()
                local target = tr.Entity
                if IsValid(target) and target:IsPlayer() and target ~= ply then
                    local dist = ply:EyePos():Distance(target:EyePos())
                    if dist <= 150 then
                        local headBone = target:LookupBone("ValveBiped.Bip01_Head1") or 0
                        local headPos = target:GetBonePosition(headBone) or target:EyePos()
                        -- Кости ушей
                        local leftEarBone = target:LookupBone("ValveBiped.Bip01_L_Ear")
                        local rightEarBone = target:LookupBone("ValveBiped.Bip01_R_Ear")
                        local up = Vector(0,0,9)
                        local down = Vector(0,0,-8)
                        local left = leftEarBone and (target:GetBonePosition(leftEarBone) - headPos) or Vector(5,0,0)
                        local right = rightEarBone and (target:GetBonePosition(rightEarBone) - headPos) or Vector(-5,0,0)
                        -- Уменьшаем высоту (делаем голову "ниже")
                        up = up * 0.7
                        down = down * 0.7
                        -- Получаем точки
                        local points = {
                            (headPos + up):ToScreen(),
                            (headPos + down):ToScreen(),
                            (headPos + left):ToScreen(),
                            (headPos + right):ToScreen(),
                        }
                        -- Находим границы
                        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                        local allVisible = true
                        for _, pt in ipairs(points) do
                            if not pt.visible then allVisible = false break end
                            minX = math.min(minX, pt.x)
                            minY = math.min(minY, pt.y)
                            maxX = math.max(maxX, pt.x)
                            maxY = math.max(maxY, pt.y)
                        end
                        if allVisible then
                            -- === Фиксированный размер рамки и проверка угла обзора ===
                            local headScreen = headPos:ToScreen()
                            if headScreen.visible then
                                -- Проверка угла между взглядом и целью
                                local forward = ply:EyeAngles():Forward()
                                local toTarget = (target:EyePos() - ply:EyePos()):GetNormalized()
                                local dot = forward:Dot(toTarget)
                                local angle = math.deg(math.acos(dot))
                                if angle < 45 then -- только если цель в центре обзора (90° сектор)
                                    -- Проверка: LocalPlayer должен быть в секторе обзора target
                                    local targetForward = target:EyeAngles():Forward()
                                    local toLocal = (ply:EyePos() - target:EyePos()):GetNormalized()
                                    local dot2 = targetForward:Dot(toLocal)
                                    local angle2 = math.deg(math.acos(dot2))
                                    if angle2 < 45 then -- только если игрок с HUD в секторе обзора target
                                        -- Динамический размер рамки в зависимости от расстояния
                                        local maxDist = 150
                                        local minW, minH = 60, 60
                                        local maxW, maxH = 175, 175
                                        local dist = ply:EyePos():Distance(target:EyePos())
                                        local t = math.Clamp((dist / maxDist), 0, 1)
                                        local boxW = Lerp(1-t, minW, maxW)
                                        local boxH = boxW -- всегда квадрат
                                        local minX = headScreen.x - boxW/2
                                        local minY = headScreen.y - boxH/2 - 15 -- поднять на 15 выше
                                        local maxX = headScreen.x + boxW/2
                                        local maxY = headScreen.y + boxH/2 - 10
                                        local len = 16
                                        surface.SetDrawColor(255,255,255,200)
                                        -- Левый верхний угол
                                        surface.DrawLine(minX, minY, minX+len, minY)
                                        surface.DrawLine(minX, minY, minX, minY+len)
                                        -- Правый верхний угол
                                        surface.DrawLine(maxX, minY, maxX-len, minY)
                                        surface.DrawLine(maxX, minY, maxX, minY+len)
                                        -- Левый нижний угол
                                        surface.DrawLine(minX, maxY, minX+len, maxY)
                                        surface.DrawLine(minX, maxY, minX, maxY-len)
                                        -- Правый нижний угол
                                        surface.DrawLine(maxX, maxY, maxX-len, maxY)
                                        surface.DrawLine(maxX, maxY, maxX, maxY-len)
                                    end
                                    -- Удалены линии взгляда, веер, линия до target и вывод расстояния
                                end
                            end
                        end
                    end
                end
            end
        end
        local isBinocular = input.IsKeyDown(KEY_B)
        -- Кэш видимости игроков (обновляется раз в 0.2 сек)
        self._visiblePlayersCache = self._visiblePlayersCache or {}
        self._visiblePlayersCacheTime = self._visiblePlayersCacheTime or 0
        if CurTime() > (self._visiblePlayersCacheTime or 0) then
            self._visiblePlayersCache = {}
            for _, target in ipairs(ents.GetAll()) do
                if target ~= ply and IsValid(target) and target:Alive() and target:IsPlayer() then
                    local dist = ply:EyePos():Distance(target:EyePos())
                    if (isBinocular and dist <= 2000) or (not isBinocular and dist <= 150) then
                        local forward = ply:EyeAngles():Forward()
                        local toTarget = (target:EyePos() - ply:EyePos()):GetNormalized()
                        local dot = forward:Dot(toTarget)
                        local angle = math.deg(math.acos(dot))
                        if angle < 45 then
                            local tr = util.TraceLine({start = ply:EyePos(), endpos = target:EyePos(), filter = {ply}})
                            if tr.Entity == target or tr.HitPos:DistToSqr(target:EyePos()) < 36*36 then
                                self._visiblePlayersCache[target] = true
                            end
                        end
                    end
                end
            end
            self._visiblePlayersCacheTime = CurTime() + 0.2
        end

        if isBinocular then
            for _, target in ipairs(ents.GetAll()) do
                if self._visiblePlayersCache[target] then
                    local dist = ply:EyePos():Distance(target:EyePos())
                    local headBone = target:LookupBone("ValveBiped.Bip01_Head1") or 0
                    local headPos = target:GetBonePosition(headBone) or target:EyePos()
                    local headScreen = headPos:ToScreen()
                    if headScreen.visible then
                        local maxDist = 150
                        local minW, minH = 60, 60
                        local maxW, maxH = 175, 175
                        local t = math.Clamp((dist / maxDist), 0, 1)
                        local boxW = Lerp(1-t, minW, maxW)
                        local boxH = boxW
                        local minX = headScreen.x - boxW/2
                        local minY = headScreen.y - boxH/2 - 15
                        local maxX = headScreen.x + boxW/2
                        local maxY = headScreen.y + boxH/2 - 10
                        local len = 16
                        surface.SetDrawColor(255,255,255,200)
                        surface.DrawLine(minX, minY, minX+len, minY)
                        surface.DrawLine(minX, minY, minX, minY+len)
                        surface.DrawLine(maxX, minY, maxX-len, minY)
                        surface.DrawLine(maxX, minY, maxX, minY+len)
                        surface.DrawLine(minX, maxY, minX+len, maxY)
                        surface.DrawLine(minX, maxY, minX, maxY-len)
                        surface.DrawLine(maxX, maxY, maxX-len, maxY)
                        surface.DrawLine(maxX, maxY, maxX, maxY-len)
                    end
                end
            end
        else
            for _, target in ipairs(ents.GetAll()) do
                if self._visiblePlayersCache[target] then
                    local dist = ply:EyePos():Distance(target:EyePos())
                    local headBone = target:LookupBone("ValveBiped.Bip01_Head1") or 0
                    local headPos = target:GetBonePosition(headBone) or target:EyePos()
                    local headScreen = headPos:ToScreen()
                    if headScreen.visible then
                        local maxDist = 150
                        local minW, minH = 60, 60
                        local maxW, maxH = 175, 175
                        local t = math.Clamp((dist / maxDist), 0, 1)
                        local boxW = Lerp(1-t, minW, maxW)
                        local boxH = boxW
                        local minX = headScreen.x - boxW/2
                        local minY = headScreen.y - boxH/2 - 15
                        local maxX = headScreen.x + boxW/2
                        local maxY = headScreen.y + boxH/2 - 10
                        local len = 16
                        surface.SetDrawColor(255,255,255,200)
                        surface.DrawLine(minX, minY, minX+len, minY)
                        surface.DrawLine(minX, minY, minX, minY+len)
                        surface.DrawLine(maxX, minY, maxX-len, minY)
                        surface.DrawLine(maxX, minY, maxX, minY+len)
                        surface.DrawLine(minX, maxY, minX+len, maxY)
                        surface.DrawLine(minX, maxY, minX, maxY-len)
                        surface.DrawLine(maxX, maxY, maxX-len, maxY)
                        surface.DrawLine(maxX, maxY, maxX, maxY-len)
                    end
                end
            end
        end
        -- === КОНЕЦ ОБВОДКИ ===
    end
end 