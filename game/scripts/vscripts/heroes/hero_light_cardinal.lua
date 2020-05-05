local LinkedModifiers = {}

-- light_cardinal_piety modifiers
modifier_light_cardinal_piety_hot = modifier_light_cardinal_piety_hot or class({
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
    GetTexture = function(self)
        return light_cardinal_piety:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/piety/light_sphere_buff.vpcf"
    end
})

function modifier_light_cardinal_piety_hot:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.heal = self.ability:GetSpecialValueFor("healing") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_light_cardinal_piety_hot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = self.heal * Units:GetHeroIntellect(self.caster)
    GameMode:HealUnit(healTable)
end

LinkedModifiers["modifier_light_cardinal_piety_hot"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_piety_debuff = modifier_light_cardinal_piety_debuff or class({
    IsDebuff = function(self)
        return true
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
        return light_cardinal_piety:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
    end
})

function modifier_light_cardinal_piety_debuff:GetModifierMiss_Percentage()
    return self.miss_chance or 0
end

function modifier_light_cardinal_piety_debuff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.miss_chance = self.ability:GetSpecialValueFor("miss_chance") / 100
end

LinkedModifiers["modifier_light_cardinal_piety_debuff"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_piety
light_cardinal_piety = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_piety"
    end
})

function light_cardinal_piety:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("radius")
        self.hot_duration = self:GetSpecialValueFor("hot_duration")
        self.blind_duration = self:GetSpecialValueFor("miss_duration")
        self.silence_duration = self:GetSpecialValueFor("silence_duration")
        caster:EmitSound("Hero_Omniknight.Purification")
        local position = caster:GetAbsOrigin()
        local allies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                position,
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, ally in pairs(allies) do
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = ally
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_light_cardinal_piety_hot"
            modifierTable.duration = self.hot_duration
            GameMode:ApplyBuff(modifierTable)
        end
        local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                position,
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_light_cardinal_piety_debuff"
            modifierTable.duration = self.blind_duration
            GameMode:ApplyDebuff(modifierTable)
            modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_silence"
            modifierTable.duration = self.silence_duration
            GameMode:ApplyDebuff(modifierTable)
        end
        local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/piety/light_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
end

-- light_cardinal_purification modifiers
modifier_light_cardinal_purification = modifier_light_cardinal_purification or class({
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
    GetTexture = function(self)
        return light_cardinal_purification:GetAbilityTextureName()
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
    self:StartIntervalThink(0.1)
end

function modifier_light_cardinal_purification:OnDestroy()
    if not IsServer() then
        return
    end
    self.caster:StopSound("Hero_Omniknight.Repel")
end

function modifier_light_cardinal_purification:OnIntervalThink()
    if not IsServer() then
        return
    end
    self.target:Purge(false, true, false, true, true)
end

function modifier_light_cardinal_purification:GetFireProtectionBonus()
    return 1.0
end

function modifier_light_cardinal_purification:GetFrostProtectionBonus()
    return 1.0
end

function modifier_light_cardinal_purification:GetEarthProtectionBonus()
    return 1.0
end

function modifier_light_cardinal_purification:GetVoidProtectionBonus()
    return 1.0
end

function modifier_light_cardinal_purification:GetHolyProtectionBonus()
    return 1.0
end

function modifier_light_cardinal_purification:GetNatureProtectionBonus()
    return 1.0
end

function modifier_light_cardinal_purification:GetInfernoProtectionBonus()
    return 1.0
end

LinkedModifiers["modifier_light_cardinal_purification"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_purification
light_cardinal_purification = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_purification"
    end
})

function light_cardinal_purification:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self:GetCursorTarget()
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_light_cardinal_purification"
        modifierTable.duration = self:GetSpecialValueFor("protection_duration")
        GameMode:ApplyBuff(modifierTable)
        caster:EmitSound("Hero_Omniknight.Repel")
    end
end

-- light_cardinal_sublimation modifiers
modifier_light_cardinal_sublimation = modifier_light_cardinal_sublimation or class({
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

function light_cardinal_sublimation:OnSpellStart(unit, special_cast)
    if IsServer() then
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
end
-- light_cardinal_salvation modifiers
modifier_light_cardinal_salvation_aura = modifier_light_cardinal_salvation_aura or class({
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

modifier_light_cardinal_salvation_aura_buff = modifier_light_cardinal_salvation_aura_buff or class({
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
                damageTable.victim:AddNewModifier(damageTable.victim, self, "modifier_light_cardinal_salvation_aura_cd", { duration = auraAbility:GetSpecialValueFor("respawn_cd") })
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

modifier_light_cardinal_salvation_aura_cd = modifier_light_cardinal_salvation_aura_cd or class({
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
            local modifier = caster:AddNewModifier(caster, self, "modifier_light_cardinal_salvation_aura", { duration = -1 })
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
    GameMode.LIGHT_CARDINAL_INIT = true
end