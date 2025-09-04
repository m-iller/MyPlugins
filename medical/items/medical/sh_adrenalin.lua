ITEM.name = "Адреналин"
ITEM.description = "Лечит 50 единиц здоровья. Снимает размытость и контузию. Поднимает из нокаута и стана."

ITEM.model = Model("models/carlsmei/escapefromtarkov/medical/adrenaline.mdl")

ITEM.UseTime = 1
ITEM.HealAmount = 50
ITEM.KOGetUp = true
ITEM.StunGetUp = true
ITEM.RemoveEffect = {"blurred", "concucsion"}
ITEM.IsSingleUse = true

--Сделать что сначала все норм а потом возращаются эффекты или снимается ХП