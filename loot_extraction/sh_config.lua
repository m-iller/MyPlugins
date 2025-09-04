local PLUGIN = PLUGIN

PLUGIN.itemlist = { --list of items that can be chosen in the extractor
    "soda",
    "radio"
}

PLUGIN.defaultitem = "soda" -- an item that is set in extractor when spawned

PLUGIN.capturetime = 2 --time for the capture
PLUGIN.lootdelay = 60 -- time in seconds for loot extraction sequence to occure
PLUGIN.maxloot = 8 -- maximum amount of items in each extractor