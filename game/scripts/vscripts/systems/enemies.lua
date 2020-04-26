if Enemies == nil then
    _G.Enemies = class({})
end

function Enemies:Init()
    if (not IsServer()) then
        return
    end
    Enemies.STATS_CALCULATE_INTERVAL = 1
    Enemies:InitPanaromaEvents()
end

function Enemies:OnUpdateEnemyStatsRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        local enemy = EntIndexToHScript(event.enemy)
        if player ~= nil and enemy ~= nil then
            player.latestSelectedEnemy = enemy
            Timers:CreateTimer(0, function()
                if (enemy ~= nil and not enemy:IsNull() and enemy == player.latestSelectedEnemy) then
                    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_update_enemy_stats_from_server", { enemy = enemy:entindex(), stats = json.encode(enemy.stats) })
                    return Enemies.STATS_CALCULATE_INTERVAL
                end
            end)
        end
    end
end

function Enemies:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_update_enemy_stats", Dynamic_Wrap(Enemies, 'OnUpdateEnemyStatsRequest'))
end

function Enemies:IsElite(unit)
    if(not unit or unit:IsNull()) then
        return false
    end
    return false
end

function Enemies:IsBoss(unit)
    if(not unit or unit:IsNull()) then
        return false
    end
    if (string.find(unit:GetUnitName(), "boss")) then
        return true
    end
    return false
end

if not Enemies.initialized then
    Enemies:Init()
    Enemies.initialized = true
end