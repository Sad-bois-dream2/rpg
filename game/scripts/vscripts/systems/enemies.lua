if Enemies == nil then
    _G.Enemies = class({})
end

function Enemies:InitAbilites()
    -- zone1
    -- ursa boss
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_rend", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_fury", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_roar", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_swift", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_slam", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_hunt", Enemies.ABILITY_TYPE_INNATE)
    -- lycan boss
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_call", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_companion", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_wound", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_wolf_form", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_howl_aura", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_agility", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_double_strike", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_bleeding", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan_call_wolf", "lycan_double_strike", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan_call_wolf", "lycan_bleeding", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan_companion_wolf", "lycan_double_strike", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_lycan_companion_wolf", "lycan_bleeding", Enemies.ABILITY_TYPE_INNATE)
    -- brood boss
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_toxin", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_comes", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_cocoons", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_kiss", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_spit", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_hunger", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_web", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood_spiderling", "brood_toxin", Enemies.ABILITY_TYPE_INNATE)
end

-- Internal stuff
function Enemies:Init()
    if (not IsServer()) then
        return
    end
    Enemies.ABILITY_TYPE_INNATE = 1
    Enemies.ABILITY_TYPE_RANDOM = 2
    Enemies.ABILITY_TYPE_LAST = 2
    Enemies.eliteAbilities = {}
    Enemies.enemyAbilities = {}
    Enemies.STATS_SENDING_INTERVAL = 1
    Enemies.MAX_ABILITIES = 10
    Enemies.DAMAGE_CLEAN_INTERVAL = 30
    Enemies.data = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_creep_scaling, 'OnPostTakeDamage'))
    Enemies:InitAbilites()
    Enemies:InitPanaromaEvents()
end

function Enemies:RegisterEnemyAbility(enemyName, abilityName, abilityType)
    abilityType = tonumber(abilityType)
    if (enemyName and abilityName and abilityType and abilityType > 0 and abilityType < Enemies.ABILITY_TYPE_LAST) then
        table.insert(Enemies.enemyAbilities, { owner = enemyName, name = abilityName, type = abilityType })
    end
end

function Enemies:RegisterEliteAbility(abilityName)
    if (abilityName) then
        table.insert(Enemies.eliteAbilities, abilityName)
    end
end

function Enemies:GetAbilityListsForEnemy(unit)
    local result = { {}, {} }
    if (not unit or unit:IsNull()) then
        return result
    end
    if (Enemies:IsElite(unit)) then
        result[2] = Enemies.eliteAbilities
    end
    local unitName = unit:GetUnitName()
    for _, ability in pairs(Enemies.enemyAbilities) do
        if (ability.owner == unitName) then
            if (ability.type == Enemies.ABILITY_TYPE_INNATE) then
                table.insert(result[1], ability.name)
            elseif (ability.type == Enemies.ABILITY_TYPE_RANDOM) then
                table.insert(result[2], ability.name)
            end
        end
    end
    return result
end

function Enemies:GetAbilitiesLevel(difficulty)
    local result = 1
    if (difficulty > 4) then
        result = 2
    end
    if (difficulty > 7) then
        result = 3
    end
    return 1
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
                    return Enemies.STATS_SENDING_INTERVAL
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
    return unit:HasModifier("modifier_creep_elite")
end

function Enemies:IsBoss(unit)
    if (not unit or unit:IsNull()) then
        return false
    end
    if (unit.GetUnitLabel and string.find(unit:GetUnitLabel():lower(), "boss")) then
        return true
    end
    return false
end

function Enemies:GetBossHealingPercentFor(unit)
    if (not unit or unit:IsNull()) then
        return 0
    end
    local modifier = unit:FindModifierByName("modifier_creep_scaling")
    if(not modifier or not modifier.difficulty) then
        return 0
    end
    local result = 0.1
    local difficulty = modifier.difficulty
    if (difficulty > 4) then
        result = 0.2
    end
    if (difficulty > 7) then
        result = 0.3
    end
    return result
end

function Enemies:OnBossHealing(unit)
    if (not unit or unit:IsNull()) then
        return
    end
    local healTable = {}
    healTable.caster = unit
    healTable.target = unit
    healTable.ability = nil
    healTable.heal = unit:GetMaxHealth() * Enemies:GetBossHealingPercentFor(unit)
    GameMode:HealUnit(healTable)
    local pidx = ParticleManager:CreateParticle("particles/units/boss/boss_healing.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
    Timers:CreateTimer(2, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end

function Enemies:IsDamagedByHero(unit, hero)
    if (not unit or not hero or unit:IsNull() or hero:IsNull() or not unit.bossHealing) then
        return false
    end
    if (unit.bossHealing.damage[hero:GetEntityIndex()]) then
        return true
    else
        return false
    end
end

function Enemies:ResetDamageForHero(unit, hero)
    if (not unit or not hero or unit:IsNull() or hero:IsNull() or not unit.bossHealing) then
        return
    end
    unit.bossHealing.damage[hero:GetEntityIndex()] = nil
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

function modifier_creep_scaling:OnCreated()
    if (not IsServer()) then
        return
    end
    self.creep = self:GetParent()
    self.name = self.creep:GetUnitName()
    self.damage = Enemies.data[self.name]["AttackDamageMax"]
    self.armor = 2
    self.elementalArmor = 0.11
    self.healthBonus = 1
    if (Enemies:IsBoss(self.creep)) then
        self.armor = 15
        self.elementalArmor = 0.47
    else
        local eliteChance = 5
        if (RollPercentage(eliteChance)) then
            self.creep:AddNewModifier(self.creep, nil, "modifier_creep_elite", { Duration = -1 })
            self.armor = 5
            self.elementalArmor = 0.23
            self.damage = self.damage * 1.5
            self.healthBonus = 10
        end
    end
    self.difficulty = 1
    local abilitiesLevel = Enemies:GetAbilitiesLevel(self.difficulty)
    local abilities = Enemies:GetAbilityListsForEnemy(self.creep)
    local abilitiesAdded = 0
    local castbarRequired = false
    for i, ability in pairs(abilities[1]) do
        if (not self.creep:HasAbility(ability)) then
            local addedAbility = self.creep:AddAbility(ability)
            addedAbility:SetLevel(abilitiesLevel)
            abilitiesAdded = abilitiesAdded + 1
            if (addedAbility.IsRequireCastbar and not castbarRequired) then
                castbarRequired = addedAbility:IsRequireCastbar()
            end
        end
    end
    if (abilitiesAdded < 10) then
        for i, ability in pairs(abilities[2]) do
            if (not self.creep:HasAbility(ability)) then
                local addedAbility = self.creep:AddAbility(ability)
                addedAbility:SetLevel(abilitiesLevel)
                abilitiesAdded = abilitiesAdded + 1
                if (addedAbility.IsRequireCastbar and not castbarRequired) then
                    castbarRequired = addedAbility:IsRequireCastbar()
                end
            end
        end
    end
    if (castbarRequired == true) then
        Castbar:AddToUnit(self.creep)
    end
    self.damage = self.damage * math.pow(self.difficulty, 3)
    self.armor = math.min(self.armor + ((50 - self.armor) * (self.difficulty / 10)), 150)
    self.elementalArmor = math.min((self.armor * 0.06) / (1 + self.armor * 0.06), 0.9)
    self.baseHealth = (Enemies.data[self.name]["StatusHealth"] * self.difficulty * HeroList:GetHeroCount() * self.healthBonus) - Enemies.data[self.name]["StatusHealth"]
    Timers:CreateTimer(0, function()
        local stats = self.creep:FindModifierByName("modifier_stats_system")
        if (stats) then
            stats:OnIntervalThink()
            self.creep:SetHealth(self.creep:GetMaxHealth())
            self.creep:SetMana(self.creep:GetMaxMana())
        else
            return 0.25
        end
    end, self)
    self.creep.bossHealing = {}
    self.creep.bossHealing.damage = {}
    self:StartIntervalThink(Enemies.DAMAGE_CLEAN_INTERVAL)
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

function modifier_creep_scaling:GetHealthBonus()
    return self.baseHealth
end

function modifier_creep_scaling:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.creep.bossHealing.damage = {}
end

function modifier_creep_scaling:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_creep_scaling")
    if (modifier) then
        damageTable.victim.bossHealing.damage[damageTable.attacker:GetEntityIndex()] = true
    end
end

LinkLuaModifier("modifier_creep_scaling", "systems/enemies", LUA_MODIFIER_MOTION_NONE)

modifier_creep_elite = modifier_creep_elite or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
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
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MODEL_SCALE }
    end,
    GetModifierModelScale = function(self)
        return 25
    end,
    GetTexture = function()
        return "centaur_khan_endurance_aura"
    end,
    GetEffectName = function(self)
        return "particles/units/elite/elite_overhead.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end
})

LinkLuaModifier("modifier_creep_elite", "systems/enemies", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    local IsLegitUnit = unit:IsCreature() and not (unit:GetUnitName() == "npc_dota_thinker")
    if (not unit:HasModifier("modifier_creep_scaling") and not Summons:IsSummmon(unit) and IsLegitUnit and unit:GetTeam() == DOTA_TEAM_NEUTRALS) then
        unit:AddNewModifier(unit, nil, "modifier_creep_scaling", { Duration = -1 })
    end
end, nil)

if not Enemies.initialized then
    Enemies:Init()
    Enemies.initialized = true
end