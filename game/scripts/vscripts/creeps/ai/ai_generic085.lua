GENERIC_AI_THINK_INTERVAL = 0.85

function Spawn(keys)
    if not IsServer() then
        return
    end
    if thisEntity == nil then
        return
    end
    Castbar:AddToUnit(thisEntity)
    thisEntity.ai = {}
    thisEntity:SetContextThink("Think", Think, GENERIC_AI_THINK_INTERVAL)
end

function Think()
    if not IsServer() then
        return
    end
    local aggroTarget = Aggro:GetUnitCurrentTarget(thisEntity)
    if (aggroTarget and thisEntity:IsAlive()) then
        if (not (thisEntity.ai.castedAbility and thisEntity.ai.castedAbility:IsInAbilityPhase())) then
            thisEntity.ai.castedAbility = nil
        else
            return GENERIC_AI_THINK_INTERVAL
        end
        local abiltiesCount = thisEntity:GetAbilityCount() - 1
        for i = 0, abiltiesCount do
            local ability = thisEntity:GetAbilityByIndex(i)
            if (ability and ability:IsCooldownReady() and ability:IsFullyCastable()) then
                local behavior = ability:GetBehavior()
                local isPassive = (bit.band(behavior, DOTA_ABILITY_BEHAVIOR_PASSIVE) == DOTA_ABILITY_BEHAVIOR_PASSIVE)
                if (not isPassive) then
                    local isNoTarget = (bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR_NO_TARGET)
                    if (isNoTarget) then
                        thisEntity:CastAbilityNoTarget(ability, -1)
                        thisEntity.ai.castedAbility = ability
                        break
                    end
                    local isUnitTarget = (bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)
                    if (isUnitTarget) then
                        thisEntity:CastAbilityOnTarget(aggroTarget, ability, -1)
                        thisEntity.ai.castedAbility = ability
                        break
                    end
                    local isPointTarget = (bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR_POINT)
                    if (isPointTarget) then
                        thisEntity:CastAbilityOnPosition(aggroTarget:GetAbsOrigin(), ability, -1)
                        thisEntity.ai.castedAbility = ability
                        break
                    end
                end
            end
        end
        if (thisEntity.ai.castedAbility) then
            return GENERIC_AI_THINK_INTERVAL
        end
        thisEntity:MoveToTargetToAttack(aggroTarget)
    end
    return GENERIC_AI_THINK_INTERVAL
end