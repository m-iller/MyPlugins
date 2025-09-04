local PLUGIN = PLUGIN
local RNDX = PLUGIN.RNDX
local FLAGS = RNDX.SHAPE_FIGMA

local DrawTextCenteredEnts, CleanupTextCorrectionsEnts, CreateFontsEnts do
    local textHeightCorrectionsEnts = {}
    local function GetTextCorrectionEnts(text, font)
        local cacheKey = font .. "_" .. text
        if textHeightCorrectionsEnts[cacheKey] then return textHeightCorrectionsEnts[cacheKey] end
        surface.SetFont(font)
        local _, height = surface.GetTextSize(text)
        local visualHeight, emptySpace = surface.GetVisualCharacterHeight(text, font)
        local correction = (height - visualHeight) * 0.5 - emptySpace
        textHeightCorrectionsEnts[cacheKey] = correction
        return correction
    end

    function DrawTextCenteredEnts(text, font, x, y, color, xAlign, yAlign)
        surface.SetFont(font)
        local correction = GetTextCorrectionEnts(text, font)
        draw.SimpleText(text, font, x, y + correction * 0.5, color, xAlign, yAlign)
    end

    function CleanupTextCorrectionsEnts()
        textHeightCorrectionsEnts = {}
    end

    function CreateFontsEnts()
        surface.CreateFont("Zen-Kaku-Gothic-Regular", {
            font = "Zen Kaku Gothic Antique",
            extended = true,
            size = 60,
            weight = 500,
        })

        surface.CreateFont("Zen-Kaku-Gothic-Interaction", {
            font = "Zen Kaku Gothic Antique",
            extended = true,
            size = 88,
            weight = 600,
        })
    end
end

local hoveredButtonEnts = nil
local buttonHoverStatesEnts = {}
local buttonAnimationsEnts = {}
local useBindEnts
local targetPlayerEnts = NULL
local targetEntityEnts = NULL
local menuAlphaEnts = 0
local lastActionTimeEnts = 0
local flashAnimationsEnts = {}
local pendingActionsEnts = {}
local lastInteractionTimeEnts = 0

-- Initialize animations for buttons
local function InitializeButtonAnimationsEnts(buttons)
    for i = 1, #buttons do
        if not buttonAnimationsEnts[i] then
            buttonAnimationsEnts[i] = 0
        end
        if not flashAnimationsEnts[i] then
            flashAnimationsEnts[i] = 0
        end
    end
end

local UpdateBindingsEnts, HandleInputEnts, IsPressingEnts, IsPressedEnts, IsMousePressedEnts, StartDrawEnts, EndDrawEnts, GetCursorPosEnts, IsHoveringEnts do
    local inputEnabledEnts, isPressingEnts, isPressedEnts
    local mouseXEnts, mouseYEnts
    local isMousePressingEnts, isMousePressedEnts
    local function FindTargetPlayerEnts()
        if not inputEnabledEnts then return NULL end
        local localPlayer = LocalPlayer()
        local eyePos = localPlayer:EyePos()
        local trace = {
            start = eyePos,
            endpos = eyePos + localPlayer:GetAimVector() * PLUGIN.INTERFACE_DISTANCE,
            filter = localPlayer,
            mask = MASK_SHOT_HULL
        }

        local result = util.TraceLine(trace)
        if not result.Hit then return NULL end
        local entity = result.Entity
        if IsValid(entity) then
            if not PLUGIN.whitelistedEntities[entity:GetClass()] then return NULL end
            local distSqr = localPlayer:GetPos():DistToSqr(entity:GetPos())
            if distSqr <= PLUGIN.MAX_DISTANCE_SQR then return entity end
        end
        return NULL
    end

    function UpdateBindingsEnts()
        useBindEnts = input.LookupBinding("+use", true)
    end

    function HandleInputEnts()
        if render.GetRenderTarget() or vgui.CursorVisible() then
            inputEnabledEnts = false
            targetPlayerEnts = NULL
            targetEntityEnts = NULL
            return
        end

        local useKey = useBindEnts and input.GetKeyCode(useBindEnts)
        inputEnabledEnts = true
        local wasPressing = isPressingEnts
        isPressingEnts = useKey and input.IsButtonDown(useKey)
        
        -- Проверяем задержку в 1 секунду
        local currentTime = CurTime()
        if currentTime - lastInteractionTimeEnts < 1 then
            isPressedEnts = false
        else
            isPressedEnts = not wasPressing and isPressingEnts
            if isPressedEnts then
                lastInteractionTimeEnts = currentTime
            end
        end
        
        local wasMousePressing = isMousePressingEnts
        isMousePressingEnts = input.IsMouseDown(MOUSE_LEFT)
        isMousePressedEnts = not wasMousePressing and isMousePressingEnts
        targetEntityEnts = FindTargetPlayerEnts()
        if isPressingEnts then
            targetPlayerEnts = targetEntityEnts
        else
            targetPlayerEnts = NULL
        end
    end

    function IsPressingEnts()
        return inputEnabledEnts and isPressingEnts
    end

    function IsPressedEnts()
        return inputEnabledEnts and isPressedEnts
    end

    function IsMousePressedEnts()
        return inputEnabledEnts and isMousePressedEnts
    end

    function StartDrawEnts(pos, angles, scale, ignoredEntity)
        local localPlayer = LocalPlayer()
        local eyePos = localPlayer:EyePos()
        local eyePosToUi = pos - eyePos
        local normal = angles:Up()
        local dot = eyePosToUi:Dot(normal)
        if dot >= 0 then return false end
        cam.Start3D2D(pos, angles, scale)
        local cursorVisible, hoveringWorld = vgui.CursorVisible(), vgui.IsHoveringWorld()
        if not hoveringWorld and cursorVisible then return true end
        local eyeNormal
        if cursorVisible and hoveringWorld then
            eyeNormal = gui.ScreenToVector(gui.MousePos())
        else
            eyeNormal = localPlayer:GetEyeTrace().Normal
        end

        local hitPos = util.IntersectRayWithPlane(eyePos, eyeNormal, pos, normal)
        if not hitPos then return true end
        local query = {
            start = eyePos,
            endpos = hitPos,
            filter = {localPlayer, ignoredEntity}
        }

        if util.TraceLine(query).Hit then return true end
        local diff = pos - hitPos
        mouseXEnts = diff:Dot(-angles:Forward()) / scale
        mouseYEnts = diff:Dot(-angles:Right()) / scale
        return true
    end

    function EndDrawEnts()
        cam.End3D2D()
    end

    function GetCursorPosEnts()
        return mouseXEnts, mouseYEnts
    end

    function IsHoveringEnts(x, y, w, h)
        return mouseXEnts and mouseYEnts and mouseXEnts >= x and mouseXEnts <= (x + w) and mouseYEnts >= y and mouseYEnts <= (y + h)
    end
end

local CalculateMenuDimensionsEnts, CalculateAlphaEnts, UpdateButtonAnimationsEnts, CalculateButtonPositionEnts do
    local function CalculateMaxTextWidthEnts()
        local maxWidth = 0
        surface.SetFont("Zen-Kaku-Gothic-Regular")
        local buttons = PLUGIN:GetButtonsForEntity(targetEntityEnts)
        for _, btn in ipairs(buttons) do
            if btn.text2 then
                local ftext = btn.text..btn.text2(targetEntityEnts)
                local textWidth = surface.GetTextSize(ftext)
                maxWidth = math.max(maxWidth, textWidth)
            else
                local textWidth = surface.GetTextSize(btn.text)
                maxWidth = math.max(maxWidth, textWidth)
            end
        end
        return maxWidth + 4 * PLUGIN.BACKGROUND_PADDING
    end
    local cachedWidthEnts = nil
    function CalculateMenuDimensionsEnts()
        if not cachedWidthEnts then cachedWidthEnts = CalculateMaxTextWidthEnts() end
        local buttons = PLUGIN:GetButtonsForEntity(targetEntityEnts)
        local visibleButtons = 0
        for _, btn in ipairs(buttons) do
            if btn.check(targetEntityEnts) then visibleButtons = visibleButtons + 1 end
        end

        local height = visibleButtons * (PLUGIN.BUTTON_HEIGHT + PLUGIN.BUTTON_MARGIN) - PLUGIN.BUTTON_MARGIN + 2 * PLUGIN.BACKGROUND_PADDING
        return cachedWidthEnts, height
    end

    function CalculateAlphaEnts(ply)
        local eyeAngles = ply:EyeAngles()
        local playerViewDirection = eyeAngles:Forward()
        local toLocalPlayer = (LocalPlayer():GetPos() - ply:GetPos()):GetNormalized()
        local dotProduct = playerViewDirection:Dot(toLocalPlayer)
        local angle = math.deg(math.acos(dotProduct))
        local angleAlpha = 1
        if angle > PLUGIN.FADE_ANGLE then 
            angleAlpha = math.max(0, 1 - (angle - PLUGIN.FADE_ANGLE) / (120 - PLUGIN.FADE_ANGLE)) 
        end
        local distSqr = LocalPlayer():GetPos():DistToSqr(ply:GetPos())
        local distanceAlpha = 1
        if distSqr > PLUGIN.FADE_START_SQR then 
            distanceAlpha = math.max(0, 1 - (math.sqrt(distSqr) - math.sqrt(PLUGIN.FADE_START_SQR)) / PLUGIN.FADE_DISTANCE) 
        end
        return math.min(angleAlpha, distanceAlpha)
    end

    function UpdateButtonAnimationsEnts()
        local frameTime = RealFrameTime()
        local buttons = PLUGIN:GetButtonsForEntity(targetEntityEnts)
        InitializeButtonAnimationsEnts(buttons)
        for i, btn in ipairs(buttons) do
            local targetScale = (hoveredButtonEnts == i) and 1 or 0
            buttonAnimationsEnts[i] = Lerp(frameTime * PLUGIN.BUTTON_ANIMATION_SPEED, buttonAnimationsEnts[i], targetScale)
            if flashAnimationsEnts[i] > 0 then
                flashAnimationsEnts[i] = math.max(0, flashAnimationsEnts[i] - frameTime / PLUGIN.FLASH_DURATION)
                if flashAnimationsEnts[i] == 0 and pendingActionsEnts[i] then
                    local action = pendingActionsEnts[i]
                    pendingActionsEnts[i] = nil
                    action.func(action.ply)
                end
            end
        end
    end

    function CalculateButtonPositionEnts(index)
        local _, height = CalculateMenuDimensionsEnts()
        local baseY = -height * 0.5 + PLUGIN.BACKGROUND_PADDING
        local totalOffset = 0
        local visibleIndex = 0
        local buttons = PLUGIN:GetButtonsForEntity(targetEntityEnts)
        for i = 1, #buttons do
            if buttons[i].check(targetEntityEnts) then
                visibleIndex = visibleIndex + 1
                if visibleIndex < index then
                    local scale = buttonAnimationsEnts[i]
                    local buttonHeight = PLUGIN.BUTTON_HEIGHT * (1 + (PLUGIN.BUTTON_SCALE_FACTOR - 1) * scale)
                    local marginHeight = PLUGIN.BUTTON_MARGIN * (1 + (PLUGIN.MARGIN_SCALE_FACTOR - 1) * scale)
                    totalOffset = totalOffset + buttonHeight + marginHeight
                end
            end
        end
        return baseY + totalOffset
    end
end

local DrawPlayerInterfaceEnts do
    function DrawPlayerInterfaceEnts(ply)
        if not IsValid(ply) or not ply:Alive() or ply == LocalPlayer() then return end
        if not PLUGIN.whitelistedEntities[ply:GetClass()] then return end
        
        local baseAlpha = CalculateAlphaEnts(ply)
        if baseAlpha <= 0 then return end
        if not IsPressingEnts() or targetPlayerEnts ~= ply then
            menuAlphaEnts = math.max(0, menuAlphaEnts - RealFrameTime() * PLUGIN.MENU_FADE_SPEED)
            if menuAlphaEnts == 0 then 
                buttonHoverStatesEnts = {}
                -- Reset animations when menu closes
                local buttons = PLUGIN:GetButtonsForEntity(ply)
                InitializeButtonAnimationsEnts(buttons)
            end
        else
            menuAlphaEnts = math.min(1, menuAlphaEnts + RealFrameTime() * PLUGIN.MENU_FADE_SPEED)
        end

        local pos = ply:EyePos() + Vector(0, 0, 10)
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Up(), -90)
        ang:RotateAroundAxis(ang:Forward(), 90)
        local scale = 0.03
        local width, _ = CalculateMenuDimensionsEnts()
        cam.IgnoreZ(true)
        if StartDrawEnts(pos, ang, scale, ply) then
            render.UpdateScreenEffectTexture()
            if not IsPressingEnts() or targetPlayerEnts ~= ply then
                surface.SetAlphaMultiplier(baseAlpha)
                RNDX.Draw(PLUGIN.INTERACTION_CIRCLE_RADIUS, -PLUGIN.INTERACTION_CIRCLE_RADIUS, -PLUGIN.INTERACTION_CIRCLE_RADIUS, PLUGIN.INTERACTION_CIRCLE_RADIUS * 2, PLUGIN.INTERACTION_CIRCLE_RADIUS * 2, PLUGIN.BACKGROUND_COLOR, FLAGS + RNDX.BLUR)
                RNDX.Draw(PLUGIN.INTERACTION_CIRCLE_RADIUS, -PLUGIN.INTERACTION_CIRCLE_RADIUS, -PLUGIN.INTERACTION_CIRCLE_RADIUS, PLUGIN.INTERACTION_CIRCLE_RADIUS * 2, PLUGIN.INTERACTION_CIRCLE_RADIUS * 2, PLUGIN.BACKGROUND_COLOR, FLAGS)
                local bindKey = string.upper(useBindEnts or "E")
                DrawTextCenteredEnts(bindKey, "Zen-Kaku-Gothic-Interaction", 0, 0, PLUGIN.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                surface.SetAlphaMultiplier(1)
            end

            if menuAlphaEnts > 0 then
                surface.SetAlphaMultiplier(baseAlpha * menuAlphaEnts)
                UpdateButtonAnimationsEnts()
                hoveredButtonEnts = nil
                local visibleIndex = 0
                local buttons = PLUGIN:GetButtonsForEntity(ply)
                for i, btn in ipairs(buttons) do
                    if not btn.check(ply) then continue end
                    visibleIndex = visibleIndex + 1
                    local y = CalculateButtonPositionEnts(visibleIndex)
                    local btnWidth = width - 2 * PLUGIN.BACKGROUND_PADDING
                    local currentTextColor = Color(234, 234, 234)
                    local scaleFactor = 1 + (PLUGIN.BUTTON_SCALE_FACTOR - 1) * buttonAnimationsEnts[i]
                    local scaledWidth = math.ceil(btnWidth * scaleFactor)
                    local scaledHeight = math.ceil(PLUGIN.BUTTON_HEIGHT * scaleFactor)
                    local centerX = -width * 0.5 + PLUGIN.BACKGROUND_PADDING + btnWidth * 0.5
                    local centerY = y + scaledHeight * 0.5
                    local flashedColor = Color(Lerp(flashAnimationsEnts[i] * PLUGIN.FLASH_INTENSITY, PLUGIN.BACKGROUND_COLOR.r, PLUGIN.FLASH_COLOR.r), Lerp(flashAnimationsEnts[i] * PLUGIN.FLASH_INTENSITY, PLUGIN.BACKGROUND_COLOR.g, PLUGIN.FLASH_COLOR.g), Lerp(flashAnimationsEnts[i] * PLUGIN.FLASH_INTENSITY, PLUGIN.BACKGROUND_COLOR.b, PLUGIN.FLASH_COLOR.b), PLUGIN.BACKGROUND_COLOR.a * (baseAlpha * menuAlphaEnts))
                    local isHovering = IsHoveringEnts(centerX - scaledWidth * 0.5, centerY - scaledHeight * 0.5, scaledWidth, scaledHeight)
                    if isHovering then
                        hoveredButtonEnts = i
                        currentTextColor = Color(150, 104, 75)
                        if not buttonHoverStatesEnts[i] then
                            surface.PlaySound("ui_base/hover1.mp3")
                            buttonHoverStatesEnts[i] = true
                        end

                        if IsMousePressedEnts() and CurTime() - lastActionTimeEnts > PLUGIN.ACTION_COOLDOWN then
                            pendingActionsEnts[i] = {
                                func = btn.action,
                                ply = ply
                            }
                            lastActionTimeEnts = CurTime()
                            flashAnimationsEnts[i] = 1
                            surface.PlaySound("ui_base/click.mp3")
                        end
                    else
                        buttonHoverStatesEnts[i] = false
                    end

                    RNDX.Draw(scaledHeight * 0.5, centerX - scaledWidth * 0.5, centerY - scaledHeight * 0.5, scaledWidth, scaledHeight, PLUGIN.BACKGROUND_COLOR, FLAGS + RNDX.BLUR)
                    RNDX.Draw(scaledHeight * 0.5, centerX - scaledWidth * 0.5, centerY - scaledHeight * 0.5, scaledWidth, scaledHeight, flashedColor, FLAGS)
                    if btn.text2 then
                        DrawTextCenteredEnts(btn.text..btn.text2(ply), "Zen-Kaku-Gothic-Regular", centerX, centerY, currentTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    else
                        DrawTextCenteredEnts(btn.text, "Zen-Kaku-Gothic-Regular", centerX, centerY, currentTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

                surface.SetAlphaMultiplier(1)
            end

            EndDrawEnts()
        end

        cam.IgnoreZ(false)
    end
end

CreateFontsEnts()
UpdateBindingsEnts()

hook.Add("OnScreenSizeChanged", "UpdatePlayerInteractionEnts", function()
    CreateFontsEnts()
    CleanupTextCorrectionsEnts()
    surface.ClearVCHCache()
    cachedWidthEnts = nil
end)

hook.Add("InitPostEntity", "InitializePlayerInteractionEnts", function()
    CreateFontsEnts()
    UpdateBindingsEnts()
    timer.Create("LookupBindings", 60, 0, UpdateBindingsEnts)
end)

hook.Add("PreRender", "HandlePlayerInteractionMenuInputEnts", HandleInputEnts)
hook.Add("PreDrawEffects", "DrawPlayerInteractionMenuEnts", function()
    local localPlayer = LocalPlayer()
    if not IsValid(localPlayer) then return end
    if IsValid(targetEntityEnts) then DrawPlayerInterfaceEnts(targetEntityEnts) end
end)