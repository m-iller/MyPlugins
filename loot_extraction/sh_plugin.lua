PLUGIN.name = 'Loot Extractor'
PLUGIN.description = 'An entity that extracts chosen item.'
PLUGIN.author = 'Miller'

local PLUGIN = PLUGIN

ix.util.Include("sh_config.lua")
ix.util.Include("cl_menudraw.lua")

if SERVER then

util.AddNetworkString("ixOpenLootExtractionMenu")
util.AddNetworkString("ixLootExtractionMenuCallBack")
util.AddNetworkString("ixLootExtractionItemsCallback")

net.Receive("ixLootExtractionMenuCallBack", function()
    local ent = net.ReadEntity()
    local item = net.ReadString()

    ent.Vars.CurrentItem = item
end)

net.Receive("ixLootExtractionItemsCallback", function(_,ply)
    local ent = net.ReadEntity()
    local allitems = net.ReadBool()

    local char = ply:GetCharacter()
    local inventory = char:GetInventory()

    local itemcount

    if ent.Vars.LootAmount <= 0 then
        ply:Notify("Extractor is empty.")
        return
    end

    if allitems then
        itemcount = ent.Vars.LootAmount

        for v = 1, itemcount do
            local a,_ = inventory:Add(ent.Vars.CurrentItem, 1, nil)
            if not a then
                ply:Notify("Insufficient inventory space!")
                ix.item.Get(ent.Vars.CurrentItem):Spawn(ent:GetPos()+Vector(0,50,0))
            end
        end
    else
        itemcount = 1
        local a,_ = inventory:Add(ent.Vars.CurrentItem, 1, nil)
		if not a then
			ply:Notify("Insufficient inventory space!")
            ix.item.Get(ent.Vars.CurrentItem):Spawn(ent:GetPos()+Vector(0,50,0))
        end
    end

    ent.Vars.LootAmount = ent.Vars.LootAmount - itemcount
end)

local delay = PLUGIN.lootdelay
local nextOccurance = 0

function PLUGIN:Think()
    local timeLeft = nextOccurance - CurTime()
    
    if timeLeft < 0 then
        for k,v in pairs(ents.FindByClass("extractionpoint")) do
            if v.Vars.LootAmount < PLUGIN.maxloot then
                v.Vars.LootAmount = v.Vars.LootAmount + 1
            end
        end 

        nextOccurance = CurTime() + delay
    end

end

end