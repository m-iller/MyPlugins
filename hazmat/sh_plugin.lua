PLUGIN.name = 'Civil workers unioun professions'
PLUGIN.description = 'Hazmat and mechanic professions.'
PLUGIN.author = 'Miller'

PLUGIN.FurnaceArea = {
    ["Start"] = Vector(1765.960083, -645.795227, -79.968750),
    ["End"] = Vector(1978.221680, -771.350952, 2.292992)
}
PLUGIN.CorpseBurningTime = 5
PLUGIN.RewardForCorpse = 1 -- loyalty points

PLUGIN.StartCorpseBagSound = ""
PLUGIN.EndCorpseBagSound = "tetopear/tetopear.ogg"
PLUGIN.TimeToPackCorpse = 5 

PLUGIN.PlantDestructionSound = "player/footsteps/p2_fs_jump_land_tile_01.wav"
PLUGIN.PlantModels = {
	[1] = "models/jq/hlvr/props/infestation/p1/rock_1.mdl",
	[2] = "models/jq/hlvr/props/infestation/p1/rock_2.mdl",
	[3] = "models/jq/hlvr/props/infestation/p1/rock_4.mdl"
}
PLUGIN.TimeToPickUpPlant = 1
PLUGIN.MinRewardForPlant = 50 -- in mL added to ballon
PLUGIN.MaxRewardForPlant = 250

PLUGIN.TimeToPourInBarrel = 5
PLUGIN.LoyaltyModifier = 0.0005 --mL to loyalty points

PLUGIN.BarrelPourSound = "ambient/energy/weld1.wav"
PLUGIN.PickUpPlantSound = "ambient/energy/weld1.wav"

PLUGIN.BreakageParams = { --Максимум - 3 разных типа поломки. Количество сложностей не ограничено
    ["mechanical"] = {
        name = "Механическая",
        nameRUSSIA = "хуйню",
        fixitem = "Шестерни",
        difficulty = {
            ["easy"] = {name = "Легкая", time = 1, minitmes = 1, maxitmes = 3}, --Время на починку [s], минимальное и максимальное количество предметов для починки
            ["medium"] = {name = "Средняя", time = 2, minitmes = 2, maxitmes = 5},
            ["hard"] = {name = "Тяжелая", time = 3, minitmes = 3, maxitmes = 7}
        }
    },
    ["electrical"] = {
        name = "Электрическая",
        nameRUSSIA = "проводку", --Починить ""
        fixitem = "Проводка",
        difficulty = {
            ["easy"] = {name = "Легкая", time = 1, minitmes = 1, maxitmes = 3}, --Время на починку [s], минимальное и максимальное количество предметов для починки
            ["medium"] = {name = "Средняя", time = 2, minitmes = 2, maxitmes = 5},
            ["hard"] = {name = "Тяжелая", time = 3, minitmes = 3, maxitmes = 7}
        }
    },
    ["casing"] ={
        name = "Корпусная",
        nameRUSSIA = "корпус",
        fixitem = "Оболочка",
        difficulty = {
            ["easy"] = {name = "Легкая", time = 1, minitmes = 1, maxitmes = 3}, --Время на починку [s], минимальное и максимальное количество предметов для починки
            ["medium"] = {name = "Средняя", time = 2, minitmes = 2, maxitmes = 5},
            ["hard"] = {name = "Тяжелая", time = 3, minitmes = 3, maxitmes = 7}
        }
    }
}

PLUGIN.MaxItemsMechBox = 10 --Max of each item in mech box
PLUGIN.TimeToFillMechBox = 2 --Time to fill all items
PLUGIN.FillUpMechBoxSound = "tetopear/tetopear.ogg"

PLUGIN.MechanicEntities = { --Entities that can break, set breakChance to 0 for "mech_" entities
    ["mech_poweroutlet"] = {name = "Электрический щит", hp = 100, breakUseChance = 0, breakSound = "",  secondBreakChance = 10, thirdBreakChance = 0},
    ["mech_biglamp"] = {name = "Большая лампа", hp = 100, breakUseChance = 0, breakSound = "",  secondBreakChance = 0, thirdBreakChance = 0},
    ["testmechentity"] = {name = "Тестовая_машина", hp = 100, breakUseChance = 100, breakSound = "",  secondBreakChance = 100, thirdBreakChance = 100},
}

PLUGIN.MechChatNotifySound = "ui_base/denyselect.mp3"
PLUGIN.MechFixupSound = "ui_base/denyselect.mp3"
PLUGIN.MechFixingAnimation = "Zombie_Attack_Frenzy"
PLUGIN.MechCheckupTime = 2
PLUGIN.RegularSparksSound = "ambient/energy/newspark02.wav"
PLUGIN.SparksTimer = 15

PLUGIN.UtilityEnts = { --non-interactive entities that break up over time
    ["mech_poweroutlet"] = true,
    ["mech_biglamp"] = true,
}

PLUGIN.RandomUtilityEntsBreakTime = 360 --Время [s] через которое производится проверка сломались ли объекты
--которые чисто для механика (коробка проводов там и т.д.)
PLUGIN.RandomUtilityEntsBreakChance = 100

ix.util.Include("nets/sv_netsmech.lua")
ix.util.Include("nets/sv_netshazm.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_funcscache.lua")
ix.util.Include("sh_interactdefinitions.lua")
ix.util.Include("sv_breaktimer.lua")