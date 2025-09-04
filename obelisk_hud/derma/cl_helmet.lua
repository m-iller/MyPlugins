-- Obelisk HUD Helmet Style Renderer

if CLIENT then
    -- Создание жирных шрифтов для меток
    surface.CreateFont("ixMenuButtonFontBold", {
        font = "Roboto",
        size = 22,
        weight = 900,
        antialias = true,
        extended = true,
    })
    surface.CreateFont("ixMenuButtonFontSmallBold", {
        font = "Roboto",
        size = 18,
        weight = 900,
        antialias = true,
        extended = true,
    })
    -- Ensure OBELISK_HUD.renderers is initialized
    OBELISK_HUD = OBELISK_HUD or {}
    OBELISK_HUD.renderers = OBELISK_HUD.renderers or {}
    
    -- Загрузка иконки стамины
    local staminaIcon = Material("icons/stamina.png", "smooth")
    
    -- Градиент для компаса
    local gradientUp = surface.GetTextureID("vgui/gradient-u")
    
    -- Загрузка материала pp/blurscreen
    -- local helmetOverlayMat = Material("pp/binoscope")
    local combineOverlay = ix.util.GetMaterial("effects/combine_binocoverlay")
    
    -- Вспомогательная функция для форматирования таймера (М:СС)
    local function formatTimer(secs)
        secs = math.max(0, math.floor(secs))
        local m = math.floor(secs / 60)
        local s = secs % 60
        return string.format("%d:%02d", m, s)
    end

    -- Helmet HUD renderer
    OBELISK_HUD.renderers.helmet = function(self, w, h, data)
        -- Отрисовка overlay под всем HUD
        surface.SetDrawColor(255,255,255,255)
        render.UpdateScreenEffectTexture()
        combineOverlay:SetFloat("$alpha", 0.5)
        combineOverlay:SetInt("$ignorez", 1)
        render.SetMaterial(combineOverlay)
        render.DrawScreenQuad()
        local stamina = data.stamina
        local maxStamina = data.maxStamina
        
        -- Draw Stamina bar with helmet style
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
        local staminaBarHeight = 6 -- уменьшенная высота полоски
        local staminaBarY = h - staminaBarHeight - math.max(h * 0.01, 8)
        local staminaBarX = (w - staminaBarWidth) / 2
        local staminaFillWidth = math.Clamp(self._animatedStamina, 0, maxStamina) / maxStamina * staminaBarWidth
        local centerX = staminaBarX + staminaBarWidth / 2
        
        -- Helmet style stamina color (теперь всегда белый)
        local staminaColor = Color(255, 255, 255)
        
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
        else
            self._staminaBlur = Lerp(0.05, self._staminaBlur or 0, 0)
        end


        -- === БЛЮР ПОВЕРХ КОМПАСА, МИНИКАРТЫ, СОЮЗНИКОВ, СИГНАЛОВ ===
        if self._staminaBlur and self._staminaBlur > 0.01 then
            ix.util.DrawBlur(self, self._staminaBlur, 2, 255)
        end

        if self._staminaBarAlpha > 5 then
            -- Блюр под полоской стамины
            local blurAlpha = math.Clamp(self._staminaBarAlpha * 0.5, 0, 120)
            ix.util.DrawBlurAt(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight, 5, 0.2, blurAlpha)

            -- Тёмный полупрозрачный фон
            surface.SetDrawColor(20, 20, 20, blurAlpha)
            surface.DrawRect(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight)

            -- Draw stamina fill
            surface.SetDrawColor(staminaColor.r, staminaColor.g, staminaColor.b, math.Clamp(self._staminaBarAlpha, 0, 255))
            surface.DrawRect(centerX - staminaFillWidth/2, staminaBarY, staminaFillWidth, staminaBarHeight)

            -- Тонкая белая полоска под стаминой
            surface.SetDrawColor(255,255,255,180)
            surface.DrawRect(staminaBarX, staminaBarY + staminaBarHeight + 2, staminaBarWidth, 2)

            -- Иконка стамины над полоской (как в standard)
            self._staminaIconAlpha = self._staminaIconAlpha or 0
            self._staminaIconScale = self._staminaIconScale or 1.0
            local iconShouldShow = stamina < 30
            if iconShouldShow then
                self._staminaIconAlpha = Lerp(0.05, self._staminaIconAlpha, 255)
                self._staminaIconScale = Lerp(0.15, self._staminaIconScale, 1.0)
            else
                self._staminaIconAlpha = Lerp(0.15, self._staminaIconAlpha, 0)
                self._staminaIconScale = Lerp(0.08, self._staminaIconScale, 1.5)
            end
            if self._staminaIconAlpha > 5 then
                local iconSize = staminaBarHeight * 3.2 * self._staminaIconScale * 4 -- увеличено в 4 раза
                local iconX = centerX - iconSize / 2
                local iconY = staminaBarY - iconSize - 10
                local shake = 0
                if stamina < 30 then
                    shake = math.sin(CurTime() * 12) * 2
                end
                local pulse = (math.sin(CurTime() * 6) + 1) / 2
                local r = Lerp(pulse, 255, 220)
                local g = Lerp(pulse, 255, 20)
                local b = Lerp(pulse, 255, 60)
                local iconAlpha = math.Clamp(self._staminaIconAlpha, 0, 255)
                surface.SetMaterial(staminaIcon)
                surface.SetDrawColor(r, g, b, iconAlpha)
                surface.DrawTexturedRect(iconX + shake, iconY + shake, iconSize, iconSize)
            end
        end

        -- === КОМПАС В СТИЛЕ visor ===
        self._compassFade = self._compassFade or 1
        self._lastYaw = self._lastYaw or nil
        self._lastMoveTime = self._lastMoveTime or CurTime()
        local fadeSpeed = FrameTime() * 3
        if not IsValid(LocalPlayer()) then return end
        local yaw = LocalPlayer():EyeAngles().y
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
        local compassWidth = w * 0.7
        local compassHeight = h * 0.06
        local centerX = w / 2
        local baseY = h * 0.11 - 80
        local fov = LocalPlayer().GetFOV and LocalPlayer():GetFOV() or 120
        local pxPerDeg = compassWidth / fov

    -- Полупрозрачный тёмный фон под компасом (во всю ширину экрана, без закруглений)
    do
        -- Чёрный фон сверху до начала основного фона компаса
        local bgAlpha = 200
        local blackBgX = 0
        local blackBgY = -10
        local blackBgW = ScrW()
        local blackBgH = (baseY + compassHeight) + 10
        surface.SetDrawColor(0, 0, 0, bgAlpha)
        surface.DrawRect(blackBgX, blackBgY, blackBgW, blackBgH)
        
        local bgX = 0
        local bgY = baseY + compassHeight
        local bgW = ScrW()
        local bgH = compassHeight * 2
        local bgAlpha = 200
        surface.SetDrawColor(0, 0, 0, bgAlpha)
        surface.SetTexture(gradientUp)
        surface.DrawTexturedRect(bgX, bgY, bgW, bgH)
    end
    local adv_compass_tbl = {
        [0] = "E", [45] = "SE", [90] = "S", [135] = "SW", [180] = "W", [225] = "NW", [270] = "N", [315] = "NE", [360] = "E"
    }
    for deg = 0, 359, 1 do
        local rel = ((deg - yaw + 360) % 360)
        if rel > 180 then rel = rel - 360 end
        if math.abs(rel) > fov/2 then goto continue_compass end
        local x = centerX + rel * pxPerDeg
        local isCardinal = adv_compass_tbl[deg] ~= nil
        local is15 = deg % 15 == 0 and not isCardinal
        local is5 = deg % 5 == 0 and not isCardinal and not is15
        -- 1° деления не рисуем
        if not isCardinal and not is15 and not is5 then goto continue_compass end
        local lineHeight, lineAlpha
        if isCardinal then
            lineHeight = compassHeight * 0.95 * 0.8
            lineAlpha = 255
        elseif is15 then
            lineHeight = compassHeight * 0.65
            lineAlpha = 180
        elseif is5 then
            lineHeight = compassHeight * 0.38
            lineAlpha = 80
        end
        if math.abs(rel) < 0.5 then
            lineHeight = lineHeight * 1.5
        elseif math.abs(rel) < 1.5 then
            lineHeight = lineHeight * 1.2
        end
        local dist = math.abs(x - centerX)
        local fade = 1 - math.Clamp(dist / (compassWidth/2), 0, 1)
        local alpha = math.floor(lineAlpha * (fade^2) * self._compassFade)
        surface.SetDrawColor(255,255,255,alpha)
        local y = baseY + compassHeight/2 - lineHeight/2
        surface.DrawRect(x-1, y, 2, lineHeight)
        if isCardinal then
            draw.SimpleText(adv_compass_tbl[deg], "ixMenuButtonFont", x, y + lineHeight + 2, Color(255,255,255,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        elseif is15 then
            draw.SimpleText(tostring(deg), "ixMenuButtonFont", x, y + lineHeight + 2, Color(255,255,255,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        ::continue_compass::
    end
    -- === КОНЕЦ КОМПАСА ===

        -- === МИНИКАРТА (серый круглый фон, белая рамка, стрелка) ===
        do
            local minimapSize = 180
            local minimapMargin = 24
            local x = w - minimapSize - minimapMargin - 60
            local y = h * 0.35
            local cx, cy = x + minimapSize/2, y + minimapSize/2
            local radius = minimapSize/2
            draw.NoTexture()
            surface.SetDrawColor(65, 65, 65, 107)
            local circle = {}
            for i = 0, 360, 6 do
                local a = math.rad(i)
                table.insert(circle, {x = cx + math.cos(a)*radius, y = cy + math.sin(a)*radius})
            end
            surface.DrawPoly(circle)
            surface.SetDrawColor(230,230,240,110)
            surface.DrawCircle(cx, cy, radius-1, 230,230,240,110)
            local ply = LocalPlayer()
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

            -- === МЕТКИ СИГНАЛОВ (смерть союзника) ===
        end
        -- === КОНЕЦ МИНИКАРТЫ ===

        -- === ОБВОДКА И КВАДРАТ ВОКРУГ ЛИЦА ===
        local isBinocular = input.IsKeyDown(KEY_B)
        self._visiblePlayersCache = self._visiblePlayersCache or {}
        self._visiblePlayersCacheTime = self._visiblePlayersCacheTime or 0
        if CurTime() > (self._visiblePlayersCacheTime or 0) then
            self._visiblePlayersCache = {}
            local ply = LocalPlayer()
            local plyAng = ply:EyeAngles()
            local plyForward = plyAng:Forward()
            local plyUp = plyAng:Up()
            for _, target in ipairs(ents.GetAll()) do
                if target ~= ply and IsValid(target) and target:Alive() and target:IsPlayer() then
                    local dist = ply:EyePos():Distance(target:EyePos())
                    if (isBinocular and dist <= 2000) or (not isBinocular and dist <= 150) then
                        local toTarget = (target:EyePos() - ply:EyePos()):GetNormalized()
                        -- Горизонтальный угол
                        local dotForward = plyForward:Dot(toTarget)
                        local angleForward = math.deg(math.acos(dotForward))
                        -- Вертикальный угол
                        local dotUp = plyUp:Dot(toTarget)
                        local angleUp = math.deg(math.asin(dotUp))
                        if dotForward > 0 and angleForward < 45 and math.abs(angleUp) < 30 then
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
                    local dist = LocalPlayer():EyePos():Distance(target:EyePos())
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
                    local dist = LocalPlayer():EyePos():Distance(target:EyePos())
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

        -- === ПОДСВЕТКА СОЮЗНИКОВ И ТЕКСТ НАД ГОЛОВОЙ ===
        local ply = LocalPlayer()
        local FACTION_POLICE = FACTION_POLICE or _G.FACTION_POLICE
        local allies = {}
        for _, target in ipairs(player.GetAll()) do
            if target ~= ply and IsValid(target) and target:Alive() and target:GetCharacter() and target:GetCharacter():GetFaction() == FACTION_POLICE then
                local dist = ply:EyePos():Distance(target:EyePos())
                if dist <= 300 then
                    table.insert(allies, target)
                end
            end
        end
        -- Подсветка halo
        if #allies > 0 then
            halo.Add(allies, Color(0, 200, 255), 2, 2, 1, true, true)
        end
        -- Текст над головой союзников, если они в прицеле
        local tr = ply:GetEyeTrace()
        for _, target in ipairs(allies) do
            if tr.Entity == target then
                local char = target:GetCharacter()
                local name = char and char:GetName() or target:Nick()
                local class = char and (ix and ix.class and ix.class.Get and ix.class.Get(char:GetClass()) and ix.class.Get(char:GetClass()).name or char:GetClass() or "") or ""
                local headBone = target:LookupBone("ValveBiped.Bip01_Head1") or 0
                local headPos = target:GetBonePosition(headBone) or target:EyePos()
                headPos = headPos + Vector(0, 0, 16) -- смещение вверх над головой
                local screen = headPos:ToScreen()
                draw.SimpleTextOutlined(name, "ixMenuButtonFontSmall", screen.x, screen.y, Color(0,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,200))
                if class and class ~= "" then
                    draw.SimpleTextOutlined(class, "ixMenuButtonFontSmall", screen.x, screen.y + 18, Color(180,220,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,180))
                end
            end
        end
        -- === КОНЕЦ ПОДСВЕТКИ И ТЕКСТА ===

        -- === СПИСОК БЛИЖАЙШИХ СОЮЗНИКОВ СПРАВА ПОД МИНИКАРТОЙ ===
        -- Поддержка UTF-8
        local utf8 = utf8 or require and require("utf8") or _G.utf8
        local function utf8sub(str, i, j)
            if utf8 and utf8.sub then
                return utf8.sub(str, i, j)
            else
                return string.sub(str, i, j)
            end
        end
        local function utf8len(str)
            if utf8 and utf8.len then
                return utf8.len(str)
            else
                return #str
            end
        end
        self._alliesList = self._alliesList or {}
        local now = CurTime()
        -- Сканируем актуальных союзников (массив, ключ - character:GetID())
        local newAllies = {}
        for _, target in ipairs(player.GetAll()) do
            local char = target:GetCharacter()
            if target ~= ply and IsValid(target) and target:Alive() and char and char:GetFaction() == FACTION_POLICE then
                local dist = ply:EyePos():Distance(target:EyePos())
                if dist <= 300 then
                    table.insert(newAllies, {ent=target, dist=dist, key=char:GetID()})
                end
            end
        end
        -- Сортируем по расстоянию и формируем очередь
        local sortedAllies = {}
        for _, info in ipairs(newAllies) do table.insert(sortedAllies, info) end
        table.sort(sortedAllies, function(a, b) return a.dist < b.dist end)
        local maxAllies = 6
        local showAllies = {}
        for i=1, math.min(#sortedAllies, maxAllies) do table.insert(showAllies, sortedAllies[i]) end
        local extraCount = #sortedAllies - maxAllies
        local extraKey = "__extra__"
        -- Очередь для порядка отображения
        self._alliesQueue = self._alliesQueue or {}
        -- Синхронизируем очередь с актуальными союзниками
        local queueKeys = {}
        for i, v in ipairs(self._alliesQueue) do queueKeys[v.key] = true end
        -- Добавляем новых союзников в очередь
        for _, v in ipairs(sortedAllies) do
            if not queueKeys[v.key] then
                table.insert(self._alliesQueue, {key = v.key, ent = v.ent, dist = v.dist, wasInRadius = false})
            end
        end
        -- Обновляем состояние inRadius для очереди
        for i = #self._alliesQueue, 1, -1 do
            local v = self._alliesQueue[i]
            local inRadius = false
            for _, na in ipairs(newAllies) do if na.key == v.key then inRadius = true break end end
            if v.wasInRadius == nil then v.wasInRadius = false end
            -- Если только что вошёл в радиус
            if not v.wasInRadius and inRadius then
                -- Сбросим анимацию появления
                if self._alliesList[v.key] then
                    self._alliesList[v.key].state = "appearing"
                    self._alliesList[v.key].phase = 1
                    self._alliesList[v.key].charIndex = 0
                    self._alliesList[v.key].eraseIndex = 0
                    self._alliesList[v.key].text = ""
                end
            end
            -- Если только что вышел из радиуса
            if v.wasInRadius and not inRadius then
                if self._alliesList[v.key] and self._alliesList[v.key].state ~= "erasing" then
                    self._alliesList[v.key].state = "erasing"
                    self._alliesList[v.key].lastUpdate = now
                end
            end
            v.wasInRadius = inRadius
            -- Если совсем ушёл — удаляем из очереди
            if not inRadius and (not self._alliesList[v.key] or self._alliesList[v.key].state == "erasing" and self._alliesList[v.key].charIndex == 0) then
                table.remove(self._alliesQueue, i)
            end
        end
        -- Ограничиваем очередь до 6 (для отображения)
        local visibleQueue = {}
        for i=1, math.min(#self._alliesQueue, maxAllies) do table.insert(visibleQueue, self._alliesQueue[i]) end
        -- Для extra строки
        local totalAllies = #self._alliesQueue
        -- Обновляем список союзников
        for key, data in pairs(self._alliesList) do
            if key ~= extraKey then
                local ally = data.ent
                local inVisibleQueue = false
                local currentDist = data.dist
                for _, v in ipairs(visibleQueue) do if v.key == key then inVisibleQueue = true; currentDist = v.dist break end end
                local inNewAllies = false
                for _, na in ipairs(newAllies) do if na.key == key then inNewAllies = true; currentDist = na.dist break end end
                if not inNewAllies or not inVisibleQueue then
                    if data.state ~= "erasing" then
                        data.state = "erasing"
                        data.lastUpdate = now
                    end
                else
                    if data.state == "erasing" then
                        data.state = "restoring"
                        data.lastUpdate = now
                    end
                    -- Обновляем дистанцию в реальном времени
                    local char = data.ent and data.ent:GetCharacter()
                    if char then
                        local dist = math.floor(ply:EyePos():Distance(data.ent:EyePos()))
                        local distSuffix = (L and L("distance_units") or "u")
                        data.infoTextDist = " | " .. dist .. distSuffix
                        data.infoText = (data.infoTextBase or "") .. (data.infoTextDist or "")
                        if data.state == "idle" then
                            data.text = data.infoText
                        elseif data.state == "appearing" or data.state == "restoring" then
                            -- если в процессе печати, не обновляем text, только infoText
                        end
                    end
                end
            end
        end
        -- Обработка строки "Cоюзные силы (N)"
        if totalAllies > maxAllies then
            local alliesForcesText = (L and L("allied_forces") or "Cоюзные силы") .. " ("..tostring(totalAllies)..")"
            if not self._alliesList[extraKey] then
                self._alliesList[extraKey] = {
                    ent = nil,
                    dist = 0,
                    state = "appearing",
                    lastUpdate = now,
                    text = "",
                    phase = 1,
                    charIndex = 0,
                    eraseIndex = 0,
                    infoText = alliesForcesText,
                }
            else
                self._alliesList[extraKey].infoText = alliesForcesText
                if self._alliesList[extraKey].state == "erasing" then
                    self._alliesList[extraKey].state = "restoring"
                    self._alliesList[extraKey].lastUpdate = now
                end
            end
        else
            if self._alliesList[extraKey] and self._alliesList[extraKey].state ~= "erasing" then
                self._alliesList[extraKey].state = "erasing"
                self._alliesList[extraKey].lastUpdate = now
            end
        end
        -- Добавляем новых союзников
        for _, v in ipairs(visibleQueue) do
            local key, info = v.key, v
            if not self._alliesList[key] then
                self._alliesList[key] = {
                    ent = info.ent,
                    dist = info.dist,
                    state = "appearing",
                    lastUpdate = now,
                    text = "",
                    phase = 1,
                    charIndex = 0,
                    eraseIndex = 0,
                    infoText = "",
                }
            end
        end
        -- Анимация и удаление
        local alliesToRemove = {}
        for key, data in pairs(self._alliesList) do
            local ent = data.ent
            if not IsValid(ent) and key ~= extraKey then
                table.insert(alliesToRemove, key)
            else
                -- Фазы: 1 — печать "Обнаружен...", 2 — стирание, 3 — печать инфо, 4 — idle, erasing — стирание инфо, restoring — обратная печать
                if data.state == "appearing" then
                    local msg = key == extraKey and data.infoText or (L and L("ally_found_msg") or "Обнаружен новый союзник по близости")
                    if data.phase == 1 then
                        local msgLen = utf8len(msg)
                        if data.charIndex < msgLen then
                            data.charIndex = math.min(msgLen, data.charIndex + FrameTime()*18)
                            data.text = utf8sub(msg, 1, math.floor(data.charIndex))
                        else
                            data.phase = 2
                            data.eraseIndex = msgLen
                            data.lastUpdate = now + 0.3
                        end
                    elseif data.phase == 2 then
                        if now > data.lastUpdate then
                            if data.eraseIndex > 0 then
                                data.eraseIndex = math.max(0, data.eraseIndex - FrameTime()*24)
                                data.text = utf8sub(msg, 1, math.floor(data.eraseIndex))
                            else
                                data.phase = 3
                                data.charIndex = 0
                                if key ~= extraKey then
                                    local char = ent:GetCharacter()
                                    local name = char and char:GetName() or ent:Nick()
                                    local class = char and (ix and ix.class and ix.class.Get and ix.class.Get(char:GetClass()) and ix.class.Get(char:GetClass()).name or char:GetClass() or "") or ""
                                    local dist = math.floor(data.dist)
                                    data.infoTextBase = name .. (class ~= "" and (" | "..class) or "")
                                    local distSuffix = (L and L("distance_units") or "u")
                                    data.infoTextDist = " | " .. dist .. distSuffix
                                    data.infoText = data.infoTextBase .. data.infoTextDist
                                end
                            end
                        end
                    elseif data.phase == 3 then
                        local infoLen = utf8len(data.infoText)
                        if data.charIndex < infoLen then
                            data.charIndex = math.min(infoLen, data.charIndex + FrameTime()*18)
                            data.text = utf8sub(data.infoText, 1, math.floor(data.charIndex))
                        else
                            data.state = "idle"
                            data.text = data.infoText
                        end
                    end
                elseif data.state == "idle" then
                    -- ничего
                elseif data.state == "erasing" then
                    -- Медленное стирание, сначала base, потом расстояние
                    local baseLen = data.infoTextBase and utf8len(data.infoTextBase) or 0
                    local distLen = data.infoTextDist and utf8len(data.infoTextDist) or 0
                    local totalLen = baseLen + distLen
                    if data.charIndex > 0 then
                        -- Стираем base очень медленно
                        if data.charIndex > distLen then
                            data.charIndex = math.max(distLen, data.charIndex - FrameTime()*6)
                        else
                            data.charIndex = math.max(0, data.charIndex - FrameTime()*6)
                        end
                        data.text = utf8sub(data.infoText, 1, math.floor(data.charIndex))
                    else
                        table.insert(alliesToRemove, key)
                    end
                elseif data.state == "restoring" then
                    local infoLen = utf8len(data.infoText)
                    if data.charIndex < infoLen then
                        data.charIndex = math.min(infoLen, data.charIndex + FrameTime()*18)
                        data.text = utf8sub(data.infoText, 1, math.floor(data.charIndex))
                    else
                        data.state = "idle"
                        data.text = data.infoText
                    end
                end
            end
        end
        for _, key in ipairs(alliesToRemove) do
            self._alliesList[key] = nil
        end
        -- Рисуем список
        local minimapSize = 180
        local minimapMargin = 24
        local x = w - minimapSize - minimapMargin - 240
        local y = h * 0.35 + minimapSize + 24
        local title = L and L("nearby_allies_title") or "Ближайшие союзники"
        surface.SetFont("ixMenuButtonFontSmall")
        local titleW, titleH = surface.GetTextSize(title)
        draw.SimpleText(title, "ixMenuButtonFontSmall", x + 60, y, Color(0,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(0,200,255,180)
        surface.DrawRect(x + 60, y+titleH+2, titleW+12, 2)
        local lineY = y + titleH + 10
        -- Сначала союзники из очереди, потом extra
        for i = 1, #visibleQueue do
            local v = visibleQueue[i]
            local data = self._alliesList[v.key]
            if data then
                draw.SimpleText(data.text, "ixMenuButtonFontSmall", x, lineY, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                lineY = lineY + 22
            end
        end
        if self._alliesList[extraKey] then
            draw.SimpleText(self._alliesList[extraKey].text, "ixMenuButtonFontSmall", x, lineY, Color(200,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        -- === КОНЕЦ СПИСКА СОЮЗНИКОВ ===

        -- === СИГНАЛЫ (СОБЫТИЯ) ===
        -- Обработка входящих death-сигналов с сервера
        OBELISK_HUD._pendingPoliceDeaths = OBELISK_HUD._pendingPoliceDeaths or {}
        for i = #OBELISK_HUD._pendingPoliceDeaths, 1, -1 do
            local data = OBELISK_HUD._pendingPoliceDeaths[i]
            -- Проверяем, не добавлен ли уже сигнал (по позиции и времени)
            local already = false
            for _, v in ipairs(self._signalsQueue or {}) do
                if v.deathPos and v.deathPos:DistToSqr(data.pos) < 1 then
                    already = true
                    break
                end
            end
            if not already then
                local dist = math.floor(LocalPlayer():GetPos():Distance(data.pos))
                table.insert(self._signalsQueue, {
                    key = tostring(data.entIndex) .. "_" .. tostring(data.time),
                    type = "death",
                    dist = dist,
                    deathPos = data.pos,
                    ent = nil,
                    state = "appearing",
                    lastUpdate = CurTime(),
                    text = "",
                    phase = 1,
                    charIndex = 0,
                    eraseIndex = 0,
                    infoText = "",
                    infoTextBase = "Союзник мертв",
                    infoTextDist = " | " .. dist .. "у",
                    color = Color(220,40,40),
                })
            end
            table.remove(OBELISK_HUD._pendingPoliceDeaths, i)
        end
        self._signalsQueue = self._signalsQueue or {}
        self._signalsList = self._signalsList or {}
        local maxSignals = 4
        local signalsExtraKey = "__extra__"
        -- Локализация
        local signalsTitle = L and L("signals_title") or "Сигналы"
        local signalAllyDown = L and L("signal_ally_down") or "Потерян Сигнал"
        local signalAllyDead = L and L("signal_ally_dead") or "Союзник мертв"
        local signalEvents = L and L("signal_events") or "Событий"
        local distSuffix = (L and L("distance_units") or "у")

        -- Слушаем смерти союзников (client-side hook)
        self._signalsDeathCache = self._signalsDeathCache or {}
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= LocalPlayer() and IsValid(ply) and not ply:Alive() and not self._signalsDeathCache[ply] then
                local deathPos = ply:GetPos()
                local dist = math.floor(LocalPlayer():GetPos():Distance(deathPos))
                if dist <= 2500 then
                    table.insert(self._signalsQueue, {
                        key = (ply:EntIndex()) .. "_" .. tostring(CurTime()),
                        type = "death",
                        dist = dist,
                        deathPos = deathPos,
                        ent = ply,
                        state = "appearing",
                        lastUpdate = CurTime(),
                        text = "",
                        phase = 1,
                        charIndex = 0,
                        eraseIndex = 0,
                        infoText = "",
                        infoTextBase = signalAllyDead,
                        infoTextDist = " | " .. dist .. distSuffix,
                        color = Color(220,40,40),
                    })
                    self._signalsDeathCache[ply] = true
                end
            end
        end
        -- Ограничиваем очередь до 4 (для отображения)
        local visibleSignals = {}
        for i=1, math.min(#self._signalsQueue, maxSignals) do table.insert(visibleSignals, self._signalsQueue[i]) end
        local totalSignals = #self._signalsQueue
        -- Обработка extra строки
        if totalSignals > maxSignals then
            if not self._signalsList[signalsExtraKey] then
                self._signalsList[signalsExtraKey] = {
                    state = "appearing",
                    lastUpdate = CurTime(),
                    text = "",
                    phase = 1,
                    charIndex = 0,
                    eraseIndex = 0,
                    infoText = signalEvents .. " - " .. tostring(totalSignals),
                    color = Color(200,220,255),
                }
            else
                self._signalsList[signalsExtraKey].infoText = signalEvents .. " - " .. tostring(totalSignals)
                if self._signalsList[signalsExtraKey].state == "erasing" then
                    self._signalsList[signalsExtraKey].state = "restoring"
                    self._signalsList[signalsExtraKey].lastUpdate = CurTime()
                end
            end
        else
            if self._signalsList[signalsExtraKey] and self._signalsList[signalsExtraKey].state ~= "erasing" then
                self._signalsList[signalsExtraKey].state = "erasing"
                self._signalsList[signalsExtraKey].lastUpdate = CurTime()
            end
        end
        for _, v in ipairs(visibleSignals) do
            local key = v.key
            if not self._signalsList[key] then
                self._signalsList[key] = {
                    state = "appearing",
                    lastUpdate = CurTime(),
                    text = "",
                    phase = 1,
                    charIndex = 0,
                    eraseIndex = 0,
                    infoText = "",
                    infoTextBase = v.infoTextBase,
                    infoTextDist = v.infoTextDist,
                    color = v.color,
                    created = CurTime(),
                    deathPos = v.deathPos, -- сохраняем позицию смерти
                    ent = v.ent,
                }
            end
        end
        -- Анимация и удаление сигналов
        local signalsToRemove = {}
        for key, data in pairs(self._signalsList) do
            if key ~= signalsExtraKey then
                -- Новая логика: событие живёт 90 секунд, потом начинает стираться
                local timeLeft = 90
                if data.created then
                    timeLeft = 90 - (CurTime() - data.created)
                    if timeLeft <= 0 and data.state ~= "erasing" then
                        data.state = "erasing"
                        data.lastUpdate = CurTime()
                    end
                end
                if not (function() for _, v in ipairs(visibleSignals) do if v.key == key then return true end end return false end)() then
                    if data.state ~= "erasing" then
                        data.state = "erasing"
                        data.lastUpdate = CurTime()
                    end
                end
                data._timeLeft = timeLeft
                -- Пересчитываем дистанцию до deathPos, если она есть
                if data.deathPos then
                    local dist = math.floor(LocalPlayer():GetPos():Distance(data.deathPos))
                    data.infoTextDist = " | " .. dist .. distSuffix
                end
            end
            -- Анимация
            if data.state == "appearing" then
                local msg = (data.phase == 1) and signalAllyDown or (data.infoTextBase or "") .. (data.infoTextDist or "")
                local msgLen = utf8len(msg)
                if data.phase == 1 then
                    if data.charIndex < msgLen then
                        data.charIndex = math.min(msgLen, data.charIndex + FrameTime()*18)
                        data.text = utf8sub(msg, 1, math.floor(data.charIndex))
                    else
                        data.phase = 2
                        data.eraseIndex = msgLen
                        data.lastUpdate = CurTime() + 0.7
                    end
                elseif data.phase == 2 then
                    if CurTime() > data.lastUpdate then
                        if data.eraseIndex > 0 then
                            data.eraseIndex = math.max(0, data.eraseIndex - FrameTime()*6)
                            data.text = utf8sub(msg, 1, math.floor(data.eraseIndex))
                        else
                            data.phase = 3
                            data.charIndex = 0
                        end
                    end
                elseif data.phase == 3 then
                    local infoMsg = (data.infoTextBase or "") .. (data.infoTextDist or "")
                    local infoLen = utf8len(infoMsg)
                    if data.charIndex < infoLen then
                        data.charIndex = math.min(infoLen, data.charIndex + FrameTime()*18)
                        data.text = utf8sub(infoMsg, 1, math.floor(data.charIndex))
                    else
                        data.state = "idle"
                        data.text = infoMsg
                    end
                end
            elseif data.state == "idle" then
                -- ничего
            elseif data.state == "erasing" then
                local infoMsg = (data.infoTextBase or "") .. (data.infoTextDist or "")
                local infoLen = utf8len(infoMsg)
                if data.charIndex > 0 then
                    data.charIndex = math.max(0, data.charIndex - FrameTime()*6)
                    data.text = utf8sub(infoMsg, 1, math.floor(data.charIndex))
                else
                    table.insert(signalsToRemove, key)
                end
            elseif data.state == "restoring" then
                local infoMsg = (data.infoTextBase or "") .. (data.infoTextDist or "")
                local infoLen = utf8len(infoMsg)
                if data.charIndex < infoLen then
                    data.charIndex = math.min(infoLen, data.charIndex + FrameTime()*18)
                    data.text = utf8sub(infoMsg, 1, math.floor(data.charIndex))
                else
                    data.state = "idle"
                    data.text = infoMsg
                end
            end
        end
        for _, key in ipairs(signalsToRemove) do
            self._signalsList[key] = nil
        end
        -- Рисуем блок сигналов
        local signalsX = x + 120
        local signalsY = lineY + 18
        draw.SimpleText(signalsTitle, "ixMenuButtonFont", signalsX + 60, signalsY, Color(0,200,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(0,200,255,180)
        local signalsTitleW, signalsTitleH = surface.GetTextSize(signalsTitle)
        surface.DrawRect(signalsX + 60, signalsY+signalsTitleH+2, signalsTitleW+12, 2)
        local sigLineY = signalsY + signalsTitleH + 10
        for i = 1, #visibleSignals do
            local v = visibleSignals[i]
            local data = self._signalsList[v.key]
            if data then
                -- Пересчитываем дистанцию до deathPos прямо перед отрисовкой
                if data.deathPos then
                    local dist = math.floor(LocalPlayer():GetPos():Distance(data.deathPos))
                    data.infoTextDist = " | " .. dist .. distSuffix
                    -- Если сигнал в фазе idle или показа второго текста, обновляем текст
                    if data.state == "idle" or (data.state == "appearing" and data.phase == 3) or data.state == "restoring" then
                        data.text = (data.infoTextBase or "") .. (data.infoTextDist or "")
                    end
                end
                local timerText = ""
                if data._timeLeft and data._timeLeft > 0 and data._timeLeft < 90 then
                    timerText = formatTimer(data._timeLeft)
                end
                local textW = surface.GetTextSize(data.text or "")
                draw.SimpleText(data.text, "ixMenuButtonFont", signalsX - 130, sigLineY, data.color or Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                if timerText ~= "" then
                    draw.SimpleText(timerText, "ixMenuButtonFont", signalsX - 130 + textW + 16, sigLineY, Color(200,200,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                sigLineY = sigLineY + 22
            end
        end
        if self._signalsList[signalsExtraKey] then
            local data = self._signalsList[signalsExtraKey]
            draw.SimpleText(data.text, "ixMenuButtonFont", signalsX - 70, sigLineY, data.color or Color(200,220,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        -- === КОНЕЦ СИГНАЛОВ ===

    end
end 

-- === ВЫВОД ТЕКСТА В ЛЕВОМ ВЕРХНЕМ УГЛУ ===

OBELISK_HUD = OBELISK_HUD or {}
OBELISK_HUD.helmetText = OBELISK_HUD.helmetText or {}

function OBELISK_HUD.helmetText.Reset()
    local ht = OBELISK_HUD.helmetText
    ht._lines = {}
    ht._currentText = nil
    ht._currentChar = 0
    ht._lastUpdate = 0
    ht._initialIndex = 1
    ht._randomPool = nil
    ht._initialTexts = nil
    ht._isActive = false
end

local function getHelmetInitialTexts()
    local t = {}
    for i = 1, 5 do
        local str = L("helmet_text_initial_"..i, {})
        if str and str ~= "" then
            table.insert(t, str)
        end
    end
    return t
end
local function getHelmetRandomTexts()
    local t = {}
    for i = 1, 10 do
        local str = L("helmet_text_random_"..i, {})
        if str and str ~= "" then
            table.insert(t, str)
        end
    end
    return t
end

-- Не инициализируем helmetText при загрузке файла

local function getNextHelmetText()
    local ht = OBELISK_HUD.helmetText
    ht._initialTexts = ht._initialTexts or getHelmetInitialTexts()
    ht._randomPool = ht._randomPool or getHelmetRandomTexts()
    if ht._initialIndex <= #ht._initialTexts then
        local text = ht._initialTexts[ht._initialIndex]
        ht._initialIndex = ht._initialIndex + 1
        return text
    else
        if #ht._randomPool == 0 then
            ht._randomPool = getHelmetRandomTexts()
        end
        local idx = math.random(1, #ht._randomPool)
        local text = ht._randomPool[idx]
        table.remove(ht._randomPool, idx)
        return text
    end
end

-- Для поддержки UTF-8
local utf8 = utf8 or require and require("utf8") or _G.utf8
local function utf8sub(str, i, j)
    if utf8 and utf8.sub then
        return utf8.sub(str, i, j)
    else
        -- fallback на string.sub (может ломать юникод)
        return string.sub(str, i, j)
    end
end

function OBELISK_HUD.helmetText.Think()
    local ht = OBELISK_HUD.helmetText
    if not ht._currentText then
        ht._currentText = getNextHelmetText()
        ht._currentChar = 0
        ht._lastUpdate = CurTime()
    end
    if ht._currentText then
        local speed = 0.22 -- очень медленная скорость печати (секунд на символ)
        if CurTime() - ht._lastUpdate > speed then
            ht._currentChar = ht._currentChar + 1
            ht._lastUpdate = CurTime()
            if ht._currentChar > (utf8 and utf8.len and utf8.len(ht._currentText) or #ht._currentText) then
                table.insert(ht._lines, {text = ht._currentText, time = CurTime()})
                if #ht._lines > 5 then
                    table.remove(ht._lines, 1)
                end
                ht._currentText = nil
                ht._currentChar = 0
                ht._lastUpdate = CurTime() + 1.5 -- задержка перед следующим текстом
            end
        end
    end
end

function OBELISK_HUD.helmetText.Draw()
    local ht = OBELISK_HUD.helmetText
    if not ht._initialTexts then return end
    local x, y = 32, 32
    local lineHeight = 20
    surface.SetFont("ixMenuButtonFontSmall")
    for i, line in ipairs(ht._lines or {}) do
        draw.SimpleText(line.text, "ixMenuButtonFontSmall", x, y + (i-1)*lineHeight, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    if ht._currentText then
        local shown = utf8sub(ht._currentText, 1, ht._currentChar)
        draw.SimpleText(shown, "ixMenuButtonFontSmall", x, y + #(ht._lines or {})*lineHeight, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end
hook.Add("HUDPaint", "ObeliskHelmetText", function()
    local char = LocalPlayer():GetCharacter()
    if not char then return end
    
    if OBELISK_HUD and OBELISK_HUD.helmetText and OBELISK_HUD.helmetText._isActive and OBELISK_HUD.helmetText._initialTexts then
        if OBELISK_HUD.selectedRenderer == "helmet" then
            OBELISK_HUD.helmetText.Think()
            OBELISK_HUD.helmetText.Draw()
        end
    end
end)
-- Запуск только при спавне персонажа
hook.Remove("CharacterLoaded", "ObeliskHelmetTextStart")

-- Запуск только при спавне персонажа
hook.Add("CharacterLoaded", "ObeliskHelmetTextStart", function()
    if OBELISK_HUD and OBELISK_HUD.helmetText then
        OBELISK_HUD.helmetText.Reset()
        -- Инициализация массивов для запуска
        OBELISK_HUD.helmetText._initialTexts = getHelmetInitialTexts()
        OBELISK_HUD.helmetText._randomPool = getHelmetRandomTexts()
        OBELISK_HUD.helmetText._isActive = true
    end
end) 

-- Сброс текста при смерти
hook.Add("PlayerDeath", "ObeliskHelmetTextResetOnDeath", function(victim, inflictor, attacker)
    if victim == LocalPlayer() and OBELISK_HUD and OBELISK_HUD.helmetText then
        OBELISK_HUD.helmetText.Reset()
        OBELISK_HUD.helmetText._isActive = false
    end
end)

-- Запуск текста заново при респавне
hook.Add("PlayerSpawn", "ObeliskHelmetTextStartOnSpawn", function(ply)
    if ply == LocalPlayer() and OBELISK_HUD and OBELISK_HUD.helmetText then
        OBELISK_HUD.helmetText.Reset()
        OBELISK_HUD.helmetText._initialTexts = getHelmetInitialTexts()
        OBELISK_HUD.helmetText._randomPool = getHelmetRandomTexts()
        OBELISK_HUD.helmetText._isActive = true
    end
end) 

--[[
-- === НОЧНОЕ ВИДЕНИЕ ===
OBELISK_HUD = OBELISK_HUD or {}
OBELISK_HUD.helmetNightVisionActive = false
local NIGHT_VISION_KEY = KEY_P
local nightVisionColorMod = {
    ["$pp_colour_addr"] = 150,
    ["$pp_colour_addg"] = 100,
    ["$pp_colour_addb"] = 10,
    ["$pp_colour_brightness"] = -2,
    ["$pp_colour_contrast"] = 7,
    ["$pp_colour_colour"] = 0.22,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

hook.Add("Think", "ObeliskHelmetNightVisionKey", function()
    if input.IsKeyDown(NIGHT_VISION_KEY) and not OBELISK_HUD._nightVisionKeyPressed then
        OBELISK_HUD.helmetNightVisionActive = not OBELISK_HUD.helmetNightVisionActive
        OBELISK_HUD._nightVisionKeyPressed = true
        print("[ObeliskHUD] Night vision toggled:", OBELISK_HUD.helmetNightVisionActive)
    elseif not input.IsKeyDown(NIGHT_VISION_KEY) then
        OBELISK_HUD._nightVisionKeyPressed = false
    end
end)

hook.Add("HUDPaint", "ObeliskHelmetNightVisionEffect", function()
    if OBELISK_HUD and OBELISK_HUD.helmetNightVisionActive then
        print("[ObeliskHUD] DrawColorModify called")
        DrawColorModify(nightVisionColorMod)
    end
end)
]] 