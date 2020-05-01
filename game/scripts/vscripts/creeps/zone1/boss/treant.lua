---------------------
-- treant hook
---------------------
target:EmitSound("treant_treant_attack_09") --come here
caster:EmitSound("sounds/weapons/hero/treant/natures_guise.vsnd") --casting sound
caster:EmitSound("sounds/weapons/hero/dark_willow/bramble_spawn.vsnd")  --vine spawn sound
---------------------
-- treant seed
---------------------
--get sound from imba
---------------------
-- treant growth
---------------------
caster:EmitSound("Hero_Treant.Overgrowth.Cast")

---------------------
-- treant bash
---------------------
ursa_rend = class({
    GetAbilityTextureName = function(self)
        return "ursa_rend"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_ursa_rend"
    end,
})

modifier_ursa_rend = modifier_ursa_rend or class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_ursa_rend:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

LinkLuaModifier("modifier_ursa_rend", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ursa_rend:OnAttackLanded(keys)
    --start cd
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
        keys.target:EmitSound("Hero_Slardar.Bash")
        self.parent:EmitSound("ursa_ursa_overpower_05")
        self.ability:ApplyRend(keys.target, self.parent)
        local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
        self.ability:StartCooldown(abilityCooldown)
    end
end

function ursa_rend:ApplyRend(target, parent)
    -- "Rend first applies its armor debuff, bash, then Ursa's attack damage, and then the Rend damage."
    self.armor_reduction_duration = self.armor_reduction_duration or self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_ursa_rend_armor"
    modifierTable.duration = self.armor_reduction_duration
    GameMode:ApplyDebuff(modifierTable)
    self.stun = self.stun or self:GetSpecialValueFor("stun")
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_stunned"
    modifierTable.duration = self.stun
    GameMode:ApplyDebuff(modifierTable)
    local ursa_rend_armor_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(ursa_rend_armor_fx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    Timers:CreateTimer(15.0, function()
        ParticleManager:DestroyParticle(ursa_rend_armor_fx, false)
        ParticleManager:ReleaseParticleIndex(ursa_rend_armor_fx)
    end)

end

modifier_ursa_rend_armor = modifier_ursa_rend_armor or class({
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
    end
})


function modifier_ursa_rend_armor:OnCreated()
    if not IsServer() then
        return
    end
    self.armor_reduction_percentage = 0
    local modifier = self:GetCaster():FindModifierByName("modifier_ursa_rend")
    if (modifier) then
        self.armor_reduction_percentage = modifier.ability:GetSpecialValueFor("armor_reduction_percentage") * -0.01
    end

end

function modifier_ursa_rend_armor:GetArmorPercentBonus()
    return self.armor_reduction_percentage
end
----------------
-- treant ingrain
---------------
caster:EmitSound("treant_treant_ability_leechseed_05") --life and death
----------------
-- treant fertilize
----------------
caster:EmitSound("Hero_Furion.TreantSpawn")
