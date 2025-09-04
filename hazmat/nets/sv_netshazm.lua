local PLUGIN = PLUGIN

if SERVER then
    util.AddNetworkString("ixCollectInfestedPlant")
    util.AddNetworkString("ixPourOutInBarrel")
    
    net.Receive("ixCollectInfestedPlant", function(_,ply)

        local ent = net.ReadEntity()

        ply:SetAction("Сбор...", PLUGIN.TimeToPickUpPlant)
		ply:DoStaredAction(ent, function()

        ent:Destroy()

        local char = ply:GetCharacter()
        local inv = char:GetInventory()

        local container = inv:HasItem("toxic_ballon")

        if container then
            if not container:GetLiquid() then
                container:SetLiquid("plantwaste")
            end

            local vol = container:GetVolume()
            local newvol = vol + math.random(PLUGIN.MinRewardForPlant, PLUGIN.MaxRewardForPlant)

            if newvol <= container.capacity then
                container:SetVolume(newvol)
            else
                container:SetVolume(container.capacity)
            end
        end

		end, PLUGIN.TimeToPickUpPlant, function()
			if (IsValid(ply)) then
				ply:SetAction()
			end
		end)
    end)

    net.Receive("ixPourOutInBarrel", function(_,ply)
        local ent = net.ReadEntity()

        ply:SetAction("Слив...", PLUGIN.TimeToPourInBarrel)
		ply:DoStaredAction(ent, function()

        local char = ply:GetCharacter()
        local inv = char:GetInventory()

        local container = inv:HasItem("toxic_ballon")

        if container then
            local volume = container:GetVolume()

		    if volume > 0 then
			    local loyalty = volume*PLUGIN.LoyaltyModifier
			    ply:Notify("Вы получили "..tostring(loyalty).." лояльности")

			    char:AddLoyalty(loyalty)

			    container:SetVolume(0)
		    else
		    	ply:Notify("Нечего сливать...")	
		    end
        end

		end, PLUGIN.TimeToPourInBarrel, function()
			if (IsValid(ply)) then
				ply:SetAction()
			end
		end)
    end)
end
