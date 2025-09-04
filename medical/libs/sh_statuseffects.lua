local PLUGIN = PLUGIN


ix.effects = {}
ix.effects.stored = {}

if SERVER then

function ix.effects.LoadFromDir()
    local path = "gamemodes/starwarsrp/plugins/medical/statuseffects/"

    local files, directories = file.Find(path.."*", "GAME")

    print("------------------MEDICAL_DEBUG--------------------------")
    for _, v in ipairs(files) do
        if string.find(v, ".lua") then
            local niceName = string.sub(v, 4, -5)

            EFFECT = setmetatable({ uniqueID = niceName }, ix.meta.effect)
            
            ix.util.Include("statuseffects/" .. v)
            ix.effects.stored[niceName] = EFFECT

            EFFECT = nil
        end
    end

    print("MEDICAL_DEBUG: Total effects loaded: " .. table.Count(ix.effects.stored))
    for k, v in pairs(ix.effects.stored) do
        print("MEDICAL_DEBUG: Effect stored: " .. k .. " -> " .. tostring(v.name))
    end
end

end

function ix.effects.FindByName(effect)
    effect = effect:lower()

    for k, v in pairs(ix.effects.stored) do
        if (v.name and effect:find(v.name:lower())) then
            return ix.effects.stored[k]
        end
        
        -- Проверяем по короткому имени (ключу)
        if (k:lower() == effect) then
            return ix.effects.stored[k]
        end
        
        -- Проверяем частичное совпадение с ключом
        if (k:lower():find(effect)) then
            return ix.effects.stored[k]
        end
    end

    return nil
end

function ix.effects.GetAll()
    return ix.effects.stored
end

function ix.effects.GetByName(name)
    return ix.effects.stored[name]
end