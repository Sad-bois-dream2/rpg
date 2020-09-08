local LinkedModifiers = {}
-- priestess_of_sacred_forest_herbaceous_essence
modifier_priestess_of_sacred_forest_herbaceous_essence_buff = class({
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
    end
})

function modifier_priestess_of_sacred_forest_herbaceous_essence_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_priestess_of_sacred_forest_herbaceous_essence_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_herbaceous_essence_cd = class({
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
    end
})

LinkedModifiers["modifier_priestess_of_sacred_forest_herbaceous_essence_cd"] = LUA_MODIFIER_MOTION_NONE

priestess_of_sacred_forest_herbaceous_essence = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_herbaceous_essence"
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("dispel") > 0) then
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        else
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function priestess_of_sacred_forest_herbaceous_essence:OnAbilityPhaseStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    self.originalCastPoint = self:GetCastPoint()
    local modifier = self:GetCursorTarget():FindModifierByName("modifier_priestess_of_sacred_forest_twilight_breeze_hot")
    if (modifier and modifier.ability and modifier.ability.sphBonus) then
        self:SetOverrideCastPoint(self.originalCastPoint * (1 - modifier.ability.sphBonus))
    end
    return true
end

function priestess_of_sacred_forest_herbaceous_essence:OnAbilityPhaseInterrupted(unit, special_cast)
    if (not IsServer()) then
        return
    end
    self:SetOverrideCastPoint(self.originalCastPoint)
end

function priestess_of_sacred_forest_herbaceous_essence:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    self:SetOverrideCastPoint(self.originalCastPoint)
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local healTable = {}
    healTable.caster = caster
    healTable.target = target
    healTable.ability = self
    healTable.heal = Units:GetHeroIntellect(caster) * self.healing
    if (target:GetHealth() <= target:GetMaxHealth() * self.healingMultiplierMaxHp) then
        healTable.heal = healTable.heal * self.healingMultiplier
    end
    GameMode:HealUnit(healTable)
    if (self:GetAutoCastState() and self.dispel > 0 and not caster:HasModifier("modifier_priestess_of_sacred_forest_herbaceous_essence_cd")) then
        target:Purge(false, true, false, true, true)
        caster:AddNewModifier(caster, self, "modifier_priestess_of_sacred_forest_herbaceous_essence_cd", { duration = self.dispelCd })
    end
    if (self.bonusHealingRecieved > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_herbaceous_essence_buff"
        modifierTable.duration = self.bonusHealingRecievedDuration
        GameMode:ApplyBuff(modifierTable)
    end
    local pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/herbaceous_essence/heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("Hero_Oracle.FatesEdict", target)
    Timers:CreateTimer(0.8, function()
        target:StopSound("Hero_Oracle.FatesEdict")
    end)
end

function priestess_of_sacred_forest_herbaceous_essence:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.bonusHealingRecieved = self:GetSpecialValueFor("bonus_healing_recieved") / 100
    self.bonusHealingRecievedDuration = self:GetSpecialValueFor("bonus_healing_recieved_duration")
    self.healingMultiplier = self:GetSpecialValueFor("healing_multiplier")
    self.healingMultiplierMaxHp = self:GetSpecialValueFor("healing_multiplier_maxhp") / 100
    self.dispel = self:GetSpecialValueFor("dispel")
    self.dispelCd = self:GetSpecialValueFor("dispel_cd")
end

-- priestess_of_sacred_forest_thorny_protection modifiers
modifier_priestess_of_sacred_forest_thorny_protection_slow_aura = class({
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
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_priestess_of_sacred_forest_thorny_protection_slow_aura_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end
})

function modifier_priestess_of_sacred_forest_thorny_protection_slow_aura:OnCreated(keys)
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_priestess_of_sacred_forest_thorny_protection_slow_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_thorny_protection_slow_aura_buff = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetMoveSpeedPercentBonus = function(self)
        return self.ability.msSlow or 0
    end
})

function modifier_priestess_of_sacred_forest_thorny_protection_slow_aura_buff:OnCreated()
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_priestess_of_sacred_forest_thorny_protection_slow_aura_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_thorny_protection_slow = class({
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
    GetEffectName = function(self)
        return "particles/units/priestess_of_sacred_forest/thorny_protection/slow_debuff.vpcf"
    end
})

function modifier_priestess_of_sacred_forest_thorny_protection_slow:GetAttackSpeedBonus()
    return self.ability.asSlow
end

function modifier_priestess_of_sacred_forest_thorny_protection_slow:GetSpellHasteBonus()
    return self.ability.sphSlow
end

function modifier_priestess_of_sacred_forest_thorny_protection_slow:OnCreated(keys)
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_priestess_of_sacred_forest_thorny_protection_slow"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_thorny_protection_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
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
        return "modifier_priestess_of_sacred_forest_thorny_protection_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end
})

function modifier_priestess_of_sacred_forest_thorny_protection_thinker:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.wall = self:GetParent()
    self.wall.thornyHp = self.ability.block * Units:GetHeroIntellect(self.ability:GetCaster())
    self.pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/thorny_protection/positive/thorny_protection.vpcf", PATTACH_ABSORIGIN, self.wall)
    ParticleManager:SetParticleControl(self.pidx, 1, Vector(self.ability.radius, 0, 0))
    EmitSoundOn("Hero_Treant.NaturesGrasp.Spawn", self.wall)
    if (self.ability.msSlow > 0) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.wall
        modifierTable.target = self.wall
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_thorny_protection_slow_aura"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
    end
    self:StartIntervalThink(0.1)
end

function modifier_priestess_of_sacred_forest_thorny_protection_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    local hp = tostring(math.floor(self.wall.thornyHp))
    local count = #hp
    ParticleManager:SetParticleControl(self.pidx, 3, Vector(tonumber(hp:sub(1, 1)), tonumber(hp:sub(2, 2)), tonumber(hp:sub(3, 3))))
    ParticleManager:SetParticleControl(self.pidx, 4, Vector(tonumber(hp:sub(4, 4)), tonumber(hp:sub(5, 5)), tonumber(hp:sub(6, 6))))
    ParticleManager:SetParticleControl(self.pidx, 5, Vector(count > 0 and 1 or 0, count > 1 and 1 or 0, count > 2 and 1 or 0))
    ParticleManager:SetParticleControl(self.pidx, 6, Vector(count > 3 and 1 or 0, count > 4 and 1 or 0, count > 5 and 1 or 0))
end

function modifier_priestess_of_sacred_forest_thorny_protection_thinker:OnDestroy()
    if not IsServer() then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, true)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    local pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/thorny_protection/positive/thorny_protection_endcap.vpcf", PATTACH_ABSORIGIN, self.ability:GetCaster())
    ParticleManager:SetParticleControl(pidx, 0, self.wall:GetAbsOrigin())
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.ability.radius, 0, 0))
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("Hero_Treant.NaturesGrasp.Destroy", self.wall)
    UTIL_Remove(self.wall)
end

LinkedModifiers["modifier_priestess_of_sacred_forest_thorny_protection_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_thorny_protection_buff = class({
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
        return priestess_of_sacred_forest_thorny_protection:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_START }
    end
})

function modifier_priestess_of_sacred_forest_thorny_protection_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_priestess_of_sacred_forest_thorny_protection_buff:GetDamageReductionBonus()
    return self.ability.damageReduction
end

function modifier_priestess_of_sacred_forest_thorny_protection_buff:OnAttackStart(keys)
    if not IsServer() then
        return
    end
    if (keys.target == self.caster and self.ability.msSlow > 0) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = keys.attacker
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_thorny_protection_slow"
        modifierTable.duration = self.ability.slowDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_priestess_of_sacred_forest_thorny_protection_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_priestess_of_sacred_forest_thorny_protection_buff")
    if (damageTable.damage > 0 and modifier) then
        local wall = modifier:GetAuraOwner()
        if (wall and not wall:IsNull()) then
            if (damageTable.damage >= wall.thornyHp) then
                damageTable.damage = damageTable.damage - wall.thornyHp
                wall:RemoveModifierByName("modifier_priestess_of_sacred_forest_thorny_protection_thinker")
            else
                wall.thornyHp = wall.thornyHp - damageTable.damage
                damageTable.damage = 0
            end
            return damageTable
        end
    end
end

LinkedModifiers["modifier_priestess_of_sacred_forest_thorny_protection_buff"] = LUA_MODIFIER_MOTION_NONE

-- priestess_of_sacred_forest_thorny_protection
priestess_of_sacred_forest_thorny_protection = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_thorny_protection"
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end
})

function priestess_of_sacred_forest_thorny_protection:OnUpgrade()
    self.block = self:GetSpecialValueFor("block") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.radius = self:GetSpecialValueFor("radius")
    self.asSlow = self:GetSpecialValueFor("as_slow") / 100
    self.sphSlow = self:GetSpecialValueFor("sph_slow") / 100
    self.slowDuration = self:GetSpecialValueFor("slow_duration")
    self.msSlow = self:GetSpecialValueFor("ms_slow") / 100
    self.damageReduction = self:GetSpecialValueFor("damage_reduction") / 100
end

function priestess_of_sacred_forest_thorny_protection:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    CreateModifierThinker(
            caster,
            self,
            "modifier_priestess_of_sacred_forest_thorny_protection_thinker",
            {
                duration = self.duration
            },
            self:GetCursorPosition(),
            caster:GetTeamNumber(),
            false
    )
end

-- priestess_of_sacred_forest_twilight_breeze
modifier_priestess_of_sacred_forest_twilight_breeze_airy = class({
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
    end
})

---@param damageTable DAMAGE_TABLE
function modifier_priestess_of_sacred_forest_twilight_breeze_airy:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_priestess_of_sacred_forest_twilight_breeze_airy")
    if (damageTable.damage > 0 and modifier and damageTable.physdmg) then
        local stacks = modifier:GetStackCount()
        if (stacks > 0) then
            modifier:SetStackCount(stacks - 1)
            damageTable.damage = 0
            return damageTable
        else
            modifier:Destroy()
        end
    end
end

LinkedModifiers["modifier_priestess_of_sacred_forest_twilight_breeze_airy"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_twilight_breeze_hot = class({
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
        return "particles/units/priestess_of_sacred_forest/twilight_breeze/buff.vpcf"
    end,
})

function modifier_priestess_of_sacred_forest_twilight_breeze_hot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.tick)
end

function modifier_priestess_of_sacred_forest_twilight_breeze_hot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = self.ability.healing * Units:GetHeroIntellect(self.caster)
    GameMode:HealUnit(healTable)
end

LinkedModifiers["modifier_priestess_of_sacred_forest_twilight_breeze_hot"] = LUA_MODIFIER_MOTION_NONE

priestess_of_sacred_forest_twilight_breeze = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_twilight_breeze"
    end,
})

function priestess_of_sacred_forest_twilight_breeze:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.tick = self:GetSpecialValueFor("tick")
    self.stacks = self:GetSpecialValueFor("stacks")
    self.sphBonus = self:GetSpecialValueFor("sph_bonus") / 100
    self.spreadRadius = self:GetSpecialValueFor("spread_radius")
end

function priestess_of_sacred_forest_twilight_breeze:OnSpellStart(secondCast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_twilight_breeze_hot"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    if (self.stacks > 0) then
        modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_twilight_breeze_airy"
        modifierTable.duration = -1
        modifierTable.stacks = self.stacks
        modifierTable.max_stacks = self.stacks
        GameMode:ApplyStackingBuff(modifierTable)
    end
    EmitSoundOn("Ability.Windrun", target)
    if (secondCast or not (self.spreadRadius > 0)) then
        return
    end
    local allies = FindUnitsInRadius(caster:GetTeamNumber(),
            target:GetAbsOrigin(),
            nil,
            self.spreadRadius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, ally in pairs(allies) do
        if (not ally:HasModifier("modifier_priestess_of_sacred_forest_twilight_breeze_hot")) then
            local cd = self:GetCooldownTimeRemaining()
            self:EndCooldown()
            caster:SetCursorCastTarget(ally)
            self:OnSpellStart(true)
            self:StartCooldown(cd)
            return
        end
    end
end

-- priestess_of_sacred_forest_tranquility
modifier_priestess_of_sacred_forest_tranquility_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
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
        return "modifier_priestess_of_sacred_forest_tranquility_thinker_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end
})

function modifier_priestess_of_sacred_forest_tranquility_thinker:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.thinker = self:GetParent()
    self.ability.caster:EmitSound("Hero_Enchantress.NaturesAttendantsCast")
    self.pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/tranquility/rain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.thinker)
    ParticleManager:SetParticleControl(self.pidx, 7, Vector(self.ability.radius, 0, 0))
    self:StartIntervalThink(self.ability.tick)
end

function modifier_priestess_of_sacred_forest_tranquility_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    local thereAreSpirit = (self.ability.spirit > 0)
    if (self.ability.caster:GetHealth() < 1 or (not thereAreSpirit and not self.ability:IsChanneling())) then
        self:Destroy()
        return nil
    end
    if (not thereAreSpirit) then
        self.ability.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
    end
    local pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/tranquility/rain_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.thinker)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    local allies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.thinker:GetAbsOrigin(),
            nil,
            self.ability.radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    if (self.ability.useHighestMaxHealth > 0) then
        local highestMaxHp = 0
        for _, ally in pairs(allies) do
            local allyMaxHp = ally:GetMaxHealth()
            if (allyMaxHp > highestMaxHp) then
                highestMaxHp = allyMaxHp
            end
        end
        for _, ally in pairs(allies) do
            local healTable = {}
            healTable.caster = self.ability.caster
            healTable.ability = self.ability
            healTable.target = ally
            healTable.heal = highestMaxHp * self.ability.healing
            GameMode:HealUnit(healTable)
        end
    else
        for _, ally in pairs(allies) do
            local healTable = {}
            healTable.caster = self.ability.caster
            healTable.ability = self.ability
            healTable.target = ally
            healTable.heal = ally:GetMaxHealth() * self.ability.healing
            GameMode:HealUnit(healTable)
        end
    end
end

function modifier_priestess_of_sacred_forest_tranquility_thinker:OnDestroy()
    if not IsServer() then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    self.ability.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)
    self.ability.caster:StopSound("Hero_Enchantress.NaturesAttendantsCast")
    if (self.ability.spirit > 0) then
        self.ability:OnChannelFinish()
    end
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_priestess_of_sacred_forest_tranquility_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_tranquility_thinker_buff = class({
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
    GetDamageReductionBonus = function(self)
        return self.ability.dmgReduction
    end
})

function modifier_priestess_of_sacred_forest_tranquility_thinker_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_priestess_of_sacred_forest_tranquility_thinker_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_tranquility_buff = class({
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
    end
})

function modifier_priestess_of_sacred_forest_tranquility_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_priestess_of_sacred_forest_tranquility_buff:GetHealingCausedPercentBonus()
    return self.ability.healingCausedProc
end

LinkedModifiers["modifier_priestess_of_sacred_forest_tranquility_buff"] = LUA_MODIFIER_MOTION_NONE

priestess_of_sacred_forest_tranquility = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_tranquility"
    end,
    GetChannelTime = function(self)
        if (self:IsRequireCastbar()) then
            return self:GetSpecialValueFor("channel_time")
        else
            return 0
        end
    end,
    IsRequireCastbar = function(self)
        return not (self:GetSpecialValueFor("spirit") > 0)
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("spirit") > 0) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET
        else
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
        end
    end,
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end
})

function priestess_of_sacred_forest_tranquility:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.dmgReduction = self:GetSpecialValueFor("dmg_reduction") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.channelTime = self:GetSpecialValueFor("channel_time")
    self.tick = self:GetSpecialValueFor("tick")
    self.healingCausedProc = self:GetSpecialValueFor("healing_caused_proc") / 100
    self.healingCausedProcDuration = self:GetSpecialValueFor("healing_caused_proc_duration")
    self.useHighestMaxHealth = self:GetSpecialValueFor("use_highest_maxhealth")
    self.spirit = self:GetSpecialValueFor("spirit")
end

function priestess_of_sacred_forest_tranquility:OnSpellStart()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
    local thinker = CreateModifierThinker(
            self.caster,
            self,
            "modifier_priestess_of_sacred_forest_tranquility_thinker",
            {
                duration = self.channelTime,
            },
            self.caster:GetAbsOrigin(),
            self.caster:GetTeamNumber(),
            false
    )
    if (self.spirit > 0) then
        thinker:FollowEntity(self.caster, false)
    end
end

function priestess_of_sacred_forest_tranquility:OnChannelFinish()
    if not IsServer() then
        return
    end
    if ((self.healingCausedProc > 0 and self:GetChannelStartTime() + self.channelTime >= GameRules:GetGameTime()) or self.spirit > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self.caster
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_tranquility_buff"
        modifierTable.duration = self.healingCausedProcDuration
        GameMode:ApplyBuff(modifierTable)
    end
end

-- priestess_of_sacred_forest_sleep_dust
modifier_priestess_of_sacred_forest_sleep_dust_hot = class({
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
    end
})

function modifier_priestess_of_sacred_forest_sleep_dust_hot:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self.pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/sleep_dust/sleep_dust_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
    ParticleManager:SetParticleControl(self.pidx, 1, Vector(self.ability.hotTick, 0, 0))
    self:StartIntervalThink(self.ability.hotTick)
end

function modifier_priestess_of_sacred_forest_sleep_dust_hot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = Units:GetHeroIntellect(self.caster) * self.ability.hotHealing
    GameMode:HealUnit(healTable)
end

function modifier_priestess_of_sacred_forest_sleep_dust_hot:OnDestroy()
    if not IsServer() then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

LinkedModifiers["modifier_priestess_of_sacred_forest_sleep_dust_hot"] = LUA_MODIFIER_MOTION_NONE

modifier_priestess_of_sacred_forest_sleep_dust_sleep = class({
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
    GetHealingReceivedPercentBonus = function(self)
        return self.ability.sleepHealingReceived
    end,
    GetEffectName = function(self)
        return "particles/generic_gameplay/generic_sleep.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    ShouldUseOverheadOffset = function(self)
        return true
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true
        }
    end
})

function modifier_priestess_of_sacred_forest_sleep_dust_sleep:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_priestess_of_sacred_forest_sleep_dust_sleep")
    if (modifier and damageTable.damage > 0) then
        local stacks = modifier:GetStackCount() - 1
        if (stacks > 0) then
            damageTable.damage = 0
            modifier:SetStackCount(stacks)
            return damageTable
        else
            modifier:Destroy()
        end
    end
end

function modifier_priestess_of_sacred_forest_sleep_dust_sleep:OnCreated()
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_priestess_of_sacred_forest_sleep_dust_sleep"] = LUA_MODIFIER_MOTION_NONE

priestess_of_sacred_forest_sleep_dust = class({})

function priestess_of_sacred_forest_sleep_dust:OnUpgrade()
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.hotHealing = self:GetSpecialValueFor("hot_healing") / 100
    self.hotDuration = self:GetSpecialValueFor("hot_duration")
    self.hotTick = self:GetSpecialValueFor("hot_tick")
    self.sleepDuration = self:GetSpecialValueFor("sleep_duration")
    self.sleepHealingReceived = self:GetSpecialValueFor("sleep_healing_received") / 100
    self.sleepDamageBlock = self:GetSpecialValueFor("sleep_damage_block")
    self.range = self:GetSpecialValueFor("range")
    self.speed = self:GetSpecialValueFor("speed")
    self.width = self:GetSpecialValueFor("width")
end

function priestess_of_sacred_forest_sleep_dust:OnProjectileHit(target, location)
    if (not IsServer()) then
        return
    end
    if (target and target ~= self.caster and not TableContains(self.affectedAllies, target)) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self.caster
        modifierTable.target = target
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_sleep_dust_sleep"
        modifierTable.duration = self.sleepDuration
        modifierTable.stacks = self.sleepDamageBlock
        modifierTable.max_stacks = self.sleepDamageBlock
        GameMode:ApplyStackingBuff(modifierTable)
        local healTable = {}
        healTable.caster = caster
        healTable.target = target
        healTable.ability = self
        healTable.heal = Units:GetHeroIntellect(self.caster) * self.healing
        GameMode:HealUnit(healTable)
        if (self.hotDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.caster = self.caster
            modifierTable.target = target
            modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_sleep_dust_hot"
            modifierTable.duration = self.hotDuration
            GameMode:ApplyBuff(modifierTable)
        end
        table.insert(self.affectedAllies, target)
    end
    return false
end

function priestess_of_sacred_forest_sleep_dust:OnSpellStart()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    local casterLocation = self.caster:GetAbsOrigin()
    local casterTeam = self.caster:GetTeamNumber()
    local direction = (self:GetCursorPosition() - casterLocation):Normalized()
    self.affectedAllies = {}
    local projectile = {
        Ability = self,
        EffectName = "particles/units/priestess_of_sacred_forest/sleep_dust/sleep_dust.vpcf",
        vSpawnOrigin = casterLocation,
        fDistance = self.range,
        fStartRadius = self.width,
        fEndRadius = self.width,
        Source = self.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = direction * self.speed,
        bProvidesVision = true,
        iVisionRadius = 400,
        iVisionTeamNumber = casterTeam
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    EmitSoundOn("Hero_Enchantress.EnchantCast", self.caster)
end

-- priestess_of_sacred_forest_spirits
SPIRITS_STATE_DAY = 0
SPIRITS_STATE_NIGHT = 1

modifier_priestess_of_sacred_forest_spirits = class({
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

function modifier_priestess_of_sacred_forest_spirits:OnCreated()
    self.ability = self:GetAbility()
    self.state = SPIRITS_STATE_DAY
    self.pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/spirits/spirits_positive.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.ability.caster)
end

function modifier_priestess_of_sacred_forest_spirits:GetHealingCausedPercentBonus()
    if(self.state == SPIRITS_STATE_DAY) then
        return Units:GetNatureDamage(self.ability.caster)
    end
    return 0
end

function modifier_priestess_of_sacred_forest_spirits:GetNatureDamageBonus()
    if(self.state == SPIRITS_STATE_NIGHT) then
        return Units:GetHealingCausedPercent(self.ability.caster)
    end
    return 0
end

function modifier_priestess_of_sacred_forest_spirits:SwitchSpirits()
    if not IsServer() then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    if (self.state == SPIRITS_STATE_DAY) then
        self.pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/spirits/spirits_negative.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.ability.caster)
        self.state = SPIRITS_STATE_NIGHT
    else
        self.pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/spirits/spirits_positive.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.ability.caster)
        self.state = SPIRITS_STATE_DAY
    end
    self:SetStackCount(self.state)
end

LinkedModifiers["modifier_priestess_of_sacred_forest_spirits"] = LUA_MODIFIER_MOTION_NONE

priestess_of_sacred_forest_spirits = class({})

function priestess_of_sacred_forest_spirits:OnUpgrade()
    if not IsServer() then
        return
    end
    if (not self.state) then
        self.caster = self:GetCaster()
        self.modifier = self.caster:AddNewModifier(self.caster, self, "modifier_priestess_of_sacred_forest_spirits", { duration = -1 })
    end
    self.natureDmgToHealing = self:GetSpecialValueFor("nature_dmg_per_healing_caused")
    self.healingToNatureDmg = self:GetSpecialValueFor("healing_caused_per_nature_dmg")
    self.cooldownDelay = self:GetSpecialValueFor("cooldown_delay")
    self.bonusHealingCaused = self:GetSpecialValueFor("bonus_healing_caused") / 100
    self.bonusHealingCausedDuration = self:GetSpecialValueFor("bonus_healing_caused_duration")
end

function priestess_of_sacred_forest_spirits:OnSpellStart()
    if not IsServer() then
        return
    end
    self.modifier:SwitchSpirits()
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_priestess_of_sacred_forest", MotionController)
end

if (IsServer() and not GameMode.PRIESTESS_OF_SACRED_FOREST_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_priestess_of_sacred_forest_thorny_protection_buff, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_priestess_of_sacred_forest_twilight_breeze_airy, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_priestess_of_sacred_forest_sleep_dust_sleep, 'OnTakeDamage'))
    GameMode.PRIESTESS_OF_SACRED_FOREST_INIT = true
end