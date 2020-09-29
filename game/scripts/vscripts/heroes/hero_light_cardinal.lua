local LinkedModifiers = {}

-- light_cardinal_piety
modifier_light_cardinal_piety_hot = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/piety/light_sphere_buff.vpcf"
    end
})

function modifier_light_cardinal_piety_hot:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.hotTick)
end

function modifier_light_cardinal_piety_hot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = self.ability.hotHealing * Units:GetHeroIntellect(self.caster) + self.ability.hotHealingMissingHp * (self.caster:GetMaxHealth() - self.caster:GetHealth())
    GameMode:HealUnit(healTable)
end

LinkedModifiers["modifier_light_cardinal_piety_hot"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_piety_stacks = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end
})

function modifier_light_cardinal_piety_stacks:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_light_cardinal_piety_stacks:GetBuffAmplificationBonus()
    return self.ability.buffsDurationPerStack * self:GetStackCount()
end

function modifier_light_cardinal_piety_stacks:OnTooltip()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("buffs_duration_per_stack")
end

LinkedModifiers["modifier_light_cardinal_piety_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_piety = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_light_cardinal_piety:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.totalModifiersCount = 0
    self:StartIntervalThink(0.5)
end

function modifier_light_cardinal_piety:OnIntervalThink()
    if not IsServer() then
        return
    end
    local removeTable = {}
    self.totalModifiersCount = 0
    for allyIndex, ally in pairs(self.ability.buffsTable) do
        local modifiersOnTargetCount = 0
        local modifiersOnTarget = ally:FindAllModifiers()
        for _, modifier in pairs(modifiersOnTarget) do
            if (modifier.IsDebuff and modifier:IsDebuff() == false and modifier.IsHidden and modifier:IsHidden() == false and modifier:GetCaster() == self.caster) then
                modifiersOnTargetCount = modifiersOnTargetCount + 1
            end
        end
        if (modifiersOnTargetCount == 0) then
            table.insert(removeTable, allyIndex)
        end
        self.totalModifiersCount = self.totalModifiersCount + modifiersOnTargetCount
    end
    for _, index in pairs(removeTable) do
        self.ability.buffsTable[index] = nil
    end
    self:SetStackCount(1)
end

function modifier_light_cardinal_piety:GetHealingCausedPercentBonus()
    return math.min(self.totalModifiersCount * (self.ability.healingCausedPerBuff or 0), (self.ability.maxHealingCausedFromBuffs or 0))
end

function modifier_light_cardinal_piety:OnPostModifierApplied(modifierTable)
    local ability = modifierTable.caster:FindAbilityByName("light_cardinal_piety")
    if (not ability) then
        return modifierTable
    end
    if (self.IsHidden and self:IsHidden() == true) then
        return modifierTable
    end
    if (self.IsDebuff and self:IsDebuff() == true) then
        return modifierTable
    end
    if (ability.healingCausedPerBuff and ability.healingCausedPerBuff > 0 and ability.buffsTable) then
        if (not TableContains(ability.buffsTable, modifierTable.target)) then
            table.insert(ability.buffsTable, modifierTable.target)
        end
    end
end

LinkedModifiers["modifier_light_cardinal_piety"] = LUA_MODIFIER_MOTION_NONE

light_cardinal_piety = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_piety"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_light_cardinal_piety"
    end
})

function light_cardinal_piety:OnUpgrade()
    if not IsServer() then
        return
    end
    self.hotHealing = self:GetSpecialValueFor("hot_healing") / 100
    self.hotHealingMissingHp = self:GetSpecialValueFor("hot_missing_health_healing") / 100
    self.hotDuration = self:GetSpecialValueFor("hot_duration")
    self.hotTick = self:GetSpecialValueFor("hot_tick")
    self.radius = self:GetSpecialValueFor("radius")
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.healingMissingHp = self:GetSpecialValueFor("healing_missing_hp") / 100
    self.buffsDurationPerStack = self:GetSpecialValueFor("buffs_duration_per_stack") / 100
    self.stacksDuration = self:GetSpecialValueFor("stacks_duration")
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.healingCausedPerBuff = self:GetSpecialValueFor("healing_caused_per_buff") / 100
    self.maxHealingCausedFromBuffs = self:GetSpecialValueFor("max_healing_caused_from_buffs") / 100
    if (not self.buffsTable) then
        self.buffsTable = {}
    end
end

function light_cardinal_piety:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local allies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local instaHealing = self.healing * Units:GetHeroIntellect(caster) + self.healingMissingHp * (caster:GetMaxHealth() - caster:GetHealth())
    for _, ally in pairs(allies) do
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = ally
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_light_cardinal_piety_hot"
        modifierTable.duration = self.hotDuration
        GameMode:ApplyBuff(modifierTable)
        if (self.healing > 0) then
            local healTable = {}
            healTable.caster = caster
            healTable.target = ally
            healTable.ability = self
            healTable.heal = instaHealing
            GameMode:HealUnit(healTable)
        end
    end
    if (self.buffsDurationPerStack > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = caster
        modifierTable.target = caster
        modifierTable.modifier_name = "modifier_light_cardinal_piety_stacks"
        modifierTable.duration = self.stacksDuration
        modifierTable.stacks = #allies
        modifierTable.max_stacks = self.maxStacks
        GameMode:ApplyStackingBuff(modifierTable)
    end
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/piety/light_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("Hero_Omniknight.Purification", caster)
end

-- light_cardinal_purification modifiers
modifier_light_cardinal_purification = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/items_fx/black_king_bar_avatar.vpcf"
    end
})

function modifier_light_cardinal_purification:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    self.caster = self:GetCaster()
    self.tick = 0.1
    self.currentTime = 0
    self:OnIntervalThink()
    self:StartIntervalThink(self.tick)
end

function modifier_light_cardinal_purification:OnDestroy()
    if not IsServer() then
        return
    end
    if (not self.endHealingTriggered) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.target
        healTable.ability = self.ability
        healTable.heal = self.ability.intToEndHealing * Units:GetHeroIntellect(self.caster) + self.ability.missingHpToEndHealing * (self.caster:GetMaxHealth() - self.caster:GetHealth())
        GameMode:HealUnit(healTable)
    end
    self.caster:StopSound("Hero_Omniknight.Repel")
end

function modifier_light_cardinal_purification:OnIntervalThink()
    if not IsServer() then
        return
    end
    if (self.ability.maxHealthToHot > 0) then
        self.currentTime = self.currentTime + self.tick
        if (self.currentTime > self.ability.hotTick) then
            local healTable = {}
            healTable.caster = self.caster
            healTable.target = self.target
            healTable.ability = self.ability
            healTable.heal = self.ability.maxHealthToHot * (self.caster:GetMaxHealth() - self.caster:GetHealth())
            GameMode:HealUnit(healTable)
            self.currentTime = 0
        end
    end
    if (self.ability.allyMaxHpToEndHealingProc > 0 and (self.target:GetMaxHealth() / self.target:GetHealth()) <= self.ability.allyMaxHpToEndHealingProc) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.target
        healTable.ability = self.ability
        healTable.heal = self.ability.intToEndHealing * Units:GetHeroIntellect(self.caster) + self.ability.missingHpToEndHealing * (self.caster:GetMaxHealth() - self.caster:GetHealth())
        GameMode:HealUnit(healTable)
        self.endHealingTriggered = true
    end
    self.target:Purge(false, true, false, true, true)
end

function modifier_light_cardinal_purification:GetFireProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetFrostProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetEarthProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetVoidProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetHolyProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetNatureProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetInfernoProtectionBonus()
    return self.ability.eleArmor
end

LinkedModifiers["modifier_light_cardinal_purification"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_purification
light_cardinal_purification = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_purification"
    end
})

function light_cardinal_purification:OnUpgrade()
    if not IsServer() then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.eleArmor = self:GetSpecialValueFor("elearmor") / 100
    self.maxHealthToHot = self:GetSpecialValueFor("max_health_to_hot") / 100
    self.hotTick = self:GetSpecialValueFor("hot_tick")
    self.intToEndHealing = self:GetSpecialValueFor("int_to_end_healing") / 100
    self.missingHpToEndHealing = self:GetSpecialValueFor("missing_hp_to_end_healing") / 100
    self.allyMaxHpToEndHealingProc = self:GetSpecialValueFor("ally_max_hp_to_end_healing_proc") / 100
end

function light_cardinal_purification:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_light_cardinal_purification"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    caster:EmitSound("Hero_Omniknight.Repel")
end

-- light_cardinal_sublimation modifiers
modifier_light_cardinal_sublimation = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return light_cardinal_sublimation:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/sublimation/sublimation_buff.vpcf"
    end
})

function modifier_light_cardinal_sublimation:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    self.regeneration = self.ability:GetSpecialValueFor("regeneration") / 100
    self.dmg_red = self.ability:GetSpecialValueFor("dmg_reduction") / 100
end

function modifier_light_cardinal_sublimation:GetDamageReductionBonus()
    return self.dmg_red or 0
end

function modifier_light_cardinal_sublimation:GetHealthRegenerationBonus()
    local regeneration = self.regeneration * self.target:GetMaxHealth()
    return regeneration or 0
end

function modifier_light_cardinal_sublimation:GetManaRegenerationBonus()
    local regeneration = self.regeneration * self.target:GetMaxMana()
    return regeneration or 0
end

LinkedModifiers["modifier_light_cardinal_sublimation"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_sublimation
light_cardinal_sublimation = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_sublimation"
    end
})

function light_cardinal_sublimation:OnUpgrade()
    if not IsServer() then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
end

function light_cardinal_sublimation:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_light_cardinal_sublimation"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
    caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
end

-- light_cardinal_salvation modifiers
modifier_light_cardinal_salvation_aura = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.aura_radius or 1500
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_light_cardinal_salvation_aura_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

LinkedModifiers["modifier_light_cardinal_salvation_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_salvation_aura_buff = class({
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
    GetTexture = function(self)
        return light_cardinal_salvation:GetAbilityTextureName()
    end
})

function modifier_light_cardinal_salvation_aura_buff:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) then
        local modifier = damageTable.victim:FindModifierByName("modifier_light_cardinal_salvation_aura_buff")
        local on_cd = damageTable.victim:HasModifier("modifier_light_cardinal_salvation_aura_cd")
        if (modifier ~= nil and not on_cd) then
            local health_after_dmg = damageTable.victim:GetHealth() - damageTable.damage
            if (health_after_dmg < 1) then
                local auraAbility = modifier:GetAbility()
                local modifierTable = {}
                modifierTable.ability = auraAbility
                modifierTable.target = damageTable.victim
                modifierTable.caster = damageTable.victim
                modifierTable.modifier_name = "modifier_light_cardinal_salvation_aura_cd"
                modifierTable.duration = auraAbility:GetSpecialValueFor("respawn_cd")
                local cooldownModifier = GameMode:ApplyDebuff(modifierTable)
                -- Just to be sure
                cooldownModifier:SetDuration(modifierTable.duration, true)
                local healTable = {}
                healTable.caster = auraAbility:GetCaster()
                healTable.target = damageTable.victim
                healTable.ability = auraAbility
                healTable.heal = (auraAbility:GetSpecialValueFor("respawn_hp") / 100) * damageTable.victim:GetMaxHealth()
                GameMode:HealUnit(healTable)
                local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/salvation/aura_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
                Timers:CreateTimer(1.5, function()
                    ParticleManager:DestroyParticle(pidx, false)
                    ParticleManager:ReleaseParticleIndex(pidx)
                end)
                damageTable.victim:EmitSound("Item.GuardianGreaves.Activate")
                damageTable.damage = 0
                return damageTable
            end
        end
    end
end

LinkedModifiers["modifier_light_cardinal_salvation_aura_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_salvation_aura_cd = class({
    IsDebuff = function(self)
        return true
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
    GetTexture = function(self)
        return light_cardinal_salvation:GetAbilityTextureName()
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_light_cardinal_salvation_aura_cd:OnDeath(event)
    local hero = self:GetParent()
    if (hero ~= event.unit) then
        return
    end
    self:Destroy()
end

LinkedModifiers["modifier_light_cardinal_salvation_aura_cd"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_salvation
light_cardinal_salvation = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_salvation"
    end
})

function light_cardinal_salvation:OnUpgrade()
    if IsServer() then
        local level = self:GetLevel()
        if (level > 3) then
            local caster = self:GetCaster()
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_light_cardinal_salvation_aura"
            modifierTable.duration = -1
            local modifier = GameMode:ApplyBuff(modifierTable)
            modifier.aura_radius = self:GetSpecialValueFor("aura_radius")
        end
    end
end

function light_cardinal_salvation:OnSpellStart(unit, special_cast)
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_silence"
    modifierTable.duration = self:GetSpecialValueFor("silence_duration")
    GameMode:ApplyDebuff(modifierTable)
    local hp_cost = (self:GetSpecialValueFor("health_cost") / 100) * self.caster:GetMaxHealth()
    local cur_health = self.caster:GetHealth() - hp_cost
    if (cur_health < 1) then
        cur_health = 1
    end
    self.caster:SetHealth(cur_health)
    self.caster:EmitSound("Hero_Silencer.Curse.Cast")
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/salvation/light.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    local healing = (self:GetSpecialValueFor("healing") / 100) * Units:GetHeroIntellect(self.caster)
    local allies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.caster:GetAbsOrigin(),
            nil,
            self:GetSpecialValueFor("radius"),
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, ally in pairs(allies) do
        if (ally ~= self.caster) then
            local healTable = {}
            healTable.caster = self.caster
            healTable.target = ally
            healTable.ability = self
            healTable.heal = healing
            GameMode:HealUnit(healTable)
            ally:Purge(false, true, false, true, true)
        end
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_light_cardinal", MotionController)
end

if (IsServer() and not GameMode.LIGHT_CARDINAL_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_light_cardinal_salvation_aura_buff, 'OnTakeDamage'))
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_light_cardinal_piety, 'OnPostModifierApplied'))
    GameMode.LIGHT_CARDINAL_INIT = true
end