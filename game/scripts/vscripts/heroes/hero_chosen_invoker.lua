local LinkedModifiers = {}

-- chosen_invoker_purification_brilliance modifiers
modifier_chosen_invoker_purification_brilliance_buff = modifier_chosen_invoker_purification_brilliance_buff or class({
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
        return chosen_invoker_purification_brilliance:GetAbilityTextureName()
    end
})

function modifier_chosen_invoker_purification_brilliance_buff:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    PrintTable(keys)
    if (not keys or not keys.mana) then
        self:Destroy()
    end
    self.caster = self:GetParent()
    self.mana = keys.mana
end

function modifier_chosen_invoker_purification_brilliance_buff:GetManaRegenerationBonus()
    return self.mana * self:GetStackCount() * self.caster:GetMaxMana()
end

LinkedModifiers["modifier_chosen_invoker_purification_brilliance_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_chosen_invoker_purification_brilliance = modifier_chosen_invoker_purification_brilliance or class({
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

function modifier_chosen_invoker_purification_brilliance:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.target = self.ability:GetCursorTarget()
    self.baseDamage = self.ability:GetSpecialValueFor("base_damage")
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
    self:OnIntervalThink()
end

function modifier_chosen_invoker_purification_brilliance:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.caster:RemoveGesture(ACT_DOTA_ATTACK)
    self.caster:RemoveGesture(ACT_DOTA_ATTACK2)
    local attachPoint = "attach_attack"
    if (RandomInt(0, 1) == 1) then
        self.caster:StartGesture(ACT_DOTA_ATTACK2)
        attachPoint = "attach_attack2"
    else
        self.caster:StartGesture(ACT_DOTA_ATTACK)
        attachPoint = "attach_attack1"
    end
    local pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/purification_brilliance/purification_brilliance_rope.vpcf", PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControlEnt(pidx, 0, self.caster, PATTACH_POINT_FOLLOW, attachPoint, self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.baseDamage + (self.damage * Units:GetHeroIntellect(self.caster))
    damageTable.holydmg = true
    GameMode:DamageUnit(damageTable)
end

function modifier_chosen_invoker_purification_brilliance:OnDestroy()
    if (not IsServer()) then
        return
    end
    self.caster:RemoveGesture(ACT_DOTA_ATTACK)
    self.caster:RemoveGesture(ACT_DOTA_ATTACK2)
end

LinkedModifiers["modifier_chosen_invoker_purification_brilliance"] = LUA_MODIFIER_MOTION_NONE

-- chosen_invoker_purification_brilliance
chosen_invoker_purification_brilliance = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_purification_brilliance"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function chosen_invoker_purification_brilliance:OnChannelFinish(interrupted)
    if (not IsServer()) then
        return
    end
    local target = self:GetCursorTarget()
    if (interrupted and (not target or target:IsNull() or not target:IsAlive())) then
        local caster = self:GetCaster()
        local mana = self:GetSpecialValueFor("mana") / 100
        local manaDuration = self:GetSpecialValueFor("mana_duration")
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_chosen_invoker_purification_brilliance_buff"
        modifierTable.modifier_params = { mana = mana }
        modifierTable.duration = manaDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingBuff(modifierTable)
    end
    self.modifier:Destroy()
end

function chosen_invoker_purification_brilliance:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    self.modifier = caster:AddNewModifier(caster, self, "modifier_chosen_invoker_purification_brilliance", { duration = self:GetChannelTime() })
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_chosen_invoker", MotionController)
end