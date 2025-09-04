if SERVER then

local PLUGIN = PLUGIN
local CHAR = ix.meta.character

function PLUGIN:PlayerHurt(victim, attacker, healthRemaining)
	if (healthRemaining <= 0 and healthRemaining >= -30) then
		local char = victim:GetCharacter()
		if (victim:GetNetVar("KnockedOut", false)) then
			return  
		end
		char:KnockedOut(true)
		victim:SetHealth(victim:GetMaxHealth() * 0.05)
	end
end

function CHAR:Stuned(status, duration)
    local client = self:GetPlayer()
    if not client:Alive() then return end

    if not IsValid(client) then return end
    if status then
        client:SetNetVar("Stunned", true)
        client:SetRagdolled(true)

        client:SetHealth(client:GetMaxHealth() * 0.05)

        net.Start("ixStunEffect")
        net.WriteBool(true)
        net.WriteFloat(duration)
        net.WriteFloat(CurTime())
        net.Send(client)

        timer.Create(client:SteamID64().."Stun", duration, 1, function()
            client:SetNetVar("Stunned", false)
            client:SetRagdolled(false)
            self:AddTrauma("blurred", HITGROUP_HEAD)
        end)
    else
        client:SetNetVar("Stunned", false)
        client:SetRagdolled(false)
        self:AddTrauma("blurred", HITGROUP_HEAD)

        net.Start("ixStunEffect")
        net.WriteBool(false)
        net.WriteFloat(0)
        net.WriteFloat(0)
        net.Send(client)

        timer.Remove(client:SteamID64().."Stun")
    end
end

function CHAR:KnockedOut(status)
    local client = self:GetPlayer()
    if not client:Alive() then return end

    if status then
        client:SetNetVar("KnockedOut", true)
        client:SetRagdolled(true)

        client:SetHealth(client:GetMaxHealth() * 0.05)

        net.Start("ixKnockedOutEffect")
        net.WriteBool(true)
        net.Send(client)

        timer.Create(client:SteamID64().."KnockedOut", ix.config.Get("KnockedOutDuration"), 1, function()
            if client:GetNetVar("KnockedOut", false) then
                client:Kill()
            else
                timer.Remove(client:SteamID64().."KnockedOut")
            end
        end)    
    else
        client:SetNetVar("KnockedOut", false)
        client:SetRagdolled(false)
        self:AddTrauma("blurred", HITGROUP_HEAD)

        net.Start("ixKnockedOutEffect")
        net.WriteBool(false)
        net.Send(client)

        timer.Remove(client:SteamID64().."KnockedOut")
    end
end

end