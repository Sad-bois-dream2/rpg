if Aggro == nil then
    _G.Aggro = class({})
end

function Aggro:Init()
    Aggro.COMBAT_RADIUS = 1500
    Aggro.CALC_INTERVAL = 0.5
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(Aggro, 'OnTakeDamage'))
end

function Aggro:OnTakeDamage(damageTable)
    if (IsClient()) then
        return
    end
    local attacker = damageTable.attacker
    local victim = damageTable.victim
    if (attacker ~= nil and victim ~= nil and not attacker:IsNull() and not victim:IsNull() and attacker ~= victim) then
        if (victim.aggro ~= nil and not Summons:IsSummmon(attacker)) then
            Aggro:Add(attacker, victim, damageTable.damage)
        end
        if (attacker.aggro ~= nil and not Summons:IsSummmon(victim)) then
            Aggro:Add(victim, attacker, damageTable.damage)
        end
    end
end

function Aggro:OnCreepSpawn(creep)
    if IsClient() then
        return
    end
    if (creep ~= nil) then
        creep:AddNewModifier(creep, nil, "modifier_aggro_system", { Duration = -1 })
    end
end

---@param unit CDOTA_BaseNPC
---@param targets table
function Aggro:GetAllTargets(unit)
    local targets = {}
    if (unit ~= nil and not unit:IsNull() and unit.aggro ~= nil) then
        for i, v in pairs(unit.aggro.enemies) do
            local target = EntIndexToHScript(i)
            if (target ~= nil and not target:IsNull()) then
                table.insert(targets, target)
            end
        end
    end
    return targets
end

---@param source CDOTA_BaseNPC
---@param unit CDOTA_BaseNPC
---@param aggro number
function Aggro:Add(source, unit, aggro)
    aggro = tonumber(aggro)
    if (source ~= nil and not source:IsNull() and unit ~= nil and not unit:IsNull() and unit.aggro ~= nil and aggro ~= nil) then
        local entIndex = source:GetEntityIndex()
        unit.aggro.enemies[entIndex] = (unit.aggro.enemies[entIndex] or 0) + aggro
    end
end

---@param source CDOTA_BaseNPC
---@param unit CDOTA_BaseNPC
function Aggro:Get(source, unit)
    if (source ~= nil and not source:IsNull() and unit ~= nil and not unit:IsNull() and unit.aggro ~= nil) then
        local entIndex = source:GetEntityIndex()
        return unit.aggro.enemies[entIndex] or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
function Aggro:Reset(unit)
    if (unit ~= nil and not unit:IsNull() and unit.aggro ~= nil) then
        for i, v in pairs(unit.aggro.enemies) do
            unit.aggro.enemies[i] = 0
        end
    end
end

function Aggro:CalculateAggro(creep)
    local newTarget
    for hero, aggro in pairs(creep.aggro.enemies) do
        if (Aggro:IsValidTarget(creep, hero)) then
            newTarget = hero
        end
        break
    end
    local latestTargetAggro = creep.aggro.enemies[creep.aggro.current_target] or 0
    local ignoreAggroTarget = Aggro:GetIgnoreAggroTarget(creep)
    if (ignoreAggroTarget and Aggro:IsValidTarget(creep, ignoreAggroTarget:GetEntityIndex())) then
        newTarget = ignoreAggroTarget
    else
        for hero, aggro in pairs(creep.aggro.enemies) do
            if (aggro > 0 and Aggro:IsValidTarget(creep, hero)) then
                if (Aggro:HasTaunt(hero)) then
                    newTarget = hero
                    break
                end
                if (aggro > latestTargetAggro) then
                    latestTargetAggro = aggro
                    newTarget = hero
                end
            end
        end
    end
    if (newTarget ~= nil) then
        local newTargetEntity = EntIndexToHScript(newTarget)
        if (newTargetEntity ~= creep.aggro.current_target) then
            CustomGameEventManager:Send_ServerToAllClients("rpg_aggro_target_changed", { creep = creep:GetEntityIndex(), target = newTarget })
        end
        creep.aggro.current_target = newTargetEntity
    else
        creep.aggro.current_target = nil
    end
end

function Aggro:GetIgnoreAggroTarget(unit)
    local ignoreAggroTarget
    if (unit == nil) then
        return ignoreAggroTarget
    end
    if (not unit:IsNull()) then
        local unitModifiers = unit:FindAllModifiers()
        for i = 1, #unitModifiers do
            if (unitModifiers[i].IsTaunt) then
                ignoreAggroTarget = unitModifiers[i].GetIgnoreAggroTarget(unitModifiers[i])
                if (ignoreAggroTarget) then
                    return ignoreAggroTarget
                end
            end
        end
    end
    return ignoreAggroTarget
end

function Aggro:HasTaunt(unit)
    if (unit == nil) then
        return false
    end
    unit = EntIndexToHScript(unit)
    if (not unit:IsNull()) then
        local unitModifiers = unit:FindAllModifiers()
        local hasTaunt = false
        for i = 1, #unitModifiers do
            if (unitModifiers[i].IsTaunt) then
                hasTaunt = unitModifiers[i].IsTaunt(unitModifiers[i])
                if (hasTaunt) then
                    return hasTaunt
                end
            end
        end
    end
    return false
end

function Aggro:IsUnitInCombat(creep)
    if (creep == nil or creep:isNull() or creep.aggro == nil) then
        return false
    end
    return (creep.aggro.current_target ~= nil)
end

function Aggro:GetUnitCurrentTarget(creep)
    return creep.aggro.current_target
end

function Aggro:IsValidTarget(creep, target)
    target = EntIndexToHScript(target)
    if (creep == nil or creep:IsNull()) then
        return false
    end
    if (target == nil or target:IsNull()) then
        return false
    end
    if (not target:IsAlive()) then
        return false
    end
    local distance_to_target = (target:GetAbsOrigin() - creep:GetAbsOrigin()):Length()
    if (distance_to_target > Aggro.COMBAT_RADIUS) then
        return false
    end
    if (target:IsInvisible()) then
        return false
    end
    if (target:IsInvulnerable()) then
        return false
    end
    return true
end

modifier_aggro_system = modifier_aggro_system or class({
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
})

function modifier_aggro_system:OnCreated(event)
    if IsServer() then
        self.creep = self:GetParent()
        self.creep.aggro = {}
        self.creep.aggro.enemies = {}
        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs(heroes) do
            Aggro:Add(hero, self.creep, 0)
        end
        self:StartIntervalThink(Aggro.CALC_INTERVAL)
    end
end

function modifier_aggro_system:OnIntervalThink()
    if IsServer() then
        Aggro:CalculateAggro(self.creep)
        --[[local target_to_attack = Aggro:GetUnitCurrentTarget(self.creep)
        if (target_to_attack) then
            self.creep:MoveToTargetToAttack(target_to_attack)
            print("Current target: " .. target_to_attack:GetUnitName() .. " with aggro " .. self.creep.aggro.enemies[target_to_attack:GetEntityIndex()])
        else
            print("No target to attack")
        end --]]
    end
end

LinkLuaModifier("modifier_aggro_system", "systems/aggro", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
    Aggro:Init()
end