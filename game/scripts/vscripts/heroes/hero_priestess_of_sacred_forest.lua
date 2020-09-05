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

function priestess_of_sacred_forest_herbaceous_essence:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
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

-- priestess_of_sacred_forest_twilight_breeze modifiers
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
    end,
    GetTexture = function(self)
        return priestess_of_sacred_forest_twilight_breeze:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/priestess_of_sacred_forest/twilight_breeze/buff.vpcf"
    end,
})

---@param damageTable DAMAGE_TABLE
function modifier_priestess_of_sacred_forest_twilight_breeze_airy:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) then
        ---@type CDOTA_Buff
        local modifier = damageTable.victim:FindModifierByName("modifier_priestess_of_sacred_forest_twilight_breeze_airy")
        if (modifier ~= nil and damageTable.physdmg) then
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
    GetTexture = function(self)
        return priestess_of_sacred_forest_twilight_breeze:GetAbilityTextureName()
    end
})

function modifier_priestess_of_sacred_forest_twilight_breeze_hot:OnCreated()
    local ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.heal = ability:GetSpecialValueFor("healing")
    self.ability = ability
    local tick = ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_priestess_of_sacred_forest_twilight_breeze_hot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = self.heal
    GameMode:HealUnit(healTable)
end

LinkedModifiers["modifier_priestess_of_sacred_forest_twilight_breeze_hot"] = LUA_MODIFIER_MOTION_NONE
-- priestess_of_sacred_forest_twilight_breeze
priestess_of_sacred_forest_twilight_breeze = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_twilight_breeze"
    end,
})

function priestess_of_sacred_forest_twilight_breeze:OnSpellStart(unit, special_cast)
    if IsServer() then
        local duration = self:GetSpecialValueFor("duration")
        local stacks = self:GetSpecialValueFor("stacks")
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_twilight_breeze_hot"
        modifierTable.duration = duration
        GameMode:ApplyBuff(modifierTable)
        modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_twilight_breeze_airy"
        modifierTable.duration = -1
        modifierTable.stacks = stacks
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingBuff(modifierTable)
        EmitSoundOn("Ability.Windrun", target)
    end
end
-- priestess_of_sacred_forest_tranquility modifiers
modifier_priestess_of_sacred_forest_tranquility_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 800
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
        return "modifier_priestess_of_sacred_forest_tranquility_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetEffectName = function(self)
        return "particles/units/priestess_of_sacred_forest/tranquility/rain.vpcf"
    end
})

function modifier_priestess_of_sacred_forest_tranquility_thinker:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    if self.ability then
        self.radius = self.ability:GetSpecialValueFor("radius")
        self.caster = self:GetParent()
        self.position = self.caster:GetAbsOrigin()
        self.heal = self.ability:GetSpecialValueFor("healing") / 100
        local tick = self.ability:GetSpecialValueFor("tick")
        self:StartIntervalThink(tick)
    else
        self:Destroy()
    end
end

function modifier_priestess_of_sacred_forest_tranquility_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    local allies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.position,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, ally in pairs(allies) do
        local healTable = {}
        healTable.caster = self.caster
        healTable.ability = self.ability
        healTable.target = ally
        healTable.heal = ally:GetMaxHealth() * self.heal
        GameMode:HealUnit(healTable)
    end
end

function modifier_priestess_of_sacred_forest_tranquility_thinker:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)
        caster:StopSound("Hero_Enchantress.NaturesAttendantsCast")
    end
end

LinkedModifiers["modifier_priestess_of_sacred_forest_tranquility_thinker"] = LUA_MODIFIER_MOTION_NONE

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
    end,
    GetTexture = function(self)
        return priestess_of_sacred_forest_tranquility:GetAbilityTextureName()
    end
})

function modifier_priestess_of_sacred_forest_tranquility_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.dmg_reduction = self.ability:GetSpecialValueFor("dmg_reduction") / 100
end

function modifier_priestess_of_sacred_forest_tranquility_buff:GetDamageReductionBonus()
    return self.dmg_reduction or 0
end

LinkedModifiers["modifier_priestess_of_sacred_forest_tranquility_buff"] = LUA_MODIFIER_MOTION_NONE

-- priestess_of_sacred_forest_tranquility
priestess_of_sacred_forest_tranquility = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_tranquility"
    end,
    GetChannelTime = function(self)
        return self:GetSpecialValueFor("channel_time")
    end
})

function priestess_of_sacred_forest_tranquility:IsRequireCastbar()
    return true
end

function priestess_of_sacred_forest_tranquility:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_tranquility_thinker"
        modifierTable.duration = -1
        caster.priestess_of_sacred_forest_tranquility_modifier = GameMode:ApplyBuff(modifierTable)
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
        Timers:CreateTimer(0.9, function()
            if (caster:HasModifier("modifier_priestess_of_sacred_forest_tranquility_thinker")) then
                caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
                local pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/tranquility/rain_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                Timers:CreateTimer(2.0, function()
                    ParticleManager:DestroyParticle(pidx, false)
                    ParticleManager:ReleaseParticleIndex(pidx)
                end)
                return 1
            end
        end)
        caster:EmitSound("Hero_Enchantress.NaturesAttendantsCast")
    end
end

function priestess_of_sacred_forest_tranquility:OnChannelFinish()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    if (caster.priestess_of_sacred_forest_tranquility_modifier ~= nil) then
        caster.priestess_of_sacred_forest_tranquility_modifier:Destroy()
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_priestess_of_sacred_forest", MotionController)
end

if (IsServer() and not GameMode.PRIESTESS_OF_SACRED_FOREST_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_priestess_of_sacred_forest_thorny_protection_buff, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_priestess_of_sacred_forest_twilight_breeze_airy, 'OnTakeDamage'))
    GameMode.PRIESTESS_OF_SACRED_FOREST_INIT = true
end