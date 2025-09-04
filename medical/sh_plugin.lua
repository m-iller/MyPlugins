PLUGIN.name = "Medical"
PLUGIN.description = "Medicine system for Helix"
PLUGIN.author = "Miller"

ix.config.Add("KnockedOutDuration", 60, "Time to death when knocked out", nil,
{
    data = {min = 10, max = 300},
    category = "Medical"}
)
ix.config.Add("MedicalScannerRange", 100, "Scanner range to player", nil,
{
    data = {min = 10, max = 500},
    category = "Medical"}
)
ix.config.Add("MedicalScannerCooldown", 1, "Scanner cooldown", nil,
{
    data = {min = 1, max = 20},
    category = "Medical"}
)
ix.config.Add("ScanningTime", 2, "Scanning time", nil,{
    data = {min = 1, max = 20},
    category = "Medical"}
)

ix.config.Add("BactaHealTime", 5, "Bacta heal time", nil,{
    data = {min = 1, max = 20},
    category = "Medical"}
)   

ix.config.Add("BleedingMedDmg", 0.5, "Medium bleeding damage", nil,{
    data = {min = 0.1, max = 5, decimals = 1},
    category = "Medical"}
)
ix.config.Add("BleedingMinDmg", 1, "Light bleeding damage", nil,{
    data = {min = 0.1, max = 5, decimals = 1},
    category = "Medical"}
)
ix.config.Add("BleedingMaxDmg", 1, "Strong bleeding damage", nil,{
    data = {min = 0.1, max = 5, decimals = 1},
    category = "Medical"}
)

ix.config.Add("InfectionDmg", 10, "Infection damage", nil,{
    data = {min = 0.1, max = 500, decimals = 1},
    category = "Medical"}
)
ix.config.Add("InfectionTime", 10, "Time before infection damage", nil,{
    data = {min = 10, max = 300},
    category = "Medical"}
)

ix.config.Add("Max HP", 100, "Maximum HP for character", nil,{
    data = {min = 1, max = 1000},
    category = "Medical"}
)

PLUGIN.HitgroupConfigTable = { --effects contain the minimum HP percent to trigger the effect
    [HITGROUP_GENERIC] = { --Любой урон не по конечностям + взрывной
        modifier = 1.0,
        name = "Общее",
        effects = {
            ["concucsion"] = 50,
            ["blurred"] = 25,
            ["bonebreak"] = 10,
        }
    },
    [HITGROUP_HEAD] = { --Урон в голову
        modifier = 2,
        name = "Голова",    
        effects = {
            ["bleedingmax"] = 50,
            ["concucsion"] = 75,
            ["burn"] = 50,
            ["surfacedmg"] = 1,
        }
    },
    [HITGROUP_CHEST] = { --Урон в грудь
        modifier = 1.0,
        name = "Грудь",
        effects = {
            ["bleedingmed"] = 20,
            ["bleedingmax"] = 35,
            ["bleedingmin"] = 15,
            ["burn"] = 15,
            ["surfacedmg"] = 1,
        }
    },
    [HITGROUP_STOMACH] = { --Урон в живот
        modifier = 1.25,
        name = "Живот",
        effects = {
            ["bleedingmed"] = 20,
            ["bleedingmax"] = 35,
            ["bleedingmin"] = 15,
            ["burn"] = 15,
            ["surfacedmg"] = 1,
        }
    },
    [HITGROUP_RIGHTARM] = { --Урон в правую руку
        modifier = 0.5,
        name = "Правая рука",
        effects = {
            ["bleedingmed"] = 5,
            ["bleedingmax"] = 15,
            ["bleedingmin"] = 2.5,
            ["burn"] = 2.5,
            ["surfacedmg"] = 1,
            ["bonebreak"] = 10,
        }
    },
    [HITGROUP_LEFTARM] = { --Урон в левую руку
        modifier = 0.5,
        name = "Левая рука",
        effects = {
            ["bleedingmed"] = 5,
            ["bleedingmax"] = 15,
            ["bleedingmin"] = 2.5,
            ["burn"] = 2.5,
            ["surfacedmg"] = 0.5,
            ["bonebreak"] = 10,
        }
    },
    [HITGROUP_LEFTLEG] = { --Урон в левую ногу
        modifier = 0.5,
        name = "Левая нога",
        effects = {
            ["bleedingmed"] = 20,
            ["bleedingmax"] = 35,
            ["bleedingmin"] = 15,
            ["burn"] = 15,
            ["surfacedmg"] = 1,
            ["bonebreak"] = 10,
        }
    },
    [HITGROUP_RIGHTLEG] = { --Урон в правую ногу
        modifier = 0.5,
        name = "Правая нога",
        effects = {
            ["bleedingmed"] = 20,
            ["bleedingmax"] = 35,
            ["bleedingmin"] = 15,
            ["burn"] = 15,
            ["surfacedmg"] = 1,
            ["bonebreak"] = 10,
        }
    },
}

PLUGIN.DamageTypesConfigTable = {
    generic = { -- no-type and damage that doesn't fit other types
        aveffects = {["bleedingmax"] = true, ["bleedingmed"] = true, ["bleedingmin"] = true, ["surfacedmg"] = true, ["bonebreak"] = true},
    },
    bulletDmg = { -- bullet damage
        aveffects = {["bleedingmax"] = true, ["bleedingmed"] = true, ["bleedingmin"] = true, ["burn"] = true, ["surfacedmg"] = true, ["bonebreak"] = true, ["blurred"] = true},
    },
    burnDmg = { --fire damage
        aveffects = {["burn"] = true, ["surfacedmg"] = true, ["blurred"] = true, ["concucsion"] = true},
    },
    fallDmg = {
        aveffects = {["bleedingmax"] = true, ["bleedingmed"] = true, ["bleedingmin"] = true, ["surfacedmg"] = true, ["bonebreak"] = true},
    },
    explDmg = { --explosion
        aveffects = {["burn"] = true, ["surfacedmg"] = true, ["bonebreak"] = true, ["concucsion"] = true},
    },
}

ix.util.Include("meta/sh_effect.lua")
ix.util.Include("sv_damageprocessing.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sv_deathprocessing.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("hooks/sv_hooks.lua")

if SERVER then
    ix.effects.LoadFromDir()

    util.AddNetworkString("ixConcussionEffect")
    util.AddNetworkString("ixBlurredEffect")    
    util.AddNetworkString("ixStunEffect")
    util.AddNetworkString("ixKnockedOutEffect")
    util.AddNetworkString("ixBloodLossEffect")
end