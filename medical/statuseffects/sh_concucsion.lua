local PLUGIN = PLUGIN

EFFECT.name = "Контузия"

EFFECT.duration = 0
EFFECT.speedMultiplier = 0.3

EFFECT._timerID = nil

function EFFECT:OnStart(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()

    if not IsValid(ply) then return end

    self._timerID = "concussion_" .. tostring(ply:SteamID64()) .. "_" .. tostring(self.uniqueID)

    local hitgroupName = "неизвестная область"
    if PLUGIN.HitgroupConfigTable[hitgroup] then
        hitgroupName = PLUGIN.HitgroupConfigTable[hitgroup].name
    end

    ply:SetRunSpeed(ply:GetRunSpeed() * self.speedMultiplier)
    ply:SetWalkSpeed(ply:GetWalkSpeed() * self.speedMultiplier)

    net.Start("ixConcussionEffect")
    net.WriteBool(true)
    net.WriteString(self.uniqueID)
    net.Send(ply)

    if self.duration == 0 then return end

    timer.Create(self._timerID, self.duration, 1, function()
        if not IsValid(ply) or not self.isActive then
            timer.Remove(self._timerID)
            return
        end

        self:EndEffect(character, hitgroup)
    end)
end

function EFFECT:OnEnd(character, hitgroup)
    if not SERVER then return end

    local ply = character:GetPlayer()

    self._timerID = "concussion_" .. tostring(ply:SteamID64()) .. "_" .. tostring(self.uniqueID)

    timer.Remove(self._timerID)

    ply:SetRunSpeed(ix.config.Get("runSpeed"))
    ply:SetWalkSpeed(ix.config.Get("walkSpeed"))

    if IsValid(ply) then
        net.Start("ixConcussionEffect")
        net.WriteBool(false)
        net.WriteString(self.uniqueID)
        net.Send(ply)
    end

    self._timerID = nil
end 