ITEM.name = "Жидкостный баллон"
ITEM.description = "Контейнер для жидкости"
ITEM.model = "models/hlvr/characters/hazmat_worker/props/canister.mdl"
ITEM.width	= 1
ITEM.height	= 2
ITEM.capacity = 8000

ITEM.functions.drop = {
    OnCanRun = function(item)
        return false
    end
}