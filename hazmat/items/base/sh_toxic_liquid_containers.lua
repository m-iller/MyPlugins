
ITEM.name = "Liquid Container";
ITEM.model = "models/props_junk/garbage_glassbottle001a.mdl";
ITEM.width	= 1;
ITEM.height	= 1;
ITEM.description = "Liquid Container base.";
ITEM.category = "Containers";
ITEM.liquid = nil                               -- default to being empty
ITEM.capacity = 500                             -- max capacity of the container, in mL
ITEM.emptyContainer = nil                       -- item uniqueID that the container should become upon being empty. generally, only use this for bottles of things you want to start filled - say, beer you want to become a beer bottle.

if (CLIENT) then
    function ITEM:PaintOver(item, w, h)
        local amount = item:GetVolume()

        if amount >= 0 then
            local liquid = ix.liquids.Get(item:GetLiquid())
            surface.SetDrawColor(35, 35, 35, 225)
            surface.DrawRect(2, h-9, w-4, 7)

			local filledWidth = (w-5) * (amount / item.capacity)
			
            local color = ix.config.Get("color")
            if liquid and ix.option.Get("useLiquidColor", true) then
                color = liquid:GetColor()
            end

            surface.SetDrawColor(color)
            surface.DrawRect(3, h-8, filledWidth, 5)
		end
	end
end

function ITEM:PopulateTooltip(tooltip)
    local data = tooltip:AddRow("data")
    local vol = self:GetVolume()

    if(vol <= 0) then
        data:SetText("\nCapacity: " .. ix.liquids.ConvertUnit(self.capacity) .. "\nEmpty")
    else 
        data:SetText("\nCapacity: " .. ix.liquids.ConvertUnit(self.capacity) .. "\n" ..
        "Current Amount: " .. ix.liquids.ConvertUnit(vol) .. "\n" ..
        "Contains " .. ix.liquids.Get(self:GetLiquid()):GetName())
    end

    data:SetFont("ixGenericFont")
	data:SizeToContents()
end

-- Called when a new instance of this item has been made.
function ITEM:OnInstanced(invID, x, y)
    if self.liquid then
        local liquid
        if ix.liquids.Get(self.liquid) then
            liquid = self.liquid
        elseif ix.liquids.FindByName(self.liquid) then
            liquid = ix.liquids.FindByName(self.liquid).uniqueID
        end

        if liquid then
            self:SetVolume(self.capacity)
            self:SetLiquid(liquid)
        else
            self:SetVolume(0)
        end
    else
        self:SetVolume(0)
    end
end

function ITEM:GetVolume()
    return self:GetData("currentAmount", 0)
end

function ITEM:SetVolume(vol)
    if vol > self.capacity then
        self:SetData("currentAmount", self.capacity)
    elseif vol == 0 then
        if self.emptyContainer then
            self:SetData("replaceWithContainer", true)
            self:Remove()
        else
            self:SetData("currentAmount", 0)
            self:SetLiquid(nil)
        end
    else
        self:SetData("currentAmount", vol)
    end
end

function ITEM:GetFreeVolume()
    local vol = self:GetVolume()
    if vol < self.capacity then
        return self.capacity - vol
    end

    return 0
end

function ITEM:GetLiquid()
    return self:GetData("currentLiquid", nil)
end

function ITEM:SetLiquid(liquid)
    self:SetData("currentLiquid", liquid)
end

function ITEM:HasLiquid(liquid)
    return ix.liquids.Get(liquid) and self:GetLiquid() == liquid
end

-- returns the weight of the container + weight of the held liquid (if any) in kilograms
function ITEM:GetWeight()
    if self:GetLiquid() then
        return self.capacity + (self:GetVolume() * ix.liquids.Get(self:GetLiquid()):GetWeight())
    else
        return self.capacity
    end
end

function ITEM:OnRemoved()
    if self.player and self:GetData("replaceWithContainer", false) and self.emptyContainer then
        local inv = self.player:GetCharacter():GetInventory()
        if !inv or (!inv:Add(self.emptyContainer, 1, nil, self.x, self.y)) then
            ix.item.Spawn(self.emptyContainer, client, nil, nil, nil)
        end
    end
end

ITEM.functions.CPour = {
    name = "Pour Out",
    icon = "icon16/paintcan.png",
	OnRun = function(item)
        local client = item.player

        client:EmitSound(ix.liquids.Get(item:GetLiquid()):GetTransferSound())
        item:SetVolume(0)

        return false
	end,
    OnCanRun = function(item)
        return item.player and item:GetVolume() > 0
    end
}

ITEM.suppressed = function(item, name)
    if(name == "drop") then
        return
    end
    
	if(item:GetVolume() <= 0) then
		return true, name, "This drink is empty."
	end

	return false
end