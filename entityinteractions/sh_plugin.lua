PLUGIN.name = "Interactions"
PLUGIN.description = "Adds a menu for interacting with players."
PLUGIN.author = "76561198343742557"
-- Constants
PLUGIN.INTERFACE_DISTANCE = 150
PLUGIN.FADE_DISTANCE = 50
PLUGIN.BUTTON_HEIGHT = 80
PLUGIN.BUTTON_MARGIN = 15
PLUGIN.BACKGROUND_PADDING = 25
PLUGIN.FADE_ANGLE = 360
PLUGIN.MAX_DISTANCE_SQR = PLUGIN.INTERFACE_DISTANCE * PLUGIN.INTERFACE_DISTANCE
PLUGIN.FADE_START_SQR = (PLUGIN.INTERFACE_DISTANCE - PLUGIN.FADE_DISTANCE) * (PLUGIN.INTERFACE_DISTANCE - PLUGIN.FADE_DISTANCE)
PLUGIN.BUTTON_SCALE_FACTOR = 1.1
PLUGIN.BUTTON_ANIMATION_SPEED = 12
PLUGIN.MARGIN_SCALE_FACTOR = 1.4
PLUGIN.MENU_FADE_SPEED = 5
PLUGIN.ACTION_COOLDOWN = 0.3
PLUGIN.INTERACTION_CIRCLE_RADIUS = 48
-- Colors
PLUGIN.COLOR_WHITE = Color(255, 255, 255, 255)
PLUGIN.TEXT_COLOR = Color(234, 234, 234, 120)
PLUGIN.FLASH_COLOR = Color(160, 114, 85)
PLUGIN.BACKGROUND_COLOR = Color(30, 30, 30, 180)
-- Animation settings
PLUGIN.FLASH_DURATION = 0.2
PLUGIN.FLASH_INTENSITY = 0.7
-- Entity whitelist
PLUGIN.whitelistedEntities = {
}
-- Entity-specific buttons
PLUGIN.entityButtons = {
    --[[--
    ["ENTITY CLASS"] = {
        {
            text = "TEXT",
            action = function(ent)
                FUNCTION
            end,
            check = function(ent)
                return true
            end
        },
        {
            text = "TEXT",
            action = function(ent)
                FUNCTION
            end,
            check = function(ent)
                return true
            end
        },
    },
    --]]--
}
-- Function to get buttons for specific entity
function PLUGIN:GetButtonsForEntity(entity)
    if not IsValid(entity) then return {} end
    
    local entityClass = entity:GetClass()
    local buttons = self.entityButtons[entityClass] or self.entityButtons["default"]
    
    return buttons
end
PLUGIN.RNDX = ix.util.Include("libs/cl_rndx.lua")
PLUGIN.utils = ix.util.Include("libs/cl_utils.lua")
ix.util.Include("libs/cl_visualcharacterheight.lua")
ix.util.Include("cl_plugin.lua")