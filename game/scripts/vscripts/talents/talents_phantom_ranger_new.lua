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

function phantom_ranger_void_arrows:OnOrbFire( params )
    local caster = self:GetCaster()
    local manaCost = self:GetManaCost(self:GetLevel() - 1)
    local powerAddictionCostIncrease = TalentTree:GetHeroTalentLevel(caster, 36)
    if costIncrease ~= 0 then
        caster:SpendMana(manaCost * powerAddictionCostIncrease, self)
    end
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnOrbImpact( params )
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

phantom_ranger_hunters_focus = phantom_ranger_hunters_focus or class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_hunters_focus"
    end,
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
    LinkLuaModifier(LinkedModifier, "talents/talents_phantom_ranger", MotionController)
end

if (IsServer() and not GameMode.TALENTS_PHANTOM_RANGER_INIT) then
    --GameMode.PreDamageEventHandlersTable = {}
    --GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_hunters_focus_buff, 'OnTakeDamage'))
    --GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_42, 'OnTakeDamage'))
    GameMode.TALENTS_PHANTOM_RANGER_INIT = true
end