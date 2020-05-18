if Enemies == nil then
    _G.Enemies = class({})
end

function Enemies:InitAbilites()
    -- zone1
    -- ursa boss
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_jelly", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_dash", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_fury", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_roar", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_swift", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_slam", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_hunt", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_ursa", "ursa_rend", Enemies.ABILITY_TYPE_INNATE)
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
    --Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_kiss", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_spit", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_hunger", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_web", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood", "brood_angry", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_brood_spiderling", "brood_toxin", Enemies.ABILITY_TYPE_INNATE)
    -- treant boss
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_hook", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_flux", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_storm", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_seed", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_one", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_ingrain", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_regrowth", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant", "treant_beam", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_treant_lesser_treant", "treant_root", Enemies.ABILITY_TYPE_INNATE)
    --mirana boss
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_shard", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_sky", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_blessing", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_holy", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_under", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_aligned", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_guile", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_bound", Enemies.ABILITY_TYPE_INNATE)
    --luna boss
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_void", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_sky", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_curse", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_wave", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_cruelty", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_orbs", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_wax_wane", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_bound", Enemies.ABILITY_TYPE_INNATE)
    --venge boss
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_missile", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_sky", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_side", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_fall", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_tide", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_moonify", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_umbra", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_guardian", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_storm", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_fel", Enemies.ABILITY_TYPE_INNATE)
    --spirit of mirana
    Enemies:RegisterEnemyAbility("npc_boss_mirana", "mirana_shard", Enemies.ABILITY_TYPE_INNATE)
    --spirit of luna
    Enemies:RegisterEnemyAbility("npc_boss_luna", "luna_void", Enemies.ABILITY_TYPE_INNATE)
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
    Enemies.data = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    Enemies:InitAbilites()
    Enemies:InitPanaromaEvents()
end

function Enemies:GetItemDropFor(enemy)
    local itemDrop = {}
    if (not enemy or enemy:IsNull() or not enemy:GetOwner()) then
        return itemDrop
    end

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
        local eliteAbilities = {}
        for _, ability in pairs(Enemies.eliteAbilities) do
            table.insert(eliteAbilities, ability)
        end
        result[2] = eliteAbilities
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
    difficulty = tonumber(difficulty)
    if (not difficulty) then
        return 1
    end
    local result = 1
    if (difficulty > 4) then
        result = 2
    end
    if (difficulty > 7) then
        result = 3
    end
    return result
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
    if (not modifier) then
        return 0
    end
    local result = 0.1
    local difficulty = Difficulty:GetValue()
    if (difficulty > 4) then
        result = 0.2
    end
    if (difficulty > 7) then
        result = 0.3
    end
    return result
end

function Enemies:OnBossHealing(boss, hero)
    if (not boss or boss:IsNull()) then
        return
    end
    local healTable = {}
    healTable.caster = boss
    healTable.target = boss
    healTable.ability = nil
    healTable.heal = boss:GetMaxHealth() * Enemies:GetBossHealingPercentFor(boss)
    GameMode:HealUnit(healTable)
    local pidx = ParticleManager:CreateParticle("particles/units/boss/boss_healing.vpcf", PATTACH_ABSORIGIN_FOLLOW, boss)
    Timers:CreateTimer(2, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end

function Enemies:OverwriteAbilityFunctions(ability)
    if (not ability or ability:IsNull()) then
        return
    end
    local IsCastbarRequired = false
    local IsInterruptible = true
    if (ability.IsRequireCastbar) then
        IsCastbarRequired = ability:IsRequireCastbar()
    end
    if (IsCastbarRequired == false) then
        return
    end
    if (ability.IsInterruptible) then
        IsInterruptible = ability:IsInterruptible()
    end
    if (IsInterruptible == false) then
        return
    end
    if (not ability.OnAbilityPhaseInterrupted2) then
        ability.OnAbilityPhaseInterrupted2 = ability.OnAbilityPhaseInterrupted
        ability.OnAbilityPhaseInterrupted = function(context)
            local abilityLevel = context:GetLevel()
            context:EndCooldown()
            context:StartCooldown(context:GetCooldown(abilityLevel - 1))
            if (context.OnAbilityPhaseInterrupted2) then
                context.OnAbilityPhaseInterrupted2(context)
            end
        end
    end
end

modifier_creep_scaling = class({
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
    self.difficulty = Difficulty:GetValue()
    if (Enemies:IsBoss(self.creep)) then
        self.armor = 15
        self.elementalArmor = 0.47
    else
        local eliteChance = math.floor(5 * (1 + (self.difficulty)))
        if (RollPercentage(eliteChance) and not self.creep:GetOwner()) then
            self.creep:AddNewModifier(self.creep, nil, "modifier_creep_elite", { Duration = -1 })
            self.armor = 5
            self.elementalArmor = 0.23
            self.damage = self.damage * 1.5
            self.healthBonus = 10
        end
    end
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
            Enemies:OverwriteAbilityFunctions(addedAbility)
        end
    end
    local missAbilities = Enemies.MAX_ABILITIES - abilitiesAdded
    local randomAbilities = {}
    if (missAbilities > #abilities[2]) then
        missAbilities = #abilities[2]
    end
    for i = 0, missAbilities do
        local randIndex = math.random(1, #abilities[2])
        table.insert(randomAbilities, abilities[2][randIndex])
        table.remove(abilities[2], randIndex)
    end
    for _, ability in pairs(randomAbilities) do
        if (not self.creep:HasAbility(ability)) then
            local addedAbility = self.creep:AddAbility(ability)
            addedAbility:SetLevel(abilitiesLevel)
            if (addedAbility.IsRequireCastbar and not castbarRequired) then
                castbarRequired = addedAbility:IsRequireCastbar()
            end
            Enemies:OverwriteAbilityFunctions(addedAbility)
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
            Units:ForceStatsCalculation(self.creep)
            self.creep:SetHealth(self.creep:GetMaxHealth())
            self.creep:SetMana(self.creep:GetMaxMana())
        else
            return 0.25
        end
    end, self)
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

LinkLuaModifier("modifier_creep_scaling", "systems/enemies", LUA_MODIFIER_MOTION_NONE)

modifier_creep_elite = class({
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