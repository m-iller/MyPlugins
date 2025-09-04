local PLUGIN = PLUGIN or {}

if SERVER then
    local delay = PLUGIN.RandomUtilityEntsBreakTime

    function PLUGIN:Think()
        if CurTime() >= delay then
            delay = CurTime() + PLUGIN.RandomUtilityEntsBreakTime
            for class,_ in pairs(PLUGIN.UtilityEnts) do
                for k,v in pairs(ents.FindByClass(class)) do
                    if math.random(1, 100) <= PLUGIN.RandomUtilityEntsBreakChance and not v:GetNetVar("broken") then
                        PLUGIN:IxEntityBreak(nil, v)
                    end
                end
            end
        end
    end
end