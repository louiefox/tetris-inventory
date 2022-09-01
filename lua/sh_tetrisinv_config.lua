TETRIS_INV.CONFIG = {}

TETRIS_INV.CONFIG.GridX = 8
TETRIS_INV.CONFIG.GridY = 10
TETRIS_INV.CONFIG.PickupDistance = 7500

TETRIS_INV.CONFIG.IsWhitelist = true
TETRIS_INV.CONFIG.ListedEntities = {
    ["prop_physics"] = true,
    ["spawned_weapon"] = true
}

TETRIS_INV.CONFIG.DefaultSize = { 2, 2 }
TETRIS_INV.CONFIG.CustomSizes = {
    ["ent_class"] = { 2, 4 },
    ["weapon_class"] = { 4, 4 },

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

TETRIS_INV.CONFIG.DefaultRarity = "uncommon"
TETRIS_INV.CONFIG.Rarities = {
    ["common"] = {
        Name = "Common",
        BackgroundColor = Color( 98, 99, 99 ),
        BorderColor = Color( 181, 181, 181 )
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

TETRIS_INV.CONFIG.RarityList = {
    ["ent_class"] = "rare",
    ["weapon_class"] = "rare",
    ["weapon_rpg"] = "rare",
    ["weapon_m42"] = "epic"
}