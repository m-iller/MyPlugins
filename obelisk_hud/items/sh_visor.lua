ITEM.name = "Visor"
ITEM.model = Model("models/props_combine/breenlight.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A sleek, high-tech protective visor with advanced optical enhancement systems."
ITEM.category = "Clothing"
ITEM.equipped = false

-- Принудительная загрузка модели при инициализации предмета
if SERVER then
	util.PrecacheModel("models/props_combine/breenlight.mdl")
end

-- Функция для получения имени предмета
function ITEM:GetName()
	return self.name
end

-- Функция для получения описания предмета
function ITEM:GetDescription()
	return self.description
end

-- Функция для получения модели предмета
function ITEM:GetModel()
	-- Принудительно возвращаем правильную модель
	return "models/props_combine/breenlight.mdl"
end

ITEM.functions.Equip = {
    name = "Надеть",
    icon = "icon16/heart_add.png",
    OnRun = function(item)
        local client = item.player

		client:Notify("You equipped the visor!")

		hook.Run("ObeliskVisorEquipped", client, true, item)	

		return false
	end,
	OnCanRun =  function(item)
		return true
	end
}

ITEM.functions.Unequip = {	
	name = "Снять",
	icon = "icon16/heart_remove.png",
	OnRun = function(item)
		local client = item.player
		client:Notify("You unequipped the visor!")
		item.equipped = false	

		hook.Run("ObeliskVisorEquipped", client, false, item)

		return false
	end,
	OnCanRun =  function(item)
		return true
	end
}

ITEM:Hook("drop", function(item)
	local client = item.player
	client:Notify("You unequipped the visor!")
	item.equipped = false	

	hook.Run("ObeliskVisorEquipped", client, false, item)
end)


-- Функция для отображения контекстного меню
function ITEM:PopulateTooltip(tooltip)
	local equipped = self:GetData("equipped", false)
	
	if equipped then
		tooltip:AddRow("status", L("item_visor_status_equipped") or "Status: Equipped")
		tooltip:AddRow("hud", L("item_visor_hud_visor_mode") or "HUD: Visor Mode")
	else
		tooltip:AddRow("status", L("item_visor_status_unequipped") or "Status: Unequipped")
		tooltip:AddRow("action", L("item_visor_action_equip") or "Right-click to equip")
	end
end

-- Дополнительная функция для проверки, одет ли визор
function ITEM:IsWorn(player)
	return self.equipped
end 