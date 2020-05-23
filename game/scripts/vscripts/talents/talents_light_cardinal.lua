local LinkedModifiers = {}

-- light_cardinal_harmony modifiers
modifier_light_cardinal_harmony = class({
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
    GetTexture = function(self)
        return light_cardinal_harmony:GetAbilityTextureName()
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/harmony/harmony_effect.vpcf"
    end
})

function modifier_light_cardinal_harmony:GetArmorBonus()
    local armor_bonus = self.caster.light_cardinal_harmony.armor_bonus or 0
    local armor = (self.caster:GetMaxMana() - self.caster:GetMana()) * armor_bonus
    return armor
end

function modifier_light_cardinal_harmony:GetIntellectBonus()
    local int_bonus = self.caster.light_cardinal_harmony.int_bonus or 0
    local int = (self.caster:GetMaxHealth() - self.caster:GetHealth()) * int_bonus
    return int
end

function modifier_light_cardinal_harmony:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self:StartIntervalThink(1.0)
end

function modifier_light_cardinal_harmony:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local ability = self.caster:FindAbilityByName("light_cardinal_harmony")
    if (not ability or ability:GetLevel() == 0) then
        self:Destroy()
    end
end

LinkedModifiers["modifier_light_cardinal_harmony"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_harmony
light_cardinal_harmony = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_harmony"
    end
})

function light_cardinal_harmony:OnUpgrade()
    if IsServer() then
        local caster = self:GetCaster()
        caster.light_cardinal_harmony = caster.light_cardinal_harmony or {}
        caster.light_cardinal_harmony.armor_bonus = self:GetSpecialValueFor("armor_bonus") / 100
        caster.light_cardinal_harmony.int_bonus = self:GetSpecialValueFor("int_bonus") / 100
        if (not caster:HasModifier("modifier_light_cardinal_harmony")) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_light_cardinal_harmony"
            modifierTable.duration = -1
            GameMode:ApplyBuff(modifierTable)
        end
    end
end

-- light_cardinal_spirit_shield modifiers
modifier_light_cardinal_spirit_shield = class({
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
        return light_cardinal_spirit_shield:GetAbilityTextureName()
    end
})

function modifier_light_cardinal_spirit_shield:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.absorb = self.ability:GetSpecialValueFor("absorb") / 100
    self.duration = self.ability:GetSpecialValueFor("absorb")
    self.absorbed_damage = 0
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/spirit_shield/spirit_shield.vpcf", PATTACH_ROOTBONE_FOLLOW, self.target)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.target:GetPaddedCollisionRadius() + 50, 0, 0))
    Timers:CreateTimer(self.ability.duration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end

function modifier_light_cardinal_spirit_shield:OnDestroy()
    if not IsServer() then
        return
    end
    if (TalentTree:GetHeroTalentLevel(self.caster, 34) > 0 and self.absorbed_damage > 0) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = self.target
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_34_embrace"
        modifierTable.modifier_params = { absorbed_damage = self.absorbed_damage }
        modifierTable.duration = 5
        GameMode:ApplyBuff(modifierTable)
    end
end

---@param damageTable DAMAGE_TABLE
function modifier_light_cardinal_spirit_shield:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) then
        local modifier = damageTable.victim:FindModifierByName("modifier_light_cardinal_spirit_shield")
        if (modifier ~= nil and modifier.caster ~= nil and modifier.caster:IsAlive()) then
            local block = damageTable.damage * modifier.absorb
            local casterHealth = modifier.caster:GetHealth()
            if (casterHealth > 1) then
                local healthReduce = 0
                if (block >= casterHealth) then
                    healthReduce = block - (casterHealth - 1)
                    damageTable.damage = damageTable.damage - healthReduce
                else
                    healthReduce = block
                    damageTable.damage = damageTable.damage - block
                end
                modifier.absorbed_damage = modifier.absorbed_damage + healthReduce
                local finalHealth = casterHealth - healthReduce
                if (finalHealth < 1) then
                    finalHealth = 1
                end
                modifier.caster:SetHealth(finalHealth)
                return damageTable
            end
        end
    end
end

LinkedModifiers["modifier_light_cardinal_spirit_shield"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_spirit_shield
light_cardinal_spirit_shield = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_spirit_shield"
    end
})

function light_cardinal_spirit_shield:OnSpellStart(unit, special_cast)
    if not IsServer() then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = self:GetCaster()
    modifierTable.modifier_name = "modifier_light_cardinal_spirit_shield"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    modifierTable.caster:EmitSound("Hero_Silencer.Curse_Tick")
    Timers:CreateTimer(1, function()
        modifierTable.caster:StopSound("Hero_Silencer.Curse_Tick")
    end)
end

-- modifier_npc_dota_hero_silencer_talent_34 (Embrace)
modifier_npc_dota_hero_silencer_talent_34_embrace = class({
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
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_34.png"
    end
})

function modifier_npc_dota_hero_silencer_talent_34_embrace:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.hps = (keys.absorbed_damage * (0.4 + (0.1 * TalentTree:GetHeroTalentLevel(self.caster, 34)))) / math.floor(self:GetDuration())
    self:StartIntervalThink(1)
end

function modifier_npc_dota_hero_silencer_talent_34_embrace:OnIntervalThink()
    if not IsServer() then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = self.hps
    GameMode:HealUnit(healTable)
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_34_embrace"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_35 (Possession)
modifier_npc_dota_hero_silencer_talent_35 = class({
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

function modifier_npc_dota_hero_silencer_talent_35:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_35:GetHealthPercentBonus()
    local ability = self.caster:FindModifierByName("modifier_light_cardinal_harmony")
    if (ability) then
        return 0.4 + (0.1 * TalentTree:GetHeroTalentLevel(self.caster, 35))
    end
    return 0
end

function modifier_npc_dota_hero_silencer_talent_35:GetManaPercentBonus()
    local ability = self.caster:FindModifierByName("modifier_light_cardinal_harmony")
    if (ability) then
        return 0.4 + (0.1 * TalentTree:GetHeroTalentLevel(self.caster, 35))
    end
    return 0
end

function modifier_npc_dota_hero_silencer_talent_35:GetHealthRegenerationPercentBonus()
    local ability = self.caster:FindModifierByName("modifier_light_cardinal_harmony")
    if (ability) then
        return -0.5
    end
    return 0
end

function modifier_npc_dota_hero_silencer_talent_35:GetManaRegenerationPercentBonus()
    local ability = self.caster:FindModifierByName("modifier_light_cardinal_harmony")
    if (ability) then
        return -0.5
    end
    return 0
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_35"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_40 (Divine Cloak)
modifier_npc_dota_hero_silencer_talent_40 = class({
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

function modifier_npc_dota_hero_silencer_talent_40:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.timer = 0
    self:StartIntervalThink(1.0)
end

function modifier_npc_dota_hero_silencer_talent_40:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.timer = self.timer + 1
    if (self.timer > 5) then
        self.timer = 0
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_40_divine_cloak"
        modifierTable.duration = -1
        local cloak = GameMode:ApplyBuff(modifierTable)
        cloak:SetStackCount(math.min(2 + TalentTree:GetHeroTalentLevel(self.caster, 40), 7))
    end
end

---@param damageTable DAMAGE_TABLE
function modifier_npc_dota_hero_silencer_talent_40:OnTakeDamage(damageTable)
    ---@type CDOTA_Buff
    local modifier = damageTable.victim:FindModifierByName("modifier_npc_dota_hero_silencer_talent_40_divine_cloak")
    if (modifier and damageTable.damage > 0) then
        local stacks = modifier:GetStackCount()
        if (stacks > 0) then
            stacks = stacks - 1
            modifier:SetStackCount(math.max(0, stacks))
            if (stacks < 1) then
                modifier:Destroy()
            end
            local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/talents/divine_cloak/divine_cloak_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
            Timers:CreateTimer(0.5, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
            damageTable.damage = 0
            return damageTable
        end
    end
end

---@param damageTable DAMAGE_TABLE
function modifier_npc_dota_hero_silencer_talent_40:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_npc_dota_hero_silencer_talent_40")
    if (modifier) then
        modifier.timer = 0
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_40"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_silencer_talent_40_divine_cloak = class({
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
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_40.png"
    end
})

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_40_divine_cloak"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_41 (Divine Aid)
modifier_npc_dota_hero_silencer_talent_41 = class({
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

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_41"] = LUA_MODIFIER_MOTION_NONE

---@param healTable HEAL_TABLE
function modifier_npc_dota_hero_silencer_talent_41:OnPreHeal(healTable)
    if (healTable.heal > 0 and healTable.caster:HasModifier("modifier_npc_dota_hero_silencer_talent_41")) then
        healTable.heal = healTable.heal + (healTable.target:GetMaxHealth() * 0.01 * TalentTree:GetHeroTalentLevel(self.caster, 41))
        return healTable
    end
end

-- modifier_npc_dota_hero_silencer_talent_46 (Priesthood)
modifier_npc_dota_hero_silencer_talent_46 = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_silencer_talent_46:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.radius = 2000
end

function modifier_npc_dota_hero_silencer_talent_46:OnAbilityFullyCast()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        local enemyAggro = Aggro:Get(self.caster, enemy) * math.max(-0.05 * TalentTree:GetHeroTalentLevel(self.caster, 46), -0.25)
        if (enemyAggro > 0) then
            enemyAggro = enemyAggro * -1
        end
        Aggro:Add(self.caster, enemy, enemyAggro)
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_46"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_47 (HOLY CRUSADER)
modifier_npc_dota_hero_silencer_talent_47 = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_silencer_talent_47:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.radius = 2000
end

function modifier_npc_dota_hero_silencer_talent_47:OnAbilityFullyCast()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        local aggro = math.abs(Aggro:Get(self.caster, enemy) * 0.05 * TalentTree:GetHeroTalentLevel(self.caster, 47))
        if (aggro < 1) then
            aggro = 1
        end
        Aggro:Add(self.caster, enemy, aggro)
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_47"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_desecration
light_cardinal_desecration = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_desecration"
    end
})

function light_cardinal_desecration:IsRequireCastbar()
    return true
end

function light_cardinal_desecration:OnSpellStart(unit, special_cast)
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local casterHealth = caster:GetMaxHealth() * (self:GetSpecialValueFor("damage") / 100)
    casterHealth = caster:GetHealth() - casterHealth
    if (casterHealth < 1) then
        casterHealth = 1
    end
    caster:SetHealth(casterHealth)
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/desecration/desecration.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    Timers:CreateTimer(1.5, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    caster:EmitSound("Hero_Silencer.Curse_Tick")
end

-- modifier_npc_dota_hero_silencer_talent_36 (Sacrilege)
modifier_npc_dota_hero_silencer_talent_36 = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_silencer_talent_36:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_36:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if keys.unit == self.caster and keys.ability:GetName() == "light_cardinal_desecration" then
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_36_sacrilege"
        modifierTable.duration = 5
        GameMode:ApplyBuff(modifierTable)
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_36"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_silencer_talent_36_sacrilege = class({
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
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_36.png"
    end
})

function modifier_npc_dota_hero_silencer_talent_36_sacrilege:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_36_sacrilege:GetSpellDamageBonus()
    return 0.1 + (0.1 * TalentTree:GetHeroTalentLevel(self.caster, 36))
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_36_sacrilege"] = LUA_MODIFIER_MOTION_NONE

-- modifiers light_cardinal_consecration
modifier_light_cardinal_consecration = class({
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
    GetEffectName = function(self)
        return "particles/units/light_cardinal/consecration/consecration.vpcf"
    end
})

function modifier_light_cardinal_consecration:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    self.radius = self.ability:GetSpecialValueFor("radius")
    self:StartIntervalThink(self.ability:GetSpecialValueFor("tick"))
end

function modifier_light_cardinal_consecration:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local ability = self.caster:FindAbilityByName("light_cardinal_consecration")
    if (not ability or ability:GetLevel() == 0) then
        self:Destroy()
    end
    local damage = self.damage * (self.caster:GetMaxHealth() - self.caster:GetHealth())
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/consecration/consecration_wave.vpcf", PATTACH_ROOTBONE_FOLLOW, self.caster)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("Hero_Omniknight.Repel.TI8", self.caster)
    Timers:CreateTimer(0.5, function()
        StopSoundOn("Hero_Omniknight.Repel.TI8", self.caster)
    end)
    if (damage > 0) then
        local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                self.caster:GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local hasTalent = (TalentTree:GetHeroTalentLevel(self.caster, 37) > 0)
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.damage = damage
            damageTable.holydmg = true
            GameMode:DamageUnit(damageTable)
            local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/consecration/consecration_impact.vpcf", PATTACH_ROOTBONE_FOLLOW, enemy)
            Timers:CreateTimer(1, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
            if (hasTalent) then
                local modifierTable = {}
                modifierTable.ability = self.ability
                modifierTable.target = enemy
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_37_anointed_grounds"
                modifierTable.duration = 3
                GameMode:ApplyDebuff(modifierTable)
            end
        end
    end
end

LinkedModifiers["modifier_light_cardinal_consecration"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_consecration
light_cardinal_consecration = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_consecration"
    end
})

function light_cardinal_consecration:OnToggle(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        caster.light_cardinal_consecration = caster.light_cardinal_consecration or {}
        if (self:GetToggleState()) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_light_cardinal_consecration"
            modifierTable.duration = -1
            caster.light_cardinal_consecration.modifier = GameMode:ApplyBuff(modifierTable)
            self:EndCooldown()
            self:StartCooldown(self:GetCooldown(1))
        else
            if (caster.light_cardinal_consecration.modifier ~= nil) then
                caster.light_cardinal_consecration.modifier:Destroy()
            end
        end
    end
end

-- modifier_npc_dota_hero_silencer_talent_37 (Anointed Grounds)
modifier_npc_dota_hero_silencer_talent_37_anointed_grounds = class({
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
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_37.png"
    end
})

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetFireProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetFrostProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetEarthProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetVoidProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetHolyProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetNatureProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

function modifier_npc_dota_hero_silencer_talent_37_anointed_grounds:GetInfernoProtectionBonus()
    return math.max(-0.1 * TalentTree:GetHeroTalentLevel(self.caster, 37), -0.3)
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_37_anointed_grounds"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_smite
light_cardinal_smite = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_smite"
    end
})

function light_cardinal_smite:IsRequireCastbar()
    return true
end

function light_cardinal_smite:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/smite/smite.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    local damageTable = {}
    damageTable.caster = caster
    damageTable.target = target
    damageTable.ability = self
    damageTable.damage = Units:GetHeroIntellect(caster) * (self:GetSpecialValueFor("damage") / 100)
    damageTable.holydmg = true
    local modifier = caster:FindModifierByName("modifier_npc_dota_hero_silencer_talent_38_misery")
    if (modifier) then
        damageTable.damage = damageTable.damage * ((1 + (0.04 + (0.01 * TalentTree:GetHeroTalentLevel(caster, 38)))) * modifier:GetStackCount())
    end
    GameMode:DamageUnit(damageTable)
end

-- modifier_npc_dota_hero_silencer_talent_42 (Clarity)
modifier_npc_dota_hero_silencer_talent_42 = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_silencer_talent_42:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_42:OnAbilityFullyCast()
    if (not IsServer()) then
        return
    end
    if (RollPercentage(25 + (5 * TalentTree:GetHeroTalentLevel(self.caster, 42)))) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.caster
        healTable.ability = nil
        healTable.heal = self.caster:GetMaxMana() * 0.05
        GameMode:HealUnitMana(healTable)
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_42"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_43 (Mana Tide)
modifier_npc_dota_hero_silencer_talent_43 = class({
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

function modifier_npc_dota_hero_silencer_talent_43:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_43:GetManaPercentBonus()
    return 0.3 + (0.1 * TalentTree:GetHeroTalentLevel(self.caster, 43))
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_43"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_48 (Mana Shield)
modifier_npc_dota_hero_silencer_talent_48 = class({
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

function modifier_npc_dota_hero_silencer_talent_48:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_48:GetDamageReductionBonus()
    return 0.01 + (0.02 * TalentTree:GetHeroTalentLevel(self.caster, 48))
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_48"] = LUA_MODIFIER_MOTION_NONE

function modifier_npc_dota_hero_silencer_talent_48:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) then
        if (damageTable.victim:HasModifier("modifier_npc_dota_hero_silencer_talent_48")) then
            local casterMana = damageTable.victim:GetMana()
            if (damageTable.damage >= casterMana) then
                damageTable.damage = damageTable.damage - casterMana
                damageTable.victim:SetMana(0)
            else
                damageTable.victim:SetMana(casterMana - damageTable.damage)
                damageTable.damage = 0
            end
            modifier_out_of_combat:ResetTimer(damageTable.victim)
            return damageTable
        end
    end
end

function modifier_npc_dota_hero_silencer_talent_48:OnPostTakeDamage(damageTable)
    if (damageTable.victim:HasModifier("modifier_npc_dota_hero_silencer_talent_48")) then
        damageTable.victim:ForceKill(false)
    end
end

-- modifier_npc_dota_hero_silencer_talent_49 (ASCENDANCY)
modifier_npc_dota_hero_silencer_talent_49 = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_49"] = LUA_MODIFIER_MOTION_NONE

function modifier_npc_dota_hero_silencer_talent_49:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_49:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    local abilityLevel = keys.ability:GetLevel()
    if (keys.ability:GetCooldown(abilityLevel) < 1) then
        return
    end
    for i = 0, self.caster:GetAbilityCount() do
        local ability = self.caster:GetAbilityByIndex(i)
        if (ability) then
            local cooldownTable = {}
            cooldownTable.reduction = math.min(1 * TalentTree:GetHeroTalentLevel(self.caster, 49), 5)
            cooldownTable.ability = ability:GetAbilityName()
            cooldownTable.isflat = true
            cooldownTable.target = self.caster
            GameMode:ReduceAbilityCooldown(cooldownTable)
        end
    end
end
-- light_cardinal_patronage modifiers
modifier_light_cardinal_patronage = class({
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
        return light_cardinal_patronage:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/patronage/patronage.vpcf"
    end
})

function modifier_light_cardinal_patronage:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.crit_chance = keys.crit_chance
    self.crit_factor = keys.crit_factor / 100
end

function modifier_light_cardinal_patronage:OnDestroy(keys)
    if (not IsServer()) then
        return
    end
    local caster = self:GetParent()
    local talentLevel = TalentTree:GetHeroTalentLevel(caster, 39)
    if (talentLevel > 0) then
        local cooldownTable = {}
        cooldownTable.reduction = talentLevel
        cooldownTable.ability = keys.ability:GetAbilityName()
        cooldownTable.isflat = true
        cooldownTable.target = self.unit
        GameMode:ReduceAbilityCooldown(cooldownTable)
        return
    end
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_light_cardinal_patronage_debuff"
    modifierTable.modifier_params = {}
    modifierTable.modifier_params.debuff_dmgred = self.ability:GetSpecialValueFor("debuff_dmgred") / 100
    modifierTable.modifier_params.debuff_spelldmg = self.ability:GetSpecialValueFor("debuff_spelldmg") / 100
    modifierTable.duration = self.ability:GetSpecialValueFor("debuff_duration")
    GameMode:ApplyDebuff(modifierTable)
end

function modifier_light_cardinal_patronage:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_light_cardinal_patronage")
    if (modifier and GameMode:RollCriticalChance(damageTable.attacker, modifier.crit_chance)) then
        damageTable.crit = modifier.crit_factor
        return damageTable
    end
end

LinkedModifiers["modifier_light_cardinal_patronage"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_patronage_debuff = class({
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
    GetTexture = function(self)
        return light_cardinal_patronage:GetAbilityTextureName()
    end
})

function modifier_light_cardinal_patronage_debuff:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.debuff_dmgred = keys.debuff_dmgred
    self.debuff_spelldmg = keys.debuff_spelldmg
end

function modifier_light_cardinal_patronage_debuff:GetSpellDamageBonus()
    return -self.debuff_spelldmg
end

function modifier_light_cardinal_patronage_debuff:GetDamageReductionBonus()
    return -self.debuff_dmgred
end

LinkedModifiers["modifier_light_cardinal_patronage_debuff"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_patronage
light_cardinal_patronage = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_patronage"
    end
})

function light_cardinal_patronage:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_light_cardinal_patronage"
    modifierTable.modifier_params = {}
    modifierTable.modifier_params.crit_factor = self:GetSpecialValueFor("crit_factor")
    modifierTable.modifier_params.crit_chance = self:GetSpecialValueFor("crit_chance")
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
end

-- modifier_npc_dota_hero_silencer_talent_38 (Misery)
modifier_npc_dota_hero_silencer_talent_38_misery = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_38.png"
    end
})

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_38_misery"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_silencer_talent_38 = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_silencer_talent_38:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if (keys.ability:GetName() ~= "light_cardinal_smite") then
        return
    end
    local caster = self:GetParent()
    local target = keys.ability:GetCursorTarget()
    local modifier = caster:FindModifierByName("modifier_npc_dota_hero_silencer_talent_38_misery")
    if (not modifier) then
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_38_misery"
        modifierTable.duration = 5
        modifier = GameMode:ApplyBuff(modifierTable)
        modifier.target = target
    end
    modifier:ForceRefresh()
    if (modifier.target ~= target) then
        modifier:Destroy()
    else
        modifier:SetStackCount(math.min(modifier:GetStackCount() + 1, 5))
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_38"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_44 (Combustion)
modifier_npc_dota_hero_silencer_talent_44 = class({
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

function modifier_npc_dota_hero_silencer_talent_44:OnTakeDamage(damageTable)
    if (damageTable.attacker:HasModifier("modifier_npc_dota_hero_silencer_talent_44") and not damageTable.attacker.modifier_npc_dota_hero_silencer_talent_44) then
        damageTable.damage = damageTable.damage + (damageTable.victim:GetMaxHealth() * math.min(0.01 * TalentTree:GetHeroTalentLevel(damageTable.attacker, 44), 0.05))
        damageTable.attacker.modifier_npc_dota_hero_silencer_talent_44 = true
        local silencer = damageTable.attacker
        Timers:CreateTimer(5, function()
            silencer.modifier_npc_dota_hero_silencer_talent_44 = nil
        end)
        local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/smite/smite_flying_thing.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
        Timers:CreateTimer(1, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        return damageTable
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_44"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_45 (Divine Swiftness)
modifier_npc_dota_hero_silencer_talent_45 = class({
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

function modifier_npc_dota_hero_silencer_talent_45:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_silencer_talent_45:GetMoveSpeedPercentBonus()
    local buffCount = 0
    local unitModifiers = self.caster:FindAllModifiers()
    for i = 1, #unitModifiers do
        if (not unitModifiers[i]:IsDebuff() and not unitModifiers[i]:IsHidden()) then
            buffCount = buffCount + 1
        end
    end
    return (0.03 + (0.02 * TalentTree:GetHeroTalentLevel(self.caster, 45))) * buffCount
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_45"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_50 (Nullification)
modifier_npc_dota_hero_silencer_talent_50_nullification_cd = class({
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
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_50.png"
    end
})

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_50_nullification_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_silencer_talent_50_nullification = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_silencer/talent_50.png"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_npc_dota_hero_silencer_talent_50_nullification:OnTooltip()
    return self:GetStackCount()
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_50_nullification"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_silencer_talent_50 = class({
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

function modifier_npc_dota_hero_silencer_talent_50:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_npc_dota_hero_silencer_talent_50_nullification")
    if (modifier) then
        local amount = modifier:GetStackCount()
        if (damageTable.damage >= amount) then
            damageTable.damage = damageTable.damage - amount
            modifier:Destroy()
        else
            modifier:SetStackCount(math.floor(amount - damageTable.damage))
            damageTable.damage = 0
        end
        return damageTable
    end
    if (damageTable.victim:HasModifier("modifier_npc_dota_hero_silencer_talent_50")) then
        local casterHealth = damageTable.victim:GetHealth()
        local cap = damageTable.victim:GetMaxHealth() * 0.05
        if ((casterHealth - damageTable.damage) <= cap and not damageTable.victim:HasModifier("modifier_npc_dota_hero_silencer_talent_50_nullification_cd")) then
            local talentLevel = TalentTree:GetHeroTalentLevel(damageTable.victim, 50)
            local duration = math.min(90, 125 - talentLevel)
            local modifierTable = {}
            modifierTable.ability = nil
            modifierTable.target = damageTable.victim
            modifierTable.caster = damageTable.victim
            modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_50_nullification_cd"
            modifierTable.duration = duration
            local cooldownModifier = GameMode:ApplyBuff(modifierTable)
            cooldownModifier:SetDuration(duration, true)
            local shieldAmount = (damageTable.victim:GetMaxHealth() - casterHealth) * (0.60 + (0.15 * talentLevel))
            modifierTable = {}
            modifierTable.ability = nil
            modifierTable.target = damageTable.victim
            modifierTable.caster = damageTable.victim
            modifierTable.modifier_name = "modifier_npc_dota_hero_silencer_talent_50_nullification"
            modifierTable.duration = -1
            local shield = GameMode:ApplyBuff(modifierTable)
            shield:SetStackCount(math.floor(shieldAmount))
            damageTable.damage = 0
            return damageTable
        end
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_50"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_silencer_talent_51 (ENLIGHTENMENT)
modifier_npc_dota_hero_silencer_talent_51 = class({
    IsDebuff = function()
        return false
    end,
    IsHidden = function()
        return true
    end,
    IsPurgable = function()
        return false
    end,
    RemoveOnDeath = function()
        return false
    end,
    AllowIllusionDuplicate = function()
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_npc_dota_hero_silencer_talent_51:OnTakeDamage(damageTable)
    if (damageTable.attacker:HasModifier("modifier_npc_dota_hero_silencer_talent_51") and damageTable.ability) then
        damageTable.damage = damageTable.damage + (Units:GetHeroIntellect(damageTable.attacker) * (0.45 + (0.05 * TalentTree:GetHeroTalentLevel(damageTable.attacker, 51))))
        return damageTable
    end
end

LinkedModifiers["modifier_npc_dota_hero_silencer_talent_51"] = LUA_MODIFIER_MOTION_NONE

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_light_cardinal", MotionController)
end

if (IsServer() and not GameMode.TALENTS_LIGHT_CARDINAL_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_light_cardinal_spirit_shield, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_40, 'OnTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_40, 'OnPostTakeDamage'))
    GameMode:RegisterPreHealEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_41, 'OnPreHeal'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_48, 'OnTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_48, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_light_cardinal_patronage, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_44, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_50, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_silencer_talent_51, 'OnTakeDamage'))
    GameMode.TALENTS_LIGHT_CARDINAL_INIT = true
end