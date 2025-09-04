local PLUGIN = PLUGIN

if CLIENT then
    -- CONFIG
    local shouldConcussion = false
    local concussionScreenActive = false
    local concussionEffectID = nil
    local concussionStartTime = 0
    local concussionDuration = 5
    local concussionSound = nil
    local canChangeVolume = true

    local shouldBloodLoss = false
    local shouldBlurVision = false
    local breathingSound = nil
    local breathingStartTime = 0

    function PLUGIN:DrawMedicalHUD()
        local char = LocalPlayer():GetCharacter()
        if not char then return end
        
        local traumatable = char:GetTrauma()

        if shouldConcussion then
            PLUGIN:DrawConcussionOverlay()
        end

        if shouldBlurVision then
            PLUGIN:DrawBlurredVision()
        end

        if shouldBloodLoss then
            PLUGIN:DrawBloodLossOverlay()
        end
    end

    function PLUGIN:DrawBloodLossOverlay()
        local screenW, screenH = ScrW(), ScrH()
        local period = 5
        local minAlpha = 180
        local maxAlpha = 240

        DrawMotionBlur(0.1, 1, 0.01)

        local t = CurTime()
        if not self._blurStartTime then
            self._blurStartTime = t
        end
        local elapsed = t - self._blurStartTime

        local phase = math.floor(elapsed / period)
        local phaseTime = elapsed % period
        local alpha

        if phase % 2 == 0 then
            alpha = Lerp(phaseTime / period, minAlpha, maxAlpha)
        else
            alpha = Lerp(phaseTime / period, maxAlpha, minAlpha)
        end

        surface.SetDrawColor(0, 0, 0, math.Clamp(alpha, minAlpha, maxAlpha))
        surface.DrawRect(0, 0, screenW, screenH)
    end 

    function PLUGIN:DrawBlurredVision()
        local screenW, screenH = ScrW(), ScrH()
        local period = 5
        local minAlpha = 180
        local maxAlpha = 240

        local t = CurTime()
        if not self._blurStartTime then
            self._blurStartTime = t
        end
        local elapsed = t - self._blurStartTime

        local phase = math.floor(elapsed / period)
        local phaseTime = elapsed % period
        local alpha

        if phase % 2 == 0 then
            alpha = Lerp(phaseTime / period, minAlpha, maxAlpha)
        else
            alpha = Lerp(phaseTime / period, maxAlpha, minAlpha)
        end

        if not breathingSound then
            breathingSound = CreateSound(LocalPlayer(), "player/breathe1.wav")
            breathingSound:Play()
            breathingStartTime = CurTime()
        end

        surface.SetDrawColor(0, 0, 0, math.Clamp(alpha, minAlpha, maxAlpha))
        surface.DrawRect(0, 0, screenW, screenH)
    end

    function PLUGIN:DrawConcussionOverlay()
        if not concussionScreenActive then 
            return 
        end
        
        surface.SetDrawColor(255, 255, 255, 255)
        DrawMotionBlur(0.1, 1, 0.01)

        local currentTime = CurTime()
        local elapsed = currentTime - concussionStartTime
        local volume = concussionSound:GetVolume() * 100
        local alpha = 255

        if elapsed < 0.1 then
            local fadeProgress = elapsed / 0.1
            alpha = Lerp(fadeProgress, 0, 255)
        elseif elapsed > concussionDuration - 1.5 then
            local fadeProgress = (elapsed - (concussionDuration - 1.5)) / 1.5
            alpha = Lerp(fadeProgress, 255, 0)
        end

        alpha = math.Clamp(alpha, 0, 255)
        volume = math.Clamp(volume, 0, 100)

        local screenW, screenH = ScrW(), ScrH()

        if canChangeVolume then
            concussionSound:ChangeVolume((volume - elapsed*0.01)/100)
        end

        if (volume <= 0.1) then
            concussionSound:ChangeVolume(0.1)
            canChangeVolume = false
        end
        
        surface.SetDrawColor(255, 255, 255, alpha * 0.9)
        surface.DrawRect(0, 0, screenW, screenH)
        
        local flickerIntensity = math.sin(currentTime * 6) * 0.15 + 0.85
        surface.SetDrawColor(255, 255, 255, alpha * 0.4 * flickerIntensity)
        surface.DrawRect(0, 0, screenW, screenH)
        
        local blurRadius = 15
        for i = 1, 3 do
            local blurAlpha = alpha * 0.08 / i
            surface.SetDrawColor(255, 255, 255, blurAlpha)
            surface.DrawOutlinedRect(-blurRadius * i, -blurRadius * i, screenW + blurRadius * i * 2, screenH + blurRadius * i * 2, blurRadius)
        end
    end

    function PLUGIN:HUDPaint()
        PLUGIN:DrawMedicalHUD()
    end

    net.Receive("ixConcussionEffect", function()
        local shouldPlay = net.ReadBool()
        local effectID = net.ReadString()
        
        if shouldPlay then
            shouldConcussion = true
            concussionSound = CreateSound(LocalPlayer(), "statuseffects/ear-ringing.wav")
            concussionSound:ChangeVolume(100)
            concussionSound:Play()
            
            concussionScreenActive = true
            concussionEffectID = effectID
            concussionStartTime = CurTime()
            canChangeVolume = true
        else
            shouldConcussion = false
            concussionSound:Stop()
            concussionSound = nil
            
            concussionScreenActive = false
            concussionEffectID = nil
        end
    end)

    net.Receive("ixBlurredEffect", function()
        local shouldPlay = net.ReadBool()
        local effectID = net.ReadString()
        
        if shouldPlay then
            shouldBlurVision = true
        else
            shouldBlurVision = false
            if breathingSound then
                breathingSound:Stop()
                breathingSound = nil
            end
        end
    end)

    net.Receive("ixBloodLossEffect", function()
        local shouldPlay = net.ReadBool()

        if shouldPlay then
            shouldBloodLoss = true
        else
            shouldBloodLoss = false
        end
    end)
end