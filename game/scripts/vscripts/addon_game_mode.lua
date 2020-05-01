-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache(context)
    --[[
      This function is used to precache resources/units/items/abilities that will be needed
      for sure in your game and that will not be precached by hero selection.  When a hero
      is selected from the hero selection screen, the game will precache that hero's assets,
      any equipped cosmetics, and perform the data-driven precaching defined in that hero's
      precache{} block, as well as the precache{} block for any equipped abilities.

      See GameMode:PostLoadPrecache() in gamemode.lua for more information
      ]]

    DebugPrint("[BAREBONES] Performing pre-load precache")
    -- not sure about all this
    -- Light Cardinal talents
    PrecacheResource("particle_folder", "particles/units/light_cardinal/talents/divine_cloak", context)
    -- Terror Lord talents
    PrecacheResource("particle_folder", "particles/units/terror_lord/talents/vengeance", context)
    PrecacheResource("particle_folder", "particles/units/terror_lord/talents/ashes_of_terror", context)
    PrecacheResource("particle", "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", context)
    -- Dummy
    PrecacheResource("particle", "particles/units/dummy/dummy.vpcf", context)
    PrecacheResource("particle", "particles/units/dummy/dummy_number.vpcf", context)
    PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_ogre_magi.vsndevts", context)
    -- Elite enemies
    PrecacheResource("particle", "particles/units/elite/elite_overhead.vpcf", context)
    -- All enemy abilities
    for _, ability in pairs(Enemies.enemyAbilities) do
        PrecacheItemByNameSync(ability.name, context)
    end
    for _, ability in pairs(Enemies.eliteAbilities) do
        PrecacheItemByNameSync(ability, context)
    end
    -- All talents abilities
    for _, hero_talents in pairs(TalentTree.talent_abilities) do
        for _, ability in pairs(hero_talents) do
            PrecacheItemByNameSync(ability, context)
        end
    end
end

-- Create the game mode when we activate
function Activate()
    GameRules.GameMode = GameMode()
    GameRules.GameMode:_InitGameMode()
end