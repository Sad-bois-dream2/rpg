local LinkedModifiers = {}
--priestess_of_sacred_forest_herbaceous_essence modifiers
-- priestess_of_sacred_forest_herbaceous_essence
priestess_of_sacred_forest_herbaceous_essence = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_herbaceous_essence"
    end
})

function priestess_of_sacred_forest_herbaceous_essence:IsRequireCastbar()
    return true
end

function priestess_of_sacred_forest_herbaceous_essence:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local healTable = {}
        healTable.caster = caster
        healTable.target = target
        healTable.ability = self
        healTable.heal = Units:GetHeroIntellect(caster) * (self:GetSpecialValueFor("healing") / 100)
        GameMode:HealUnit(healTable)
        target:Purge(false, true, false, true, true)
        local pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/herbaceous_essence/heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        EmitSoundOn("Hero_Oracle.FatesEdict", target)
        Timers:CreateTimer(0.8, function()
            target:StopSound("Hero_Oracle.FatesEdict")
        end)
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
end
-- priestess_of_sacred_forest_thorny_protection modifiers
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
    end,
    GetTexture = function(self)
        return priestess_of_sacred_forest_thorny_protection:GetAbilityTextureName()
    end,
})

function modifier_priestess_of_sacred_forest_thorny_protection_slow:GetAttackSpeedBonus()
    return self.as_slow
end

function modifier_priestess_of_sacred_forest_thorny_protection_slow:GetSpellHasteBonus()
    return self.sph_slow
end

function modifier_priestess_of_sacred_forest_thorny_protection_slow:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.thorny_protection_block = self.ability:GetSpecialValueFor("block")
    self.sph_slow = self.ability:GetSpecialValueFor("sph_slow") / 100
    self.as_slow = self.ability:GetSpecialValueFor("as_slow")
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
        return self.radius or 350
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
    if (keys.ability_entindex == nil) then
        return
    end
    self.ability = EntIndexToHScript(keys.ability_entindex)
    if self.ability then
        local wall = self:GetParent()
        wall.thorny_protection_block = self.ability:GetSpecialValueFor("block")
        self.radius = self.ability:GetSpecialValueFor("radius")
    else
        self:Destroy()
    end
end

function modifier_priestess_of_sacred_forest_thorny_protection_thinker:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        EmitSoundOn("Hero_Treant.NaturesGrasp.Destroy", parent)
        UTIL_Remove(parent)
    end
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

function modifier_priestess_of_sacred_forest_thorny_protection_buff:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) then
        local modifier = damageTable.victim:FindModifierByName("modifier_priestess_of_sacred_forest_thorny_protection_buff")
        if (modifier ~= nil) then
            local wall = modifier:GetAuraOwner()
            if (wall ~= nil and not wall:IsNull()) then
                if (damageTable.damage >= wall.thorny_protection_block) then
                    damageTable.damage = damageTable.damage - wall.thorny_protection_block
                    wall:RemoveModifierByName("modifier_priestess_of_sacred_forest_thorny_protection_thinker")
                else
                    wall.thorny_protection_block = wall.thorny_protection_block - damageTable.damage
                    damageTable.damage = 0
                end
            end
        end
    end
end

function modifier_priestess_of_sacred_forest_thorny_protection_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.slow_duration = self.ability:GetSpecialValueFor("slow_duration")
end

function modifier_priestess_of_sacred_forest_thorny_protection_buff:OnAttackStart(keys)
    if not IsServer() then
        return
    end
    if (keys.target == self.caster and keys.attacker:GetTeamNumber() ~= self.caster:GetTeamNumber()) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = keys.attacker
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_priestess_of_sacred_forest_thorny_protection_slow"
        modifierTable.duration = self.slow_duration
        GameMode:ApplyDebuff(modifierTable)
    end
end

LinkedModifiers["modifier_priestess_of_sacred_forest_thorny_protection_buff"] = LUA_MODIFIER_MOTION_NONE

-- priestess_of_sacred_forest_thorny_protection
priestess_of_sacred_forest_thorny_protection = class({
    GetAbilityTextureName = function(self)
        return "priestess_of_sacred_forest_thorny_protection"
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius") or 350
    end
})

function priestess_of_sacred_forest_thorny_protection:OnSpellStart(unit, special_cast)
    if IsServer() then
        local duration = self:GetSpecialValueFor("duration")
        local caster = self:GetCaster()
        local cursor_position = self:GetCursorPosition()
        local handle = CreateModifierThinker(
                caster,
                self,
                "modifier_priestess_of_sacred_forest_thorny_protection_thinker",
                {
                    duration = duration,
                    ability_entindex = self:entindex()
                },
                cursor_position,
                caster:GetTeamNumber(),
                false
        )
        EmitSoundOn("Hero_Treant.NaturesGrasp.Spawn", handle)
        local pidx = ParticleManager:CreateParticle("particles/units/priestess_of_sacred_forest/thorny_protection/thorns.vpcf", PATTACH_ABSORIGIN, handle)
        Timers:CreateTimer(duration, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
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
        caster.priestess_of_sacred_forest_tranquility_modifier = caster:AddNewModifier(caster, self, "modifier_priestess_of_sacred_forest_tranquility_thinker", { Duration = -1 })
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