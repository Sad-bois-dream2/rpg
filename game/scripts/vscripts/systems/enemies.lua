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
    Enemies:RegisterEnemyAbility("npc_boss_lycan", "lycan_lupine", Enemies.ABILITY_TYPE_INNATE)
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
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_quake", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_mind_control", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_root", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_venge", "venge_fel", Enemies.ABILITY_TYPE_INNATE)
    --tower
    Enemies:RegisterEnemyAbility("npc_tower_helltower", "helltower_hellfire", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_tower_holytower", "holytower_holyfrost", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_tower_naturetower", "naturetower_felblight", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_tower_earthtower", "earthtower_tectonic", Enemies.ABILITY_TYPE_INNATE)
    --yukionna boss
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_promise", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_breath", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_snowstorm", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_drain", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_beauty", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_child", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_women", Enemies.ABILITY_TYPE_INNATE)
    Enemies:RegisterEnemyAbility("npc_boss_yukionna", "yukionna_body", Enemies.ABILITY_TYPE_INNATE)
    --draugr golem boss
    Enemies:RegisterEnemyAbility("npc_boss_draugr_golem", "draugr_golem_tomb", Enemies.ABILITY_TYPE_INNATE)
end

function Enemies:GetEliteEnemyDropChance(enemy, difficulty)
    local baseDropChance = 35
    local maxDropChance = 70
    return math.min(baseDropChance + ((maxDropChance - baseDropChance) * ((difficulty * 1.8) / Enemies.DIFFICULTY_MAX)), maxDropChance)
end

function Enemies:BuildDropTable(enemy, difficulty)
    local dropTable = {}
    local IsBoss = Enemies:IsBoss(enemy)
    local IsElite = Enemies:IsElite(enemy)
    local dropChance = 10
    if (IsElite) then
        dropChance = Enemies:GetEliteEnemyDropChance(enemy, difficulty)
    end
    if (IsBoss) then
        dropChance = 100
    end
    if (not RollPercentage(dropChance)) then
        return dropTable
    end
    local itemsPerDrop = 1
    local dropChanceFactor = Enemies.dropChanceFactor
    local itemsTable = {}
    table.insert(itemsTable, Inventory.rarity.common, { tier = Inventory:GetItemsByRarity(Inventory.rarity.common), chance = 100 })
    if (difficulty > Enemies.DIFFICULTY1) then
        table.insert(itemsTable, Inventory.rarity.uncommon, { tier = Inventory:GetItemsByRarity(Inventory.rarity.uncommon), chance = 60 })
    end
    if (difficulty > Enemies.DIFFICULTY1_5) then
        table.insert(itemsTable, Inventory.rarity.rare, { tier = Inventory:GetItemsByRarity(Inventory.rarity.rare), chance = 25 })
        itemsTable[Inventory.rarity.uncommon].chance = 80
    end
    if (difficulty > Enemies.DIFFICULTY2) then
        itemsTable[Inventory.rarity.rare].chance = 35
    end
    if (difficulty > Enemies.DIFFICULTY2_5) then
        table.insert(itemsTable, Inventory.rarity.uniqueRare, { tier = Inventory:GetItemsByRarity(Inventory.rarity.uniqueRare), chance = 20 })
    end
    if (difficulty > Enemies.DIFFICULTY3) then
        itemsTable[Inventory.rarity.uniqueRare].chance = 25
    end
    if (difficulty > Enemies.DIFFICULTY3_5) then
        table.insert(itemsTable, Inventory.rarity.legendary, { tier = Inventory:GetItemsByRarity(Inventory.rarity.legendary), chance = 25 })
    end
    if (difficulty > Enemies.DIFFICULTY4) then
        table.insert(itemsTable, Inventory.rarity.uniqueLegendary, { tier = Inventory:GetItemsByRarity(Inventory.rarity.uniqueLegendary), chance = 25 })
    end
    if (difficulty > Enemies.DIFFICULTY4_5) then
        table.insert(itemsTable, Inventory.rarity.cursedLegendary, { tier = Inventory:GetItemsByRarity(Inventory.rarity.cursedLegendary), chance = 35 })
    end
    if (difficulty > Enemies.DIFFICULTY5) then
        table.insert(itemsTable, Inventory.rarity.ancient, { tier = Inventory:GetItemsByRarity(Inventory.rarity.ancient), chance = 15 })
    end
    if (difficulty > Enemies.DIFFICULTY5_5) then
        table.insert(itemsTable, Inventory.rarity.uniqueAncient, { tier = Inventory:GetItemsByRarity(Inventory.rarity.uniqueAncient), chance = 10 })
        table.insert(itemsTable, Inventory.rarity.cursedAncient, { tier = Inventory:GetItemsByRarity(Inventory.rarity.cursedAncient), chance = 15 })
        itemsTable[Inventory.rarity.common] = nil
        itemsTable[Inventory.rarity.uncommon] = nil
        itemsTable[Inventory.rarity.rare].chance = 100
        dropChanceFactor = dropChanceFactor + 0.1
    end
    if (difficulty > Enemies.DIFFICULTY6) then
        if (IsElite) then
            itemsPerDrop = RandomInt(1, 2)
        end
    end
    if (difficulty > Enemies.DIFFICULTY6_5) then
        if (IsBoss) then
            itemsPerDrop = 2
        end
    end
    if (difficulty > Enemies.DIFFICULTY7) then
        dropChanceFactor = dropChanceFactor + 0.2
        if (IsBoss) then
            dropChanceFactor = dropChanceFactor + 0.3
        end
    end
    if (difficulty > Enemies.DIFFICULTY7_5) then
        table.insert(itemsTable, Inventory.rarity.immortal, { tier = Inventory:GetItemsByRarity(Inventory.rarity.immortal), chance = 7 })
    end
    if (difficulty > Enemies.DIFFICULTY8) then
        table.insert(itemsTable, Inventory.rarity.uniqueImmortal, { tier = Inventory:GetItemsByRarity(Inventory.rarity.uniqueImmortal), chance = 2 })
    end
    if (difficulty > Enemies.DIFFICULTY8_5) then
        table.insert(itemsTable, Inventory.rarity.cursedImmortal, { tier = Inventory:GetItemsByRarity(Inventory.rarity.cursedImmortal), chance = 3 })
    end
    if (difficulty > Enemies.DIFFICULTY9) then
        itemsTable[Inventory.rarity.rare] = nil
        itemsTable[Inventory.rarity.uniqueRare] = nil
        itemsTable[Inventory.rarity.legendary] = nil
        itemsTable[Inventory.rarity.uniqueLegendary] = nil
        itemsTable[Inventory.rarity.cursedLegendary] = nil
        itemsTable[Inventory.rarity.ancient] = 100
    end
    if (difficulty > Enemies.DIFFICULTY9_5) then
        itemsTable[Inventory.rarity.immortal].chance = itemsTable[Inventory.rarity.immortal].chance * 1.5
        itemsTable[Inventory.rarity.uniqueImmortal].chance = itemsTable[Inventory.rarity.uniqueImmortal].chance * 1.5
        itemsTable[Inventory.rarity.cursedImmortal].chance = itemsTable[Inventory.rarity.cursedImmortal].chance * 1.5
    end
    if (difficulty > Enemies.DIFFICULTY10) then
        dropChanceFactor = dropChanceFactor + 0.25
    end
    for _, itemsTier in pairs(itemsTable) do
        itemsTier.chance = math.min(itemsTier.chance * dropChanceFactor, 100)
    end
    for i = 1, itemsPerDrop do
        for rarity = #itemsTable, Inventory.rarity.common do
            if (GetTableSize(dropTable) >= itemsPerDrop) then
                break
            end
            if (itemsTable[rarity] and RollPercentage(itemsTable[rarity].chance)) then
                table.insert(dropTable, itemsTable[rarity].tier[math.random(1, #itemsTable[rarity].tier)])
            end
        end
    end
    return dropTable
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
    Enemies.DIFFICULTY1 = 1
    Enemies.DIFFICULTY1_5 = 1.5
    Enemies.DIFFICULTY2 = 2
    Enemies.DIFFICULTY2_5 = 2.5
    Enemies.DIFFICULTY3 = 3
    Enemies.DIFFICULTY3_5 = 3.5
    Enemies.DIFFICULTY4 = 4
    Enemies.DIFFICULTY4_5 = 4.5
    Enemies.DIFFICULTY5 = 5
    Enemies.DIFFICULTY5_5 = 5.5
    Enemies.DIFFICULTY6 = 6
    Enemies.DIFFICULTY6_5 = 6.5
    Enemies.DIFFICULTY7 = 7
    Enemies.DIFFICULTY7_5 = 7.5
    Enemies.DIFFICULTY8 = 8
    Enemies.DIFFICULTY8_5 = 8.5
    Enemies.DIFFICULTY9 = 9
    Enemies.DIFFICULTY9_5 = 9.5
    Enemies.DIFFICULTY10 = 10
    Enemies.DIFFICULTY10_5 = 10.5
    Enemies.DIFFICULTY_MAX = 10.5
    Enemies.dropChanceFactor = 1
    Enemies:InitAbilites()
    Enemies:InitPanaromaEvents()
end

--[[
CustomGameEventManager:Send_ServerToAllClients("rpg_enemy_item_dropped", { item = "item_claymore_custom", hero = HeroList:GetHero(0):GetUnitName(), player_id = 0, stats = json.encode({
    {
        name = "attack_damage",
        value = 4
    },
    {
        name = "attack_speed",
        value = 1
    }
})})
--]]

function Enemies:GetItemDropProjectileIndexByRarity(rarity)
    if (rarity >= Inventory.rarity.immortal) then
        return 10
    end
    if (rarity >= Inventory.rarity.ancient) then
        return 8
    end
    if (rarity >= Inventory.rarity.legendary) then
        return 6
    end
    if (rarity >= Inventory.rarity.rare) then
        return 4
    end
    if (rarity >= Inventory.rarity.uncommon) then
        return 2
    end
    return 0
end

function Enemies:LaunchItem(itemData)
    local pidx
    Timers:CreateTimer(itemData.delay, function()
        if (itemData.launched) then
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
            local createdItem = Inventory:CreateItemOnGround(itemData.hero, itemData.landPosition, itemData.itemName)
            CustomGameEventManager:Send_ServerToAllClients("rpg_enemy_item_dropped", { item = itemData.itemName, hero = itemData.hero:GetUnitName(), player_id = itemData.hero:GetPlayerOwnerID(), stats = json.encode(createdItem.stats) })
            EmitSoundOnLocationWithCaster(itemData.landPosition, "ui.trophy_new", itemData.hero)
        else
            itemData.landPosition = itemData.hero:GetAbsOrigin() + RandomVector(itemData.hero:GetPaddedCollisionRadius() + 50)
            pidx = ParticleManager:CreateParticle("particles/items/drop/projectile/item_projectile.vpcf", PATTACH_ABSORIGIN, itemData.hero)
            ParticleManager:SetParticleControl(pidx, 0, itemData.launchPosition)
            ParticleManager:SetParticleControl(pidx, 1, itemData.landPosition)
            ParticleManager:SetParticleControl(pidx, 2, Vector(Enemies:GetItemDropProjectileIndexByRarity(itemData.itemRarity), 0, 0))
            ParticleManager:SetParticleControl(pidx, 4, Vector(itemData.travelTime, 0, 0))
            itemData.launched = true
            return itemData.travelTime
        end
    end)
end

function Enemies:DropItems(enemy)
    if (not enemy or enemy:IsNull() or not enemy:GetOwner()) then
        return
    end
    local difficulty = Difficulty:GetValue()
    local travelTime = 1.25
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        local delay = 0
        for _, item in pairs(Enemies:BuildDropTable(enemy, difficulty)) do
            local itemData = {}
            itemData.hero = hero
            itemData.itemName = item.name
            itemData.itemRarity = item.rarity
            itemData.launchPosition = enemy:GetAbsOrigin()
            itemData.travelTime = travelTime
            itemData.delay = delay
            Enemies:LaunchItem(itemData)
            delay = delay + 0.5
        end
    end
end

function Enemies:RegisterEnemyAbility(enemyName, abilityName, abilityType)
    abilityType = tonumber(abilityType)
    if (enemyName and abilityName and abilityType and abilityType > 0 and abilityType < Enemies.ABILITY_TYPE_LAST) then
        table.insert(Enemies.enemyAbilities, { owner = enemyName, name = abilityName, type = abilityType })
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
                    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_enemy_update_stats_from_server", { enemy = enemy:entindex(), stats = json.encode(enemy.stats) })
                    return Enemies.STATS_SENDING_INTERVAL
                end
            end)
        end
    end
end

function Enemies:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_enemy_update_stats", Dynamic_Wrap(Enemies, 'OnUpdateEnemyStatsRequest'))
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
    end,
    DeclareFunctions = function()
        return { MODIFIER_EVENT_ON_DEATH }
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
    self.as = 0
    self.ms = 0
    self.debuff_resist = 0
    self.difficulty = Difficulty:GetValue()
    if (Enemies:IsBoss(self.creep)) then
        self.armor = 15
        self.elementalArmor = 0.47
        --flat speed bonus per difficulty for boss
        self.as = 5
        self.ms = 50
        --flat debuff resistance per difficulty for boss
        self.debuff_resist = 3
        --pull boss back if they run too far 2500 range
        Timers:CreateTimer(5, function()
            self.spawn_pos = self.creep:GetAbsOrigin()
            self:StartIntervalThink(2)
        end)
    else
        local eliteChance = math.floor(5 * (1 + (self.difficulty)))
        if (RollPercentage(eliteChance) and not self.creep:GetOwner()) then
            self.creep:AddNewModifier(self.creep, nil, "modifier_creep_elite", { Duration = -1 })
            self.armor = 5
            self.elementalArmor = 0.23
            self.damage = self.damage * 1.5
            self.healthBonus = 10
            self.as = 2
            self.ms = 20
        end
    end
    self.debuff_resist_total = self.debuff_resist * self.difficulty * 0.01
    self.as_total = self.as  * self.difficulty
    self.ms_total = self.ms  * self.difficulty + 150  -- base is 150 lazy to fix all to 300 so there is 150 here
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
    self.damage = self.damage * math.pow(self.difficulty, 1 + 2 *(self.difficulty - 1)/9) --x^(1 + 2 * (x-1)/9) more smooth than x^3 but same value at ml10
    self.armor = math.min(self.armor + ((50 - self.armor) * (self.difficulty / Enemies.DIFFICULTY_MAX)), 150)
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

function modifier_creep_scaling:OnIntervalThink()
    self.current_pos = self.creep:GetAbsOrigin()
    local displacement = self.spawn_pos - self.current_pos
    local distance = displacement:Length2D()
    if distance > 2500 then
        FindClearSpaceForUnit(self.creep, self.spawn_pos, true)
        Aggro:Reset(self.creep)
    end
end

function modifier_creep_scaling:GetDebuffResistanceBonus()
    return self.debuff_resist_total
end

function modifier_creep_scaling:GetMoveSpeedBonus()
    return self.ms_total
end

function modifier_creep_scaling:GetAttackSpeedBonus()
    return self.as_total
end

function modifier_creep_scaling:OnDeath(keys)
    if (not IsServer()) then
        return
    end
    if (keys.unit == self.creep) then
        if (Enemies:IsBoss(self.creep)) then
            Enemies.dropChanceFactor = Enemies.dropChanceFactor + 0.05
            Notifications:BottomToAll({ image = "s2r://panorama/images/hud/skull_stroke_png.vtex", duration = 3 })
            Notifications:BottomToAll({ text = "#" .. self.creep:GetUnitName().." ", duration = 3, continue = true })
            Notifications:BottomToAll({ text = "#DOTA_Difficulty_BossDead", duration = 3, continue = true })
            Notifications:BottomToAll({ text = (math.floor((Enemies.dropChanceFactor - 1) * 10000) / 100) .. "%!", duration = 3, continue = true })
        end
        Enemies:DropItems(self.creep)
    end
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
    if (not unit:HasModifier("modifier_creep_scaling") and not Summons:IsSummmon(unit) and IsLegitUnit and unit:GetTeam() ~= DOTA_TEAM_GOODGUYS) then
        unit:AddNewModifier(unit, nil, "modifier_creep_scaling", { Duration = -1 })
    end
end, nil)

if not Enemies.initialized then
    Enemies:Init()
    Enemies.initialized = true
end