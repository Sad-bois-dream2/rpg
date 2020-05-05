local LinkedModifiers = {}

-- phantom_ranger_void_arrows
phantom_ranger_void_arrows = class({
    GetAbilityTextureName = function(self)
        return "dark_seer_surge"
    end
})

function phantom_ranger_void_arrows:GetIntrinsicModifierName()
    return "modifier_generic_orb_effect_lua"
end

-------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnSpellStart()
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:GetProjectileName()
    return "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf"
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnOrbFire(params)
    local caster = self:GetCaster()
    local manaCost = self:GetManaCost(self:GetLevel() - 1)
    local powerAddictionCostIncrease = TalentTree:GetHeroTalentLevel(caster, 36)
    if costIncrease ~= 0 then
        caster:SpendMana(manaCost * powerAddictionCostIncrease, self)
    end
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnOrbImpact(params)
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("void_damage")
    local powerAddictionDamageModifier = 1 + (TalentTree:GetHeroTalentLevel(caster, 36) / 3)
    if params.target ~= nil then
        GameMode:DamageUnit({ caster = caster, target = params.target, damage = damage * powerAddictionDamageModifier, voiddmg = true, ability = self })
    end
    --local sound_cast = "Hero_ObsidianDestroyer.ArcaneOrb.Impact"
    --EmitSoundOn( sound_cast, params.target )
end

--------------------------------------------------------------------------------
-- Hunter's Focus Modifiers
modifier_phantom_ranger_hunters_focus_buff = class({
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
    GetAbilityTextureName = function(self)
        return "phantom_ranger_hunters_focus"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK }
    end
})

function modifier_phantom_ranger_hunters_focus_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.bonusAttackSpeed = MAXIMUM_ATTACK_SPEED
    self.bonusAttackDamage = self:GetAbility():GetSpecialValueFor("attack_damage") / 100
    self.talent37Level = TalentTree:GetHeroTalentLevel(self.caster, 37)
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackSpeedBonus()
    return self.bonusAttackSpeed
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackDamagePercentBonus()
    return self.bonusAttackDamage
end

function modifier_phantom_ranger_hunters_focus_buff:OnTakeDamage(damageTable)
    local talent37Level = TalentTree:GetHeroTalentLevel(damageTable.attacker, 37)
    if (talent37Level > 0 and damageTable.damage > 0) then
        if (damageTable.attacker:HasModifier("modifier_phantom_ranger_hunters_focus_buff")) then
            damageTable.damage = damageTable.damage * (0.45 + (0.1 * talent37Level))
            return damageTable
        end
    end
end

function modifier_phantom_ranger_hunters_focus_buff:OnAttack(keys)
    if not IsServer() then return end
    if self.talent37Level == 0 then return end
    -- "Secondary arrows are not released upon attacking allies."
    -- The "not keys.no_attack_cooldown" clause seems to make sure the function doesn't trigger on PerformAttacks with that false tag so this thing doesn't crash
    local bonusTargets = 1 + self.talent37Level
    local multishotRadius = 600
    if (keys.attacker == self.caster and keys.target and keys.target:GetTeamNumber() ~= self.caster:GetTeamNumber() and not keys.no_attack_cooldown and not self.caster:PassivesDisabled()) then
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, multishotRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)

        local targetNumber = 0

        for _, enemy in pairs(enemies) do
            self.caster:PerformAttack(enemy, true, true, true, true, true, false, false)
            targetNumber = targetNumber + 1
            if targetNumber >= bonusTargets then
                break
            end
        end
    end
end

LinkedModifiers["modifier_phantom_ranger_hunters_focus_buff"] = LUA_MODIFIER_MOTION_NONE

phantom_ranger_hunters_focus = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_hunters_focus"
    end
})

function phantom_ranger_hunters_focus:OnSpellStart()
    if not IsServer() then
        return
    end
    local hunters_focus_duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    GameMode:ApplyBuff({ caster = caster, target = caster, ability = self, modifier_name = "modifier_phantom_ranger_hunters_focus_buff", duration = hunters_focus_duration })
end


--------------------------------------------------------------------------------
-- Internal stuff

for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_phantom_ranger_new", MotionController)
end

if (IsServer() and not GameMode.TALENTS_PHANTOM_RANGER_INIT) then
    --GameMode.PreDamageEventHandlersTable = {}
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_hunters_focus_buff, 'OnTakeDamage'))
    --GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_42, 'OnTakeDamage'))
    GameMode.TALENTS_PHANTOM_RANGER_INIT = true
end