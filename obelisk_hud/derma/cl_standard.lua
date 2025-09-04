-- Obelisk HUD Standard Style Renderer

if CLIENT then
    -- Initialize renderers table if it doesn't exist
    OBELISK_HUD.renderers = OBELISK_HUD.renderers or {}
    
    -- Загрузка иконки стамины
    local staminaIcon = Material("icons/stamina.png", "smooth")
    
    -- Standard HUD renderer - только стамина
    OBELISK_HUD.renderers.standard = function(self, w, h, data)
        local stamina = data.stamina
        local maxStamina = data.maxStamina
        
        -- Draw Stamina bar
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
        local staminaBarHeight = math.max(h * 0.012, 4)
        local staminaBarY = h - staminaBarHeight - math.max(h * 0.01, 8)
        local staminaBarX = (w - staminaBarWidth) / 2
        local staminaFillWidth = math.Clamp(self._animatedStamina, 0, maxStamina) / maxStamina * staminaBarWidth
        local centerX = staminaBarX + staminaBarWidth / 2
        
        -- Get stamina color based on threshold (30)
        local staminaColor = (stamina < 30) and Color(220, 20, 60) or Color(255, 255, 255)
        
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
                -- amount: при 5 стамины = 1, при 40% = 0
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
            -- surface.DrawOutlinedRect(staminaBarX, staminaBarY, staminaBarWidth, staminaBarHeight, 1)

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
                -- Плавное мигание цвета (от белого к красному)
                local pulse = (math.sin(CurTime() * 6) + 1) / 2 -- 0..1
                local r = Lerp(pulse, 255, 220)
                local g = Lerp(pulse, 255, 20)
                local b = Lerp(pulse, 255, 60)
                local iconAlpha = math.Clamp(self._staminaIconAlpha, 0, 255)
                surface.SetMaterial(staminaIcon)
                surface.SetDrawColor(r, g, b, iconAlpha)
                surface.DrawTexturedRect(iconX + shake, iconY + shake, iconSize, iconSize)
            end
        end
    end
end 