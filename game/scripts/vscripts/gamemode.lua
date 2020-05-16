-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
BAREBONES_DEBUG_SPEW = IsInToolsMode()

if GameMode == nil then
    DebugPrint('[BAREBONES] creating game mode')
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
--require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
--require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
--require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
--require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
--require('libraries/playertables')
-- This library can be used to create container inventories or container shops
--require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
--require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
--require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
--require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
-- rest shit
json = require('libraries/json')
require('libraries/popup')
require('systems/game_mechanics')
require('systems/difficulty')
require('systems/inventory')
require('items/require')
require('systems/talenttree')
require('talents/require')
require('systems/summons')
require('systems/castbar')
require('systems/aggro')
require('systems/heroes')
require('systems/units')
require('systems/enemies')
require('systems/dummy')
require('heroes/require')
require('creeps/require')
--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
    DebugPrint("[BAREBONES] Performing Post-Load precache")
    GameMode:PerformGameMechanicsPostInit()
    --PrecacheItemByNameAsync("item_example_item", function(...) end)
    --PrecacheItemByNameAsync("example_ability", function(...) end)

    --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
    --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
    DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
    DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]

function GameMode:OnHeroInGame(hero)
    Heroes:OnHeroCreation(hero)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
    if (BAREBONES_DEBUG_SPEW) then
        -- sad bois for testing all stuff in game
        CreateUnitByNameAsync("npc_test_unit", Vector(-14229, 15319, 0), true, nil, nil, DOTA_TEAM_NEUTRALS, nil)
        CreateUnitByNameAsync("npc_test_unit", Vector(-14229, 15159, 0), true, nil, nil, DOTA_TEAM_NEUTRALS, nil)
    end
    -- Trainer
    CreateUnitByNameAsync("npc_dummy_dps_unit", Vector(-13794.283203, 14577.936523, 384), true, nil, nil, DOTA_TEAM_NEUTRALS, function(dummy)
        dummy:SetForwardVector(Vector(-0.977157, 0.212519, -0))
    end)
    -- Vision in village
    CreateUnitByNameAsync("npc_village_vision", Vector(-14681.115234,15143.157227,384), false, nil, nil, DOTA_TEAM_GOODGUYS, nil)
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
    GameMode = self
    DebugPrint('[BAREBONES] Starting to load gamemode...')
    GameMode:InitPanaromaEvents()
    local GameModeEntity = GameRules:GetGameModeEntity()
    GameModeEntity:SetUnseenFogOfWarEnabled(true)
    GameModeEntity:SetFogOfWarDisabled(false)
    GameModeEntity:SetBuybackEnabled(false)
    GameModeEntity:SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), self)
    DebugPrint('[BAREBONES] Done loading gamemode!\n\n')
end

function GameMode:IsValidBoolean(bool)
    local str = tostring(bool)
    return (str ~= nil and (str == "false" or str == "true"))
end

-- panaroma global stuff
function GameMode:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_say_chat_message", Dynamic_Wrap(GameMode, 'OnSayChatMessageRequest'))
    CustomGameEventManager:RegisterListener("rpg_close_all_windows", Dynamic_Wrap(GameMode, 'OnCloseAllWindowsRequest'))
end

function GameMode:OnCloseAllWindowsRequest(event, args)
    if (not event) then
        return
    end
    event.player_id = tonumber(event.player_id)
    if (event.player_id) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if (player) then
            TalentTree:OnTalentTreeWindowCloseRequest(event, args)
            Inventory:OnInventoryWindowCloseRequest(event, args)
            Dummy:OnDummyCloseWindowRequest(event, args)
        end
    end
end

function GameMode:OnSayChatMessageRequest(event, args)
    if (not event) then
        return
    end
    event.player_id = tonumber(event.player_id)
    if (event.player_id and event.msg) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if (player) then
            Say(player, event.msg, true)
        end
    end
end