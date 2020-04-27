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
    if (not unit or unit:IsNull()) then
        return false
    end
    return false
end

function Enemies:IsBoss(unit)
    if (not unit or unit:IsNull()) then
        return false
    end
    if (string.find(unit:GetUnitName(), "boss")) then
        return true
    end
    return false
end

modifier_creep_scaling = modifier_creep_scaling or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_creep_scaling:GetValue(minValue, maxValue, scaling)
    return minValue + ((maxValue - minValue) * scaling)
end

function modifier_creep_scaling:OnCreated()
    if (not IsServer()) then
        return
    end
    self.creep = self:GetParent()
    self.name = self.creep:GetUnitName()
    self.damage = Enemies.data[self.name]["AttackDamageMax"]
    self.armor = 2
    self.elementalArmor = 0.11
    if (Enemies:IsElite(self.creep)) then
        self.armor = 5
        self.elementalArmor = 0.23
    end
    if (Enemies:IsBoss(self.creep)) then
        self.armor = 15
        self.elementalArmor = 0.47
    end
    self.difficulty = 1
    self.damage = self.damage * math.pow(self.difficulty, 3)
    self.armor = math.min(self.armor + ((50 - self.armor) * self.difficulty), 150)
    self.elementalArmor = math.min(self.elementalArmor + ((0.75 - self.elementalArmor) * self.difficulty), 0.9)
end

function modifier_creep_scaling:GetAttackDamageBonus()
    return self.damage
end

function modifier_creep_scaling:GetArmorBonus()
    return self.armor
end

function modifier_creep_scaling:GetFireProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetFrostProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetEarthProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetVoidProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetHolyProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetNatureProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetInfernoProtectionBonus()
    return self.elementalArmor
end

function modifier_creep_scaling:GetBaseAttackTime()
    return 2
end

LinkLuaModifier("modifier_creep_scaling", "systems/enemies", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    local isUnitThinker = (unit:GetUnitName() == "npc_dota_thinker")
    if (not unit:HasModifier("modifier_creep_scaling") and not Summons:IsSummmon(unit) and not isUnitThinker and unit:GetTeam() == DOTA_TEAM_NEUTRALS) then
        unit:AddNewModifier(unit, nil, "modifier_creep_scaling", { Duration = -1 })
    end
end, nil)

Enemies.initialized = false

if not Enemies.initialized then
    Enemies:Init()
    Enemies.initialized = true
    Enemies.data = LoadKeyValues("scripts/npc/npc_units_custom.txt")
end