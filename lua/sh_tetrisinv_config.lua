TETRIS_INV.CONFIG = {}

TETRIS_INV.CONFIG.InventoryKey = KEY_I -- The key used to open the inventory. List: https://wiki.facepunch.com/gmod/Enums/KEY

TETRIS_INV.CONFIG.GridX = 8 -- The width of the inventory (should be no higher than 30)
TETRIS_INV.CONFIG.GridY = 10 -- The height of the inventory (should be no higher than 30)
TETRIS_INV.CONFIG.PickupDistance = 7500 -- How far away a player can pick up items from

TETRIS_INV.CONFIG.IsWhitelist = true -- Whether the list is a blacklist or whitelist
TETRIS_INV.CONFIG.ListedEntities = { -- Entities that can/cant be picked up
    ["prop_physics"] = true, -- Value in [] is the entity class
    ["spawned_weapon"] = true
}

TETRIS_INV.CONFIG.DefaultSize = { 2, 2 } -- The default item size (width, height)
TETRIS_INV.CONFIG.CustomSizes = { -- Custom item sizes entity/weapon class and then (width, height)
    ["ent_class"] = { 2, 4 },
    ["weapon_class"] = { 4, 4 },

    -- DarkRP Weapons
    ["weapon_ak472"] = { 4, 2 },
    ["weapon_m42"] = { 4, 2 },
    ["weapon_pumpshotgun2"] = { 4, 1 },
    ["ls_sniper"] = { 4, 2 },
    ["weapon_mac102"] = { 2, 2 },
    ["weapon_mp52"] = { 3, 2 },
    ["weapon_deagle2"] = { 2, 1 },
    ["weapon_fiveseven2"] = { 2, 1 },
    ["weapon_glock2"] = { 2, 1 },
    ["weapon_p2282"] = { 2, 1 },
}

TETRIS_INV.CONFIG.DefaultRarity = "uncommon" -- Default item rarity
TETRIS_INV.CONFIG.Rarities = {
    ["common"] = { -- Unique name, should be lower case and no spaces
        Name = "Common", -- Name of rarity
        BackgroundColor = Color( 98, 99, 99 ), -- Background color
        BorderColor = Color( 181, 181, 181 ) -- Border color
    },
    ["uncommon"] = {
        Name = "Uncommon",
        BackgroundColor = Color( 16, 102, 23 ),
        BorderColor = Color( 33, 191, 41 )
    },
    ["rare"] = {
        Name = "Rare",
        BackgroundColor = Color( 16, 44, 102 ),
        BorderColor = Color( 33, 85, 191 )
    },
    ["epic"] = {
        Name = "Epic",
        BackgroundColor = Color( 85, 16, 102 ),
        BorderColor = Color( 162, 33, 191 )
    }
}

TETRIS_INV.CONFIG.RarityList = { -- List of items and their rarities
    ["ent_class"] = "rare", -- Entity class
    ["weapon_class"] = "rare", -- Weapon class

    ["weapon_rpg"] = "rare",
    ["weapon_m42"] = "epic"
}