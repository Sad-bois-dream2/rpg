if Summons == nil then
    _G.Summons = class({})
end

modifier_summon = modifier_summon or class({
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
})

modifier_summon_owner_aa_fix = modifier_summon_owner_aa_fix or class({
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
})

function modifier_summon_owner_aa_fix:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

function modifier_summon_owner_aa_fix:GetModifierBaseDamageOutgoing_Percentage()
    return -100
end

function modifier_summon:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_summon:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(1.0)
    end
end

function modifier_summon:OnIntervalThink()
    if IsServer() then
        local summon = self:GetParent()
        if (summon.owner ~= nil) then
            local target_to_attack = summon.owner.summons.target_to_attack
            if (target_to_attack == nil or target_to_attack:IsNull()) then
                local distance_to_owner = (summon.owner:GetAbsOrigin() - summon:GetAbsOrigin()):Length()
                local blink_distance = 750
                if (distance_to_owner > blink_distance) then
                    FindClearSpaceForUnit(summon, summon.owner:GetAbsOrigin(), true)
                else
                    summon:MoveToNPC(summon.owner)
                end
            else
                if (target_to_attack:IsAlive()) then
                    summon:MoveToTargetToAttack(target_to_attack)
                end
            end
        end
    end
end

function modifier_summon:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_summon:GetModifierAttackSpeedBonus_Constant()
    return self:GetParent().attack_speed
end

function modifier_summon:OnAttackLanded(event)
    if IsServer() then
        local summon = event.attacker
        local target = event.target
        if (summon ~= nil and not summon:IsNull() and target ~= nil and summon ~= target and summon == self:GetParent() and summon:IsAlive()) then
            local owner = summon.owner
            local damageTable = {
                caster = summon.owner,
                target = target,
                damage = summon.damage,
                physdmg = summon.damage_types.physdmg,
                firedmg = summon.damage_types.firedmg,
                frostdmg = summon.damage_types.frostdmg,
                earthdmg = summon.damage_types.earthdmg,
                naturedmg = summon.damage_types.naturedmg,
                voiddmg = summon.damage_types.voiddmg,
                infernodmg = summon.damage_types.infernodmg,
                holydmg = summon.damage_types.holydmg,
                puredmg = summon.damage_types.puredmg,
                ability = summon.ability,
                fromsummon = true
            }
            GameMode:DamageUnit(damageTable)
            if (Summons:IsSummonCanProcOwnerAutoAttack(summon) and owner:IsAlive()) then
                -- reduce owner aa dmg to 0 for that hit
                owner:AddNewModifier(owner, nil, "modifier_summon_owner_aa_fix", {})
                owner:PerformAttack(target, true, true, true, true, false, false, true)
                owner:RemoveModifierByName("modifier_summon_owner_aa_fix")
            end
        end
    end
end

function modifier_summon:OnSummonMasterAttackLanded(event)
    if IsServer() then
        local hero = event.attacker
        local target = event.target
        if (target ~= nil and target:GetTeamNumber() ~= hero:GetTeamNumber()) then
            hero.summons.target_to_attack = target
        end
    end
end

function modifier_summon:OnSummonMasterIssueOrder(event)
    if IsServer() then
        local hero = event.unit
        local order = event.order_type
        if (order == DOTA_UNIT_ORDER_CAST_TARGET) then
            local target = event.ability:GetCursorTarget()
            if (target ~= nil and target:GetTeamNumber() ~= hero:GetTeamNumber()) then
                hero.summons.target_to_attack = event.ability:GetCursorTarget()
            end
        end
        if (order == DOTA_UNIT_ORDER_STOP) then
            hero.summons.target_to_attack = nil
        end
    end
end

if IsServer() then
    --idk
    ---@param args fun(caster: CDOTA_BaseNPC, unit: CDOTA_BaseNPC, position: handle, damage: number, ability: CDOTA_Ability_Lua):CDOTA_BaseNPC
    function Summons:SummonUnit(args)
        if (args == nil) then
            return nil
        end
        local caster = args.caster
        local summon = args.unit
        local position = args.position
        local ability = args.ability
        if (caster == nil or summon == nil or position == nil or ability == nill) then
            return nil
        end
        summon = CreateUnitByName(summon, position, true, caster, caster, caster:GetTeamNumber())
        if (summon == nil) then
            return nil
        end
        summon.damage = args.damage
        if (summon.damage == nil) then
            summon.damage = 1
        end
        summon.ability = ability
        summon.damage_types = {}
        summon.owner = caster
        summon.canprocaa = false
        summon:AddNewModifier(caster, nil, "modifier_summon", { Duration = -1 })
        return summon
    end

    ---@param summon CDOTA_BaseNPC
    function Summons:IsSummonCanProcOwnerAutoAttack(summon)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            return summon.canprocaa or false
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param canproc boolean
    function Summons:SetSummonCanProcOwnerAutoAttack(summon, canproc)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.canprocaa = canproc
        end
    end

    ---@param summon CDOTA_BaseNPC
    function Summons:GetSummonAttackSpeed(summon)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            return summon.attack_speed or 0
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param attack_speed number
    function Summons:SetSummonAttackSpeed(summon, attack_speed)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.attack_speed = attack_speed
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHavePhysDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.physdmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveFireDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.firedmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveFrostDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.frostdmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveEarthDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.earthdmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveNatureDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.naturedmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveVoidDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.voiddmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveInfernoDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.infernodmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHaveInfernoDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.holydmg = is_have
        end
    end

    ---@param summon CDOTA_BaseNPC
    ---@param is_have boolean
    function Summons:SetSummonHavePureDamageType(summon, is_have)
        if (summon ~= nil and not summon:IsNull() and summon:FindModifierByName("modifier_summon") ~= nil) then
            summon.damage_types.puredmg = is_have
        end
    end

    ---@param hero CDOTA_BaseNPC
    function Summons:SetupForHero(hero)
        if (hero ~= nil) then
            hero.summons = hero.summons or {}
        end
    end

    function Summons:IsSummmon(unit)
        if (unit ~= nil) then
            return (unit:FindModifierByName("modifier_summon") ~= nil)
        end
    end
end

LinkLuaModifier("modifier_summon", "systems/summons", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_summon_owner_aa_fix", "systems/summons", LUA_MODIFIER_MOTION_NONE)
